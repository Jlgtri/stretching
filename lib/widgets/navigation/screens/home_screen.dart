import 'dart:async';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/refresh_content_hook.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models/smstretching/sm_story_model.dart';
import 'package:stretching/models/yclients/user_record_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/content_provider.dart';
import 'package:stretching/providers/firebase_providers.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/components/stories.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/activities_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The id converter of the [SMStoryModel].
final Provider<SMStoryIdConverter> smStoryIdConverterProvider =
    Provider<SMStoryIdConverter>(SMStoryIdConverter._);

/// The id converter of the [SMStoryModel].
class SMStoryIdConverter implements JsonConverter<SMStoryModel?, int> {
  const SMStoryIdConverter._(final this._ref);
  final ProviderRefBase _ref;

  @override
  SMStoryModel? fromJson(final int media) {
    for (final story in _ref.read(smStoriesProvider)) {
      if (story.media == media) {
        return story;
      }
    }
  }

  @override
  int toJson(final SMStoryModel? story) => story!.media;
}

/// The provider of already watched [SMStoryModel].
final StateNotifierProvider<SaveToHiveIterableNotifier<SMStoryModel, String>,
        Iterable<SMStoryModel>> homeWatchedStoriesProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<SMStoryModel, String>,
        Iterable<SMStoryModel>>(
  (final ref) => SaveToHiveIterableNotifier<SMStoryModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'home_stories',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(smStoryIdConverterProvider)),
    ),
    defaultValue: const Iterable<SMStoryModel>.empty(),
  ),
);

/// The scroll controller for the [StoryCardScreen] scrollable.
final Provider<ScrollController> storiesScrollControllerProvider =
    Provider<ScrollController>((final ref) => ScrollController());

/// The [OpenContainer.openBuilder] provider of the [StoryCardScreen] for each
/// [SMStoryModel].
final StateProviderFamily<void Function()?, int> storiesCardsProvider =
    StateProvider.family<void Function()?, int>(
  (final ref, final storyMedia) => null,
);

