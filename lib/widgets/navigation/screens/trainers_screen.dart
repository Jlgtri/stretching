import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:darq/darq.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/disposable_change_notifier_hook.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/models_yclients/trainer_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/focus_wrapper.dart';
import 'package:stretching/widgets/content_screen.dart';
import 'package:stretching/widgets/navigation/components/filters.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The provider of filters for [SMTrainerModel].
final StateNotifierProvider<SaveToHiveIterableNotifier<ClassCategory, String>,
        Iterable<ClassCategory>> trainersCategoriesFilterProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<ClassCategory, String>,
        Iterable<ClassCategory>>((final ref) {
  return SaveToHiveIterableNotifier<ClassCategory, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'trainers_categories',
    converter: const StringToIterableConverter(
      IterableConverter(EnumConverter<ClassCategory>(ClassCategory.values)),
    ),
    defaultValue: const Iterable<ClassCategory>.empty(),
  );
});

/// Provider of the search value on trainers screen.
final StateProvider<String> searchTrainersProvider =
    StateProvider<String>((final ref) => '');

/// Provider of the normalized trainers with applied filters.
final Provider<Iterable<CombinedTrainerModel>> filteredTrainersProvider =
    Provider<Iterable<CombinedTrainerModel>>((final ref) {
  return ref.watch(
    /// Apply a filter to trainers.
    ///
    /// First of all, removes all undesired trainers from yClients trainers.
    /// Secondly, applies a text search by trainer's name.
    /// Thirdly, applies a filter by trainer's categories.
    /// And finally, removes dublicates.
    trainersProvider.select((final trainers) {
      final categories = ref.watch(trainersCategoriesFilterProvider);
      final search = ref.watch(searchTrainersProvider).state;
      return ref.watch(combinedTrainersProvider).where((final trainer) {
        return search.isEmpty ||
            (trainer.item1.trainerName.toLowerCase())
                .contains(search.toLowerCase());
      }).where((final trainer) {
        if (categories.isEmpty) {
          return true;
        } else {
          final trainerCategories = trainer.item1.classesType?.toCategories();
          return trainerCategories?.any(categories.contains) ?? false;
        }
      }).distinct((final trainer) => trainer.item1.trainerName.toLowerCase());
    }),
  );
});

/// The screen for the [NavigationScreen.trainers].
class TrainersScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.trainers].
  const TrainersScreen({final Key? key}) : super(key: key);

  /// The height of the categories picker widget.
  static const double categoriesHeight = 84;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(trainersCategoriesFilterProvider);

    final refreshController = useMemoized(() => RefreshController());
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final searchKey = useMemoized(() => GlobalKey());

    final areTrainersPresent = ref.watch(
      combinedTrainersProvider.select((final trainers) => trainers.isNotEmpty),
    );
    final trainers = ref.watch(filteredTrainersProvider);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return FocusWrapper(
      unfocussableKeys: <GlobalKey>[searchKey],
      child:
          // CustomDraggableScrollBar(
          //   itemsCount: trainers.length,
          //   visible: trainers.length > 6,
          //   leadingChildHeight:
          //       InputDecorationStyle.search.toolbarHeight + categoriesHeight + 20,
          //   trailingChildHeight: InputDecorationStyle.search.toolbarHeight,
          //   labelTextBuilder: (final index) {
          //     final trainer =
          //         trainers.elementAt(min((index + 1) & ~1, trainers.length - 1));
          //     return Text(
          //       trainer.item1.trainerName.isNotEmpty
          //           ? trainer.item1.trainerName[0].toUpperCase()
          //           : '-',
          //       style: theme.textTheme.subtitle2
          //           ?.copyWith(color: theme.colorScheme.surface),
          //     );
          //   },
          //   builder: (final context, final scrollController, final resetPosition) {
          //     return
          SmartRefresher(
        controller: refreshController,
        onLoading: refreshController.loadComplete,
        onRefresh: () async {
          await Future.wait(<Future<void>>[
            ref.read(trainersProvider.notifier).refresh(),
            ref.read(smTrainersProvider.notifier).refresh()
          ]);
          refreshController.refreshCompleted();
        },
        child: CustomScrollView(
          shrinkWrap: true,
          cacheExtent: double.infinity,
          controller: ModalScrollController.of(context),
          slivers: <Widget>[
            const SliverPadding(padding: EdgeInsets.only(top: 20)),

            /// A search field and categories.
            SliverAppBar(
              key: UniqueKey(),
              primary: false,
              backgroundColor: Colors.transparent,
              toolbarHeight: InputDecorationStyle.search.toolbarHeight,
              titleSpacing: 12,
              title: Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                child: TextField(
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
                  ),
                ),
              ),
              bottom: categories.getSelectorWidget(
                theme,
                (final category, final value) {
                  final categoriesNotifier = ref.read(
                    trainersCategoriesFilterProvider.notifier,
                  );
                  value
                      ? categoriesNotifier.add(category)
                      : categoriesNotifier.remove(category);
                },
              ),
            ),

            /// The list of trainers.
            if (trainers.isNotEmpty)
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  mainAxisExtent: 210,
                ),
                delegate: SliverChildBuilderDelegate(
                  (final context, final index) =>
                      TrainerCard(trainers.elementAt(index)),
                  childCount: trainers.length,
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
            SliverPadding(
              padding: EdgeInsets.only(
                top: InputDecorationStyle.search.toolbarHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The card to display a trainer.
///
/// Initially shows just a card, but opens [TrainerScreen] when pressed.
class TrainerCard extends StatelessWidget {
  /// The card to display a trainer.
  ///
  /// Initially shows just a card, but opens [TrainerScreen] when pressed.
  const TrainerCard(
    final this.trainer, {
    final Key? key,
  }) : super(key: key);

  /// The trainer model from YClients API to display on this screen.
  final CombinedTrainerModel trainer;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer<void>(
      tappable: false,
      openElevation: 0,
      closedElevation: 0,
      openColor: Colors.transparent,
      closedColor: Colors.transparent,
      middleColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: (final context, final action) =>
          TrainerScreen(trainer, onBackButtonPressed: action),
      closedBuilder: (final context, final action) {
        return MaterialButton(
          onPressed: action,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: trainer.item1.trainerPhoto,
                imageBuilder: (final context, final imageProvider) {
                  return CircleAvatar(
                    radius: 80,
                    foregroundImage: imageProvider,
                  );
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8).copyWith(bottom: 0),
                  child: Text(
                    trainer.item1.trainerName,
                    style: theme.textTheme.subtitle2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
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
        await controller.setLooping(true);
        await controller.play();
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
      paragraphs: <Tuple2<String?, String>>[
        Tuple2(null, trainer.item1.shortlyAbout)
      ],
      carousel: videoPlayerController == null
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
