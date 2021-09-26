import 'dart:async';
import 'dart:math';

import 'package:catcher/catcher.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod/riverpod.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/main.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/home_screen.dart';
import 'package:stretching/widgets/navigation/screens/studios_screen.dart';
import 'package:stretching/widgets/navigation/screens/trainers_screen.dart';
import 'package:uni_links/uni_links.dart';

/// The provider of the initial [getInitialUri] handler.
final FutureProvider<void> initialUniLinkProvider =
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
  if (uri == null || uri.scheme != 'smstretching') {
    return;
  }

  Future<void> goToScreen(final NavigationScreen screen) async {
    final navigation = ref.read(navigationProvider);
    Future<void> clearNavigator() async {
      final screen = NavigationScreen.values.elementAt(navigation.index);
      final navigator = ref.read(currentNavigatorProvider(screen)).currentState;
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
                final scrollController = ref.read(
                  navigationScrollControllerProvider(
                    NavigationScreen.trainers,
                  ),
                );
                final viewportDimension =
                    scrollController.position.viewportDimension;
                var offset = 144 + (248 * (index & ~1) / 2);
                if (scrollController.hasClients &&
                    (offset < scrollController.offset ||
                        offset > scrollController.offset + viewportDimension)) {
                  if (offset > scrollController.offset + viewportDimension) {
                    offset -= viewportDimension - 260;
                  }
                  final indexOffset =
                      max(0, scrollController.offset - 144) ~/ 248;
                  final offsetDuration =
                      (indexOffset - (index & ~1) ~/ 2).abs() * 300;
                  await scrollController.animateTo(
                    offset.clamp(0, scrollController.position.maxScrollExtent),
                    curve: Curves.ease,
                    duration: Duration(milliseconds: min(offsetDuration, 3000)),
                  );
                }
                ref.read(trainersCardsProvider(filteredTrainer)).state?.call();
                await Future<void>.delayed(TrainerCard.transitionDuration);
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
            final scrollController = ref.read(
              navigationScrollControllerProvider(NavigationScreen.studios),
            );
            final viewportDimension =
                scrollController.position.viewportDimension;
            var offset = (88 * (index + 1) + 8 * index).toDouble();
            if (scrollController.hasClients &&
                (offset < scrollController.offset ||
                    offset > scrollController.offset + viewportDimension)) {
              if (offset > scrollController.offset + viewportDimension) {
                offset -= viewportDimension - 100;
              }
              final indexOffset = scrollController.offset ~/ 96;
              final offsetDuration = (indexOffset - (index + 1)).abs() * 250;
              await scrollController.animateTo(
                offset.clamp(0, scrollController.position.maxScrollExtent),
                curve: Curves.ease,
                duration: Duration(milliseconds: min(offsetDuration, 1000)),
              );
            }
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
            final scrollController = ref.read(storiesScrollControllerProvider);
            final viewportDimension =
                scrollController.position.viewportDimension;
            var offset = (16 + 96 * (index + 1) + 6 * index).toDouble();
            if (scrollController.hasClients &&
                (offset < scrollController.offset ||
                    offset > scrollController.offset + viewportDimension)) {
              if (offset > scrollController.offset + viewportDimension) {
                offset -= viewportDimension - 105;
              }
              final indexOffset = max(0, scrollController.offset - 16) ~/ 102;
              final offsetDuration = (indexOffset - (index + 1)).abs() * 200;
              await scrollController.animateTo(
                offset.clamp(0, scrollController.position.maxScrollExtent),
                curve: Curves.ease,
                duration: Duration(milliseconds: min(offsetDuration, 1000)),
              );
            }
            ref.read(storiesCardsProvider(story.media)).state?.call();
            await Future<void>.delayed(StoryCardScreen.transitionDuration);
            break;
          }
        }
        break;
      }
  }
}
