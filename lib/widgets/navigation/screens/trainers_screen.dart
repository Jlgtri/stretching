import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:darq/darq.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/disposable_change_notifier_hook.dart';
import 'package:stretching/hooks/refresh_content_hook.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models/smstretching/sm_classes_gallery_model.dart';
import 'package:stretching/models/smstretching/sm_trainer_model.dart';
import 'package:stretching/models/yclients/trainer_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/content_provider.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/focus_wrapper.dart';
import 'package:stretching/widgets/components/limit_loading_count.dart';
import 'package:stretching/widgets/content_screen.dart';
import 'package:stretching/widgets/navigation/components/filters.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The provider of filters for [SMTrainerModel].
final StateNotifierProvider<SaveToHiveIterableNotifier<ClassCategory, String>,
        Iterable<ClassCategory>> trainersCategoriesFilterProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<ClassCategory, String>,
        Iterable<ClassCategory>>(
  (final ref) => SaveToHiveIterableNotifier<ClassCategory, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'trainers_categories',
    converter: const StringToIterableConverter(
      IterableConverter(EnumConverter(ClassCategory.values)),
    ),
    defaultValue: const Iterable<ClassCategory>.empty(),
  ),
);

/// Provider of the search value on trainers screen.
final StateProvider<String> searchTrainersProvider =
    StateProvider<String>((final ref) => '');

/// Provider of the normalized trainers with applied filters.
///
/// First of all, removes all undesired trainers from yClients trainers.
/// Secondly, applies a text search by trainer's name.
/// Thirdly, applies a filter by trainer's categories.
/// And finally, removes dublicates.
final Provider<Iterable<CombinedTrainerModel>> filteredTrainersProvider =
    Provider<Iterable<CombinedTrainerModel>>((final ref) {
  final categories = ref.watch(trainersCategoriesFilterProvider);
  final search = ref.watch(searchTrainersProvider).state;
  return (ref.watch(combinedTrainersProvider))
      .where(
        (final trainer) =>
            (search.isEmpty ||
                (trainer.item1.trainerName.toLowerCase())
                    .contains(search.toLowerCase())) &&
            (categories.isEmpty ||
                ((trainer.item1.classesType?.toCategories())
                        ?.any(categories.contains) ??
                    false)),
      )
      .distinct((final trainer) => trainer.item1.trainerName.toLowerCase());
});

/// The [OpenContainer.openBuilder] provider of the [TrainerContainer] for each
/// [CombinedTrainerModel].
final StateProviderFamily<void Function()?, CombinedTrainerModel>
    trainersCardsProvider =
    StateProvider.family<void Function()?, CombinedTrainerModel>(
  (final ref, final trainer) => null,
);

