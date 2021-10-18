import 'dart:async';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/business_logic.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/refresh_content_hook.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models/smstretching/sm_abonement_model.dart';
import 'package:stretching/models/smstretching/sm_studio_options_model.dart';
import 'package:stretching/models/yclients/good_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/content_provider.dart';
import 'package:stretching/providers/hide_appbar_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/modals/payment_picker.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/profile/contact_screen.dart';
import 'package:stretching/widgets/navigation/screens/profile/history_screen.dart';
import 'package:stretching/widgets/navigation/screens/profile/profile_edit_screen.dart';
import 'package:tcard/tcard.dart';

/// The navigation screen for [ProfileScreen].
enum ProfileNavigationScreen {
  /// The profile editing screen.
  profile,

  /// The screen with all of the previous user's records.
  history,

  /// The screen to contact support.
  support,

  /// The root of the profile navigation.
  root
}

/// The extra data provided for [ProfileNavigationScreen].
extension ProfileNavigationScreenData on ProfileNavigationScreen {
  /// The translation of this screen.
  String get translation => '${TR.profileScreen}.${enumToString(this)}'.tr();
}

/// The screen for the [NavigationScreen.profile].
class ProfileScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.profile].
  const ProfileScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    final scrollController =
        ref.watch(navigationScrollControllerProvider(NavigationScreen.profile));
    final abonements = ref.watch(combinedAbonementsProvider);
    List<Widget> createCards() => <Widget>[
          for (var index = 0; index < abonements.length; index++)
            AbonementCard(
              abonements.elementAt(index),
              indicator: abonements.length > 1
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12, right: 24),
                        child: Text(
                          '${index + 1} / ${abonements.length}',
                          style: theme.textTheme.headline6
                              ?.copyWith(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    )
                  : null,
            )
        ];

    final userDeposit = ref.watch(
      smUserDepositProvider.select(
        (final userDeposit) =>
            userDeposit.whenOrNull(data: (final userDeposit) => userDeposit),
      ),
    );
    final prevUserDeposit = usePrevious(userDeposit);

    final abonementsCards = useRef(createCards());
    final cardController = useMemoized(TCardController.new);
    final refresh = useRefreshController(
      extraRefresh: () async {
        while (ref.read(connectionErrorProvider).state) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
        ref.refresh(smUserDepositProvider);
        await ref.read(smUserDepositProvider.future);
      },
      notifiers: <ContentNotifier>[
        ref.read(userAbonementsProvider.notifier),
        ref.read(smUserAbonementsProvider.notifier),
      ],
    );

    final currentScreen = useState(ProfileNavigationScreen.root);
    useMemoized<void>(
      () {
        abonementsCards.value = createCards();
        if (cardController.state != null) {
          // ignore: avoid_dynamic_calls
          cardController.reset(cards: abonementsCards.value);
        }
      },
      [abonements],
    );

    Future<void> action(final ProfileNavigationScreen screen) async {
      final navigator = Navigator.of(context);
      final appBarProvider =
          ref.read(hideAppBarProvider(NavigationScreen.profile));

      final Widget pushScreen;
      switch (screen) {
        case ProfileNavigationScreen.profile:
          pushScreen = const ProfileEditScreen();
          break;
        case ProfileNavigationScreen.history:
          pushScreen = const HistoryScreen();
          break;
        case ProfileNavigationScreen.support:
          pushScreen = const ContactScreen();
          break;
        case ProfileNavigationScreen.root:
          await ref.read(userProvider.notifier).setStateAsync(null);
          ref.read(navigationProvider).jumpToTab(NavigationScreen.home.index);
          final homeNavigator =
              ref.read(navigatorProvider(NavigationScreen.home)).currentState;
          homeNavigator?.popUntil(Routes.root.withName);
          return;
      }

      appBarProvider.state = true;
      await navigator.push(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (
            final context,
            final animation,
            final secondaryAnimation,
          ) =>
              pushScreen,
          transitionsBuilder: (
            final context,
            final animation,
            final secondaryAnimation,
            final child,
          ) =>
              SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          ),
        ),
      );
    }

    final _smStudiosOptions = <int, SMStudioOptionsModel>{
      for (final smStudioOption in ref.watch(smStudiosOptionsProvider))
        smStudioOption.studioId: smStudioOption
    };
    final possibleAbonements = <SMAbonementModel, GoodModel>{
      for (final abonement
          in ref.watch(smAbonementsProvider).toList(growable: false)..sort())
        for (final good
            in ref.watch(goodsProvider).toList(growable: false)..sort())
          if (good.loyaltyAbonementTypeId == abonement.yId)
            if (abonement.service == null || good.salonId == abonement.service)
              if (_smStudiosOptions.keys.contains(good.salonId)) abonement: good
    };

    Future<void> buyAbonement(
      final String email,
      final SMAbonementModel? abonement,
      final CombinedStudioModel? studio,
    ) async {
      final user = ref.read(userProvider);
      if (abonement == null || user == null) {
        return;
      }
      final businessLogic = ref.read(businessLogicProvider);
      final smDefaultStudioId =
          await ref.read(smDefaultStudioIdProvider.future);
      final good = businessLogic.goods.firstWhere(
        (final good) =>
            good.loyaltyAbonementTypeId == abonement.yId &&
            _smStudiosOptions.keys.contains(good.salonId) &&
            (abonement.service == null
                ? good.salonId == smDefaultStudioId
                : good.salonId == abonement.service),
      );
      final options = _smStudiosOptions[good.salonId]!;
      final payment = await businessLogic.payTinkoff(
        navigator: navigator,
        companyId: good.salonId,
        email: email,
        userPhone: user.phone,
        cost: user.test ? 1 : good.cost,
        terminalKey: options.key,
        terminalPass: options.pass,
      );
      if (payment.item0) {
        final result = await businessLogic.createAbonement(
          userPhone: user.phone,
          good: good,
          abonement: abonement,
          options: options,
        );

        await smStretching.editPayment(
          acquiring: payment.item1!,
          serverTime: businessLogic.serverTime,
          documentId: result.item0.documentId,
          isAbonement: true,
        );

        await Future.wait(<Future<void>>[
          ref.read(userAbonementsProvider.notifier).refresh(ref),
          ref.read(smUserAbonementsProvider.notifier).refresh(ref),
        ]);
      }
      // else {
      //   await navigator.push(
      //     MaterialPageRoute<bool>(
      //       builder: (final context) => ResultBookScreen(
      //         title: BookExceptionType.general.title,
      //         body: BookExceptionType.general.info,
      //         button: BookExceptionType.general.button,
      //       ),
      //     ),
      //   );
      // }
    }

    return Padding(
      padding: EdgeInsets.only(
        top:
            mediaQuery.viewPadding.top + mainAppBar(theme).preferredSize.height,
      ),
      child: SmartRefresher(
        controller: refresh.item0,
        onLoading: refresh.item0.loadComplete,
        onRefresh: refresh.item1,
        scrollController: scrollController,
        child: ListView(
          primary: false,
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: <Widget>[
            /// Deposit
            if ((userDeposit ?? (prevUserDeposit ?? 0)) > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DepositCard(userDeposit ?? prevUserDeposit!),
              )
            else
              // Fixes undesired disposal for underlying widgets.
              const SizedBox.shrink(),

            /// Abonements
            if (abonements.isNotEmpty) ...<Widget>[
              TCard(
                lockYAxis: true,
                slideSpeed: abonements.length == 1 ? 0 : 12,
                size: abonements.isNotEmpty
                    ? Size.fromHeight(100 * mediaQuery.textScaleFactor + 14)
                    : Size.zero,
                delaySlideFor: 150,
                onEnd: () {
                  cardController.forward(direction: SwipDirection.Right);
                },
                onForward: (final direction, final info) {
                  // ignore: avoid_dynamic_calls
                  cardController.reset(
                    cards: abonementsCards.value = <Widget>[
                      ...abonementsCards.value.sublist(1),
                      abonementsCards.value.first,
                    ],
                  );
                },
                controller: cardController,
                cards: abonementsCards.value,
              ),

              /// Buy One More Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ).copyWith(bottom: 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => showPaymentPickerBottomSheet(
                          context,
                          PaymentPickerScreen(
                            onPayment: buyAbonement,
                            smAbonements: possibleAbonements.keys,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            theme.colorScheme.surface,
                          ),
                          alignment: Alignment.centerLeft,
                          minimumSize: MaterialStateProperty.all(
                            const Size.fromHeight(60),
                          ),
                        ),
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 5),
                          child: ShaderMask(
                            shaderCallback: (final rect) =>
                                const LinearGradient(
                              colors: <Color>[
                                Color(0xFFD0ACEA),
                                Color(0xFFE898E0)
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ).createShader(rect),
                            child: const FontIcon(
                              FontIconData(
                                IconsCG.add,
                                color: Colors.white,
                                height: 32,
                                alignment: Alignment.topRight,
                              ),
                            ),
                          ),
                        ),
                        label: Text(
                          TR.abonementBuyMoreButton.tr(),
                          style: theme.textTheme.caption,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BuyAbonementCard(
                  onPressed: () => showPaymentPickerBottomSheet(
                    context,
                    PaymentPickerScreen(
                      onPayment: buyAbonement,
                      smAbonements: possibleAbonements.keys,
                    ),
                  ),
                ),
              ),

            /// Menu
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final screen in ProfileNavigationScreen.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextButton(
                        onPressed: () => action(currentScreen.value = screen),
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            theme.textTheme.headline3,
                          ),
                          overlayColor: MaterialStateProperty.all(
                            theme.colorScheme.onSurface.withOpacity(1 / 5),
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            screen == ProfileNavigationScreen.root
                                ? theme.hintColor
                                : theme.colorScheme.onSurface,
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.all(8),
                          ),
                        ),
                        child: Text(screen.translation),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// The card for displaying a [CombinedAbonementModel].
class BuyAbonementCard extends HookConsumerWidget {
  /// The card for displaying a [CombinedAbonementModel].
  const BuyAbonementCard({required final this.onPressed, final Key? key})
      : super(key: key);

  /// The callback to purchase the abonement.
  final FutureOr<void> Function() onPressed;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    const gradient = LinearGradient(
      colors: <Color>[Color(0xFFD353F0), Color(0xFF18D1EE)], //0xFFD353F0
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16).copyWith(right: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Image.asset(
              AssetsCG.emoji26a1,
              width: 20 * mediaQuery.textScaleFactor,
              height: 20 * mediaQuery.textScaleFactor,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: Text(
                    TR.abonementBuy.tr(),
                    style: theme.textTheme.bodyText1?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: theme.colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      child: Text(
                        TR.abonementBuyButton.tr(),
                        style: theme.textTheme.caption?.copyWith(
                          fontWeight: FontWeight.w500,
                          foreground: Paint()
                            ..shader = gradient.createShader(
                              const Rect.fromLTWH(0, 0, 200, 50),
                            ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(
          ObjectFlagProperty<FutureOr<void> Function()>.has(
            'onPressed',
            onPressed,
          ),
        ),
    );
  }
}

/// The card for displaying a [CombinedAbonementModel].
class AbonementCard extends ConsumerWidget {
  /// The card for displaying a [CombinedAbonementModel].
  const AbonementCard(
    final this.abonement, {
    final this.indicator,
    final Key? key,
  }) : super(key: key);

  /// The abonement to display in this card.
  final CombinedAbonementModel abonement;

  /// The widget to put as indicator if any.
  final Widget? indicator;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final isDeactivated = abonement.item1.expirationDate == null;
    final locale = ref.watch(localeProvider);
    return Stack(
      alignment: Alignment.bottomRight,
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: !isDeactivated
                ? const LinearGradient(
                    colors: <Color>[Color(0xFFD353F0), Color(0xFF18D1EE)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : null,
            color: isDeactivated ? theme.hintColor.withOpacity(1) : null,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// Title and Abonement
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /// Title
                  Text(
                    TR.abonementTitle.tr(),
                    style: theme.textTheme.subtitle1
                        ?.copyWith(color: theme.colorScheme.onPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  /// Abonement
                  Text(
                    abonement.item1.type.title,
                    style: theme.textTheme.caption
                        ?.copyWith(color: theme.colorScheme.onPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Text.rich(
                TextSpan(
                  text: isDeactivated ? TR.abonementDeactivated.tr() : null,
                  children: <InlineSpan>[
                    if (!isDeactivated) ...<InlineSpan>[
                      TextSpan(
                        text: TR.abonementLeftCount.plural(
                          abonement.item1.unitedBalanceServicesCount,
                          args: <String>[
                            abonement.item1.unitedBalanceServicesCount
                                .toString(),
                            abonement.item1.type.unitedBalanceServicesCount
                                .toString()
                          ],
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: TR.abonementLeftDate.tr(
                          args: <String>[
                            DateFormat.MMMMd(locale.toString())
                                .format(abonement.item1.expirationDate!)
                          ],
                        ),
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      )
                    ]
                  ],
                ),
                style: theme.textTheme.overline?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        if (indicator != null) indicator!,
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(
          DiagnosticsProperty<CombinedAbonementModel>(
            'abonement',
            abonement,
          ),
        ),
    );
  }
}

/// The card for displaying a [CombinedAbonementModel].
class DepositCard extends ConsumerWidget {
  /// The card for displaying a [CombinedAbonementModel].
  const DepositCard(final this.userDeposit, {final Key? key}) : super(key: key);

  /// The deposit value to display in this widget.
  final int userDeposit;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final prices = ref.watch(smActivityPriceProvider);
    final discount = ref.watch(discountProvider);
    num deposit = userDeposit;
    var leftCount = 0;
    if (deposit > 0 && discount) {
      deposit -= prices.ySalePrice.optionValue;
      leftCount++;
    }
    leftCount += (deposit / prices.regularPrice.optionValue).truncate();
    if (leftCount == 0) {
      return const SizedBox.shrink();
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFFC665F3), Color(0xFFE75566)],
          stops: <double>[0, 1],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: SizedBox(
              width: 36,
              child: EmojiText('✌️', style: TextStyle(fontSize: 22)),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /// Title
                Text(
                  TR.depositTitle.plural(leftCount),
                  style: theme.textTheme.bodyText1
                      ?.copyWith(color: theme.colorScheme.onPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                /// Info
                Flexible(
                  child: Text(
                    TR.depositInfo.plural(leftCount),
                    style: theme.textTheme.overline
                        ?.copyWith(color: theme.colorScheme.onPrimary),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties..add(DiagnosticsProperty<num>('userDeposit', userDeposit)),
    );
  }
}
