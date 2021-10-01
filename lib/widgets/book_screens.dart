import 'dart:async';
import 'dart:ui';

import 'package:darq/darq.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models_smstretching/sm_abonement_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/record_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:tinkoff_acquiring/tinkoff_acquiring.dart' hide Route;
import 'package:webview_flutter/webview_flutter.dart';

/// The custom loader widget to put on top of the [child].
class Loader extends StatelessWidget {
  /// The custom loader widget to put on top of the [child].
  const Loader({
    required final this.isLoading,
    required final this.child,
    final this.falsePop = false,
    final this.color = Colors.black,
    final Key? key,
  }) : super(key: key);

  /// If this loader is currently active.
  final bool isLoading;

  /// The child of this loader.
  final Widget child;

  /// If the [Route.willPop] should return false if this loader [isLoading].
  final bool falsePop;

  /// The color of this loader's child.
  final Color color;

  @override
  Widget build(final BuildContext context) {
    final widget = AbsorbPointer(
      absorbing: isLoading,
      child: Stack(
        children: <Widget>[
          child,
          if (isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Center(
                child: Image.asset(
                  AssetsCG.logo,
                  width: 330,
                  height: 100,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
    return falsePop
        ? WillPopScope(
            onWillPop: () => Future.value(!isLoading),
            child: widget,
          )
        : widget;
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<bool>('isLoading', isLoading))
        ..add(DiagnosticsProperty<Widget>('child', child))
        ..add(DiagnosticsProperty<bool>('falsePop', falsePop))
        ..add(ColorProperty('color', color)),
    );
  }
}

/// The callback to call when user picks a payment method.
///
/// When [finish] is called, the loader on [PromptBookScreen] is disabled.
typedef OnBookPrompt = FutureOr<void> Function(
  BuildContext context, {
  required void Function() finish,
});

/// The screen that prompts user to pay regularly or buy an abonement.
class PromptBookScreen extends HookWidget {
  /// The screen that prompts user to pay regularly or buy an abonement.
  const PromptBookScreen({
    required final this.onRegular,
    required final this.onAbonement,
    required final this.regularPrice,
    required final this.ySalePrice,
    required final this.abonementPrice,
    final this.abonementNonMatchReason = SMAbonementNonMatchReason.none,
    final this.discount = false,
    final this.onlyFinish = false,
    final Key? key,
  }) : super(key: key);

  /// The callback on regular payment.
  final OnBookPrompt onRegular;

  /// The callback on abonement payment.
  final OnBookPrompt onAbonement;

  /// The regular price of the [ActivityModel].
  final num regularPrice;

  /// The price with discount of the [ActivityModel].
  final num ySalePrice;

  /// The cheapest available [SMAbonementModel].
  final num abonementPrice;

  /// The reason the abonement was not matched.
  final SMAbonementNonMatchReason abonementNonMatchReason;

  /// If this screen should use discount.
  final bool discount;

  /// If the loader should stop only after calling the finish callback.
  final bool onlyFinish;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isExtraLoading = useState<bool>(false);
    final isLoading = useState<bool>(false);
    final isMounted = useIsMounted();
    void stopLoading() {
      if (isMounted()) {
        isExtraLoading.value = isLoading.value = false;
      }
    }

    return Loader(
      color:
          isExtraLoading.value ? theme.colorScheme.surface : Colors.transparent,
      isLoading: isLoading.value,
      child: Scaffold(
        appBar: cancelAppBar(
          theme,
          leading: const SizedBox.shrink(),
          onPressed: Navigator.of(context).maybePop,
        ),
        body: NativeDeviceOrientationReader(
          builder: (final context) => Align(
            alignment: abonementNonMatchReason == SMAbonementNonMatchReason.none
                ? Alignment.center
                : Alignment.topCenter,
            child: SingleChildScrollView(
              key: UniqueKey(),
              padding: const EdgeInsets.symmetric(horizontal: 16) +
                  EdgeInsets.only(
                    top: abonementNonMatchReason !=
                            SMAbonementNonMatchReason.none
                        ? mediaQuery.size.height / 8
                        : 0,
                    bottom: mediaQuery.size.height / 16,
                  ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (abonementNonMatchReason != SMAbonementNonMatchReason.none)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          EmojiText(
                            '😬',
                            style: const TextStyle(fontSize: 35),
                            textScaleFactor: mediaQuery.textScaleFactor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            abonementNonMatchReason.translation,
                            style: theme.textTheme.bodyText2,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  BottomButtons<dynamic>(
                    inverse: true,
                    firstTitleText: TR.promptBookRegular.tr(),
                    firstStrikeText: discount
                        ? TR.miscCurrency
                            .tr(args: <String>[regularPrice.toString()])
                        : '',
                    firstText: TR.miscCurrency.tr(
                      args: <String>[
                        (discount ? ySalePrice : regularPrice).toString()
                      ],
                    ),
                    secondTitleText: TR.promptBookAbonement.tr(),
                    secondText: TR.promptBookAbonementPrice.tr(
                      args: <String>[
                        TR.miscCurrency.tr(
                          args: <String>[abonementPrice.toStringAsFixed(0)],
                        )
                      ],
                    ),
                    onFirstPressed: (final context) async {
                      isLoading.value = true;
                      isExtraLoading.value = false;
                      try {
                        return await onRegular(context, finish: stopLoading);
                      } finally {
                        if (!onlyFinish) {
                          stopLoading();
                        } else if (isMounted()) {
                          isExtraLoading.value = true;
                        }
                      }
                    },
                    onSecondPressed: (final context) async {
                      isLoading.value = true;
                      isExtraLoading.value = false;
                      try {
                        return await onAbonement(context, finish: stopLoading);
                      } finally {
                        if (!onlyFinish) {
                          stopLoading();
                        } else if (isMounted()) {
                          isExtraLoading.value = true;
                        }
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(50, 12, 50, 0),
                    child: Text(
                      TR.promptBookAbonementAd.tr(),
                      style: theme.textTheme.bodyText1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(ObjectFlagProperty<OnBookPrompt>.has('onRegular', onRegular))
        ..add(ObjectFlagProperty<OnBookPrompt>.has('onAbonement', onAbonement))
        ..add(DiagnosticsProperty<num>('regularPrice', regularPrice))
        ..add(DiagnosticsProperty<num>('ySalePrice', ySalePrice))
        ..add(DiagnosticsProperty<num>('abonementPrice', abonementPrice))
        ..add(
          EnumProperty<SMAbonementNonMatchReason>(
            'abonementNonMatchReason',
            abonementNonMatchReason,
          ),
        )
        ..add(DiagnosticsProperty<bool>('discount', discount))
        ..add(DiagnosticsProperty<bool>('onlyFinish', onlyFinish)),
    );
  }
}

/// The screen of the successful booking.
class SuccessfulBookScreen extends ConsumerWidget {
  /// The screen of the successful booking.
  const SuccessfulBookScreen({
    required final this.activity,
    required final this.record,
    required final this.abonement,
    final Key? key,
  }) : super(key: key);

  /// The activity for which the [record] is created.
  final CombinedActivityModel activity;

  /// The record that was created before showing this screen.
  final RecordModel record;

  /// If this screen is shown after activating abonement or just regularly
  /// paying.
  final bool abonement;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: theme.brightness,
          statusBarIconBrightness: theme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
      ),
      body: NativeDeviceOrientationReader(
        builder: (final context) => Align(
          child: SingleChildScrollView(
            key: UniqueKey(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                EmojiText(
                  '🤘😍',
                  style: const TextStyle(fontSize: 45, letterSpacing: 3),
                  textScaleFactor: mediaQuery.textScaleFactor,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100 * 2 / 3),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(
                      abonement
                          ? TR.successfulBookAbonement.tr()
                          : TR.successfulBookRegular.tr(),
                      style: theme.textTheme.headline2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: mediaQuery.textScaleFactor <= 1
                          ? 285
                          : double.infinity,
                    ),
                    child: Text(
                      TR.successfulBookInfo.tr(),
                      style: theme.textTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 260,
                  child: BottomButtons<dynamic>(
                    firstText: TR.successfulBookCalendar.tr(),
                    secondText: TR.successfulBookBackToMain.tr(),
                    onFirstPressed: (final context) => activity.addToCalendar(),
                    onSecondPressed: (final context) {
                      (ref.read(navigationProvider))
                          .jumpToTab(NavigationScreen.home.index);
                      Navigator.of(context, rootNavigator: true)
                          .popUntil(Routes.root.withName);
                    },
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<CombinedActivityModel>('activity', activity))
        ..add(DiagnosticsProperty<RecordModel>('record', record))
        ..add(DiagnosticsProperty<bool>('abonement', abonement)),
    );
  }
}

/// The result screen of the booking.
class ResultBookScreen extends ConsumerWidget {
  /// The result screen of the booking.
  const ResultBookScreen({
    final this.emoji = '😞',
    final this.title = '',
    final this.body = '',
    final this.button = '',
    final this.onPressed,
    final this.showBackButton = false,
    final Key? key,
  }) : super(key: key);

  /// The emoji to put on top of this screen.
  final String emoji;

  /// The title text of this screen.
  final String title;

  /// The body text of this screen.
  final String body;

  /// The button text of this screen.
  final String button;

  /// The callback on the button on this screen.
  final void Function()? onPressed;

  /// If the back button should be shown.
  final bool showBackButton;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: showBackButton
          ? cancelAppBar(
              theme,
              onPressed: () => Navigator.of(context).maybePop(false),
            )
          : AppBar(
              toolbarHeight: 0,
              backgroundColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarBrightness: theme.brightness,
                statusBarIconBrightness: theme.brightness == Brightness.light
                    ? Brightness.dark
                    : Brightness.light,
              ),
            ),
      body: NativeDeviceOrientationReader(
        builder: (final context) => Align(
          child: SingleChildScrollView(
            key: UniqueKey(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                EmojiText(
                  emoji,
                  style: const TextStyle(fontSize: 45),
                  textScaleFactor: mediaQuery.textScaleFactor,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 295),
                    child: Text(
                      title,
                      style: theme.textTheme.headline2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 270),
                    child: Text(
                      body,
                      style: theme.textTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: TextButton(
                    style: (TextButtonStyle.light.fromTheme(theme)).copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                    ),
                    onPressed:
                        onPressed ?? () => Navigator.of(context).maybePop(true),
                    child: Text(button),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(StringProperty('emoji', emoji))
        ..add(StringProperty('title', title))
        ..add(StringProperty('body', body))
        ..add(StringProperty('button', button))
        ..add(ObjectFlagProperty<void Function()>.has('onPressed', onPressed))
        ..add(DiagnosticsProperty<bool>('showBackButton', showBackButton)),
    );
  }
}

// /// The result screen after adding user to a wishlist.
// class WishListResultScreen extends StatelessWidget {
//   /// The result screen after adding user to a wishlist.
//   const WishListResultScreen({required final this.alreadyAdded, final Key? key})
//       : super(key: key);

//   /// If this wishlist was already added.
//   final bool alreadyAdded;

//   @override
//   Widget build(final BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: cancelAppBar(
//         theme,
//         onPressed: () => Navigator.of(context).maybePop(false),
//       ),
//       body: NativeDeviceOrientationReader(
//         builder: (final context) => Align(
//           child: SingleChildScrollView(
//             key: UniqueKey(),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 EmojiText('🧘', style: const TextStyle(fontSize: 45)),
//                 const SizedBox(height: 12),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 50),
//                   child: Text(
//                     alreadyAdded
//                         ? TR.wishlistAlreadyAdded.tr()
//                         : TR.wishlistAddedTitle.tr(),
//                     style: theme.textTheme.headline2,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 45),
//                   child: Text(
//                     TR.wishlistAddedBody.tr(),
//                     style: theme.textTheme.bodyText2,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 90),
//                   child: BottomButtons<dynamic>(
//                     inverse: true,
//                     firstText: TR.wishlistAddedButton.tr(),
//                     onFirstPressed: (final context) =>
//                         Navigator.of(context).maybePop(true),
//                   ),
//                 ),
//                 const SizedBox(height: 50),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
//     super.debugFillProperties(
//       properties..add(DiagnosticsProperty<bool>('alreadyAdded', alreadyAdded)),
//     );
//   }
// }

/// The pair of [InitRequest] and [InitResponse].
typedef WebViewAcquiring = Tuple2<InitRequest, InitResponse>;

/// The screen that provides a payment for the user.
class WebViewAcquiringScreen extends HookConsumerWidget {
  /// The screen that provides a payment for the user.
  const WebViewAcquiringScreen(final this.acquiring, {final Key? key})
      : super(key: key);

  /// The data provided for acquiring at this screen.
  final WebViewAcquiring acquiring;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: mainAppBar(theme, leading: const FontIconBackButton()),
      body: WebView(
        initialUrl: acquiring.item1.paymentURL,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (final request) async {
          final successUrl = acquiring.item0.successUrl;
          final failUrl = acquiring.item0.failUrl;
          if (successUrl != null && request.url.startsWith(successUrl)) {
            await Navigator.of(context).maybePop(true);
          } else if (failUrl != null && request.url.startsWith(failUrl)) {
            await Navigator.of(context).maybePop(false);
          } else {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent;
        },
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(
          DiagnosticsProperty<WebViewAcquiring>(
            'acquiring',
            acquiring,
          ),
        ),
    );
  }
}

/// The bottom sheet that shows a refund.
Future<void> showRefundedModalBottomSheet({
  required final BuildContext context,
  required final String title,
  required final Widget child,
}) {
  final theme = Theme.of(context);
  return showMaterialModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    duration: const Duration(milliseconds: 500),
    animationCurve: Curves.easeInOut,
    closeProgressThreshold: 4 / 5,
    builder: (final context) {
      return BottomSheetBase(
        child: CustomScrollView(
          primary: false,
          shrinkWrap: true,
          controller: ModalScrollController.of(context),
          cacheExtent: double.infinity,
          slivers: <Widget>[
            SliverAppBar(
              primary: false,
              toolbarHeight: 64,
              title: Align(
                alignment: Alignment.bottomLeft,
                child: Text(title),
              ),
              titleTextStyle: theme.textTheme.headline3?.copyWith(height: 3.5),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              // backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leadingWidth: 0,
              leading: const SizedBox.shrink(),
              backgroundColor: theme.backgroundColor,
              actions: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: IconButton(
                      onPressed: Navigator.of(context).maybePop,
                      padding: const EdgeInsets.only(bottom: 2),
                      splashRadius: 16,
                      iconSize: 16,
                      icon: FontIcon(
                        FontIconData(
                          IconsCG.close,
                          height: 20,
                          alignment: Alignment.topCenter,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Material(
                color: theme.backgroundColor,
                child: child,
              ),
            ),
          ],
        ),
      );
    },
  );
}