/// The screen for the [NavigationScreen.trainers].
class TrainersScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.trainers].
  const TrainersScreen({final Key? key}) : super(key: key);

  /// The maximum count of simultaneously loading trainers.
  static const int limitLoading = 10;

  /// The height of the categories picker widget.
  static const double categoriesHeight = 80;

  /// The cross-axis count of trainers on this screen.
  static const int crossAxisCount = 2;

  /// The main-axis spacing of the trainers on this screen.
  static const double mainAxisSpacing = 16;

  /// The cross-axis spacing of the trainers on this screen.
  static const double crossAxisSpacing = 12;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final searchKey = useMemoized(GlobalKey.new);
    final refresh = useRefreshController(
      extraRefresh: () async {
        while (ref.read(connectionErrorProvider).state) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      },
      notifiers: <ContentNotifier>[
        ref.read(trainersProvider.notifier),
        ref.read(smTrainersProvider.notifier),
      ],
    );

    final trainers = ref.watch(filteredTrainersProvider);
    final areTrainersPresent = ref.watch(
      combinedTrainersProvider.select((final trainers) => trainers.isNotEmpty),
    );
    final scrollController = ref.watch(
      navigationScrollControllerProvider(NavigationScreen.trainers),
    );

    return FocusWrapper(
      unfocussableKeys: <GlobalKey>[searchKey],
      child:
          // CustomDraggableScrollBar(
          //   itemsCount: trainers.length,
          //   visible: trainers.length > 6,
          //   leadingChildHeight:
          //  InputDecorationStyle.search.toolbarHeight + categoriesHeight + 20,
          //   trailingChildHeight: InputDecorationStyle.search.toolbarHeight,
          //   labelTextBuilder: (final index) {
          //     final trainer =
          //     trainers.elementAt(min((index + 1) & ~1, trainers.length - 1));
          //     return Text(
          //       trainer.item1.trainerName.isNotEmpty
          //           ? trainer.item1.trainerName[0].toUpperCase()
          //           : '-',
          //       style: theme.textTheme.subtitle2
          //           ?.copyWith(color: theme.colorScheme.surface),
          //     );
          //   },
          //  builder: (final context, final scrollController,
          //  final resetPosition) {
          //     return
          SmartRefresher(
        controller: refresh.item0,
        onLoading: refresh.item0.loadComplete,
        onRefresh: refresh.item1,
        scrollController: scrollController,
        child: CustomScrollView(
          shrinkWrap: true,
          controller: scrollController,
          slivers: <Widget>[
            const SliverPadding(padding: EdgeInsets.only(top: 20)),

            /// A search field and categories.
            SliverAppBar(
              primary: false,
              backgroundColor: Colors.transparent,
              toolbarHeight: 40,
              titleSpacing: 16,
              title: TextField(
                key: searchKey,
                cursorColor: theme.hintColor,
                style: theme.textTheme.bodyText2,
                controller: searchController,
                focusNode: searchFocusNode,
                onChanged: (final value) =>
                    ref.read(searchTrainersProvider).state = value,
                decoration: InputDecorationStyle.search.fromTheme(
                  theme,
                  hintText: TR.trainersSearch.tr(),
                  onSuffix: () {
                    ref.read(searchTrainersProvider).state = '';
                    searchController.clear();
                    searchFocusNode.unfocus();
                  },
                ).copyWith(
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  disabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(maxWidth: 45, maxHeight: 24),
                ),
              ),
              bottom: getSelectorWidget<ClassCategory>(
                values: ClassCategory.values,
                text: (final value) => value.translation,
                selected: (final value) =>
                    ref.read(trainersCategoriesFilterProvider).contains(value),
                onSelected: (final category, final value) {
                  final categoriesNotifier = ref.read(
                    trainersCategoriesFilterProvider.notifier,
                  );
                  (value
                      ? categoriesNotifier.add
                      : categoriesNotifier.remove)(category);
                },
              ),
            ),

            /// The list of trainers.
            if (trainers.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing,
                    mainAxisExtent: TrainerCard.height(theme, mediaQuery),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (final context, final index) => Align(
                      alignment: index.isEven
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: TrainerContainer(trainers.elementAt(index)),
                    ),
                    childCount: trainers.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      EmojiText(
                        areTrainersPresent ? '🤔' : '🧘‍♀️',
                        style: const TextStyle(fontSize: 30),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        areTrainersPresent
                            ? TR.trainersEmpty.tr()
                            : TR.miscEmpty.tr(),
                        style: theme.textTheme.subtitle2,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(top: 40)),
          ],
        ),
      ),
    );
  }
}

/// The card to display a [trainer].
///
/// Initially shows just a card, but opens [TrainerScreen] when pressed.
class TrainerContainer extends ConsumerWidget {
  /// The card to display a [trainer].
  ///
  /// Initially shows just a card, but opens [TrainerScreen] when pressed.
  const TrainerContainer(
    final this.trainer, {
    final Key? key,
  }) : super(key: key);

  /// The trainer model from YClients API to display on this screen.
  final CombinedTrainerModel trainer;

  /// The [OpenContainer.transitionDuration] of this widget.
  static const Duration transitionDuration = Duration(milliseconds: 500);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) =>
      OpenContainer<void>(
        tappable: false,
        openElevation: 0,
        closedElevation: 0,
        openColor: Colors.transparent,
        closedColor: Colors.transparent,
        middleColor: Colors.transparent,
        transitionDuration: transitionDuration,
        openBuilder: (final context, final action) =>
            TrainerScreen(trainer, onBackButtonPressed: action),
        closedBuilder: (final context, final action) =>
            TrainerCard(trainer, onPressed: action),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<CombinedTrainerModel>('trainer', trainer)),
    );
  }
}

/// The card to display a [trainer].
class TrainerCard extends HookConsumerWidget {
  /// The card to display a [trainer].
  const TrainerCard(
    final this.trainer, {
    required final this.onPressed,
    final Key? key,
  }) : super(key: key);

  /// The trainer to display in this card.
  final CombinedTrainerModel trainer;

  /// The callback on press of the back button.
  final void Function() onPressed;

  /// The font of the name of the trainer of this widget.
  static TextStyle? trainerFont(final TextTheme textTheme) =>
      textTheme.subtitle2;

  /// The inner padding of this widget.
  static const EdgeInsetsGeometry padding = EdgeInsets.only(bottom: 8);

