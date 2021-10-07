import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/components/font_icon.dart';

/// The premade initialisation of a Flutter's [WidgetsBinding].
/// Also is used for accessing the non null [WidgetsBinding] class.
final Provider<WidgetsBinding> widgetsBindingProvider =
    Provider<WidgetsBinding>(
  (final ref) => WidgetsFlutterBinding.ensureInitialized(),
);

/// The provider that contais current [ThemeMode].
final StateNotifierProvider<SaveToHiveNotifier<ThemeMode, String>, ThemeMode>
    themeModeProvider =
    StateNotifierProvider<SaveToHiveNotifier<ThemeMode, String>, ThemeMode>(
  (final ref) => SaveToHiveNotifier<ThemeMode, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'theme',
    converter: const EnumConverter<ThemeMode>(ThemeMode.values),
    defaultValue: ThemeMode.system,
  ),
);

/// The provider of the current app's root [Theme].
final StateProvider<ThemeData?> rootThemeProvider =
    StateProvider<ThemeData?>((final ref) => null);

/// The provider of the current app's root [MediaQuery].
final StateProvider<MediaQueryData?> rootMediaQueryProvider =
    StateProvider<MediaQueryData?>((final ref) => null);

/// The provider that contains current locale.
final StateNotifierProvider<SaveToHiveNotifier<Locale, String>, Locale>
    localeProvider =
    StateNotifierProvider<SaveToHiveNotifier<Locale, String>, Locale>(
  (final ref) => SaveToHiveNotifier<Locale, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'locale',
    converter: localeConverter,
    defaultValue: defaultLocale,
  ),
);

/// Thhe provider of the current device's location.
final StreamProvider<Position> locationProvider = StreamProvider<Position>(
  (final ref) => Geolocator.getPositionStream(
    distanceFilter: 10,
    intervalDuration: const Duration(seconds: 10),
    timeLimit: const Duration(days: 365),
  ),
);

/// Thhe provider of the current device's location.
final StreamProvider<ServiceStatus> locationServicesProvider =
    StreamProvider<ServiceStatus>(
  (final ref) => Geolocator.getServiceStatusStream()
    ..listen((final status) {
      if (status == ServiceStatus.enabled) {
        ref.refresh(locationProvider);
      }
    }),
);

/// The style for the Google Map.
final FutureProvider<String> mapStyleProvider = FutureProvider<String>(
  (final ref) => rootBundle.loadString(AssetsCG.googleMapStyle),
);

/// The style for the Google Map.
final FutureProviderFamily<BitmapDescriptor, FontIconData> mapMarkerProvider =
    FutureProvider.family<BitmapDescriptor, FontIconData>(
        (final ref, final icon) async {
  final recorder = ui.PictureRecorder();
  final painter = icon.getPainter()..paint(Canvas(recorder), Offset.zero);
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (icon.width ?? painter.width).toInt(),
    (icon.height ?? painter.height).toInt(),
  );
  final imageBytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return imageBytes != null
      ? BitmapDescriptor.fromBytes(imageBytes.buffer.asUint8List())
      : BitmapDescriptor.defaultMarker;
});

/// The provider of current time on device.
final StreamProvider<DateTime> timeProvider = StreamProvider<DateTime>(
  (final ref) => Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (final i) => DateTime.now(),
  ),
);

/// The notifier of the current server time.
class ServerTimeNotifier extends StateNotifier<DateTime> {
  /// The notifier of the current server time.
  ServerTimeNotifier(final DateTime initialServerTime)
      : super(initialServerTime) {
    _timer.start();
  }
  final Stopwatch _timer = Stopwatch();

  /// Returns the current server time.
  @override
  DateTime get state => super.state.add(_timer.elapsed);

  /// Sets the current server time.
  @override
  set state(final DateTime initialServerTime) {
    super.state = initialServerTime;
    _timer
      ..reset()
      ..start();
  }
}

/// The provider of the device's [PackageInfo].
final Provider<PackageInfo> packageInfoProvider = Provider<PackageInfo>(
  (final ref) => throw UnimplementedError('Provider was not initialised.'),
);
