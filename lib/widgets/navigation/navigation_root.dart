import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/home_screen.dart';
import 'package:stretching/widgets/navigation/bottom_sheet.dart';
import 'package:stretching/widgets/profile_screen.dart';
import 'package:stretching/widgets/studios_screen.dart';
import 'package:stretching/widgets/trainers_screen.dart';

/// The screens for the [navigationProvider].
enum NavigationScreen {
  /// The main screen of the app.
  home,

  /// The screen with the schedule for the nearest time.
  schedule,

  /// The screen to show off studios.
  studios,

  /// The screen to show off trainers.
  trainers,

  /// The screen with user's profile
  profile
}

/// The extra data for the [NavigationScreen].
extension NavigationScreenData on NavigationScreen {
  /// The title of this navigation screen type.
  String get title => '${TR.navigation}.${enumToString(this)}'.tr();

  /// The icon of this navigation screen type.
  IconData get icon {
    switch (this) {
      case NavigationScreen.home:
        return IconsCG.home;
      case NavigationScreen.schedule:
        return IconsCG.calendar;
      case NavigationScreen.studios:
        return IconsCG.pinOutline;
      case NavigationScreen.trainers:
        return IconsCG.bolt;
      case NavigationScreen.profile:
        return IconsCG.profile;
    }
  }

  /// The navigation bar item of this navigation screen type.
  PersistentBottomNavBarItem get navBarItem {
    return PersistentBottomNavBarItem(
      title: title,
      icon: Icon(icon, size: 18),
      textStyle: const TextStyle(fontSize: 10),
      activeColorPrimary: Colors.black,
      activeColorSecondary: Colors.black,
      inactiveColorPrimary: Colors.grey,
      inactiveColorSecondary: Colors.grey,
    );
  }

  /// The screen of this navigation screen type.
  Widget get screen {
    switch (this) {
      case NavigationScreen.home:
        return const HomeScreen();
      case NavigationScreen.schedule:
        return Center(
          child: IconButton(
            icon: Icon(icon, size: 64),
            onPressed: () {},
          ),
        );
      case NavigationScreen.studios:
        return const StudiosScreen();
      case NavigationScreen.trainers:
        return const TrainersScreen();
      case NavigationScreen.profile:
        return const ProfileScreen();
    }
  }
}

/// The provider to hide the [PersistentTabView] on [NavigationScreen].
final StateProvider<bool> hideNavigationProvider =
    StateProvider<bool>((final ref) => false);

/// The provider of the [NavigationScreen].
final StateNotifierProvider<NavigationNotifier, PersistentTabController>
    navigationProvider =
    StateNotifierProvider<NavigationNotifier, PersistentTabController>(
        (final ref) {
  return NavigationNotifier(ref);
});

/// The notifier that contains the main app's navigation features.
class NavigationNotifier
    extends SaveToHiveNotifier<PersistentTabController, String>
    with ModalBottomSheets {
  /// The notifier that contains the main app's navigation features.
  factory NavigationNotifier(final ProviderRefBase ref) {
    final notifier = NavigationNotifier._(ref);
    ref.listen<bool>(userIsNullProvider, (final userIsNull) {
      if (userIsNull &&
          notifier.state.index == NavigationScreen.profile.index) {
        if (notifier.previousScreenIndex == NavigationScreen.profile.index) {
          notifier.state.index = NavigationScreen.home.index;
        } else {
          notifier.state.index = notifier.previousScreenIndex;
        }
      }
    });
    return notifier;
  }

  NavigationNotifier._(final this.ref)
      : super(
          hive: ref.watch(hiveProvider),
          saveName: 'navigation',
          converter: const PersistentTabControllerConverter(
            EnumConverter(NavigationScreen.values),
          ),
          defaultValue: PersistentTabController(),
        );

  @override
  final ProviderRefBase ref;

  @override
  void dispose() {
    super.dispose();
  }

  late int _previousScreenIndex = state.index;

  /// The index of the previous navigation screen.
  int get previousScreenIndex => _previousScreenIndex;

  /// Sets the index of the previous navigation screen.
  set previousScreenIndex(final int value) {
    if (0 <= value && value <= NavigationScreen.values.length) {
      _previousScreenIndex = value;
    }
  }
}