/// The screen for the [NavigationScreen.home].
class HomeScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.home].
  const HomeScreen({final Key? key}) : super(key: key);

  /// The spacing of the [StoryCardScreen].
  static const double storiesSpacing = 6;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final scrollController =
        ref.watch(navigationScrollControllerProvider(NavigationScreen.home));
    final storiesScrollController = ref.watch(storiesScrollControllerProvider);
    final unauthorized =
        ref.watch(userProvider.select((final user) => user == null));

    final smAdvertisments = ref.watch(smAdvertismentsProvider);
    final smStories = ref.watch(smStoriesProvider);
    final activities = ref.watch(combinedActivitiesProvider);
    final userRecords = <UserRecordModel, CombinedActivityModel>{
      for (final userRecord
          in ref.watch(userRecordsProvider).toList(growable: false)..sort())
        for (final activity in activities)
          if (!userRecord.deleted && userRecord.activityId == activity.item0.id)
            userRecord: activity
    };
    final serverTime = ref.watch(smServerTimeProvider);
    final refresh = useRefreshController(
      extraRefresh: () async {
        while (ref.read(connectionErrorProvider).state) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      },
      notifiers: <ContentNotifier>[
        ref.read(smStoriesProvider.notifier),
        ref.read(smAdvertismentsProvider.notifier),
        ref.read(userRecordsProvider.notifier),
      ],
    );

    return SmartRefresher(
      controller: refresh.item0,
      onLoading: refresh.item0.loadComplete,
      onRefresh: refresh.item1,
      scrollController: scrollController,
      child: CustomScrollView(
        primary: false,
        shrinkWrap: true,
        controller: scrollController,
        slivers: <Widget>[
          /// Stories
          if (smStories.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: SliverToBoxAdapter(
                child: LimitedBox(
                  maxHeight: 96,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16 - storiesSpacing / 2,
                    ),
                    controller: storiesScrollController,
                    itemCount: smStories.length,
                    prototypeItem: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: storiesSpacing / 2,
                      ),
                      child: StoryCardScreen(smStories.first),
                    ),
                    itemBuilder: (final context, final index) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: storiesSpacing / 2,
                      ),
                      child: StoryCardScreen(smStories.elementAt(index)),
                    ),
                  ),
                ),
              ),
            ),

          /// Advertisment
          if (smAdvertisments.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16).copyWith(bottom: 0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        offset: Offset(0, 4),
                        blurRadius: 13,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                  child: OpenContainer<void>(
                    tappable: false,
                    openElevation: 0,
                    closedElevation: 0,
                    openColor: Colors.transparent,
                    closedColor: Colors.transparent,
                    middleColor: Colors.transparent,
                    useRootNavigator: true,
                    transitionDuration: const Duration(milliseconds: 500),
                    openBuilder: (final context, final action) => Scaffold(
                      extendBodyBehindAppBar: true,
                      appBar: mainAppBar(
                        Theme.of(context),
                        leading: const FontIconBackButton(),
                      ),
                      body: WebView(
                        initialUrl: smAdvertisments.last.advLink,
                        javascriptMode: JavascriptMode.unrestricted,
                        navigationDelegate: (final navigation) =>
                            navigation.url.startsWith(smStretchingUrl)
                                ? NavigationDecision.navigate
                                : NavigationDecision.prevent,
                      ),
                    ),
                    closedBuilder: (final context, final action) => ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: InkWell(
                        overlayColor: MaterialStateProperty.all(Colors.black12),
                        highlightColor: Colors.black12,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        onTap: action,
                        child: CachedNetworkImage(
                          height: 200,
                          fit: BoxFit.fitWidth,
                          imageUrl: smAdvertisments.last.advImage,
                          imageBuilder: (final context, final imageProvider) =>
                              Ink(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: imageProvider,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          /// Empty state and nearest classes
          if (userRecords.isNotEmpty) ...<Widget>[
            /// Title
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 32),
              sliver: SliverToBoxAdapter(
                child: Text(
                  TR.homeClasses.tr(),
                  style: theme.textTheme.headline3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            /// Cards
            SliverPadding(
              padding: const EdgeInsets.only(top: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (final context, final index) {
                    final recordEntry = userRecords.entries.elementAt(index);
                    return ActivityCardContainer(
                      recordEntry.value,
                      onMain: true,
                      timeLeftBeforeStart:
                          recordEntry.key.date.difference(serverTime),
                    );
                  },
                  childCount: userRecords.length,
                ),
              ),
            ),
          ] else
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 50).copyWith(top: 32),
              sliver: SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    EmojiText(
                      '🤸',
                      style: const TextStyle(fontSize: 36),
                      textScaleFactor: mediaQuery.textScaleFactor,
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: mediaQuery.textScaleFactor <= 1
                            ? 280
                            : double.infinity,
                      ),
                      child: Text(
                        TR.homeClassesEmpty.tr(),
                        style: theme.textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// Prompt to authorize Or Sign Up For Training Button
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: TextButton(
                onPressed: unauthorized
                    ? () => Navigator.of(context, rootNavigator: true)
                        .pushNamed(Routes.auth.name)
                    : () async {
                        (ref.read(navigationProvider)).jumpToTab(
                          NavigationScreen.schedule.index,
                        );
                        await analytics.logEvent(name: FAKeys.homeGoToSchedule);
                      },
                style: (TextButtonStyle.light.fromTheme(theme)).copyWith(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.transparent,
                  ),
                ),
                child: Text(
                  (unauthorized ? TR.homeRegister : TR.homeApply).tr(),
                  style: theme.textTheme.button?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  textScaleFactor: mediaQuery.textScaleFactor.clamp(0, 1.2),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// The screen for watching [SMStoryModel].
class StoryCardScreen extends HookConsumerWidget {
  /// The screen for watching [SMStoryModel].
  const StoryCardScreen(final this.story, {final Key? key}) : super(key: key);

  /// The story to show on this screen.
  final SMStoryModel story;

  /// The [OpenContainer.transitionDuration] of this widget.
  static const Duration transitionDuration = Duration(milliseconds: 500);

  /// The size of this widget.
  static const double storySize = 96;

  /// The padding of this widget when watched.
  static const double storyInnerPadding = 6;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final alreadyWatched = ref.watch(
      homeWatchedStoriesProvider.select(
        (final watchedStories) => watchedStories
            .any((final watchedStory) => watchedStory.media == story.media),
      ),
    );

    return OpenContainer<void>(
      tappable: false,
      useRootNavigator: true,
      openElevation: 0,
      closedElevation: 0,
      openColor: Colors.transparent,
      closedColor: Colors.transparent,
      middleColor: Colors.transparent,
      transitionDuration: transitionDuration,
      openBuilder: (final context, final action) => Scaffold(
        body: Story(
          onFlashBack: action,
          onFlashForward: () async {
            action();
            if (!alreadyWatched) {
              await ref.read(homeWatchedStoriesProvider.notifier).add(story);
            }
          },
          progressSegmentPadding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 8),
          progressSegmentBuilder: ({
            required final context,
            required final index,
            required final progress,
          }) =>
              Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(1 / 2),
              borderRadius: BorderRadius.circular(1),
            ),
            child: Material(
              elevation: 1,
              color: Colors.transparent,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Material(color: theme.colorScheme.surface),
              ),
            ),
          ),
          stories: <StoryModel>[
            PhotoStory(story.mediaLink),
            if (story.storiesImgV2 != null)
              for (final image in story.storiesImgV2!)
                if (image.url.endsWith('.mp4'))
                  VideoStory(
                    VideoPlayerController.network(image.url),
                    onDownloaded: (final ref, final video) {
                      (ref.read(storyDurationProvider).state)
                          ?.call(video.duration);
                    },
                  )
                else
                  PhotoStory(image.url)
          ],
        ),
      ),
      closedBuilder: (final context, final action) {
        ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
          ref.read(storiesCardsProvider(story.media)).state = action;
        });
        return Container(
          height: storySize,
          width: storySize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: !alreadyWatched
                ? Border.all(color: const Color(0xFF5709FF))
                : null,
            borderRadius: const BorderRadius.all(Radius.circular(18)),
          ),
          child: InkWell(
            splashColor: theme.colorScheme.surface.withOpacity(1 / 5),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            onTap: () async {
              action();
              await analytics.logEvent(
                name: FAKeys.stories,
                parameters: <String, String>{
                  'content_title': translit(story.textPreview)
                },
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    story.mediaPreviewV2?.url ?? story.mediaLink,
                  ),
                ),
              ),
              child: Container(
                height: storySize - storyInnerPadding,
                width: storySize - storyInnerPadding,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
                child: Text(
                  story.textPreview,
                  style: theme.textTheme.overline?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onPrimary,
                  ),
                  textScaleFactor: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties..add(DiagnosticsProperty<SMStoryModel>('story', story)),
    );
  }
}
