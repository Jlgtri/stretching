import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/providers.dart';
import 'package:stretching/providers/connection_provider.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/authorization.dart';
import 'package:stretching/widgets/load_data.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The premade initialisation of a Flutter's [WidgetsBinding].
/// Also is used for accessing the non null [WidgetsBinding] class.
final Provider<WidgetsBinding> widgetsBindingProvider =
    Provider<WidgetsBinding>((final ref) {
  return WidgetsFlutterBinding.ensureInitialized();
});

Future<void> main() async {
  await Hive.initFlutter();
  runApp(
    EasyLocalization(
      supportedLocales: supportedLocales,
      path: AssetsCG.translations,
      startLocale: defaultLocale,
      fallbackLocale: defaultLocale,
      child: ProviderScope(
        overrides: <Override>[
          hiveProvider.overrideWithValue(
            await Hive.openBox<String>('storage'),
          )
        ],
        child: const RootScreen(),
      ),
    ),
  );
}

/// The root widget of the app.
class RootScreen extends HookConsumerWidget {
  /// The root widget of the app.
  const RootScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final ez = EasyLocalization.of(context)!;
    final snapshot = useFuture(
      useMemoized(() async {
        await ez.delegate.load(ez.currentLocale!);
        await ref.read(connectionProvider.notifier).updateConnection();
      }),
    );
    if (snapshot.connectionState != ConnectionState.done) {
      return const SizedBox.shrink();
    }

    return MaterialApp(
      title: 'Stretching',
      restorationScopeId: 'stretching',
      locale: ez.locale,
      localizationsDelegates: ez.delegates,
      supportedLocales: ez.supportedLocales,
      themeMode: ref.watch(themeProvider),
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: '/',
      // builder: (final context, final child) => TruStrainSplash(child: child!),
      home: Consumer(
        builder: (final context, final ref, final child) {
          final hasConnection = ref.watch(connectionProvider);
          // final checkedPermissions = ref.watch(checkedPermissionsProvider);
          final userIsNull =
              ref.watch(userProvider.select((final user) => user == null));

          if (hasConnection == null) {
            return const Center(child: Text('Splash Screen'));
          } else if (!hasConnection) {
            // TODO(screen): service
            return const Placeholder();
          } else if (userIsNull) {
            return Scaffold(
              appBar: AppBar(title: const Text('Stretching Demo')),
              body: SingleChildScrollView(
                child: Column(
                  children: const <Widget>[SaveData(), Authorization()],
                ),
              ),
            );
          } else {
            return const Material(child: NavigationRoot());
          }
        },
      ),
    );
  }
}
