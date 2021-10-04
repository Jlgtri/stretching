import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:stretching/utils/logger.dart';

/// The [Catcher] handler for the [FirebaseCrashlytics].
class CrashlyticsHandler extends ReportHandler {
  /// The [Catcher] handler for the [FirebaseCrashlytics].
  CrashlyticsHandler({
    final this.enableDeviceParameters = true,
    final this.enableApplicationParameters = true,
    final this.enableCustomParameters = true,
    final this.printLogs = true,
  });

  /// If device parameters should be logged.
  final bool enableDeviceParameters;

  /// If application parameters should be logged.
  final bool enableApplicationParameters;

  /// If custom parameters should be logged.
  final bool enableCustomParameters;

  /// If this handler should print logs.
  final bool printLogs;

  @override
  List<PlatformType> getSupportedPlatforms() =>
      [PlatformType.android, PlatformType.iOS];

  @override
  Future<bool> handle(final Report error, final BuildContext? context) async {
    try {
      if (printLogs) {
        logger.i('Sending crashlytics report');
      }
      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(true);
      await crashlytics.log(_getLogMessage(error));
      if (error.errorDetails != null) {
        await crashlytics.recordFlutterError(error.errorDetails!);
      } else {
        await crashlytics.recordError(
          error.error,
          error.stackTrace as StackTrace,
        );
      }
      if (printLogs) {
        logger.i('Crashlytics report sent');
      }
      return true;
    } on Exception catch (exception) {
      if (printLogs) {
        logger.i('Failed to send crashlytics report: $exception');
      }
      return false;
    }
  }

  String _getLogMessage(final Report report) {
    final buffer = StringBuffer();
    if (enableDeviceParameters) {
      buffer.write('||| Device parameters ||| ');
      for (final entry in report.deviceParameters.entries) {
        buffer.write('${entry.key}: ${entry.value} ');
      }
    }
    if (enableApplicationParameters) {
      buffer.write('||| Application parameters ||| ');
      for (final entry in report.applicationParameters.entries) {
        buffer.write('${entry.key}: ${entry.value} ');
      }
    }
    if (enableCustomParameters) {
      buffer.write('||| Custom parameters ||| ');
      for (final entry in report.customParameters.entries) {
        buffer.write('${entry.key}: ${entry.value} ');
      }
    }
    return buffer.toString();
  }
}
