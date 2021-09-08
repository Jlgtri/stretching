import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/components/font_icon.dart';

/// The premade initialisation of a Flutter's [WidgetsBinding].
/// Also is used for accessing the non null [WidgetsBinding] class.
final Provider<WidgetsBinding> widgetsBindingProvider =
    Provider<WidgetsBinding>((final ref) {
  return WidgetsFlutterBinding.ensureInitialized();
});

/// The provider that contais current theme.
final StateNotifierProvider<SaveToHiveNotifier<ThemeMode, String>, ThemeMode>
    themeProvider =
    StateNotifierProvider<SaveToHiveNotifier<ThemeMode, String>, ThemeMode>(
        (final ref) {
  return SaveToHiveNotifier<ThemeMode, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'theme',
    converter: const EnumConverter<ThemeMode>(ThemeMode.values),
    defaultValue: ThemeMode.system,
  );
});

/// The provider that contains current locale.
final StateNotifierProvider<SaveToHiveNotifier<Locale, String>, Locale>
    localeProvider =
    StateNotifierProvider<SaveToHiveNotifier<Locale, String>, Locale>(
        (final ref) {
  return SaveToHiveNotifier<Locale, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'locale',
    converter: localeConverter,
    defaultValue: defaultLocale,
  );
});

/// Thhe provider of the current device's location.
final StreamProvider<Position> locationProvider =
    StreamProvider<Position>((final ref) {
  return Geolocator.getPositionStream(
    distanceFilter: 10,
    intervalDuration: const Duration(seconds: 10),
  );
});

/// The style for the Google Map.
final FutureProvider<String> mapStyleProvider =
    FutureProvider<String>((final ref) {
  return rootBundle.loadString(AssetsCG.googleMapStyle);
});

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
final StreamProvider<DateTime> timeProvider =
    StreamProvider<DateTime>((final ref) {
  return Stream<DateTime>.periodic(const Duration(seconds: 1), (final i) {
    return DateTime.now();
  });
});

/// The provider of the orientation on the device.
final StreamProvider<NativeDeviceOrientation> orientationProvider =
    StreamProvider((final ref) {
  return NativeDeviceOrientationCommunicator().onOrientationChanged();
});

/// The provider of the current server time.
final StateNotifierProvider<ServerTimeNotifier, DateTime> serverTimeProvider =
    StateNotifierProvider<ServerTimeNotifier, DateTime>((final ref) {
  throw Exception('The provider was not initialized');
});

/// The notifier of the current server time.
class ServerTimeNotifier extends StateNotifier<DateTime> {
  /// The notifier of the current server time.
  ServerTimeNotifier(final DateTime initialServerTime)
      : super(initialServerTime) {
    _timer = Stopwatch()..start();
  }
  late final Stopwatch _timer;

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
