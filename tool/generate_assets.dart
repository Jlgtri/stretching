import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

// ignore_for_file: sort_constructors_first

ArgParser get _parser => ArgParser()
  ..addOption(
    'source-dir',
    abbr: 's',
    defaultsTo: 'assets',
    help: 'The path to assets folder.',
  )
  ..addOption(
    'output-file',
    abbr: 'o',
    defaultsTo: 'lib/codegen_assets.g.dart',
    help: 'Output file path (with name).',
  )
  ..addOption(
    'class-name',
    abbr: 'c',
    defaultsTo: 'CodeGenAssets',
    help: 'Use a valid DartClassName.',
  )
  ..addMultiOption(
    'exclude',
    abbr: 'e',
    help: 'Exclude files or folders with a regex match. '
        'Input separated by comma.',
  )
  ..addFlag(
    'add-hidden',
    abbr: 'h',
    help: 'Adds hidden files if this file is true.',
  )
  ..addFlag(
    'import-comments',
    abbr: 'i',
    defaultsTo: true,
    help: 'The flag that switches adding import comments '
        'in the generated file.',
  );

Future<void> main(final Iterable<String> args) async {
  /// Show help.
  if (args.length == 1 && (args.first == '--help' || args.first == '-h')) {
    return stdout.write(_parser.usage);
  }

  /// Generate options from [_parser].
  final options = Options.fromParser(_parser.parse(args));

  /// Get all files from [Options.sourceDir] folder.
  final files = List<File>.empty(growable: true);
  await for (final entity in options.sourceDir.list(recursive: true)) {
    if (entity is File) {
      /// Whitelist files with [Options.exclude] patterns.
      if (options.exclude.hasMatch(entity.path) ||
          options.exclude.hasMatch(basename(entity.path))) {
        continue;
      }
      files.add(entity);
    }
  }

  /// Sort source dir first and every other dir after that.
  files.sort((final a, final b) {
    final aPath = basename(a.path).toLowerCase();
    final bPath = basename(b.path).toLowerCase();
    if (b.parent.path == options.sourceDir.path) {
      return bPath.compareTo(aPath);
    } else {
      return a.parent.path
          .compareTo(b.parent.path)
          .compareTo(bPath.compareTo(aPath));
    }
  });

  /// Add initial Generator message.
  final output = StringBuffer()
    ..writeln('/// Copyright (C) 2021 by original author @ fluttercrew')
    ..writeln('/// This file was generated with FlutterCrew Assets Generator.');

  /// Add import comments.
  if (options.importComments && files.isNotEmpty) {
    output
      ..writeln()
      ..writeln('///')
      ..writeln('/// To use this, include the following in your pubspec.yaml:')
      ..writeln('///')
      ..writeln('/// flutter:')
      ..writeln('///   assets:');
    for (final file in files) {
      final path = file.path
          .replaceFirst(Directory.current.path, '')
          .replaceAll(r'\', '/');
      output.writeln('///     - $path');
    }
  }

  /// Add [Options.className] header and lint ignore rules.
  output
    ..writeln()
    ..writeln()
    ..writeln(
      '// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars',
    )
    ..writeln()
    ..writeln(
      "abstract class ${options.className} {${files.isNotEmpty ? '\n' : ''}",
    );

  String formatLine(final String path) {
    /// Get the file path without extension.
    final sourcePath = path

        /// Get the full relative path
        .replaceFirst(Directory.current.path, '')

        /// Format backslash to slashes if any.
        .replaceAll(r'\', '/');

    final keyName =

        /// Get the path without extension.
        withoutExtension(sourcePath)

            /// Remove the source dir path from path.
            .replaceFirst(basename(options.sourceDir.path), '')

            /// Get the start of the text path.
            .replaceFirst(RegExp('[/_]+'), '')

            /// Split on join symbols and format camelCase.
            .splitMapJoin(
              RegExp('[/_]+.'),
              onMatch: (final m) =>
                  m[0]!.substring(m[0]!.length - 1).toUpperCase(),
            )

            /// Replace any special symbols.
            .replaceAll(RegExp('[^a-zA-Z0-9]+'), '');
    return "  static const String $keyName = '$sourcePath';";
  }

  /// Add a record for every matched file.
  Directory? _previousDirectory;
  for (final file in files) {
    if (_previousDirectory?.path != file.parent.path &&
        file.parent.path != options.sourceDir.path) {
      if (files.indexOf(file) > 0) {
        output.writeln();
      }
      _previousDirectory = file.parent;
      output.writeln(formatLine(_previousDirectory.path));
    }
    output.writeln(formatLine(file.path));
  }

  /// Close the class.
  output.writeln('}');

  /// Write the [output] to the [Options.outputFile].
  options.outputFile.writeAsStringSync(output.toString());
}

/// The class to store this generator options.
class Options {
  /// The class to store this generator options.
  Options({
    required final this.sourceDir,
    required final this.outputFile,
    required final this.className,
    required final this.exclude,
    final this.importComments = true,
  })  : assert(!sourceDir.existsSync(), 'Source path does not exist'),
        assert(className.isNotEmpty, 'class name can not be empty');

  /// The path to assets folder.
  final Directory sourceDir;

  /// The path to save file.
  final File outputFile;

  /// The name of the generated class.
  final String className;

  /// The list of regex matches to exclude.
  final RegExp exclude;

  /// The flag to whether to show comments on files import.
  final bool importComments;

  factory Options.fromParser(final ArgResults results) => Options(
        sourceDir: Directory(results['source-dir']! as String),
        outputFile: File(results['output-file']! as String),
        className: results['class-name']! as String,
        exclude: RegExp(
          <String>[
            ...results['exclude'] as Iterable<String>,
            if (!(results['add-hidden'] as bool)) r'^\.'
          ].join('|'),
        ),
        importComments: results['import-comments']! as bool,
      );
}
