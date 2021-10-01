import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/hooks/on_disposed_hook.dart';
import 'package:stretching/providers/other_providers.dart';

/// Callback function that accepts the index of moment and
/// returns its' Duration
typedef MomentDurationGetter = Duration Function(int? index) Function(
  Duration Function(Duration Function(int? index)) duration,
);

/// Builder function that accepts current build context, moment index,
/// moment progress and gap between each segment and returns widget for segment
typedef ProgressSegmentBuilder = Widget Function({
  required BuildContext context,
  required int index,
  required double progress,
});

/// The provider for changing duration of the [Story] controller.
final StateProvider<void Function(Duration)?> storyDurationProvider =
    StateProvider<void Function(Duration)?>((final ref) => null);

/// Widget that allows you to use stories mechanism in your apps
///
/// **Usage:**
///
/// ```dart
/// Story(
///   onFlashForward: Navigator.of(context).pop,
///   onFlashBack: Navigator.of(context).pop,
///   momentCount: 4,
///   momentDurationGetter: (idx) => Duration(seconds: 4),
///   momentBuilder: (context, idx) {
///     return Container(
///       color: CupertinoColors.destructiveRed,
///       child: Center(
///         child: Text(
///           'Moment ${idx + 1}',
///           style: TextStyle(color: CupertinoColors.white),
///         ),
///       ),
///     );
///   },
/// )
/// ```
class Story extends HookConsumerWidget {
  /// Widget that allows you to use stories mechanism in your apps.
  const Story({
    required final this.stories,
    final this.onFlashForward,
    final this.onFlashBack,
    final this.progressSegmentBuilder = Story.instagramProgressSegmentBuilder,
    final this.progressSegmentPadding = const EdgeInsets.all(8),
    final this.progressOpacityDuration = const Duration(milliseconds: 300),
    final this.momentSwitcherFraction = 0.33,
    final this.startAt = 0,
    final this.fullscreen = true,
    final Key? key,
  })  : assert(stories.length > 0, 'There should be at least one story.'),
        assert(
          startAt >= 0 && startAt <= stories.length - 1,
          'The starting widget index should be in bounds with stories count.',
        ),
        assert(
          momentSwitcherFraction >= 0 &&
              momentSwitcherFraction < double.infinity,
          'The moment switcher fraction should be greater or equal to zero.',
        ),
        super(key: key);

  /// The total count of moments in a story.
  final Iterable<StoryModel> stories;

  /// Gets executed when user taps the right portion of the screen on the last
  /// moment in story or when story finishes playing.
  final VoidCallback? onFlashForward;

  /// Gets executed when user taps the left portion of the screen on the
  /// first moment in story.
  final VoidCallback? onFlashBack;

  /// The ratio of left and right tappable portions of the screen:
  /// - left for switching back,
  /// - right for switching forward.
  final double momentSwitcherFraction;

  /// Builder of the progress segment.
  ///
  /// Defaults to [instagramProgressSegmentBuilder].
  final ProgressSegmentBuilder progressSegmentBuilder;

  /// The outer padding of the [progressSegmentBuilder].
  final EdgeInsets progressSegmentPadding;

  /// Sets the duration for the progress bar show/hide animation
  final Duration progressOpacityDuration;

  /// Sets the index of the first moment that will be displayed
  final int startAt;

  /// Controls fullscreen behavior
  final bool fullscreen;

