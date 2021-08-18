import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/utils/json_converters.dart';

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
