import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
