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
import 'package:stretching/models_yclients/user_record_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/activities_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    final controller = useMemoized(() => StoryController());
    final refreshController = useMemoized(() => RefreshController());

    Widget stories(
      final String title,
      final Iterable<String> imageUrls, {
      final Gradient? gradient,
    }) {
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
          onComplete: action,
          storyItems: <StoryItem>[
            for (final imageUrl in imageUrls)
              StoryItem.pageImage(
                url: imageUrl,
                controller: controller,
                duration: const Duration(milliseconds: 2500),
              ),
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
            border: Border.all(color: const Color(0xFF5709FF)),
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
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              child: Container(
                height: 90,
                width: 90,
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Text(
                  title,
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
                    if (smStories.isNotEmpty)
                      stories(
                        TR.homeStoriesDiscount.tr(),
                        <String>[smStories.first.mediaLink],
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFF9FA5E3), Color(0xFFE59BD6)],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                    if (smStories.length > 1) ...[
                      const SizedBox(width: 6),
                      stories(
                        TR.homeStoriesWishlist.tr(),
                        <String>[smStories[1].mediaLink],
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFFD362AD), Color(0xFF8DDBF3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ],
                    if (smStories.length > 2) ...[
                      const SizedBox(width: 6),
                      stories(
                        TR.homeStoriesSupport.tr(),
                        <String>[smStories[2].mediaLink],
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFFB9506E), Color(0xFFB9506E)],
                        ),
                      ),
                    ],
                    if (smStories.length > 3) ...[
                      const SizedBox(width: 6),
                      stories(
                        TR.homeStoriesFreeActivity.tr(),
                        <String>[smStories[3].mediaLink],
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFF534A87), Color(0xFF534A87)],
                        ),
                      ),
                    ],
                  ],
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
