import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:darq/darq.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models/categories_enum.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/smstretching_providers.dart';
import 'package:stretching/providers/yclients_providers.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/components/focus_wrapper.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The provider of filters for [SMTrainerModel].
final StateNotifierProvider<SaveToHiveIterableNotifier<ClassCategory, String>,
        Iterable<ClassCategory>> trainersCategoryFilterProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<ClassCategory, String>,
        Iterable<ClassCategory>>((final ref) {
  return SaveToHiveIterableNotifier<ClassCategory, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'trainers_categories',
    converter: const StringToIterableConverter(
      IterableConverter(
        EnumConverter<ClassCategory>(ClassCategory.values),
      ),
    ),
    defaultValue: const Iterable<ClassCategory>.empty(),
  );
});

/// The screen for the [NavigationScreen.trainers].
class TrainersScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.trainers].
  const TrainersScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(trainersCategoryFilterProvider);

    final search = useState<String>('');
    final scrollController = useScrollController();
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final searchKey = useMemoized(() => GlobalKey());
    final scrollNotificationExample = useRef<ScrollUpdateNotification?>(null);

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
        final categories = ref.watch(trainersCategoryFilterProvider);
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

    Widget filterButton(final ClassCategory category) {
      final isActive = categories.contains(category);
      final surface = theme.colorScheme.surface;
      final onSurface = theme.colorScheme.onSurface;
      return MaterialButton(
        shape: RoundedRectangleBorder(
          side: const BorderSide(),
          borderRadius: BorderRadius.circular(30),
        ),
        textColor: isActive ? surface : onSurface,
        color: isActive ? onSurface : Colors.transparent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        disabledElevation: 0,
        highlightElevation: 0,
        onPressed: () {
          final categoriesNotifier = ref.read(
            trainersCategoryFilterProvider.notifier,
          );
          isActive
              ? categoriesNotifier.remove(category)
              : categoriesNotifier.add(category);
        },
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(category.translation),
      );
    }

    return FocusWrapper(
      unfocussableKeys: <GlobalKey>[searchKey],
      child: DraggableScrollbar.semicircle(
        controller: scrollController,
        // Shows the scrollbar only if current trainers length is greater
        // than 6 (3 rows).
        heightScrollThumb: trainers.length < 7 ? 0 : 40,
        padding: EdgeInsets.zero,
        backgroundColor: theme.colorScheme.onSurface,
        labelTextBuilder: (final offset) {
          /// Creates a label for the scrollbar with the first letter of
          /// current trainer.
          final index = max(0, scrollController.offset - (40 + 24) * 2) /
              scrollController.position.maxScrollExtent *
              trainers.length;
          final trainer = trainers.elementAt(
            scrollController.hasClients
                ? min(index.ceil(), trainers.length - 1)
                : 0,
          );
          return Text(
            trainer.name.isNotEmpty ? trainer.name[0].toUpperCase() : '-',
            style: theme.textTheme.subtitle2
                ?.copyWith(color: theme.colorScheme.surface),
          );
        },
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemExtent: MediaQuery.of(context).size.height - (40 + 24) * 2,
          children: <Widget>[
            /// Is used for moving the scrollbar to the initial position when
            /// search is reset.
            Builder(
              builder: (final context) {
                if (categories.isEmpty && search.value.isEmpty) {
                  final notification = scrollNotificationExample.value;
                  if (notification != null) {
                    (ref.read(widgetsBindingProvider))
                        .addPostFrameCallback((final _) {
                      ScrollUpdateNotification(
                        context: notification.context ?? context,
                        metrics: notification.metrics,
                        depth: notification.depth,
                        dragDetails: notification.dragDetails,
                        scrollDelta: double.negativeInfinity,
                      ).dispatch(notification.context ?? context);
                    });
                  }
                }
                return NotificationListener<ScrollUpdateNotification>(
                  onNotification: (final notification) {
                    scrollNotificationExample.value ??= notification;
                    return false;
                  },
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: <Widget>[
                      const SliverPadding(padding: EdgeInsets.only(top: 20)),

                      /// A search field and categories.
                      SliverAppBar(
                        primary: false,
                        backgroundColor: Colors.transparent,
                        toolbarHeight: 40,
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
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 14,
                              ),
                              prefixIcon: Align(
                                child: FontIcon(
                                  FontIconData(
                                    IconsCG.search,
                                    color: theme.hintColor,
                                  ),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 48,
                                maxWidth: 48,
                              ),
                              suffix: MaterialButton(
                                onPressed: () {
                                  search.value = '';
                                  searchController.clear();
                                  searchFocusNode.unfocus();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  TR.tooltipsCancel.tr(),
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              fillColor: theme.colorScheme.surface,
                              hintText: TR.trainersSearch.tr(),
                              border: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            onChanged: (final value) => search.value = value,
                          ),
                        ),
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(40 + 24 * 2),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (final notification) => true,
                                child: SingleChildScrollView(
                                  controller: ScrollController(),
                                  scrollDirection: Axis.horizontal,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: <Widget>[
                                      for (final category
                                          in ClassCategory.values)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: filterButton(category),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      /// The list of trainers.
                      if (trainers.isNotEmpty)
                        SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            mainAxisExtent: 210,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (final context, final index) {
                              final trainer = trainers.elementAt(index);
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  CachedNetworkImage(
                                    imageUrl: trainer.avatarBig,
                                    imageBuilder:
                                        (final context, final imageProvider) {
                                      return CircleAvatar(
                                        radius: 80,
                                        foregroundImage: imageProvider,
                                      );
                                    },
                                    placeholder: (final context, final url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (
                                      final context,
                                      final url,
                                      final dynamic error,
                                    ) =>
                                        const FontIcon(
                                      FontIconData(IconsCG.logo),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                      child: Text(
                                        trainer.name,
                                        style:
                                            theme.textTheme.bodyText1?.copyWith(
                                          fontWeight: FontWeight.normal,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        maxLines: 2,
                                        // stepGranularity: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
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
                      const SliverPadding(padding: EdgeInsets.only(top: 40)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
