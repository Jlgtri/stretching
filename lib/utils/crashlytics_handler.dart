import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:dio/dio.dart';
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
    var firstLine = true;
    void log(final String title, [final Map<String, Object?>? data]) {
      if (data?.isNotEmpty ?? true) {
        if (firstLine) {
          firstLine = false;
        } else {
          buffer.writeln();
        }
        buffer.writeln(title);
        if (data != null) {
          for (final entry in data.entries) {
            buffer.writeln('${entry.key}: ${entry.value}');
          }
        }
      }
    }

    if (enableDeviceParameters) {
      log('Device parameters:', report.deviceParameters);
    }
    if (enableApplicationParameters) {
      log('Application parameters:', report.applicationParameters);
    }
    if (enableCustomParameters) {
      log('Custom parameters:', report.customParameters);
    }
    final dynamic error = report.error;
    if (error is DioError) {
      final dynamic dioError = error.error;
      final response = error.response;
      log('API ${dioError.runtimeType.toString()}:', <String, Object?>{
        'Method': error.requestOptions.method,
        'URL': error.requestOptions.path,
        'Data': error.requestOptions.data,
        'Headers': error.requestOptions.headers,
        'Extra': error.requestOptions.extra,
        if (response != null) ...<String, Object?>{
          '\nResponse (${response.statusMessage} [${response.statusCode}])':
              response.data,
        },
      });
    }
    return buffer.toString();
  }
}
