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
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models_smstretching/sm_abonement_model.dart';
import 'package:stretching/models_smstretching/sm_studio_options_model.dart';
import 'package:stretching/models_yclients/good_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/hide_appbar_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/book_screens.dart';
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
    final navigator = Navigator.of(context, rootNavigator: true);

    final abonements = ref.watch(combinedAbonementsProvider);
    List<Widget> createCards() {
      return <Widget>[
        for (var index = 0; index < abonements.length; index++)
          AbonementCard(
            abonements.elementAt(index),
            indicator: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12, right: 24),
                child: Text(
                  '${index + 1} / ${abonements.length}',
                  style: theme.textTheme.headline6
                      ?.copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
          )
      ];
    }

    final abonementsCards = useRef(createCards());
    final cardController = useMemoized(() => TCardController());
    final refreshController = useMemoized(() => RefreshController());
    final currentScreen = useState(ProfileNavigationScreen.root);
    useMemoized<void>(
      () {
        if (cardController.state != null) {
          // ignore: avoid_dynamic_calls
          cardController.reset(cards: abonementsCards.value = createCards());
        }
      },
      [abonements.length],
    );

    FutureOr<void> Function() action(final ProfileNavigationScreen screen) {
      return () async {
        final isRoot = screen == ProfileNavigationScreen.root;
        ref.read(hideAppBarProvider(NavigationScreen.profile)).state = !isRoot;
        if (isRoot) {
          await ref.read(userProvider.notifier).setStateAsync(null);
          (ref.read(navigationProvider)).jumpToTab(NavigationScreen.home.index);
        }
      };
    }

    void reset() {
      currentScreen.value = ProfileNavigationScreen.root;
      ref.read(hideAppBarProvider(NavigationScreen.profile)).state = false;
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
    ) async {
      if (abonement == null) {
        return;
      }
      final businessLogic = ref.read(businessLogicProvider);
      final smDefaultStudioId =
          await ref.read(smDefaultStudioIdProvider.future);
      final good = businessLogic.goods.firstWhere((final good) {
        return abonement.service == null
            ? good.salonId == smDefaultStudioId
            : good.salonId == abonement.service;
      });
      final options = _smStudiosOptions[good.salonId];
      final user = ref.read(userProvider);
      if (options == null || user == null) {
        return;
      }

      final payment = await businessLogic.payTinkoff(
        navigator: navigator,
        companyId: good.salonId,
        email: email,
        userPhone: user.phone,
        cost: good.cost,
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
          ref.read(userAbonementsProvider.notifier).refresh(),
          ref.read(smUserAbonementsProvider.notifier).refresh(),
        ]);
      } else {
        await navigator.push(
          MaterialPageRoute<bool>(
            builder: (final context) => ResultBookScreen(
              title: BookExceptionType.general.title,
              body: BookExceptionType.general.info,
              button: BookExceptionType.general.button,
            ),
          ),
        );
      }
    }

    Widget content() {
      switch (currentScreen.value) {
        case ProfileNavigationScreen.profile:
          return ProfileEditScreen(onBackButton: reset);
        case ProfileNavigationScreen.history:
          return HistoryScreen(onBackButton: reset);
        case ProfileNavigationScreen.support:
          return ContactScreen(onBackButton: reset);
        case ProfileNavigationScreen.root:
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top +
                  mainAppBar(theme).preferredSize.height,
            ),
            child: SmartRefresher(
              controller: refreshController,
              onLoading: refreshController.loadComplete,
              onRefresh: () async {
                try {
                  while (ref.read(connectionErrorProvider).state) {
                    await Future<void>.delayed(const Duration(seconds: 1));
                  }
                  ref.refresh(smUserDepositProvider);
                  await Future.wait(<Future<void>>[
                    ref.read(smUserDepositProvider.future),
                    ref.read(userAbonementsProvider.notifier).refresh(),
                    ref.read(smUserAbonementsProvider.notifier).refresh(),
                  ]);
                } finally {
                  refreshController.refreshCompleted();
                }
              },
              child: ListView(
                primary: false,
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  /// Deposit
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: DepositCard(),
                  ),

                  /// Abonements
                  if (abonementsCards.value.isNotEmpty) ...[
                    TCard(
                      lockYAxis: true,
                      slideSpeed: 12,
                      size: const Size.fromHeight(100),
                      onEnd: () => cardController.forward(
                        direction: SwipDirection.Right,
                      ),
                      onForward: (final direction, final info) =>
                          // ignore: avoid_dynamic_calls
                          cardController.reset(
                        cards: abonementsCards.value = [
                          ...abonementsCards.value.sublist(1),
                          abonementsCards.value.first,
                        ],
                      ),
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
                              icon: FontIcon(
                                FontIconData(
                                  IconsCG.add,
                                  color: theme.colorScheme.primary
                                      .withOpacity(2 / 3),
                                  height: 32,
                                  alignment: Alignment.topRight,
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (final screen in ProfileNavigationScreen.values)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextButton(
                              onPressed: () =>
                                  action(currentScreen.value = screen)(),
                              style: ButtonStyle(
                                textStyle: MaterialStateProperty.all(
                                  theme.textTheme.headline3,
                                ),
                                foregroundColor: MaterialStateProperty.all(
                                  currentScreen.value == screen
                                      ? theme.hintColor
                                      : theme.colorScheme.onSurface,
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

    return PageTransitionSwitcher(
      reverse: currentScreen.value == ProfileNavigationScreen.root,
      duration: const Duration(milliseconds: 500),
      layoutBuilder: (final entries) => Stack(children: entries),
      child: content(),
      transitionBuilder: (
        final child,
        final animation,
        final secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
    );
  }
}

/// The card for displaying a [CombinedAbonementModel].
class BuyAbonementCard extends ConsumerWidget {
  /// The card for displaying a [CombinedAbonementModel].
  const BuyAbonementCard({required final this.onPressed, final Key? key})
      : super(key: key);

  /// The callback to purchase the abonement.
  final FutureOr<void> Function() onPressed;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    const gradient = LinearGradient(
      colors: <Color>[Color(0xFFD353F0), Color(0xFF18D1EE)], //0xFFD353F0
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    return Container(
      height: 130,
      decoration: const BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16).copyWith(top: 0),
        horizontalTitleGap: 8,
        minVerticalPadding: 0,
        minLeadingWidth: 30,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: EmojiText('⚡️', style: const TextStyle(fontSize: 20)),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                TR.abonementBuy.tr(),
                style: theme.textTheme.bodyText1?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              MaterialButton(
                onPressed: onPressed,
                visualDensity: VisualDensity.compact,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                color: theme.colorScheme.surface,
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
              )
            ],
          ),
        ),
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
                    style: theme.textTheme.subtitle2
                        ?.copyWith(color: theme.colorScheme.onPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

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
                    if (!isDeactivated) ...[
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
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: TR.abonementLeftDate.tr(
                          args: <String>[
                            DateFormat.MMMMd(locale.toString())
                                .format(abonement.item1.expirationDate!)
                          ],
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
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
  const DepositCard({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    return (ref.watch(smUserDepositProvider)).when(
      data: (final userDeposit) {
        num deposit = userDeposit;
        var leftCount = 0;
        final prices = ref.watch(smActivityPriceProvider);
        if (deposit > 0 && ref.watch(discountProvider)) {
          deposit -= prices.ySalePrice.optionValue;
          leftCount++;
        }
        leftCount += (deposit / prices.regularPrice.optionValue).truncate();
        if (leftCount == 0) {
          return const SizedBox.shrink();
        }
        return Container(
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
              SizedBox(
                width: 36,
                child: EmojiText('✌️', style: const TextStyle(fontSize: 22)),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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

                    /// Info
                    Text(
                      TR.depositInfo.plural(leftCount),
                      style: theme.textTheme.overline
                          ?.copyWith(color: theme.colorScheme.onPrimary),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (final error, final stackTrace) => const SizedBox.shrink(),
    );
  }
}
