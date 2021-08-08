import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/widgets/authorization.dart';
import 'package:stretching/providers.dart';

/// The premade initialisation of a Flutter's [WidgetsBinding].
/// Also is used for accessing the non null [WidgetsBinding] class.
final Provider<WidgetsBinding> widgetsBindingProvider =
    Provider<WidgetsBinding>((final ref) {
  return WidgetsFlutterBinding.ensureInitialized();
});

Future<void> main() async {
  await Hive.initFlutter();
  final storage = await Hive.openBox<String>('storage');
  runApp(
    EasyLocalization(
      supportedLocales: supportedLocales,
      path: AssetsCG.translations,
      startLocale: defaultLocale,
      fallbackLocale: defaultLocale,
      child: Builder(
        builder: (final context) {
          final ez = EasyLocalization.of(context)!;
          return FutureBuilder(
            future: ez.delegate.load(ez.currentLocale!),
            builder: (final context, final snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox.shrink();
              }
              return ProviderScope(
                overrides: <Override>[hiveProvider.overrideWithValue(storage)],
                child: const MaterialApp(home: Scaffold(body: Authorization())),
              );
            },
          );
        },
      ),
    ),
  );
}
