import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:story_view/story_view.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models_smstretching/sm_story_model.dart';
import 'package:stretching/models_yclients/user_record_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/activities_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// The id converter of the [SMStoryModel].
final Provider<SMStoryIdConverter> smStoryIdConverterProvider =
    Provider<SMStoryIdConverter>((final ref) => SMStoryIdConverter._(ref));

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
        Iterable<SMStoryModel>>((final ref) {
  return SaveToHiveIterableNotifier<SMStoryModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'home_stories',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(smStoryIdConverterProvider)),
    ),
    defaultValue: const Iterable<SMStoryModel>.empty(),
  );
});

/// The screen for the [NavigationScreen.home].
class HomeScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.home].
  const HomeScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final unauthorized = ref.watch(unauthorizedProvider);

    final smAds = ref.watch(smAdvertismentsProvider);
    final smStories = ref.watch(smStoriesProvider).toList();
    final activities = ref.watch(combinedActivitiesProvider);
    final userRecords = <UserRecordModel, CombinedActivityModel>{
      for (final userRecord
          in ref.watch(userRecordsProvider).toList(growable: false)..sort())
        for (final activity in activities)
          if (!userRecord.deleted && userRecord.activityId == activity.item0.id)
            userRecord: activity
    };
    final serverTime = ref.watch(smServerTimeProvider);
    final refreshController = useMemoized(() => RefreshController());

    return SmartRefresher(
      controller: refreshController,
      onLoading: refreshController.loadComplete,
      onRefresh: () async {
        try {
          while (ref.read(connectionErrorProvider).state) {
            await Future<void>.delayed(const Duration(seconds: 1));
          }
          await Future.wait(<Future<void>>[
            ref.read(smStoriesProvider.notifier).refresh(),
            ref.read(smAdvertismentsProvider.notifier).refresh(),
            ref.read(userRecordsProvider.notifier).refresh(),
          ]);
        } finally {
          refreshController.refreshCompleted();
        }
      },
      child: CustomScrollView(
        primary: false,
        shrinkWrap: true,
        slivers: <Widget>[
          /// Stories
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(vertical: 16).copyWith(bottom: 0),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    for (final smStory in smStories) ...[
                      StoryCardScreen(smStory),
                      const SizedBox(width: 6)
                    ]
                  ].sublist(0, smStories.length * 2 - 1),
                ),
              ),
            ),
          ),

          /// Advertisment
          if (smAds.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16).copyWith(bottom: 0),
              sliver: SliverToBoxAdapter(
                child: OpenContainer<void>(
                  tappable: false,
                  openElevation: 0,
                  closedElevation: 0,
                  openColor: Colors.transparent,
                  closedColor: Colors.transparent,
                  middleColor: Colors.transparent,
                  useRootNavigator: true,
                  transitionDuration: const Duration(milliseconds: 500),
                  openBuilder: (final context, final action) {
                    return Scaffold(
                      extendBodyBehindAppBar: true,
                      appBar: mainAppBar(
                        Theme.of(context),
                        leading: const FontIconBackButton(),
                      ),
                      body: WebView(
                        initialUrl: smAds.last.advLink,
                        javascriptMode: JavascriptMode.unrestricted,
                        navigationDelegate: (final navigation) {
                          return navigation.url.startsWith(smStretchingUrl)
                              ? NavigationDecision.navigate
                              : NavigationDecision.prevent;
                        },
                      ),
                    );
                  },
                  closedBuilder: (final context, final action) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: CachedNetworkImage(
                        fit: BoxFit.fitWidth,
                        imageUrl: smAds.last.advImage,
                        imageBuilder: (final context, final imageProvider) {
                          return ElevatedButton(
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              shape: MaterialStateProperty.all(
                                const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                              ),
                              overlayColor: MaterialStateProperty.all(
                                Colors.black.withOpacity(1 / 10),
                              ),
                              elevation: MaterialStateProperty.all(8),
                              shadowColor: MaterialStateProperty.all(
                                Colors.black.withOpacity(1 / 2),
                              ),
                            ),
                            onPressed: action,
                            child: Ink(
                              height: 100,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: imageProvider,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

          /// Prompt to authorize
          if (unauthorized)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              sliver: SliverToBoxAdapter(
                child: TextButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true)
                      .pushNamed(Routes.auth.name),
                  style: TextButtonStyle.light.fromTheme(theme).copyWith(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                  child: Text(
                    TR.homeRegister.tr(),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
              ),
            )

          /// Empty state and nearest classes
          else ...[
            SliverPadding(
              padding: const EdgeInsets.all(16).copyWith(top: 32),
              sliver: SliverToBoxAdapter(
                child: Text(
                  TR.homeClasses.tr(),
                  style: theme.textTheme.headline3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (userRecords.isEmpty)
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                sliver: SliverToBoxAdapter(
                  child: Align(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Text(
                        TR.homeClassesEmpty.tr(),
                        style: theme.textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverList(
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
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: TextButton(
                  style: (TextButtonStyle.light.fromTheme(theme)).copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
                  onPressed: () => (ref.read(navigationProvider)).jumpToTab(
                    NavigationScreen.schedule.index,
                  ),
                  child: EmojiText(
                    '⚡️  ${TR.homeApply.tr()}',
                    style: theme.textTheme.button?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
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

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = useMemoized(() => StoryController());
    final alreadyWatched = ref.watch(
      homeWatchedStoriesProvider.select((final watchedStories) {
        return watchedStories.any((final watchedStory) {
          return watchedStory.media == story.media;
        });
      }),
    );
    return OpenContainer<void>(
      tappable: false,
      openElevation: 0,
      closedElevation: 0,
      openColor: Colors.transparent,
      closedColor: Colors.transparent,
      middleColor: Colors.transparent,
      useRootNavigator: true,
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: (final context, final action) => StoryView(
        controller: controller,
        onComplete: () async {
          action();
          if (!alreadyWatched) {
            await ref.read(homeWatchedStoriesProvider.notifier).add(story);
          }
        },
        storyItems: <StoryItem>[
          StoryItem.pageImage(
            url: story.mediaLink,
            controller: controller,
            duration: const Duration(milliseconds: 2500),
          ),
          if (story.storiesImgV2 != null)
            for (final img in story.storiesImgV2!)
              if (img.url.endsWith('.mp4'))
                StoryItem.pageVideo(
                  img.url,
                  controller: controller,
                  duration: const Duration(seconds: 10),
                )
              else
                StoryItem.pageImage(
                  url: img.url,
                  controller: controller,
                  duration: const Duration(milliseconds: 2500),
                )
        ],
        onVerticalSwipeComplete: (final direction) {
          if (direction == Direction.down) {
            action();
          }
        },
      ),
      closedBuilder: (final context, final action) => Container(
        height: 96,
        width: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: !alreadyWatched
              ? Border.all(color: const Color(0xFF5709FF))
              : null,
          borderRadius: const BorderRadius.all(Radius.circular(18)),
        ),
        child: ElevatedButton(
          onPressed: action,
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shape: MaterialStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            elevation: MaterialStateProperty.all(4),
          ),
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
              height: 90,
              width: 90,
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
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties..add(DiagnosticsProperty<SMStoryModel>('story', story)),
    );
  }
}