/// The converter of the [PersistentTabController].
class PersistentTabControllerConverter<T extends Enum>
    implements JsonConverter<PersistentTabController, String> {
  /// The converter of the [PersistentTabController].
  const PersistentTabControllerConverter(
    final this.converter, {
    final this.onControllerCreated,
  });

  /// The converter for the children.
  final EnumConverter<T> converter;

  /// The callback on a converted controller.
  final void Function(PersistentTabController)? onControllerCreated;

  @override
  PersistentTabController fromJson(final Object? data) {
    PersistentTabController controller;
    if (data is PersistentTabController) {
      return data;
    } else if (data == null) {
      controller = PersistentTabController();
    } else {
      controller = PersistentTabController(
        initialIndex: converter.fromJson(data).index,
      );
    }
    onControllerCreated?.call(controller);
    return controller;
  }

  @override
  String toJson(final PersistentTabController value) =>
      converter.toJson(converter.fromJson(value.index));
}

/// The screen that provides the basic navigation.
class NavigationRoot extends HookConsumerWidget {
  /// The screen that provides the basic navigation.
  const NavigationRoot({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    const navBarHeight = 50.0;
    const appBarHeight = 60.0;
    const transitionDuration = Duration(milliseconds: 350);
    final theme = Theme.of(context);

    final navigation = ref.watch(navigationProvider.notifier);
    final isTransitioning = useState<bool>(false);
    return Stack(
      children: <Widget>[
        PersistentTabView(
          context,
          controller: navigation.state,
          navBarStyle: NavBarStyle.style6,
          bottomScreenMargin: 0,
          navBarHeight: navBarHeight,
          padding: const NavBarPadding.only(bottom: 10),
          // hideNavigationBar: ref.watch(hideNavigationProvider).state,
          itemAnimationProperties: const ItemAnimationProperties(
            duration: transitionDuration,
            curve: Curves.ease,
          ),
          screenTransitionAnimation: const ScreenTransitionAnimation(
            animateTabTransition: true,
            curve: Curves.easeInOut,
            duration: transitionDuration,
          ),
          onWillPop: (final context) {
            return navigation.showAlertBottomSheet<bool>(
              context: context!,
              defaultValue: false,
              title: TR.alertExitTitle.tr(),
              firstText: TR.alertExitApprove.tr(),
              onFirstPressed: (final context) async {
                await SystemNavigator.pop();
                exit(0);
              },
              secondText: TR.alertExitDeny.tr(),
              onSecondPressed: (final context) async {
                await Navigator.of(context).maybePop();
                return false;
              },
            );
          },
          onItemSelected: (final index) async {
            if (index == NavigationScreen.profile.index &&
                ref.read(userIsNullProvider)) {
              if (navigation.previousScreenIndex ==
                  NavigationScreen.profile.index) {
                navigation.state.index = NavigationScreen.home.index;
              } else {
                navigation.state.index = navigation.previousScreenIndex;
              }
              await Navigator.of(context, rootNavigator: true)
                  .pushNamed(Routes.auth.name);
            } else if (navigation.previousScreenIndex != index) {
              isTransitioning.value = true;
              await Future<void>.delayed(transitionDuration);
              isTransitioning.value = false;
              navigation.previousScreenIndex = index;
            }
          },
          items: <PersistentBottomNavBarItem>[
            for (final screen in NavigationScreen.values) screen.navBarItem
          ],
          screens: <Widget>[
            for (final screen in NavigationScreen.values)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: appBarHeight,
                    bottom: navBarHeight,
                  ),
                  child: screen.screen,
                ),
              ),
          ],
        ),

        /// Custom AppBar
        SafeArea(
          child: Container(
            alignment: Alignment.center,
            height: appBarHeight,
            color: theme.appBarTheme.backgroundColor,
            child: FontIcon(
              FontIconData(
                IconsCG.logo,
                height: 16,
                color: theme.appBarTheme.foregroundColor,
              ),
            ),
          ),
        ),

        /// Blocks input while screen is transitioning
        if (isTransitioning.value)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(height: navBarHeight, color: Colors.transparent),
          ),
      ],
    );
  }
}
