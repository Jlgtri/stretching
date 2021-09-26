import 'dart:async';
import 'dart:math';

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

  final navigation = ref.read(navigationProvider);
  final id = int.tryParse(uri.path.replaceFirst('/', ''));
  switch (uri.host) {
    case 'profile':
      final screenIndex = NavigationScreen.profile.index;
      if (navigation.index != screenIndex) {
        navigation.jumpToTab(screenIndex);
      }
      break;
    case 'trainer':
      if (navigation.index != NavigationScreen.trainers.index) {
        navigation.jumpToTab(NavigationScreen.trainers.index);
        await Future<void>.delayed(NavigationRoot.transitionDuration);
      }
      if (id != null) {
        for (final trainer in ref.read(trainersProvider)) {
          if (trainer.id == id) {
            final trainers = ref.read(filteredTrainersProvider);
            for (var index = 0; index < trainers.length; index++) {
              final filteredTrainer = trainers.elementAt(index);
              if (filteredTrainer.item0.name == trainer.name) {
                final scrollController = ref.read(
                  navigationScrollController(NavigationScreen.trainers),
                );
                final viewportDimension =
                    scrollController.position.viewportDimension;
                var offset = 144 + (248 * (index & ~1) / 2);
                if (scrollController.hasClients &&
                    (offset < scrollController.offset - viewportDimension ||
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
                final card = ref.read(trainersCardsProvider(filteredTrainer));
                card.state?.call();
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
      if (navigation.index != NavigationScreen.studios.index) {
        navigation.jumpToTab(NavigationScreen.studios.index);
        await Future<void>.delayed(NavigationRoot.transitionDuration);
      }
      final studiosOnMap = ref.read(studiosOnMapProvider);
      if (!studiosOnMap.state) {
        studiosOnMap.state = !studiosOnMap.state;
        await Future<void>.delayed(StudiosScreen.onMapSwitcherDuration);
      }
      break;
    case 'studio':
      if (navigation.index != NavigationScreen.studios.index) {
        navigation.jumpToTab(NavigationScreen.studios.index);
        await Future<void>.delayed(NavigationRoot.transitionDuration);
      }
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
              navigationScrollController(NavigationScreen.studios),
            );
            final viewportDimension =
                scrollController.position.viewportDimension;
            var offset = (88 * (index + 1) + 8 * index).toDouble();
            if (scrollController.hasClients &&
                (offset < scrollController.offset - viewportDimension ||
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
      if (navigation.index != NavigationScreen.schedule.index) {
        navigation.jumpToTab(NavigationScreen.schedule.index);
        await Future<void>.delayed(NavigationRoot.transitionDuration);
      }
      break;
    case 'stories':
      navigation.jumpToTab(NavigationScreen.home.index);
      await Future<void>.delayed(NavigationRoot.transitionDuration);
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
                (offset < scrollController.offset - viewportDimension ||
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
            await Future<void>.delayed(const Duration(seconds: 1));
            ref.read(storiesCardsProvider(story.media)).state?.call();
            await Future<void>.delayed(StoryCardScreen.transitionDuration);
            break;
          }
        }
        break;
      }
  }
}
