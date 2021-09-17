import 'dart:io';
import 'dart:ui' as ui;

import 'package:catcher/catcher.dart';
import 'package:dio/dio.dart';
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
import 'package:stretching/business_logic.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models_smstretching/sm_activity_price_model.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/logger.dart';
import 'package:stretching/widgets/authorization_screen.dart';
import 'package:stretching/widgets/components/animated_background.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/error_screen.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Catcher(
    debugConfig: CatcherOptions(
      ErrorPageReportMode(),
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
          hiveProvider.overrideWithValue(await Hive.openBox<String>('storage')),
          smServerTimeProvider
              .overrideWithValue(ServerTimeNotifier(DateTime.now())),
          smActivityPriceProvider
              .overrideWithValue(const SMActivityPriceModel.zero())
        ],
        child: const RootScreen(),
      ),
    ),
  );
  if (Platform.isAndroid) {
    WebView.platform = SurfaceAndroidWebView();
  }
}

/// Returns the current visibility of the splash.
final StateProvider<bool> splashProvider =
    StateProvider<bool>((final ref) => true);

/// Returns true if the app was successfully inited.
final Provider<bool> initedProvider = Provider<bool>((final ref) {
  return ref.watch(smActivityPriceProvider) !=
      const SMActivityPriceModel.zero();
});

/// If the [RefreshConfiguration] header should display a connection error.
final StateProvider<bool> connectionErrorProvider =
    StateProvider<bool>((final ref) => false);

/// The root widget of the app.
class RootScreen extends HookConsumerWidget {
  /// The root widget of the app.
  const RootScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final ez = EasyLocalization.of(context)!;
    final splash = ref.watch(splashProvider);
    final widgetsBinding = ref.read(widgetsBindingProvider);
    useMemoized(() {
      widgetsBinding.addObserver(ReviewRecordsEventHandler(context, ref));
    });
    useFuture(
      useMemoized(() async {
        splash.state = true;
        try {
          // await ref.read(hiveProvider).clear();
          await Future.wait(<Future<void>>[
            SystemChannels.textInput.invokeMethod<void>('TextInput.hide'),
            ez.delegate.load(ez.currentLocale!),
            ref.read(locationProvider.last),
            ref.read(orientationProvider.last),
            // Future.delayed(const Duration(seconds: 15)),
          ]);
          final currentLocale = ez.currentLocale;
          if (currentLocale != null) {
            ref.read(localeProvider.notifier).state = currentLocale;
          }
        } finally {
          try {
            await refreshAllProviders(ProviderScope.containerOf(context));
          } finally {
            widgetsBinding
                .addPostFrameCallback((final _) => splash.state = false);
          }
        }
      }),
      preserveState: false,
    );
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: AnimatedCrossFade(
        duration: const Duration(seconds: 2),
        reverseDuration: Duration.zero,
        sizeCurve: const Interval(0, 1 / 2, curve: Curves.ease),
        firstCurve: const Interval(0, 1 / 2, curve: Curves.easeOutQuad),
        secondCurve: const Interval(0, 1 / 2, curve: Curves.easeInQuad),
        crossFadeState:
            splash.state ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: LimitedBox(
          maxHeight: widgetsBinding.window.physicalSize.height,
          maxWidth: widgetsBinding.window.physicalSize.width,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AnimatedBackground(
                curve: Curves.ease,
                duration: const Duration(seconds: 2),
                colors: const <Color>[Color(0xFFD775AB), Color(0xFF7450E0)],
                animateAlignments: false,
                alignments: const <AlignmentGeometry>[
                  Alignment.bottomLeft,
                  Alignment.topRight
                ],
              ),
              const FontIcon(
                FontIconData(IconsCG.logo, color: Colors.white, width: 250),
              )
            ],
          ),
        ),
        secondChild: LimitedBox(
          maxHeight: widgetsBinding.window.physicalSize.height,
          maxWidth: widgetsBinding.window.physicalSize.width,
          child: MaterialApp(
            title: 'SMSTRETCHING DEV',
            restorationScopeId: 'stretching',
            locale: ez.locale,
            localizationsDelegates: ez.delegates
              ..add(RefreshLocalizations.delegate),
            debugShowCheckedModeBanner: false,
            supportedLocales: ez.supportedLocales,
            themeMode: ref.watch(themeProvider),
            theme: lightTheme,
            darkTheme: darkTheme,
            initialRoute: Routes.root.name,
            navigatorKey: Catcher.navigatorKey,
            routes: <String, Widget Function(BuildContext)>{
              for (final route in Routes.values)
                if (route.builder != null) route.name: route.builder!
            },
            builder: (final context, final child) {
              final theme = Theme.of(context);
              final textStyle =
                  theme.textTheme.bodyText2!.copyWith(color: theme.hintColor);
              final emojiStyle =
                  TextStyle(fontSize: textStyle.fontSize! * 5 / 4);
              return RefreshConfiguration(
                // Header height is 60, header trigger height is 80,
                // so max overscroll extent should be 20
                maxOverScrollExtent: 20,
                headerBuilder: () => Consumer(
                  builder: (final context, final ref, final child) {
                    final connectionError =
                        ref.watch(connectionErrorProvider).state;
                    return ClassicHeader(
                      completeDuration:
                          const Duration(seconds: 1, milliseconds: 500),
                      textStyle: textStyle,
                      idleText: TR.miscPullToRefreshIdle.tr(),
                      releaseText: TR.miscPullToRefreshRelease.tr(),
                      refreshingText: TR.miscPullToRefreshRefreshing.tr(),
                      completeText: connectionError
                          ? TR.miscPullToRefreshCompleteInternetError.tr()
                          : TR.miscPullToRefreshComplete.tr(),
                      idleIcon: EmojiText('😉', style: emojiStyle),
                      releaseIcon: EmojiText('🔥', style: emojiStyle),
                      // refreshingIcon: EmojiText('🤘', style: emojiStyle),
                      completeIcon: connectionError
                          ? const FontIcon(FontIconData(IconsCG.globe))
                          : EmojiText('❤', style: emojiStyle),
                    );
                  },
                ),
                child: child!,
              );
            },
          ),
        ),
      ),
    );

    // onGenerateRoute: (final settings) {
    //   return <String, Route<Object?>? Function(Object?)>{
    //     for (final route in Routes.values)
    //       if (route.onGenerateRoute != null)
    //         route.name: route.onGenerateRoute!
    //   }[settings.name]
    //       ?.call(settings.arguments);
    // },
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
    // Widget buildError(final Object error, final StackTrace? stackTrace) {
    //   return !(ref.watch(connectionProvider) ?? false)
    //       ? const ConnectionErrorScreen()
    //       : kDebugMode
    //           ? DebugErrorScreen(error, stackTrace)
    //           : const ErrorScreen();
    // }
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
                final dynamic exception = error.item1.error;
                if (exception is DioError) {
                  final dynamic dioError = exception.error;
                  if (dioError is SocketException) {
                    if (!ref.watch(initedProvider)) {
                      return const ConnectionErrorScreen();
                    } else {
                      final connectionError = ref.read(connectionErrorProvider);
                      if (!connectionError.state) {
                        (ref.read(widgetsBindingProvider))
                            .addPostFrameCallback((final _) async {
                          connectionError.state = true;
                          await Future<void>.delayed(
                            const Duration(seconds: 5),
                          );
                          connectionError.state = false;
                        });
                      }
                    }
                  } else {
                    (ref.read(widgetsBindingProvider))
                        .addPostFrameCallback((final _) {
                      Navigator.of(context, rootNavigator: true)
                          .popUntil(ModalRoute.withName(name));
                    });
                  }
                }
                if (!ref.watch(initedProvider)) {
                  return ErrorScreen(error.item0, error.item1);
                }
              }
              return ref.watch(splashProvider).state
                  ? const SizedBox.shrink()
                  : const NavigationRoot();
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