  /// The default progress segment builder.
  static Widget instagramProgressSegmentBuilder({
    required final BuildContext context,
    required final int index,
    required final double progress,
  }) =>
      Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(1 / 2),
          borderRadius: BorderRadius.circular(1),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(color: Colors.black),
        ),
      );

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    Future<void> hideStatusBar() => SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: const <SystemUiOverlay>[],
        );

    Future<void> showStatusBar() => SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );

    final currentIndex = useState(startAt);
    StoryModel currentStory() => stories.elementAt(currentIndex.value);
    final animationController = useAnimationController(
      duration: currentStory().duration,
    );
    final isFullscreen = useState<bool>(false);

    Future<void> switchToNextOrFinish() async {
      animationController.stop();
      if (currentIndex.value + 1 >= stories.length) {
        (onFlashForward?.call ?? Navigator.of(context).maybePop)();
      } else {
        currentIndex.value++;
        (animationController..reset()).duration = currentStory().duration;
        await animationController.forward();
      }
    }

    Future<void> switchToPrevOrFinish() async {
      animationController.stop();
      if (currentIndex.value - 1 < 0) {
        (onFlashBack?.call ?? Navigator.of(context).maybePop)();
      } else {
        currentIndex.value--;
        (animationController..reset()).duration = currentStory().duration;
        await animationController.forward();
      }
    }

    useMemoized(
      () async => fullscreen ? await hideStatusBar() : await showStatusBar(),
      [fullscreen],
    );

    useMemoized(
      () async {
        ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
          ref.read(storyDurationProvider).state = (final duration) =>
              ((animationController..reset())..duration = duration).forward();
        });
        animationController.addStatusListener((final status) async {
          if (status == AnimationStatus.completed) {
            await switchToNextOrFinish();
          }
        });
        await animationController.forward();
      },
      [animationController],
    );

    final container = useMemoized(() => ProviderScope.containerOf(context));
    useOnDisposed(() {
      container.read(widgetsBindingProvider).addPostFrameCallback((final _) {
        container.read(storyDurationProvider).state = null;
      });
      if (fullscreen) {
        showStatusBar();
      }
    });

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        currentStory(),
        Padding(
          padding: progressSegmentPadding + MediaQuery.of(context).viewPadding,
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              opacity: isFullscreen.value ? 0 : 1,
              duration: progressOpacityDuration,
              child: Row(
                children: <Widget>[
                  for (var index = 0; index < stories.length; index++)
                    Expanded(
                      child: index == currentIndex.value
                          ? AnimatedBuilder(
                              animation: animationController,
                              builder: (final context, final child) {
                                return progressSegmentBuilder(
                                  context: context,
                                  index: index,
                                  progress: animationController.value,
                                );
                              },
                            )
                          : progressSegmentBuilder(
                              context: context,
                              index: index,
                              progress: index < currentIndex.value ? 1.0 : 0.0,
                            ),
                    )
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTapDown: (final details) => animationController.stop(),
          onTapUp: (final details) {
            final width = MediaQuery.of(context).size.width;
            if (details.localPosition.dx < width * momentSwitcherFraction) {
              switchToPrevOrFinish();
            } else {
              switchToNextOrFinish();
            }
          },
          onLongPress: () {
            isFullscreen.value = true;
            animationController.stop();
          },
          onLongPressUp: () async {
            isFullscreen.value = false;
            await animationController.forward();
          },
        ),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(IterableProperty<StoryModel>('stories', stories))
        ..add(
          ObjectFlagProperty<VoidCallback?>.has(
            'onFlashForward',
            onFlashForward,
          ),
        )
        ..add(ObjectFlagProperty<VoidCallback?>.has('onFlashBack', onFlashBack))
        ..add(DoubleProperty('momentSwitcherFraction', momentSwitcherFraction))
        ..add(
          ObjectFlagProperty<ProgressSegmentBuilder>.has(
            'progressSegmentBuilder',
            progressSegmentBuilder,
          ),
        )
        ..add(
          DiagnosticsProperty<EdgeInsetsGeometry>(
            'progressSegmentPadding',
            progressSegmentPadding,
          ),
        )
        ..add(
          DiagnosticsProperty<Duration>(
            'progressOpacityDuration',
            progressOpacityDuration,
          ),
        )
        ..add(IntProperty('startAt', startAt))
        ..add(DiagnosticsProperty<bool>('fullscreen', fullscreen)),
    );
  }
}

/// The widget for showing a story.
abstract class StoryModel extends HookConsumerWidget {
  /// The widget for showing a story.
  const StoryModel(final this.url, {final Key? key}) : super(key: key);

  /// The url of this story.
  final String url;

  /// The duration of this story.
  Duration get duration;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(StringProperty('url', url))
        ..add(DiagnosticsProperty<Duration>('duration', duration)),
    );
  }
}

/// The widget with a blank story.
class PlaceholderStory extends StoryModel {
  /// The widget with a blank story.
  const PlaceholderStory({final Key? key}) : super('', key: key);

  @override
  Duration get duration => Duration.zero;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) =>
      const Center(child: CircularProgressIndicator.adaptive());
}

/// The widget for showing a photo story.
class PhotoStory extends StoryModel {
  /// The widget for showing a photo story.
  const PhotoStory(
    final String url, {
    final this.duration = const Duration(seconds: 3),
    final Key? key,
  }) : super(url, key: key);

  @override
  final Duration duration;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (final context, final url) => const PlaceholderStory(),
    );
  }
}

/// The widget for showing a video story.
class VideoStory extends StoryModel {
  /// The widget for showing a video story.
  VideoStory(
    final this.videoPlayerController, {
    final this.onDownloaded,
    final Key? key,
  }) : super(videoPlayerController.dataSource, key: key);

  /// The controller of this video story.
  final VideoPlayerController videoPlayerController;

  /// The callback to call when video is downloaded.
  final FutureOr<void> Function(WidgetRef ref, VideoPlayerValue video)?
      onDownloaded;

  @override
  Duration get duration {
    final duration = videoPlayerController.value.duration;
    return duration == Duration.zero ? const Duration(days: 365) : duration;
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final videoPlayerControllerSnapshot = useFuture(
      useMemoized(() async {
        if (!videoPlayerController.value.isInitialized) {
          await videoPlayerController.initialize();
          await videoPlayerController.setLooping(true);
          await videoPlayerController.play();
        }
        return videoPlayerController;
      }),
    );
    final _videoPlayerController = videoPlayerControllerSnapshot.data;

    final isMounted = useIsMounted();
    useMemoized<void>(
      () => (ref.read(widgetsBindingProvider))
          .addPostFrameCallback((final _) async {
        if (isMounted() &&
            _videoPlayerController != null &&
            _videoPlayerController.value.isInitialized) {
          await onDownloaded?.call(ref, _videoPlayerController.value);
        }
      }),
      [_videoPlayerController?.value.isInitialized ?? false],
    );

    return _videoPlayerController == null ||
            !_videoPlayerController.value.isInitialized
        ? const PlaceholderStory()
        : FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.topCenter,
            child: SizedBox.fromSize(
              size: _videoPlayerController.value.size,
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              ),
            ),
          );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(
          DiagnosticsProperty<VideoPlayerController>(
            'videoPlayerController',
            videoPlayerController,
          ),
        )
        ..add(
          ObjectFlagProperty<
              FutureOr<void> Function(
            WidgetRef ref,
            VideoPlayerValue video,
          )>.has(
            'onDownloaded',
            onDownloaded,
          ),
        ),
    );
  }
}
