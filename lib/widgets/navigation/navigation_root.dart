import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/navigation/bottom_sheet.dart';

/// The screens for the [navigationControllerProvider].
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
      icon: Icon(icon),
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
      case NavigationScreen.schedule:
      case NavigationScreen.studios:
      case NavigationScreen.trainers:
      case NavigationScreen.profile:
        return Center(child: Icon(icon, size: 64));
    }
  }
}

/// The provider to hide the [PersistentTabView] on [NavigationScreen].
final StateProvider<bool> hideNavigationProvider =
    StateProvider<bool>((final ref) => false);

/// The provider of the [NavigationScreen].
final StateNotifierProvider<NavigationNotifier, PersistentTabController>
    navigationControllerProvider =
    StateNotifierProvider<NavigationNotifier, PersistentTabController>(
        (final ref) {
  return NavigationNotifier(ref);
});

/// The notifier that contains the main app's navigation features.
class NavigationNotifier
    extends SaveToHiveNotifier<PersistentTabController, String>
    with ModalBottomSheets {
  /// The notifier that contains the main app's navigation features.
  NavigationNotifier(final this.ref)
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
}

/// The converter of the [PersistentTabController].
class PersistentTabControllerConverter<T extends Enum>
    implements JsonConverter<PersistentTabController, String> {
  /// The converter of the [PersistentTabController].
  const PersistentTabControllerConverter(this.converter);

  /// The converter for the children.
  final EnumConverter<T> converter;

  @override
  PersistentTabController fromJson(final Object? data) {
    if (data is PersistentTabController) {
      return data;
    } else if (data == null) {
      return PersistentTabController();
    }
    return PersistentTabController(
      initialIndex: converter.fromJson(data).index,
    );
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
    final navigationController =
        ref.watch(navigationControllerProvider.notifier);
    return PersistentTabView(
      context,
      controller: navigationController.state,
      navBarStyle: NavBarStyle.style6,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      bottomScreenMargin: 0,
      navBarHeight: 60,
      hideNavigationBar: ref.watch(hideNavigationProvider).state,
      decoration: NavBarDecoration(
        colorBehindNavBar: Colors.indigo,
        borderRadius: BorderRadius.circular(20),
      ),
      itemAnimationProperties: const ItemAnimationProperties(
        duration: Duration(milliseconds: 400),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: const ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.easeOut,
        duration: Duration(milliseconds: 300),
      ),
      padding: const NavBarPadding.only(bottom: 8),
      onWillPop: (final context) {
        return navigationController.showAlertBottomSheet<bool>(
          context: context!,
          defaultValue: false,
          title: TR.alertExitTitle.tr(),
          firstText: TR.alertExitApprove.tr(),
          onFirstPressed: (final context) {
            SystemNavigator.pop();
            return true;
          },
          secondText: TR.alertExitDeny.tr(),
          onSecondPressed: (final context) async {
            await Navigator.of(context).maybePop();
            return false;
          },
        );
      },
      items: <PersistentBottomNavBarItem>[
        for (final screen in NavigationScreen.values) screen.navBarItem
      ],
      screens: <Widget>[
        for (final screen in NavigationScreen.values) screen.screen
      ],
    );
  }
}
