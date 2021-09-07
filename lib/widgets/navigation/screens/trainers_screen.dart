import 'dart:math';

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
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/disposable_change_notifier_hook.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/models_yclients/trainer_model.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/smstretching_providers.dart';
import 'package:stretching/providers/yclients_providers.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/focus_wrapper.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/content_screen.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:stretching/widgets/navigation/components/filters.dart';
import 'package:stretching/widgets/navigation/components/scrollbar.dart';
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

    final search = useState<String>('');
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final searchKey = useMemoized(() => GlobalKey());

    final smTrainers = ref.watch(smTrainersProvider);
    late final bool areTrainersPresent;
    final trainers = ref.watch(
      /// Apply a filter to trainers.
      ///
      /// First of all, removes all undesired trainers from yClients trainers.
      /// Secondly, applies a text search by trainer's name.
      /// Thirdly, applies a filter by trainer's categories.
      /// And finally, removes dublicates.
      trainersProvider.select((final trainers) {
        areTrainersPresent = trainers.isNotEmpty;
        final categories = ref.watch(trainersCategoriesFilterProvider);
        return TrainersNotifier.normalizeTrainers(trainers)
            .where((final trainer) {
          return search.value.isEmpty ||
              trainer.name.toLowerCase().contains(search.value.toLowerCase());
        }).where((final trainer) {
          final smTrainersNull = smTrainers.cast<SMTrainerModel?>();
          final smTrainer = smTrainersNull.firstWhere(
            (final smTrainer) => smTrainer!.trainerId == trainer.id,
            orElse: () => null,
          );
          if (smTrainer == null) {
            return false;
          } else if (categories.isEmpty) {
            return true;
          } else {
            final trainerCategories = smTrainer.classesType?.toCategories();
            return trainerCategories?.any(categories.contains) ?? false;
          }
        }).distinct((final trainer) => trainer.name);
      }),
    );

    return FocusWrapper(
      unfocussableKeys: <GlobalKey>[searchKey],
      child: CustomDraggableScrollBar(
        itemsCount: trainers.length,
        visible: trainers.length > 6,
        leadingChildHeight:
            InputDecorationStyle.search.toolbarHeight + categoriesHeight + 20,
        trailingChildHeight: InputDecorationStyle.search.toolbarHeight,
        labelTextBuilder: (final index) {
          final trainer =
              trainers.elementAt(min((index + 1) & ~1, trainers.length - 1));
          return Text(
            trainer.name.isNotEmpty ? trainer.name[0].toUpperCase() : '-',
            style: theme.textTheme.subtitle2
                ?.copyWith(color: theme.colorScheme.surface),
          );
        },
        builder: (final context, final scrollController) {
          return CustomScrollView(
            shrinkWrap: true,
            controller: scrollController,
            slivers: <Widget>[
              const SliverPadding(padding: EdgeInsets.only(top: 20)),

              /// A search field and categories.
              SliverAppBar(
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
                    onChanged: (final value) => search.value = value,
                    decoration: InputDecorationStyle.search.fromTheme(
                      theme,
                      hintText: TR.trainersSearch.tr(),
                      onSuffix: () {
                        search.value = '';
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
                    (final context, final index) {
                      final trainer = trainers.elementAt(index);
                      return TrainerCard(
                        trainer,
                        smTrainers.firstWhere((final smTrainer) {
                          return smTrainer.trainerId == trainer.id;
                        }),
                      );
                    },
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
                          style: theme.textTheme.bodyText1,
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
          );
        },
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
    final this.trainer,
    final this.smTrainer, {
    final Key? key,
  }) : super(key: key);

  /// The trainer model from YClients API to display on this screen.
  final TrainerModel trainer;

  /// The trainer model from SMStretching API to display on this screen.
  final SMTrainerModel smTrainer;

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
          TrainerScreen(trainer, smTrainer, onBackButtonPressed: action),
      closedBuilder: (final context, final action) {
        return MaterialButton(
          onPressed: action,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: trainer.avatarBig,
                imageBuilder: (final context, final imageProvider) {
                  return CircleAvatar(
                    radius: 80,
                    foregroundImage: imageProvider,
                  );
                },
                placeholder: (final context, final url) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                errorWidget: (final context, final url, final dynamic error) =>
                    const FontIcon(FontIconData(IconsCG.logo)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8).copyWith(bottom: 0),
                  child: Text(
                    trainer.name,
                    style: theme.textTheme.bodyText1?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: theme.colorScheme.onSurface,
                    ),
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
        ..add(DiagnosticsProperty<TrainerModel>('trainer', trainer))
        ..add(DiagnosticsProperty<SMTrainerModel>('smTrainer', smTrainer)),
    );
  }
}

/// The screen to display a trainer.
class TrainerScreen extends HookWidget {
  /// The screen to show off a trainer.
  const TrainerScreen(
    final this.trainer,
    final this.smTrainer, {
    final this.onBackButtonPressed,
    final Key? key,
  }) : super(key: key);

  /// The trainer model from YClients API to display on this screen.
  final TrainerModel trainer;

  /// The trainer model from SMStretching API to display on this screen.
  final SMTrainerModel smTrainer;

  /// The callback on press of the back button.
  final void Function()? onBackButtonPressed;

  @override
  Widget build(final BuildContext context) {
    final videoPlayerController = useDisposableChangeNotifier(
      useMemoized(() async {
        final controller = VideoPlayerController.network(smTrainer.mediaPhoto);
        await controller.initialize();
        await controller.setLooping(true);
        await controller.play();
        return controller;
      }),
    );

    return ContentScreen(
      type: NavigationScreen.trainers,
      onBackButtonPressed: onBackButtonPressed,
      title: trainer.name,
      subtitle: (smTrainer.classesType?.toCategories())
              ?.map((final category) => category.translation)
              .join(', ') ??
          '',
      bottomButtons: BottomButtons<void>(
        inverse: true,
        direction: Axis.horizontal,
        firstText: TR.trainersIndividual.tr(),
        onFirstPressed: (final context) {},
      ),
      paragraphs: <Tuple2<String?, String>>[
        Tuple2(null, smTrainer.shortlyAbout)
      ],
      carousel: videoPlayerController == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : FittedBox(
              fit: BoxFit.fitWidth,
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
        ..add(DiagnosticsProperty<TrainerModel>('trainer', trainer))
        ..add(DiagnosticsProperty<SMTrainerModel>('smTrainer', smTrainer))
        ..add(
          ObjectFlagProperty<void Function()>.has(
            'onBackButtonPressed',
            onBackButtonPressed,
          ),
        ),
    );
  }
}