// /// The screen that pops up on error and handles connection errors.
// class ErrorHandlerScreen extends HookConsumerWidget {
//   /// The screen that pops up on error and handles connection errors.
//   const ErrorHandlerScreen({final Key? key}) : super(key: key);

//   @override
//   Widget build(final BuildContext context, final WidgetRef ref) {
//     final error = ref.watch(errorProvider).state;
//     useMemoized(
//       () {
//         if (error != null) {
//           (ref.read(widgetsBindingProvider))
//               .addPostFrameCallback((final _) async {
//             final dynamic exception = error.item1.error;
//             if (exception is DioError) {
//               final dynamic dioError = exception.error;
//               if (dioError is SocketException && ref.read(initedProvider)) {
//                 final connectionError = ref.read(connectionErrorProvider);
//                 if (!connectionError.state) {
//                   connectionError.state = true;
//                   await Future<void>.delayed(const Duration(seconds: 3));
//                   connectionError.state = false;
//                 }
//               } else {
//                 Navigator.of(context, rootNavigator: true)
//                     .popUntil(ModalRoute.withName(Routes.root.name));
//               }
//             }
//           });
//         }
//       },
//       [error?.item1.dateTime],
//     );
//     if (error != null) {
//       final inited = ref.watch(initedProvider);
//       final dynamic exception = error.item1.error;
//       if (exception is DioError) {
//         final dynamic dioError = exception.error;
//         if (dioError is SocketException && !inited) {
//           return const ConnectionErrorScreen();
//         }
//       }
//       if (!inited) {
//         return ErrorScreen(error.item0, error.item1);
//       }
//     }
//     return ref.watch(splashProvider).state
//         ? const SizedBox.shrink()
//         : const NavigationRoot();
//   }
// }
