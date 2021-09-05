import 'package:catcher/catcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/widgets/authorization_screen.dart';
import 'package:stretching/widgets/content_screen.dart';
import 'package:stretching/widgets/error_screen.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Catcher(
    debugConfig: CatcherOptions(
      SilentReportMode(),
      <ReportHandler>[ConsoleHandler()],
    ),
    releaseConfig: CatcherOptions(ErrorPageReportMode(), <ReportHandler>[]),
    rootWidget: EasyLocalization(
      supportedLocales: supportedLocales,
      path: AssetsCG.translations,
      startLocale: defaultLocale,
      fallbackLocale: defaultLocale,
      child: ProviderScope(
        overrides: <Override>[
          hiveProvider.overrideWithValue(await Hive.openBox<String>('storage'))
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
        await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
        await ez.delegate.load(ez.currentLocale!);
        await ref.read(connectionProvider.notifier).updateConnection();
        await ref.read(locationProvider.last);
        // await ref.read(hiveProvider).clear();
      }),
    );

    if (snapshot.connectionState != ConnectionState.done) {
      return const SizedBox.shrink();
    }

    // Widget buildError(final Object error, final StackTrace? stackTrace) {
    //   return !(ref.watch(connectionProvider) ?? false)
    //       ? const ConnectionErrorScreen()
    //       : kDebugMode
    //           ? DebugErrorScreen(error, stackTrace)
    //           : const ErrorScreen();
    // }

    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: 'SMSTRETCHING DEV',
      restorationScopeId: 'stretching',
      locale: ez.locale,
      localizationsDelegates: ez.delegates,
      supportedLocales: ez.supportedLocales,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: Routes.root.name,
      navigatorKey: Catcher.navigatorKey,
      routes: <String, Widget Function(BuildContext)>{
        for (final route in Routes.values) route.name: route.builder
      },
      // builder: (final context, final child) {
      //   final mediaQuery = MediaQuery.of(context);
      //   return AnnotatedRegion<SystemUiOverlayStyle>(
      //     value: themeMode == ThemeMode.light
      //         ? lightSystemUiOverlayStyle
      //         : themeMode == ThemeMode.dark
      //             ? darkSystemUiOverlayStyle
      //             : mediaQuery.platformBrightness == Brightness.light
      //                 ? lightSystemUiOverlayStyle
      //                 : darkSystemUiOverlayStyle,
      //     child: child!,
      //   );
      // },
    );
  }
}

/// The enumeration of top-level routes for this app.
enum Routes {
  /// The default screen.
  root,

  /// The authorization screen.
  auth,
}

/// The extra data provided for [Routes].
extension RoutesData on Routes {
  /// The name of this route.
  String get name =>
      this == Routes.root ? '/' : Routes.root.name + describeEnum(this);

  /// The builder of this route.
  Widget Function(BuildContext) get builder {
    switch (this) {
      case Routes.auth:
        return (final context) => const AuthorizationScreen();
      case Routes.root:
        return (final context) {
          return Consumer(
            builder: (final context, final ref, final child) {
              final error = ref.watch(errorProvider).state;
              if (error != null) {
                (ref.read(widgetsBindingProvider))
                    .addPostFrameCallback((final _) {
                  Navigator.of(context).popUntil(ModalRoute.withName(name));
                });
                if (!(ref.read(connectionProvider) ?? false)) {
                  ref.read(errorProvider).state = null;
                  return const ConnectionErrorScreen();
                }
                return ErrorScreen(error.item0, error.item1);
              }
              return (ref.watch(smStretchingContentProvider)).when(
                data: (final _) {
                  final yClientsContent = ref.watch(yClientsContentProvider);
                  return yClientsContent.when(
                    data: (final _) => const NavigationRoot(),
                    loading: () => const SizedBox.shrink(),
                    error: (final error, final stackTrace) {
                      Catcher.reportCheckedError(error, stackTrace);
                      return const SizedBox.shrink();
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (final error, final stackTrace) {
                  Catcher.reportCheckedError(error, stackTrace);
                  return const SizedBox.shrink();
                },
              );
            },
          );
        };
    }
  }
}
