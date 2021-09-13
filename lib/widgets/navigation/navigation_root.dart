import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/providers/hide_appbar_provider.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:stretching/widgets/navigation/screens/activities_screen.dart';
import 'package:stretching/widgets/navigation/screens/home_screen.dart';
import 'package:stretching/widgets/navigation/screens/profile/profile_screen.dart';
import 'package:stretching/widgets/navigation/screens/studios_screen.dart';
import 'package:stretching/widgets/navigation/screens/trainers_screen.dart';

// /// The enumeration of conten routes for this app.
// enum ContentRoutes {
//   /// The screen with trainer content.
//   trainer,

//   /// The screen with studio content.
//   studio,

//   /// The screen with activity content.
//   activity
// }

// /// The extra data provided for [ContentRoutes].
// extension ContentRoutesData on ContentRoutes {
//   static const String _self = 'content';

//   /// The name of this route.
//   String get name => '${Routes.root.name}$_self/${describeEnum(this)}';

//   /// The builder of this route.
//   Widget Function(BuildContext, Object?) get builder {
//     switch (this) {
//       case ContentRoutes.trainer:
//       case ContentRoutes.studio:
//       case ContentRoutes.activity:
//         return (final context, final args) => const ContentScreen();
//     }
//   }
// }

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
  PersistentBottomNavBarItem navBarItem(final WidgetRef ref) {
    return PersistentBottomNavBarItem(
      title: title,
      routeAndNavigatorSettings: RouteAndNavigatorSettings(
        navigatorObservers: <NavigatorObserver>[
          ref.watch(routeObserverProvider(this))
        ],
        // onGenerateRoute: (final settings) {
        //   var name = settings.name;
        //   if (name == null || name.isEmpty) {
        //     return null;
        //   }
        //   if (name.startsWith('/')) {
        //     name = name.substring(1);
        //   }
        //   switch (name.split('/').first) {
        //     case ContentRoutesData._self:
        //       return MaterialPageRoute<Never>(
        //         builder: (final context) => enumFromString(
        //           ContentRoutes.values,
        //           name!.split('/').last,
        //         ).builder(context, settings.arguments),
        //         settings: settings,
        //       );
        //   }
        // },
      ),
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
        return const ActivitiesScreen();
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

final StateProvider<bool> navigationTransitioningProvider =
    StateProvider<bool>((final ref) => false);

final StateProvider<int> currentNavigationProvider =
    StateProvider<int>((final ref) => 0);

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
// with ModalBottomSheets {
{
  /// The notifier that contains the main app's navigation features.
  factory NavigationNotifier(final ProviderRefBase ref) {
    final notifier = NavigationNotifier._(ref);
    notifier.state.addListener(() async {
      ref.read(currentNavigationProvider).state = notifier.state.index;
      ref.read(navigationTransitioningProvider).state = true;
      await Future<void>.delayed(NavigationRoot.transitionDuration);
      ref.read(navigationTransitioningProvider).state = false;
    });
    ref.listen<bool>(unauthorizedProvider, (final userIsNull) {
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

  NavigationNotifier._(final ProviderRefBase ref)
      : super(
          hive: ref.watch(hiveProvider),
          saveName: 'navigation',
          converter: const PersistentTabControllerConverter(
            EnumConverter(NavigationScreen.values),
          ),
          defaultValue: PersistentTabController(),
        );

  int _previousScreenIndex = 0;

  /// The index of the previous [NavigationScreen].
  int get previousScreenIndex => _previousScreenIndex;

  /// Sets the index of the previous [NavigationScreen].
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

  /// The height of the navigation bar.
  static const double navBarHeight = 50;

  /// The duration of the transition in the navigation bar.
  static const Duration transitionDuration = Duration(milliseconds: 350);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final appBar = mainAppBar(theme);
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        /// Root
        PersistentTabView(
          context,
          controller: ref.watch(navigationProvider),
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
          onWillPop: (final _) async {
            return (await showMaterialModalBottomSheet<bool?>(
                  context: context,
                  builder: (final context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        BottomSheetHeader(title: TR.alertExitTitle.tr()),
                        SingleChildScrollView(
                          primary: false,
                          controller: ModalScrollController.of(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 36,
                            ),
                            child: BottomButtons(
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
                            ),
                          ),
                        )
                      ],
                    );
                  },
                )) ??
                false;
          },
          onItemSelected: (final index) async {
            final navigation = ref.read(navigationProvider.notifier);
            if (index == NavigationScreen.profile.index &&
                ref.read(unauthorizedProvider)) {
              if (navigation.previousScreenIndex ==
                  NavigationScreen.profile.index) {
                navigation.state.index = NavigationScreen.home.index;
              } else {
                navigation.state.index = navigation.previousScreenIndex;
              }
              await Navigator.of(context, rootNavigator: true)
                  .pushNamed(Routes.auth.name);
            } else if (navigation.previousScreenIndex != index) {
              navigation.previousScreenIndex = index;
            }
          },
          items: <PersistentBottomNavBarItem>[
            for (final screen in NavigationScreen.values) screen.navBarItem(ref)
          ],
          selectedTabScreenContext: (final context) {
            if (context == null) {
              return;
            }
          },
          screens: <Widget>[
            for (final screen in NavigationScreen.values)
              KeyboardVisibilityBuilder(
                builder: (final context, final isKeyboardVisible) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: screen != NavigationScreen.profile
                          ? appBar.preferredSize.height +
                              mediaQuery.viewPadding.top
                          : 0,
                      bottom: isKeyboardVisible ? 0 : navBarHeight,
                    ),
                    child: screen.screen,
                  );
                },
              ),
          ],
        ),

        /// Custom AppBar
        Consumer(
          builder: (final context, final ref, final child) {
            final hideAppbar = ref.watch(
              hideAppBarProvider(
                NavigationScreen.values.elementAt(
                  ref.watch(currentNavigationProvider).state,
                ),
              ),
            );
            return IgnorePointer(
              ignoring: hideAppbar.state,
              child: AnimatedOpacity(
                duration: transitionDuration,
                curve: hideAppbar.state
                    ? const Interval(1 / 3, 2 / 3, curve: Curves.easeOut)
                    : const Interval(1 / 3, 2 / 3, curve: Curves.easeInOut),
                opacity: hideAppbar.state ? 0 : 1,
                child: SizedBox(
                  height:
                      appBar.preferredSize.height + mediaQuery.viewPadding.top,
                  child: appBar,
                ),
              ),
            );
          },
        ),

        /// Blocks input while screen is transitioning
        Consumer(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(height: navBarHeight, color: Colors.transparent),
          ),
          builder: (final context, final ref, final child) {
            final isTransitioning = ref.watch(navigationTransitioningProvider);
            return IgnorePointer(
              ignoring: !isTransitioning.state,
              child: child,
            );
          },
        )
      ],
    );
  }
}