  /// The padding of the avatar of this widget.
  static const EdgeInsetsGeometry avatarPadding = EdgeInsets.all(8);

  /// The maximum count of lines for the name of the trainer.
  static const int maxLines = 2;

  /// The diameter of the avatar of this widget.
  static const double avatarSize = 160;

  /// The overall height of this widget.
  static double height(final ThemeData theme, final MediaQueryData mediaQuery) {
    final font = trainerFont(theme.textTheme)!;
    return (padding.vertical + avatarSize + avatarPadding.vertical) +
        font.fontSize! * font.height! * maxLines * mediaQuery.textScaleFactor;
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    useMemoized(() {
      final trainerContainer = ref.read(trainersCardsProvider(trainer));
      ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
        trainerContainer.state = onPressed;
      });
    });
    final loaded = ref.watch(
      loadedDataProvider(NavigationScreen.trainers).select(
        (final loadedDataProvider) =>
            loadedDataProvider.state.contains(trainer.item1.trainerPhoto),
      ),
    );
    final loadingTrainersCount = ref.watch(
      loadingDataProvider(NavigationScreen.trainers).select(
        (final loadingDataProvider) => loadingDataProvider.state.length,
      ),
    );
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: avatarPadding,
              child: loaded ||
                      (loadingTrainersCount <= TrainersScreen.limitLoading)
                  ? CachedNetworkImage(
                      imageUrl: trainer.item1.trainerPhoto,
                      height: avatarSize,
                      width: avatarSize,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (
                        final context,
                        final url,
                        final progress,
                      ) =>
                          LimitLoadingCount(url, NavigationScreen.trainers),
                      imageBuilder: (final context, final imageProvider) =>
                          CircleAvatar(
                        radius: avatarSize / 2,
                        foregroundImage: imageProvider,
                      ),
                      errorWidget:
                          (final context, final url, final dynamic error) =>
                              const SizedBox.shrink(),
                    )
                  : const SizedBox(width: avatarSize, height: avatarSize),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  trainer.item1.trainerName,
                  style: trainerFont(theme.textTheme),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(ObjectFlagProperty<void Function()>.has('onPressed', onPressed))
        ..add(DiagnosticsProperty<CombinedTrainerModel>('trainer', trainer)),
    );
  }
}

/// The screen to display a trainer.
class TrainerScreen extends HookWidget {
  /// The screen to show off a trainer.
  const TrainerScreen(
    final this.trainer, {
    final this.onBackButtonPressed,
    final this.upperType = NavigationScreen.trainers,
    final Key? key,
  }) : super(key: key);

  /// The pair of [TrainerModel] and [SMTrainerModel] to display on this screen.
  final CombinedTrainerModel trainer;

  /// The callback on press of the back button.
  final void Function()? onBackButtonPressed;

  /// The type of the screen one level up on this one.
  final NavigationScreen? upperType;

  @override
  Widget build(final BuildContext context) {
    final videoPlayerController = useDisposableChangeNotifier(
      useMemoized(() async {
        final controller =
            VideoPlayerController.network(trainer.item1.mediaPhoto);
        await controller.initialize();
        await controller.play();
        await controller.setLooping(true);
        return controller;
      }),
    );

    return ContentScreen(
      type: upperType,
      onBackButtonPressed: onBackButtonPressed,
      title: trainer.item0.name,
      subtitle: (trainer.item1.classesType?.toCategories())
              ?.map((final category) => category.translation)
              .join(', ') ??
          '',
      // bottomButtons: BottomButtons<void>(
      //   inverse: true,
      //   direction: Axis.horizontal,
      //   firstText: TR.trainersIndividual.tr(),
      //   onFirstPressed: (final context) {},
      // ),
      carouselHeight: 400,
      paragraphs: <ContentParagraph>[
        ContentParagraph(
          expandable: false,
          body: trainer.item1.shortlyAbout,
        )
      ],
      carousel: videoPlayerController == null ||
              !videoPlayerController.value.isInitialized
          ? const Center(child: CircularProgressIndicator.adaptive())
          : FittedBox(
              fit: BoxFit.cover,
              child: SizedBox.fromSize(
                size: videoPlayerController.value.size,
                child: AspectRatio(
                  aspectRatio: videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(videoPlayerController),
                ),
              ),
            ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<CombinedTrainerModel>('trainer', trainer))
        ..add(
          ObjectFlagProperty<void Function()>.has(
            'onBackButtonPressed',
            onBackButtonPressed,
          ),
        )
        ..add(EnumProperty<NavigationScreen>('upperType', upperType)),
    );
  }
}
