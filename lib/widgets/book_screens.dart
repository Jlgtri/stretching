import 'package:darq/darq.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models_smstretching/sm_abonement_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/record_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:tinkoff_acquiring/tinkoff_acquiring.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The screen that prompts user to pay regularly or buy an abonement.
class PromptBookScreen extends StatelessWidget {
  /// The screen that prompts user to pay regularly or buy an abonement.
  const PromptBookScreen({
    required final this.onRegular,
    required final this.onAbonement,
    required final this.regularPrice,
    required final this.ySalePrice,
    required final this.abonementPrice,
    final this.abonementNonMatchReason = SMAbonementNonMatchReason.none,
    final this.discount = false,
    final Key? key,
  }) : super(key: key);

  /// The callback on regular payment.
  final OnBottomButton onRegular;

  /// The callback on abonement payment.
  final OnBottomButton onAbonement;

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

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
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
                  top: abonementNonMatchReason != SMAbonementNonMatchReason.none
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
                        EmojiText('😬', style: const TextStyle(fontSize: 35)),
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
                      TR.miscCurrency
                          .tr(args: <String>[abonementPrice.toStringAsFixed(0)])
                    ],
                  ),
                  onFirstPressed: onRegular,
                  onSecondPressed: onAbonement,
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
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(ObjectFlagProperty<OnBottomButton>.has('onRegular', onRegular))
        ..add(
          ObjectFlagProperty<OnBottomButton>.has(
            'onAbonement',
            onAbonement,
          ),
        )
        ..add(DiagnosticsProperty<num>('regularPrice', regularPrice))
        ..add(DiagnosticsProperty<num>('ySalePrice', ySalePrice))
        ..add(DiagnosticsProperty<num>('abonementPrice', abonementPrice))
        ..add(
          EnumProperty<SMAbonementNonMatchReason>(
            'abonementNonMatchReason',
            abonementNonMatchReason,
          ),
        )
        ..add(DiagnosticsProperty<bool>('discount', discount)),
    );
  }
}

/// The screen of the successful booking.
class SuccessfulBookScreen extends StatelessWidget {
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
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
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
                EmojiText('🤘😍', style: const TextStyle(fontSize: 45)),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100 * 2 / 3),
                  child: Text(
                    abonement
                        ? TR.successfulBookAbonement.tr()
                        : TR.successfulBookRegular.tr(),
                    style: theme.textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: Text(
                    TR.successfulBookInfo.tr(),
                    style: theme.textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 55),
                  child: BottomButtons<dynamic>(
                    firstText: TR.successfulBookCalendar.tr(),
                    secondText: TR.successfulBookBackToMain.tr(),
                    onFirstPressed: (final context) => activity.addToCalendar(),
                    onSecondPressed: (final context) =>
                        Navigator.of(context).maybePop(),
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
class ResultBookScreen extends StatelessWidget {
  /// The result screen of the booking.
  const ResultBookScreen({
    final this.emoji = '😞',
    final this.title = '',
    final this.body = '',
    final this.button = '',
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

  /// If the back button should be shown.
  final bool showBackButton;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
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
                EmojiText(emoji, style: const TextStyle(fontSize: 45)),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 65),
                  child: Text(
                    title,
                    style: theme.textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                    body,
                    style: theme.textTheme.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 75),
                  child: BottomButtons<dynamic>(
                    inverse: true,
                    firstText: button,
                    onFirstPressed: (final context) =>
                        Navigator.of(context).maybePop(true),
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
class WebViewAcquiringScreen extends HookWidget {
  /// The screen that provides a payment for the user.
  const WebViewAcquiringScreen(final this.acquiring, {final Key? key})
      : super(key: key);

  /// The data provided for acquiring at this screen.
  final WebViewAcquiring acquiring;

  @override
  Widget build(final BuildContext context) {
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
