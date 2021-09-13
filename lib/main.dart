import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/providers/connection_provider.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/logger.dart';
import 'package:stretching/widgets/authorization_screen.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/error_screen.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// TODO: client id buy abonement (create user for each studio)
Future<void> main() async {
  await Hive.initFlutter();
  Catcher(
    debugConfig: CatcherOptions(
      SilentReportMode(),
      <ReportHandler>[ConsoleHandler()],
      logger: ChangedCatcherLogger(),
    ),
    releaseConfig: CatcherOptions(ErrorPageReportMode(), <ReportHandler>[]),
    rootWidget: EasyLocalization(
      supportedLocales: supportedLocales,
      path: AssetsCG.translations,
      startLocale: defaultLocale,
      fallbackLocale: defaultLocale,
      child: ProviderScope(
        overrides: <Override>[
          hiveProvider.overrideWithValue(
            await Hive.openBox<String>('storage'),
          ),
          smServerTimeProvider.overrideWithValue(
            ServerTimeNotifier((await smStretching.getServerTime())!),
          ),
          smActivityPriceProvider
              .overrideWithValue((await smStretching.getActivityPrice())!)
        ],
        child: const RootScreen(),
      ),
    ),
  );
  if (Platform.isAndroid) {
    WebView.platform = SurfaceAndroidWebView();
  }
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
        // await ref.read(hiveProvider).clear();
        await Future.wait<void>(<Future<void>>[
          SystemChannels.textInput.invokeMethod<void>('TextInput.hide'),
          ez.delegate.load(ez.currentLocale!),
          ref.read(connectionProvider.notifier).updateConnection(),
          ref.read(locationProvider.last),
          ref.read(orientationProvider.last),
        ]);
        final currentLocale = ez.currentLocale;
        if (currentLocale != null) {
          ref.read(localeProvider.notifier).state = currentLocale;
        }
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
      localizationsDelegates: ez.delegates..add(RefreshLocalizations.delegate),
      debugShowCheckedModeBanner: false,
      supportedLocales: ez.supportedLocales,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: Routes.root.name,
      navigatorKey: Catcher.navigatorKey,
      routes: <String, Widget Function(BuildContext)>{
        for (final route in Routes.values)
          if (route.builder != null) route.name: route.builder!
      },
      // onGenerateRoute: (final settings) {
      //   return <String, Route<Object?>? Function(Object?)>{
      //     for (final route in Routes.values)
      //       if (route.onGenerateRoute != null)
      //         route.name: route.onGenerateRoute!
      //   }[settings.name]
      //       ?.call(settings.arguments);
      // },
      builder: (final context, final child) {
        final theme = Theme.of(context);
        final textStyle =
            theme.textTheme.bodyText2!.copyWith(color: theme.hintColor);
        final emojiStyle = TextStyle(fontSize: textStyle.fontSize! * 1.25);
        return RefreshConfiguration(
          topHitBoundary: 150,
          maxOverScrollExtent: 0,
          maxUnderScrollExtent: 0,
          headerBuilder: () => ClassicHeader(
            height: 80,
            textStyle: textStyle,
            idleText: TR.miscPullToRefreshIdle.tr(),
            releaseText: TR.miscPullToRefreshRelease.tr(),
            refreshingText: TR.miscPullToRefreshRefreshing.tr(),
            completeText: TR.miscPullToRefreshComplete.tr(),
            idleIcon: EmojiText('😉', style: emojiStyle),
            releaseIcon: EmojiText('🔥', style: emojiStyle),
            // refreshingIcon: EmojiText('🤘', style: emojiStyle),
            completeIcon: EmojiText('❤', style: emojiStyle),
          ),
          child: child!,
        );
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

  // /// The webview payment screen.
  // payment,

  // /// The screen that prompts user to pay regularly or buy an abonement.
  // bookPrompt,
}

/// The extra data provided for [Routes].
extension RoutesData on Routes {
  /// The name of this route.
  String get name =>
      this == Routes.root ? '/' : Routes.root.name + describeEnum(this);

  /// The builder of this route.
  Widget Function(BuildContext context)? get builder {
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
              return const NavigationRoot();
            },
          );
        };
    }
  }

  // /// The builder with arguments for this route.
  // Route<Object?>? Function(Object? arguments)? get onGenerateRoute {
  //   switch (this) {
  //     case Routes.payment:
  //       return (final arguments) {
  //         if (arguments is WebViewAcquiring) {
  //           return MaterialPageRoute(
  //             builder: (final context) => WebViewAcquiringScreen(arguments),
  //           );
  //         }
  //       };
  //     case Routes.bookPrompt:
  //       return (final arguments) {
  //         // return MaterialPageRoute(
  //         //   builder: (final context) => PromptBookScreen(
  //         //     onAbonement: (final context) async {},
  //         //     onRegular: (final context) async {
  //         //       // Navigator.of(context).pushReplacementNamed(
  //         //       //   Routes.payment.name,
  //         //       //   arguments: await smStretching.initAcquiring(
  //         //       //     user: user,
  //         //       //     terminalKey: terminalKey,
  //         //       //     password: password,
  //         //       //     orderId: orderId,
  //         //       //     amount: amount,
  //         //       //   ),
  //         //       // );
  //         //     },
  //         //   ),
  //         // );
  //       };
  //   }
  // }
}
