import 'dart:developer';

import 'package:logger/logger.dart';

/// The global logger.
final Logger logger = _customLogger('S');

/// The logger with a [name].
Logger _customLogger(final String? name) {
  return Logger(
    output: name != null ? _DevLogOutput(name) : null,
    level: Level.verbose,
    filter: DevelopmentFilter(),
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 10,
      lineLength: 40,
      printEmojis: false,
    ),
  );
}

class _DevLogOutput extends LogOutput {
  _DevLogOutput(this.name);

  final String name;

  @override
  void output(final OutputEvent event) {
    for (final line in event.lines) {
      log(line, name: name);
    }
  }
}
