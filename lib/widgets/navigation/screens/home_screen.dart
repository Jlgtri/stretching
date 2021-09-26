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
import 'package:stretching/hooks/refresh_content_hook.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models_smstretching/sm_story_model.dart';
import 'package:stretching/models_yclients/user_record_model.dart';
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

/// The scroll controller for the [StoryCardScreen] scrollable.
final Provider<ScrollController> storiesScrollControllerProvider =
    Provider<ScrollController>((final ref) {
  return ScrollController();
});

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

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
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
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(vertical: 16).copyWith(bottom: 0),
            sliver: SliverToBoxAdapter(
              child: LimitedBox(
                maxHeight: 96,
                child: ListView.builder(
                  cacheExtent: double.infinity,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  controller: storiesScrollController,
                  itemCount: smStories.length,
                  itemBuilder: (final context, final index) => Padding(
                    padding: index == smStories.length - 1
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(right: 6),
                    child: LimitedBox(
                      maxWidth: 96,
                      child: StoryCardScreen(smStories.elementAt(index)),
                    ),
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
                    openBuilder: (final context, final action) {
                      return Scaffold(
                        extendBodyBehindAppBar: true,
                        appBar: mainAppBar(
                          Theme.of(context),
                          leading: const FontIconBackButton(),
                        ),
                        body: WebView(
                          initialUrl: smAdvertisments.last.advLink,
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        child: InkWell(
                          overlayColor:
                              MaterialStateProperty.all(Colors.black12),
                          highlightColor: Colors.black12,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: action,
                          child: CachedNetworkImage(
                            height: 100,
                            fit: BoxFit.fitWidth,
                            imageUrl: smAdvertisments.last.advImage,
                            imageBuilder: (final context, final imageProvider) {
                              return Ink(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  image: DecorationImage(
                                    fit: BoxFit.fitWidth,
                                    image: imageProvider,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
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
          else ...<Widget>[
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
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
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

            /// Sign Up For Training Button
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: TextButton(
                  style: (TextButtonStyle.light.fromTheme(theme)).copyWith(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.transparent,
                    ),
                  ),
                  onPressed: () async {
                    (ref.read(navigationProvider)).jumpToTab(
                      NavigationScreen.schedule.index,
                    );
                    await analytics.logEvent(name: FAKeys.homeGoToSchedule);
                  },
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

  /// The [OpenContainer.transitionDuration] of this widget.
  static const Duration transitionDuration = Duration(milliseconds: 500);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = useMemoized(StoryController.new);
    final alreadyWatched = ref.watch(
      homeWatchedStoriesProvider.select((final watchedStories) {
        return watchedStories.any((final watchedStory) {
          return watchedStory.media == story.media;
        });
      }),
    );
    final stories = useMemoized(() {
      return <StoryItem>[
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
      ];
    });
    return OpenContainer<void>(
      tappable: false,
      openElevation: 0,
      closedElevation: 0,
      openColor: Colors.transparent,
      closedColor: Colors.transparent,
      middleColor: Colors.transparent,
      useRootNavigator: true,
      transitionDuration: transitionDuration,
      openBuilder: (final context, final action) => StoryView(
        controller: controller,
        onComplete: () async {
          action();
          if (!alreadyWatched) {
            await ref.read(homeWatchedStoriesProvider.notifier).add(story);
          }
        },
        onStoryShow: (final story) {
          if (stories.length == 1) {
            controller.next();
          }
        },
        storyItems: stories,
        onVerticalSwipeComplete: (final direction) {
          if (direction == Direction.down) {
            action();
          }
        },
      ),
      closedBuilder: (final context, final action) {
        ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
          ref.read(storiesCardsProvider(story.media)).state = action;
        });
        return Container(
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
            onPressed: () async {
              action();
              await analytics.logEvent(
                name: FAKeys.stories,
                parameters: <String, String>{
                  'content_title': translit(story.textPreview)
                },
              );
            },
            style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              shape: MaterialStateProperty.all(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              elevation: MaterialStateProperty.all(0),
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
