import 'dart:async';
import 'dart:math';

import 'package:catcher/catcher.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/main.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/home_screen.dart';
import 'package:stretching/widgets/navigation/screens/studios_screen.dart';
import 'package:stretching/widgets/navigation/screens/trainers_screen.dart';
import 'package:uni_links/uni_links.dart';

/// The provider of the initial [getInitialUri] handler and [uriLinkStream].
final FutureProvider<void> uniLinksProvider =
    FutureProvider<void>((final ref) async {
  uriLinkStream.listen((final uri) => _onUri(ref, uri));
  final completer = Completer<void>();
  final splashNotifier = ref.read(splashProvider.notifier);
  if (splashNotifier.state) {
    splashNotifier.addListener((final state) async {
      if (!completer.isCompleted && !state) {
        await Future<void>.delayed(RootScreen.transitionDuration);
        completer.complete();
      }
    });
  } else {
    completer.complete();
  }
  await completer.future;
  await _onUri(ref, await getInitialUri());
});

Future<void> _onUri(final ProviderRefBase ref, final Uri? uri) async {
  final theme = ref.read(rootThemeProvider).state;
  final mediaQuery = ref.read(rootMediaQueryProvider).state;
  if ((theme == null || mediaQuery == null) ||
      (uri == null || uri.scheme != 'smstretching')) {
    return;
  }

  Future<void> goToScreen(final NavigationScreen screen) async {
    final navigation = ref.read(navigationProvider);
    Future<void> clearNavigator() async {
      final screen = NavigationScreen.values.elementAt(navigation.index);
      final navigator = ref.read(navigatorProvider(screen)).currentState;
      while (await navigator?.maybePop() ?? false) {
        await Future<void>.delayed(NavigationRoot.transitionDuration);
      }
      navigator?.popUntil(Routes.root.withName);
    }

    Catcher.navigatorKey?.currentState?.popUntil(Routes.root.withName);
    try {
      if (navigation.index != screen.index) {
        await clearNavigator();
        navigation.jumpToTab(screen.index);
        await Future<void>.delayed(NavigationRoot.transitionDuration);
      }
    } finally {
      await clearNavigator();
    }
  }

  Future<void> animateToCard({
    required final ScrollController controller,
    required final int index,
    required final double height,
    final double spacing = 0,
    final double offset = 0,
    final Duration duration = const Duration(milliseconds: 300),
    final Duration maxDuration = const Duration(seconds: 3),
    final int crossAxisCount = 1,
    final Curve curve = Curves.ease,
  }) async {
    final viewportDimension = controller.position.viewportDimension;
    final _index = (index / crossAxisCount).truncate();
    var _offset = offset +
        height * (_index + (crossAxisCount > 1 ? 0 : 1)) +
        spacing * _index;
    if (controller.hasClients &&
        (_offset < controller.offset ||
            _offset > controller.offset + viewportDimension)) {
      if (_offset > controller.offset + viewportDimension) {
        _offset -= viewportDimension - (height + spacing * 3 / 2);
      }
      final indexOffset =
          max(0, controller.offset - offset) ~/ (height + spacing);
      final offsetDuration =
          (indexOffset - (_index + (crossAxisCount > 1 ? 0 : 1))).abs() *
              duration.inMilliseconds;
      await controller.animateTo(
        _offset.clamp(0, controller.position.maxScrollExtent),
        curve: curve,
        duration: Duration(
          milliseconds: offsetDuration.clamp(0, maxDuration.inMilliseconds),
        ),
      );
    }
  }

  final id = int.tryParse(uri.path.replaceFirst('/', ''));
  switch (uri.host) {
    case 'profile':
      await goToScreen(NavigationScreen.profile);
      break;
    case 'trainer':
      await goToScreen(NavigationScreen.trainers);
      if (id != null) {
        for (final trainer in ref.read(trainersProvider)) {
          if (trainer.id == id) {
            final trainers = ref.read(filteredTrainersProvider);
            for (var index = 0; index < trainers.length; index++) {
              final filteredTrainer = trainers.elementAt(index);
              if (filteredTrainer.item0.name == trainer.name) {
                await animateToCard(
                  index: index,
                  offset: 144,
                  crossAxisCount: TrainersScreen.crossAxisCount,
                  height: TrainerCard.height(theme, mediaQuery),
                  spacing: TrainersScreen.mainAxisSpacing,
                  controller: ref.read(
                    navigationScrollControllerProvider(
                      NavigationScreen.trainers,
                    ),
                  ),
                );
                ref.read(trainersCardsProvider(filteredTrainer)).state?.call();
                await Future<void>.delayed(TrainerContainer.transitionDuration);
                break;
              }
            }
            break;
          }
        }
      }
      break;
    case 'map':
      await goToScreen(NavigationScreen.studios);
      final studiosOnMap = ref.read(studiosOnMapProvider);
      if (!studiosOnMap.state) {
        studiosOnMap.state = !studiosOnMap.state;
        await Future<void>.delayed(StudiosScreen.onMapSwitcherDuration);
      }
      break;
    case 'studio':
      await goToScreen(NavigationScreen.studios);
      if (id != null) {
        final studios = ref.read(combinedStudiosProvider);
        for (var index = 0; index < studios.length; index++) {
          final studio = studios.elementAt(index);
          if (studio.item0.id == id) {
            final studiosOnMap = ref.read(studiosOnMapProvider);
            if (studiosOnMap.state) {
              studiosOnMap.state = !studiosOnMap.state;
              await Future<void>.delayed(StudiosScreen.onMapSwitcherDuration);
            }
            await animateToCard(
              index: index,
              height: StudioCard.height(mediaQuery.textScaleFactor),
              spacing: 8,
              duration: const Duration(milliseconds: 250),
              maxDuration: const Duration(seconds: 1),
              controller: ref.read(
                navigationScrollControllerProvider(NavigationScreen.studios),
              ),
            );
            ref.read(studiosCardsProvider(studio)).state?.call();
            await Future<void>.delayed(StudioScreenCard.transitionDuration);
            break;
          }
        }
      }
      break;
    case 'timetable':
      await goToScreen(NavigationScreen.schedule);
      break;
    case 'stories':
      await goToScreen(NavigationScreen.home);
      if (id != null) {
        final stories = ref.read(smStoriesProvider);
        for (var index = 0; index < stories.length; index++) {
          final story = stories.elementAt(index);
          if (story.media == id) {
            await animateToCard(
              index: index,
              offset: 16,
              height: StoryCardScreen.storySize,
              spacing: HomeScreen.storiesSpacing,
              duration: const Duration(milliseconds: 200),
              maxDuration: const Duration(seconds: 1),
              controller: ref.read(storiesScrollControllerProvider),
            );
            ref.read(storiesCardsProvider(story.media)).state?.call();
            await Future<void>.delayed(StoryCardScreen.transitionDuration);
            break;
          }
        }
        break;
      }
  }
}
