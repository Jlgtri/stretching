import 'dart:developer';

import 'package:catcher/catcher.dart';
import 'package:logger/logger.dart';
import 'package:logging/logging.dart' as logging;

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

/// The [Logger] adapter for the [CatcherLogger].
class CustomCatcherLogger implements CatcherLogger {
  /// The [Logger] adapter for the [CatcherLogger].
  const CustomCatcherLogger(final this._logger);
  final Logger _logger;

  @override
  void setup() {}

  @override
  void fine(final String message) => _logger.v(message);

  @override
  void info(final String message) => _logger.i(message);

  @override
  void warning(final String message) => _logger.w(message);

  @override
  void severe(final String message) => _logger.e(message);
}

/// The [Logger] adapter for the [CatcherLogger].
class ChangedCatcherLogger extends CatcherLogger {
  @override
  void setup() {
    logging.Logger.root.level = logging.Level.ALL;
    logging.Logger.root.onRecord.listen(
      (final rec) {
        // ignore: avoid_print
        print(rec.message);
      },
    );
  }
}
