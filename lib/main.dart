import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/providers/connection_provider.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/authorization_screen.dart';
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
        await ref.read(locationProvider.last);
        // await ref.read(hiveProvider).clear();
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
      initialRoute: Routes.root.name,
      routes: <String, Widget Function(BuildContext)>{
        for (final route in Routes.values) route.name: route.builder
      },
      builder: (final context, final child) {
        final smStretchingContent = ref.watch(smStretchingContentProvider);
        return smStretchingContent.when(
          data: (final _) {
            final yClientsContent = ref.watch(yClientsContentProvider);
            return yClientsContent.when(
              data: (final _) => child!,
              loading: () => const SizedBox.shrink(),
              error: (final error, final stackTrace) {
                return Material(
                  child: Container(
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(error.toString()),
                        const SizedBox(height: 50),
                        Text(stackTrace.toString())
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (final error, final stackTrace) {
            return Material(
              child: Container(
                color: Colors.red,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(error.toString()),
                    const SizedBox(height: 50),
                    Text(stackTrace.toString())
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// The enumeration of named routes for this app.
enum Routes {
  /// The default screen.
  root,

  /// The authorization screen.
  auth
}

/// The extra data provided for [Routes].
extension RoutesData on Routes {
  /// The name of this route.
  String get name {
    if (this == Routes.root) {
      return '/';
    }
    return Routes.root.name + describeEnum(this);
  }

  /// The builder of this route.
  Widget Function(BuildContext) get builder {
    switch (this) {
      case Routes.root:
        return (final context) {
          return Consumer(
            builder: (final context, final ref, final child) {
              final hasConnection = ref.watch(connectionProvider);
              // final checkedPermissions = ref.watch(checkedPermissionsProvider);

              if (hasConnection == null) {
                return const Center(child: Text('Splash Screen'));
              } else if (!hasConnection) {
                // TODO(screen): service
                return const Placeholder();
              } else {
                return const Material(child: NavigationRoot());
              }
            },
          );
        };
      case Routes.auth:
        return (final context) => const AuthorizationScreen();
    }
  }
}
