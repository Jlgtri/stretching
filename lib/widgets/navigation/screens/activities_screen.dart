import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:darq/darq.dart';
import 'package:dropdown_below/dropdown_below.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/business_logic.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models_smstretching/sm_classes_gallery_model.dart';
import 'package:stretching/models_smstretching/sm_record_model.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/models_smstretching/sm_wishlist_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/company_model.dart';
import 'package:stretching/models_yclients/user_record_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/firebase_providers.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/utils/logger.dart';
import 'package:stretching/widgets/book_screens.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/content_screen.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:stretching/widgets/navigation/components/filters.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/trainers_screen.dart';

/// The id converter of the [StudioModel] and [SMStudioModel].
final Provider<StudioIdConverter> studioIdConverterProvider =
    Provider<StudioIdConverter>((final ref) => StudioIdConverter._(ref));

/// The id converter of the [StudioModel] and [SMStudioModel].
class StudioIdConverter implements JsonConverter<CombinedStudioModel?, int> {
  const StudioIdConverter._(final this._ref);
  final ProviderRefBase _ref;

  @override
  CombinedStudioModel? fromJson(final int id) {
    for (final studio in _ref.read(combinedStudiosProvider)) {
      if (studio.item0.id == id) {
        return studio;
      }
    }
  }

  @override
  int toJson(final CombinedStudioModel? data) => data!.item0.id;
}

/// The provider of filters for [StudioModel] and [SMStudioModel].
final StateNotifierProvider<
        SaveToHiveIterableNotifier<CombinedStudioModel, String>,
        Iterable<CombinedStudioModel>> activitiesStudiosFilterProvider =
    StateNotifierProvider<
        SaveToHiveIterableNotifier<CombinedStudioModel, String>,
        Iterable<CombinedStudioModel>>((final ref) {
  return SaveToHiveIterableNotifier<CombinedStudioModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_studios',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(studioIdConverterProvider)),
    ),
    defaultValue: const Iterable<CombinedStudioModel>.empty(),
  );
});

/// The provider of filters for [SMTrainerModel].
final StateNotifierProvider<
        SaveToHiveIterableNotifier<CombinedClassesModel, String>,
        Iterable<CombinedClassesModel>> activitiesCategoriesFilterProvider =
    StateNotifierProvider<
        SaveToHiveIterableNotifier<CombinedClassesModel, String>,
        Iterable<CombinedClassesModel>>((final ref) {
  return SaveToHiveIterableNotifier<CombinedClassesModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_categories',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(combinedClassesIdConverterProvider)),
    ),
    defaultValue: const Iterable<CombinedClassesModel>.empty(),
  );
});

/// The provider of filters for [SMTrainerModel].
final StateNotifierProvider<SaveToHiveIterableNotifier<SMTrainerModel, String>,
        Iterable<SMTrainerModel>> activitiesTrainersFilterProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<SMTrainerModel, String>,
        Iterable<SMTrainerModel>>((final ref) {
  return SaveToHiveIterableNotifier<SMTrainerModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_trainers',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(smTrainerIdConverterProvider)),
    ),
    onValueCreated: (final trainers) =>
        trainers.toList(growable: false)..sort(),
    defaultValue: const Iterable<SMTrainerModel>.empty(),
  );
});

/// The filter for the [ActivityModel] time.
enum ActivityTime {
  /// Means the time is before 16:45.
  before,

  /// Means the time is after 16:45.
  after,

  /// Means time is all day.
  all
}

/// The extra data provided for [ActivityTime].
extension ActivityTimeData on ActivityTime {
  /// Return the translation of this time for the specified [time].
  String translate([final TimeOfDay time = filterTime]) {
    return '${TR.miscFilterTime}_${enumToString(this)}'.tr(
      args: <String>[
        <Object>[time.hour, time.minute.toString().padLeft(2, '0')].join(':')
      ],
    );
  }

  /// Check if [date] is [before] or [after] `16:45` on it's day.
  ///
  /// If [date] is at `16:45`, it returns true on [before].
  ///
  /// If this is [ActivityTime.all], returns true every time.
  bool isWithin(final DateTime date, [final TimeOfDay time = filterTime]) {
    final dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    switch (this) {
      case ActivityTime.before:
        return date.isBefore(dateTime) || date.isAtSameMomentAs(dateTime);
      case ActivityTime.after:
        return date.isAfter(dateTime);
      case ActivityTime.all:
        return true;
    }
  }
}

/// The provider of filters for [SMTrainerModel].
final StateNotifierProvider<SaveToHiveIterableNotifier<ActivityTime, String>,
        Iterable<ActivityTime>> activitiesTimeFilterProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<ActivityTime, String>,
        Iterable<ActivityTime>>((final ref) {
  return SaveToHiveIterableNotifier<ActivityTime, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_time',
    converter: const StringToIterableConverter(
      IterableConverter(EnumConverter(ActivityTime.values)),
    ),
    defaultValue: const Iterable<ActivityTime>.empty(),
  );
});

/// The current selected day of activities.
final StateProvider<DateTime> activitiesDayProvider =
    StateProvider<DateTime>((final ref) {
  final now = ref.read(currentTimeProvider).when(
        data: (final currentTime) => currentTime,
        loading: () => DateTime.now(),
        error: (final e, final st) => DateTime.now(),
      );
  final activities =
      ref.read(combinedActivitiesProvider).where((final activity) {
    return activity.item0.date.isAfter(now);
  });
  return activities.isNotEmpty ? activities.first.item0.date : DateTime.now();
});

/// The provider of search query on [ActivitiesScreen].
final StateProvider<String> activitiesSearchProvider =
    StateProvider<String>((final ref) => '');

/// Resets all filters on activity page.
Future<void> resetFilters(final WidgetRef ref) async {
  await Future.wait(<Future<void>>[
    ref.read(activitiesTimeFilterProvider.notifier).clear(),
    ref.read(activitiesCategoriesFilterProvider.notifier).clear(),
    ref.read(activitiesStudiosFilterProvider.notifier).clear(),
    ref.read(activitiesTrainersFilterProvider.notifier).clear(),
  ]);
}

/// The provider of count of activities filters.
final Provider<int> activitiesFiltersCountProvider = Provider<int>((final ref) {
  int len(final Iterable<Object> iterable) => iterable.length;
  return (ref.watch(activitiesTimeFilterProvider.select(len)) +
          ref.watch(activitiesCategoriesFilterProvider.select(len)) +
          // ref.watch(activitiesStudiosFilterProvider.select(len)) +
          ref.watch(activitiesTrainersFilterProvider.select(len)))
      .toInt();
});

/// The provider of filtered activities.
final Provider<Iterable<CombinedActivityModel>> filteredActivitiesProvider =
    Provider<Iterable<CombinedActivityModel>>((final ref) {
  final day = ref.watch(activitiesDayProvider).state;
  final time = ref.watch(activitiesTimeFilterProvider);
  final categories = ref.watch(activitiesCategoriesFilterProvider);
  final studios = ref.watch(activitiesStudiosFilterProvider);
  final trainers = ref.watch(activitiesTrainersFilterProvider);
  final now = ref.watch(
    currentTimeProvider.select((final currentTime) {
      return currentTime.when(
        data: (final currentTime) => currentTime,
        loading: () => DateTime.now(),
        error: (final e, final st) => DateTime.now(),
      );
    }),
  );
  return ref.watch(
    /// First of all, checks if any activities are present.
    /// Then, applies time, studios, trainers and classes filters.
    combinedActivitiesProvider.select((final activities) {
      return activities.where((final activity) {
        return activity.item0.date.isAfter(now) &&
            activity.item0.date.year == day.year &&
            activity.item0.date.month == day.month &&
            activity.item0.date.day == day.day &&
            (studios.isEmpty || studios.contains(activity.item1)) &&
            (trainers.isEmpty || trainers.contains(activity.item2.item1)) &&
            (categories.isEmpty ||
                categories.any((final category) {
                  return category.item0.id == activity.item0.service.id;
                })) &&
            (time.isEmpty ||
                time.any((final time) => time.isWithin(activity.item0.date)));
      }).toList(growable: false)
        ..sort((final activityA, final activityB) {
          return activityA.item0.compareTo(activityB.item0);
        });
    }),
  );
});

/// Periodic provider of the current time.
final StreamProvider<DateTime> currentTimeProvider =
    StreamProvider<DateTime>((final ref) {
  return Stream.periodic(
    const Duration(seconds: 10),
    (final index) => DateTime.now(),
  );
});

/// The provider of the current days of the [scheduleProvider].
final Provider<Iterable<DateTime>> activitiesDaysProvider =
    Provider<Iterable<DateTime>>((final ref) {
  Iterable<DateTime> result([final DateTime? now]) {
    return ref.watch(
      scheduleProvider.select(
        (final activities) {
          return (activities.map((final activity) => activity.date))
              .distinct((final date) => date.day)
              .where((final date) {
            return date.difference(now ?? DateTime.now()).inDays <
                DateTime.daysPerWeek * 2;
          }).toSet();
        },
      ),
    );
  }

  return (ref.watch(currentTimeProvider)).when(
    data: result,
    loading: result,
    error: (final e, final st) => result(),
  );
});

/// If the activities are present for the current selected day.
final Provider<bool> areActivitiesPresentProvider = Provider<bool>((final ref) {
  final day = ref.watch(activitiesDayProvider).state;
  return ref.watch(
    scheduleProvider.select((final activities) {
      final todayActivities = activities.where((final activity) {
        return activity.date.year == day.year &&
            activity.date.month == day.month &&
            activity.date.day == day.day;
      });
      return todayActivities.isNotEmpty;
      //  &&
      //     todayActivities.any((final activity) {
      //       return activity.date.isAfter(now);
      //     });
    }),
  );
});

/// The screen for the [NavigationScreen.trainers].
class ActivitiesScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.trainers].
  const ActivitiesScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final refreshController = useMemoized(() => RefreshController());
    final activities = ref.watch(filteredActivitiesProvider);
    useMemoized(() {
      ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
        ref.read(activitiesDayProvider).state = activities.first.item0.date;
      });
    });
    // CustomDraggableScrollBar(
    //   itemsCount: activities.length,
    //   visible: activities.length > 4,
    //   resetScrollbarPosition: true,
    //   leadingChildHeight:
    //       InputDecorationStyle.search.toolbarHeight + categoriesHeight + 44,
    //   labelTextBuilder: (final index) {
    //     final activity = activities.elementAt(index);
    //     return Text(
    //       <Object>[
    //         activity.item0.date.hour,
    //         activity.item0.date.minute.toString().padLeft(2, '0')
    //       ].join(':'),
    //       style: theme.textTheme.subtitle2
    //           ?.copyWith(color: theme.colorScheme.surface),
    //     );
    //   },
    //   builder: (final context, final scrollController, final resetPosition) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        /// Dropdown
        const ActivitiesStudiosPickerDropdown(),

        /// Body
        Expanded(
          child: SmartRefresher(
            controller: refreshController,
            onLoading: refreshController.loadComplete,
            onRefresh: () async {
              try {
                while (ref.read(connectionErrorProvider).state) {
                  await Future<void>.delayed(const Duration(seconds: 1));
                }
                await Future.wait(<Future<void>>[
                  ref.read(scheduleProvider.notifier).refresh(),
                  ref.read(smClassesGalleryProvider.notifier).refresh(),
                  ref.read(userRecordsProvider.notifier).refresh(),
                ]);
              } finally {
                refreshController.refreshCompleted();
              }
            },
            child: CustomScrollView(
              primary: false,
              slivers: <Widget>[
                /// A search field, categories and dates.
                SliverAppBar(
                  primary: false,
                  backgroundColor: Colors.transparent,
                  toolbarHeight: 126,
                  titleSpacing: 0,
                  title: Material(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    readOnly: true,
                                    onTap: () => Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).push<void>(
                                      MaterialPageRoute(
                                        builder: (final context) =>
                                            const ActivitiesSearch(),
                                      ),
                                    ),
                                    onChanged: (final value) =>
                                        (ref.read(activitiesSearchProvider))
                                            .state = value,
                                    decoration: InputDecorationStyle.search
                                        .fromTheme(
                                          theme,
                                          hintText: TR.activitiesSearch.tr(),
                                        )
                                        .copyWith(
                                          border: const OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          errorBorder: const OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          disabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedErrorBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          isDense: true,
                                          filled: true,
                                          fillColor: theme.colorScheme.surface,
                                          contentPadding:
                                              const EdgeInsets.all(8),
                                          prefixIconConstraints:
                                              const BoxConstraints(
                                            maxHeight: 32,
                                            maxWidth: 48,
                                          ),
                                        ),
                                  ),
                                ),
                                Consumer(
                                  builder:
                                      (final context, final ref, final child) {
                                    final filtersCount = ref
                                        .watch(activitiesFiltersCountProvider);
                                    return Badge(
                                      padding: const EdgeInsets.all(4),
                                      animationType: BadgeAnimationType.scale,
                                      animationDuration:
                                          const Duration(milliseconds: 300),
                                      position: filtersCount >= 10
                                          ? const BadgePosition(end: 4, top: 4)
                                          : const BadgePosition(end: 8, top: 6),
                                      badgeContent: Text(
                                        filtersCount.toString(),
                                        style:
                                            theme.textTheme.caption?.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.surface,
                                        ),
                                      ),
                                      ignorePointer: true,
                                      showBadge: filtersCount > 0,
                                      badgeColor: theme.colorScheme.onSurface,
                                      child: IconButton(
                                        onPressed: () async {
                                          await showActivitiesFiltersBottomSheet(
                                            context,
                                            onResetPressed: () =>
                                                resetFilters(ref),
                                          );
                                        },
                                        splashRadius: 20,
                                        tooltip: TR.miscFilterTitle.tr(),
                                        icon: FontIcon(
                                          FontIconData(
                                            IconsCG.filter,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Consumer(
                              builder: (final context, final ref, final child) {
                                final studios =
                                    ref.watch(activitiesStudiosFilterProvider);
                                final classes = ref.watch(
                                  combinedClassesProvider
                                      .select((final classes) {
                                    return classes.where((final _class) {
                                      return studios.isEmpty ||
                                          studios.any((final studio) {
                                            return studio.item1.studioTags
                                                .toCategories()
                                                .contains(_class.item0);
                                          });
                                    });
                                  }),
                                );
                                return getSelectorWidget<CombinedClassesModel>(
                                  theme: theme,
                                  text: (final smClassGallery) =>
                                      smClassGallery.item0.translation,
                                  selected: (final value) => ref
                                      .read(activitiesCategoriesFilterProvider)
                                      .contains(value),
                                  values: classes,
                                  onSelected: (final category, final value) {
                                    final categoriesNotifier = ref.read(
                                      activitiesCategoriesFilterProvider
                                          .notifier,
                                    );
                                    value
                                        ? categoriesNotifier.add(category)
                                        : categoriesNotifier.remove(category);
                                  },
                                  padding: const EdgeInsets.only(top: 16),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // bottom: PreferredSize(
                  //   preferredSize: const Size.fromHeight(60),
                  //   child:
                  // ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.only(top: 4, bottom: 12),
                  sliver: SliverPersistentHeader(
                    floating: true,
                    pinned: true,
                    delegate: ActivitiesScreenDayPicker(),
                  ),
                ),

                if (activities.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (final context, final index) {
                        final activity = activities.elementAt(index);
                        return ActivityCardContainer(
                          activity,
                          timeLeftBeforeStart: ref.watch(
                            currentTimeProvider.select((final tempNow) {
                              return activity.item0.date.difference(
                                tempNow.when(
                                  data: (final tempNow) => tempNow,
                                  loading: () => DateTime.now(),
                                  error: (final e, final st) => DateTime.now(),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                      childCount: activities.length,
                    ),
                  )

                // SliverFillRemaining(
                //   child: ListView.builder(
                //     shrinkWrap: true,
                //     primary: false,
                //     itemCount: activities.length,
                //     itemBuilder: (final context, final index) {
                //       final activity = activities.elementAt(index);
                //       return ActivityCardContainer(
                //         activity,
                //         timeLeftBeforeStart: activity.item0.date.difference(now),
                //       );
                //     },
                //   ),
                // )
                else if (ref.watch(areActivitiesPresentProvider))
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 32),
                        EmojiText('😣', style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 284),
                          child: Text(
                            TR.activitiesEmptyFilter.tr(),
                            style: theme.textTheme.subtitle2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 75),
                          child: TextButton(
                            style: TextButtonStyle.light.fromTheme(theme),
                            onPressed: () async {
                              await resetFilters(ref);
                              // dayController.jumpTo(0);
                              ref.refresh(activitiesDayProvider);
                            },
                            child: Text(TR.activitiesEmptyFilterReset.tr()),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  )
                else
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 75),
                        EmojiText('😣', style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 262),
                          child: Text(
                            TR.activitiesEmpty.tr(),
                            style: theme.textTheme.subtitle2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The [CombinedStudioModel] picker on the [ActivitiesScreen].
class ActivitiesStudiosPickerDropdown extends HookConsumerWidget {
  /// The [CombinedStudioModel] picker on the [ActivitiesScreen].
  const ActivitiesStudiosPickerDropdown({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedStudios = ref.watch(activitiesStudiosFilterProvider);
    return Container(
      color: theme.appBarTheme.backgroundColor,
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 4),
      child: DropdownBelow<CombinedStudioModel?>(
        isDense: true,
        elevation: 12,
        boxHeight: 30,
        boxWidth: 160,
        itemWidth: 160,
        icon: FontIcon(
          FontIconData(
            IconsCG.angleDown,
            height: 10,
            color: theme.hintColor,
          ),
        ),
        boxPadding: const EdgeInsets.only(bottom: 8),
        boxDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        itemTextstyle: theme.textTheme.bodyText1,
        boxTextstyle: theme.textTheme.bodyText1?.copyWith(
          color: theme.appBarTheme.foregroundColor,
        ),
        hint: Align(
          child: Text(
            selectedStudios.isNotEmpty
                ? selectedStudios.first.item1.studioName
                : TR.activitiesAllStudios.tr(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        value: selectedStudios.length == 1 ? selectedStudios.single : null,
        items: <DropdownMenuItem<CombinedStudioModel?>>[
          DropdownMenuItem<CombinedStudioModel?>(
            child: Align(
              child: Text(
                TR.activitiesAllStudios.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          for (final studio in ref.watch(combinedStudiosProvider))
            DropdownMenuItem<CombinedStudioModel>(
              value: studio,
              child: Align(
                child: Text(
                  studio.item1.studioName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
        onChanged: (final value) async {
          final filteredStudiosNotifier =
              ref.read(activitiesStudiosFilterProvider.notifier);
          if (value != null) {
            await filteredStudiosNotifier.setStateAsync([value]);
          } else {
            await filteredStudiosNotifier.clear();
          }
        },
      ),
    );
  }
}

/// The loader of the [ActivityCardContainer] for the each
/// [ActivityCardContainer.activity].
final StateProviderFamily<bool, ActivityModel> activityCardLoadingProvider =
    StateProvider.family<bool, ActivityModel>((final ref, final activity) {
  return false;
});

/// The transition between [ActivityCard] and [ActivityScreenCard].
class ActivityCardContainer extends HookConsumerWidget {
  /// The transition between [ActivityCard] and [ActivityScreenCard].
  const ActivityCardContainer(
    final this.activity, {
    required final this.timeLeftBeforeStart,
    final this.onMain = false,
    final Key? key,
  }) : super(key: key);

  /// The activity to display in this widget.
  final CombinedActivityModel activity;

  /// The amount of time left before this [activity] is starting.
  final Duration timeLeftBeforeStart;

  /// If this card is placed on main.
  final bool onMain;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final isLoading = ref.watch(activityCardLoadingProvider(activity.item0));
    final isMounted = useIsMounted();

    Future<void> logFirebase(final String name) {
      return analytics.logEvent(
        name: name,
        parameters: <String, String>{
          'studio': translit(activity.item1.item1.studioName),
          'class': activity.item0.service.title,
          'trainer': translit(activity.item2.item1.trainerName),
          'date_time': faTime(ref.read(smServerTimeProvider)),
        },
      );
    }

    Future<bool> cancelBook(
      final UserRecordModel appliedRecord, {
      required final bool fullscreen,
    }) async {
      isLoading.state = true;
      try {
        await logFirebase(
          fullscreen ? FAKeys.cancelBookScreen : FAKeys.cancelBook,
        );
        final smRecord = await (ref.read(businessLogicProvider)).cancelBook(
          recordId: appliedRecord.id,
          recordDate: appliedRecord.date,
          userPhone: ref.read(userProvider)!.phone,
          discount: ref.read(discountProvider),
        );
        if (smRecord != null) {
          Widget refundedBody(final String body, final String button) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    body,
                    style: theme.textTheme.subtitle2,
                  ),
                  const SizedBox(height: 24),
                  BottomButtons<dynamic>(
                    firstText: button,
                    onFirstPressed: (final context) {
                      navigator.popUntil(ModalRoute.withName(Routes.root.name));
                      (ref.read(navigationProvider))
                          .jumpToTab(NavigationScreen.profile.index);
                    },
                  ),
                ],
              ),
            );
          }

          switch (smRecord.payment) {
            case ActivityPaidBy.deposit:
            case ActivityPaidBy.regular:
              ref.refresh(smUserDepositProvider);
              await ref.read(smUserDepositProvider.future);
              await showRefundedModalBottomSheet(
                context: context,
                title: TR.cancelBookDepositTitle.tr(),
                child: refundedBody(
                  TR.cancelBookDepositBody.tr(),
                  TR.cancelBookDepositButton.tr(),
                ),
              );
              continue all;
            case ActivityPaidBy.abonement:
              await ref.read(userAbonementsProvider.notifier).refresh();
              await showRefundedModalBottomSheet(
                context: context,
                title: TR.cancelBookAbonementTitle.tr(),
                child: refundedBody(
                  TR.cancelBookAbonementBody.tr(),
                  TR.cancelBookAbonementButton.tr(),
                ),
              );
              continue all;
            all:
            case ActivityPaidBy.none:
              await ref.read(userRecordsProvider.notifier).refresh();
          }
          return true;
        }
      } on CancelBookException catch (exception) {
        logger.e(exception.type, exception);
        switch (exception.type) {
          case CancelBookExceptionType.notFound:
            await ref.read(userRecordsProvider.notifier).refresh();
            break;
          case CancelBookExceptionType.timeHacking:
        }
      } finally {
        if (isMounted()) {
          isLoading.state = false;
        }
      }
      return false;
    }

    Future<bool> book({required final bool fullscreen}) async {
      isLoading.state = true;
      try {
        await logFirebase(fullscreen ? FAKeys.bookScreen : FAKeys.book);
        final businessLogic = ref.read(businessLogicProvider);
        final result = await businessLogic.book(
          timeout: bookTimeout,
          navigator: navigator,
          user: ref.read(userProvider)!,
          activity: activity,
          useDiscount: ref.read(discountProvider),
          userAbonements: ref.read(combinedAbonementsProvider),
          updateAndTryAgain: (final record) async {
            await Future.wait(<Future<void>>[
              ref.read(userAbonementsProvider.notifier).refresh(),
              ref.read(smUserAbonementsProvider.notifier).refresh()
            ]);
            return businessLogic.book(
              prevRecord: record,
              navigator: navigator,
              user: ref.read(userProvider)!,
              activity: activity,
              useDiscount: ref.read(discountProvider),
              userAbonements: ref.read(combinedAbonementsProvider),
            );
          },
        );
        logger.i(result.item1);
        switch (result.item1) {
          case BookResult.depositDiscount:
          case BookResult.depositRegular:
            ref.refresh(smUserDepositProvider);
            await ref.read(smUserDepositProvider.future);
            continue all;
          case BookResult.newAbonement:
            await ref.read(smUserAbonementsProvider.notifier).refresh();
            continue abonement;
          abonement:
          case BookResult.abonement:
            await ref.read(userAbonementsProvider.notifier).refresh();
            continue all;
          all:
          case BookResult.discount:
          case BookResult.regular:
            await ref.read(userRecordsProvider.notifier).refresh();
            await navigator.push<void>(
              MaterialPageRoute(
                builder: (final context) => SuccessfulBookScreen(
                  activity: activity,
                  record: result.item0,
                  abonement: result.item1 == BookResult.newAbonement,
                ),
              ),
            );
        }
        return true;
      } on BookException catch (exception) {
        logger.e(exception.type, exception);
        if (exception.type != BookExceptionType.dismiss) {
          await Future.wait(<Future<void>>[
            if (exception.type == BookExceptionType.alreadyApplied)
              ref.read(userRecordsProvider.notifier).refresh(),
            navigator.push<void>(
              MaterialPageRoute(
                builder: (final context) => ResultBookScreen(
                  showBackButton: exception.type == BookExceptionType.payment,
                  title: exception.type.title,
                  body: exception.type.info,
                  button: exception.type.button,
                  onPressed: exception.type == BookExceptionType.general
                      ? () {
                          (ref.read(navigationProvider))
                              .jumpToTab(NavigationScreen.home.index);
                          Navigator.of(context, rootNavigator: true)
                              .popUntil(ModalRoute.withName(Routes.root.name));
                        }
                      : exception.type == BookExceptionType.alreadyApplied ||
                              exception.type == BookExceptionType.full
                          ? () => Navigator.of(context, rootNavigator: true)
                                  .popUntil(
                                ModalRoute.withName(Routes.root.name),
                              )
                          : null,
                ),
              ),
            )
          ]);
        }
      } finally {
        if (isMounted()) {
          isLoading.state = false;
        }
      }
      return false;
    }

    Future<void> addToWishList({required final bool fullscreen}) async {
      isLoading.state = true;
      try {
        await logFirebase(fullscreen ? FAKeys.wishlistScreen : FAKeys.wishlist);
        final user = ref.read(userProvider)!;
        final userWishlist = await smStretching.getWishlist(user.phone);
        final alreadyApplied = userWishlist.any((final userWishlist) {
          return userWishlist.activityId == activity.item0.id;
        });
        var addedToWishlist = false;
        if (!alreadyApplied) {
          addedToWishlist = await smStretching.createWishlist(
            SMWishlistModel(
              activityId: activity.item0.id,
              activityDate: activity.item0.date,
              addDate: ref.read(smServerTimeProvider),
              userPhone: user.phone,
            ),
          );
        }

        await navigator.push(
          MaterialPageRoute<void>(
            builder: (final context) => ResultBookScreen(
              emoji: '🧘',
              title: alreadyApplied
                  ? TR.wishlistAlreadyAdded.tr()
                  : !addedToWishlist
                      ? TR.wishlistErrorTitle.tr()
                      : TR.wishlistAddedTitle.tr(),
              body: !addedToWishlist
                  ? TR.wishlistErrorBody.tr()
                  : TR.wishlistAddedBody.tr(),
              button: !addedToWishlist
                  ? TR.wishlistErrorButton.tr()
                  : TR.wishlistAddedButton.tr(),
            ),
          ),
        );
      } finally {
        if (isMounted()) {
          isLoading.state = false;
        }
      }
    }

    return OpenContainer<void>(
      tappable: false,
      openElevation: 0,
      closedElevation: 0,
      openColor: Colors.transparent,
      closedColor: Colors.transparent,
      middleColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 650),
      closedBuilder: (final context, final action) => Loader(
        isLoading: isLoading.state,
        child: ActivityCard(
          activity,
          onMain: onMain,
          onOpenButtonPressed: action,
          timeLeftBeforeStart: timeLeftBeforeStart,
          onPressed: (final appliedRecord) => !isLoading.state
              ? ref.read(userProvider) == null
                  ? () => Navigator.of(context, rootNavigator: true)
                      .pushNamed(Routes.auth.name)
                  : appliedRecord != null
                      ? timeLeftBeforeStart.inHours < 12
                          ? null
                          : () => cancelBook(appliedRecord, fullscreen: false)
                      : activity.item0.recordsLeft <= 0
                          ? () => addToWishList(fullscreen: false)
                          : () => book(fullscreen: false)
              : null,
        ),
      ),
      openBuilder: (final context, final action) => Consumer(
        builder: (final context, final ref, final child) => Loader(
          falsePop: true,
          isLoading:
              ref.watch(activityCardLoadingProvider(activity.item0)).state,
          child: ActivityScreenCard(
            activity,
            onMain: onMain,
            onBackButtonPressed: action,
            timeLeftBeforeStart: timeLeftBeforeStart,
            onPressed: (final appliedRecord) => isMounted() && !isLoading.state
                ? ref.read(userProvider) == null
                    ? () => Navigator.of(context, rootNavigator: true)
                        .pushNamed(Routes.auth.name)
                    : appliedRecord != null
                        ? timeLeftBeforeStart.inHours < 12
                            ? null
                            : () async {
                                if (onMain &&
                                    await cancelBook(
                                      appliedRecord,
                                      fullscreen: true,
                                    )) {
                                  await navigator.maybePop();
                                }
                              }
                        : activity.item0.recordsLeft <= 0
                            ? () => addToWishList(fullscreen: true)
                            : () => book(fullscreen: true)
                : null,
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<CombinedActivityModel>('activity', activity))
        ..add(
          DiagnosticsProperty<Duration>(
            'timeLeftBeforeStart',
            timeLeftBeforeStart,
          ),
        )
        ..add(DiagnosticsProperty<bool>('onMain', onMain)),
    );
  }
}

/// The activity card to display on [ActivitiesScreen].
class ActivityCard extends ConsumerWidget {
  /// The activity card to display on [ActivitiesScreen].
  const ActivityCard(
    final this.activity, {
    required final this.timeLeftBeforeStart,
    required final this.onPressed,
    required final this.onOpenButtonPressed,
    final this.onMain = false,
    final Key? key,
  }) : super(key: key);

  /// The activity to display in this widget.
  final CombinedActivityModel activity;

  /// The amount of time left before this [activity] is starting.
  final Duration timeLeftBeforeStart;

  /// The callback with found record that returns a callback on this card.
  final void Function()? Function(UserRecordModel? appliedRecord) onPressed;

  /// The callback on the back button of this card.
  final void Function() onOpenButtonPressed;

  /// If this card is gonna be put on main screen.
  final bool onMain;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final grey = theme.colorScheme.onSurface.withOpacity(2 / 3);

    final appliedRecord = ref.watch(
      userRecordsProvider.select((final userRecords) {
        for (final record in userRecords) {
          if (record.activityId == activity.item0.id && !record.deleted) {
            return record;
          }
        }
      }),
    );

    return SizedBox(
      height: 124,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: InkWell(
            onTap: () async {
              onOpenButtonPressed();
              await analytics.logEvent(
                name: onMain ? FAKeys.upcomingRecordClick : FAKeys.activity,
                parameters: <String, String>{
                  'trainer': translit(activity.item2.item1.trainerName),
                  'studio': translit(activity.item1.item1.studioName),
                  'class': activity.item0.service.title,
                  'date_time': faTime(activity.item0.date),
                },
              );
            },
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /// Time
                        Text(
                          <Object>[
                            activity.item0.date.hour,
                            activity.item0.date.minute
                                .toString()
                                .padLeft(2, '0')
                          ].join(':'),
                          style: theme.textTheme.bodyText1,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        /// Duration
                        Text(
                          activity.item0.length.inMinutes < 60
                              ? TR.activitiesDurationMinuteShort.tr(
                                  args: <String>[
                                    activity.item0.length.inMinutes.toString()
                                  ],
                                )
                              : TR.activitiesDurationHour.plural(
                                  activity.item0.length.inHours,
                                  args: <String>[
                                    activity.item0.length.inHours.toString()
                                  ],
                                ),
                          style:
                              theme.textTheme.headline6?.copyWith(color: grey),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        /// Trainer Avatar
                        Flexible(
                          child: CachedNetworkImage(
                            imageUrl: activity.item2.item0.avatar,
                            cacheKey: 'x40_${activity.item2.item0.avatar}',
                            height: 40,
                            width: 40,
                            memCacheWidth: 40,
                            memCacheHeight: 40,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            imageBuilder: (final context, final imageProvider) {
                              return CircleAvatar(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.transparent,
                                radius: 16,
                                foregroundImage: imageProvider,
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            /// Class Name
                            Text(
                              activity.item0.service.title,
                              style: theme.textTheme.bodyText1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            /// Trainer Name
                            Text(
                              activity.item2.item1.trainerName,
                              style: theme.textTheme.caption
                                  ?.copyWith(color: grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            /// Studio Name
                            EmojiText(
                              // appliedRecord?.online != null
                              //     ? '🔗 ${TR.homeClassesOnline.tr()}'
                              //     :
                              activity.item1.item1.studioName,
                              style: theme.textTheme.caption
                                  ?.copyWith(color: grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Flexible(
                          child: Opacity(
                            opacity: appliedRecord != null &&
                                    timeLeftBeforeStart.inHours < 12
                                ? 1 / 2
                                : 1,
                            child: SizedBox(
                              height: 24,
                              width: onMain ? 120 : null,
                              child: TextButton(
                                style: (TextButtonStyle.light.fromTheme(theme))
                                    .copyWith(
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(vertical: 4),
                                  ),
                                  shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(2)),
                                    ),
                                  ),
                                  textStyle: MaterialStateProperty.all(
                                    theme.textTheme.caption,
                                  ),
                                  tapTargetSize: MaterialTapTargetSize.padded,
                                ),
                                onPressed: onPressed(appliedRecord),
                                child: Text(
                                  appliedRecord != null
                                      ? TR.activitiesCancel.tr()
                                      : activity.item0.recordsLeft > 0
                                          ? TR.activitiesApply.tr()
                                          : TR.activitiesWaitingList.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Column(
                      mainAxisAlignment: onMain
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        /// Extra Data on Main
                        if (onMain)
                          Consumer(
                            builder: (final context, final ref, final child) {
                              final locale = ref.watch(localeProvider);
                              final serverTime =
                                  ref.watch(smServerTimeProvider);
                              final isToday =
                                  activity.item0.date.year == serverTime.year &&
                                      activity.item0.date.month ==
                                          serverTime.month &&
                                      activity.item0.date.day == serverTime.day;
                              final weekDay = DateFormat.EEEE(locale.toString())
                                  .format(activity.item0.date);
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  /// Activity Date
                                  Container(
                                    width: isToday ? 70 : 90,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.primary,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(4),
                                      ),
                                    ),
                                    child: Text(
                                      isToday
                                          ? TR.homeClassesToday.tr()
                                          : DateFormat.MMMMd(locale.toString())
                                              .format(activity.item0.date),
                                      style: theme.textTheme.overline?.copyWith(
                                        color: theme.colorScheme.surface,
                                      ),
                                      maxLines: 1,
                                      textScaleFactor: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  /// Activity Weekday
                                  if (!isToday)
                                    Text(
                                      weekDay.isNotEmpty
                                          ? weekDay
                                                  .substring(0, 1)
                                                  .toUpperCase() +
                                              weekDay.substring(1).toLowerCase()
                                          : '',
                                      style: theme.textTheme.overline,
                                      maxLines: 1,
                                      textScaleFactor: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                ],
                              );
                            },
                          ),

                        /// If it is too late too cancel the activity.
                        if (appliedRecord != null &&
                            timeLeftBeforeStart.inHours < 12)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (!onMain)
                                EmojiText(
                                  '⏱',
                                  style: TextStyle(color: theme.hintColor),
                                ),
                              Text(
                                TR.activities12h.tr(),
                                textAlign: TextAlign.center,
                                style: theme.textTheme.overline,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 1,
                              ),
                            ],
                          )
                        else if (!onMain)
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: ActivityCardRecordsCount(
                              activity.item0.recordsLeft,
                              showDefault: false,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
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
      properties
        ..add(DiagnosticsProperty<CombinedActivityModel>('activity', activity))
        ..add(
          DiagnosticsProperty<Duration>(
            'timeLeftBeforeStart',
            timeLeftBeforeStart,
          ),
        )
        ..add(
          ObjectFlagProperty<void Function()? Function(UserRecordModel?)>.has(
            'onPressed',
            onPressed,
          ),
        )
        ..add(
          ObjectFlagProperty<void Function()>.has(
            'onOpenButtonPressed',
            onOpenButtonPressed,
          ),
        )
        ..add(DiagnosticsProperty<bool>('onMain', onMain)),
    );
  }
}

/// The widget that displays a current count of records left.
class ActivityCardRecordsCount extends StatelessWidget {
  /// The widget that displays a current count of records left.
  const ActivityCardRecordsCount(
    final this.recordsCount, {
    final this.showDefault = true,
    final Key? key,
  }) : super(key: key);

  /// The count of records to show in this widget.
  final int recordsCount;

  /// If the default count of records should be shown.
  final bool showDefault;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (recordsCount <= 3)
          EmojiText(
            recordsCount <= 0
                ? '😱'
                : recordsCount <= 3
                    ? '🔥'
                    : '',
          ),
        if (recordsCount <= 3 || showDefault)
          Text(
            TR.activitiesFullness.plural(max(0, recordsCount)),
            textAlign: TextAlign.center,
            style: theme.textTheme.overline
                ?.copyWith(color: theme.colorScheme.onSurface),
          ),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(IntProperty('recordsCount', recordsCount))
        ..add(DiagnosticsProperty<bool>('showDefault', showDefault)),
    );
  }
}

/// The fullscreen version of the [ActivityCard].
class ActivityScreenCard extends ConsumerWidget {
  /// The fullscreen version of the [ActivityCard].
  const ActivityScreenCard(
    final this.activity, {
    required final this.timeLeftBeforeStart,
    required final this.onPressed,
    required final this.onBackButtonPressed,
    final this.onMain = false,
    final Key? key,
  }) : super(key: key);

  /// The activity to display in this widget.
  final CombinedActivityModel activity;

  /// The amount of time left before this [activity] is starting.
  final Duration timeLeftBeforeStart;

  /// The callback with found record that returns a callback on this card.
  final void Function()? Function(UserRecordModel? appliedRecord) onPressed;

  /// The callback on the back button of this card.
  final void Function() onBackButtonPressed;

  /// If this card is gonna be put on main screen.
  final bool onMain;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    String formatSubTitle() {
      final date = DateFormat('dd.MM').format(activity.item0.date);
      final time = DateFormat.Hm().format(activity.item0.date);
      final duration = activity.item0.length.inMinutes < 60
          ? TR.activitiesDurationMinuteShort.tr(
              args: <String>[activity.item0.length.inMinutes.toString()],
            )
          : TR.activitiesDurationHour.plural(
              activity.item0.length.inHours,
              args: <String>[activity.item0.length.inHours.toString()],
            );
      return '$date | $time ($duration)';
    }

    final appliedRecord = ref.watch(
      userRecordsProvider.select((final userRecords) {
        for (final record in userRecords) {
          if (record.activityId == activity.item0.id && !record.deleted) {
            return record;
          }
        }
      }),
    );

    final theme = Theme.of(context);
    final images = activity.item3.gallery.split(',');
    return ContentScreen(
      type: onMain ? NavigationScreen.home : NavigationScreen.schedule,
      onBackButtonPressed: onBackButtonPressed,
      title: activity.item3.classesName,
      subtitle: formatSubTitle(),
      secondSubtitle: activity.item1.item1.studioAddress,
      trailing: Column(
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 54),
            child: ActivityCardRecordsCount(activity.item0.recordsLeft),
          ),
          const SizedBox(height: 24),
        ],
      ),
      carousel: CarouselSlider.builder(
        options: CarouselOptions(
          height: 280,
          viewportFraction: 1,
          enableInfiniteScroll: images.length > 1,
        ),
        itemCount: images.length,
        itemBuilder: (final context, final index, final realIndex) {
          return CachedNetworkImage(
            imageUrl: images.elementAt(index),
            fit: BoxFit.fitHeight,
            alignment: Alignment.topCenter,
            width: MediaQuery.of(context).size.width,
            height: 280,
          );
        },
      ),
      paragraphs: <ContentParagraph>[
        if (activity.item3.classInfo != null)
          Tuple2(null, activity.item3.classInfo!),
        if (activity.item3.takeThis != null)
          Tuple2(
            TR.activitiesActivityImportantInfo.tr(),
            activity.item3.takeThis!,
          ),
      ],
      persistentFooterButtons: <Widget>[
        BottomButtons<void>(
          inverse: appliedRecord != null,
          direction: appliedRecord != null ? Axis.horizontal : Axis.vertical,
          firstText: appliedRecord != null
              ? TR.activitiesActivityCancelBook.tr()
              : activity.item0.recordsLeft <= 0
                  ? TR.activitiesActivityAddToWishlist.tr()
                  : TR.activitiesActivityBookOnScreen.tr(),
          onFirstPressed: onPressed(appliedRecord) != null
              ? (final context) => onPressed(appliedRecord)?.call()
              : null,
          secondText: appliedRecord != null
              ? TR.activitiesActivityAddToCalendar.tr()
              : '',
          onSecondPressed: appliedRecord != null
              ? (final context) => activity.addToCalendar()
              : null,
        ),
      ],
      bottomNavigationBar:
          appliedRecord != null && timeLeftBeforeStart.inHours < 12
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        TR.activitiesActivityCancelBook12h.tr(),
                        style: theme.textTheme.headline6
                            ?.copyWith(color: theme.hintColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : null,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: OpenContainer<void>(
            tappable: false,
            openElevation: 0,
            closedElevation: 0,
            openColor: Colors.transparent,
            closedColor: Colors.transparent,
            middleColor: Colors.transparent,
            transitionDuration: const Duration(milliseconds: 500),
            openBuilder: (final context, final action) => TrainerScreen(
              activity.item2,
              onBackButtonPressed: action,
              upperType: null,
            ),
            closedBuilder: (final context, final action) {
              return SizedBox(
                height: 80,
                child: ListTile(
                  onTap: action,
                  // dense: true,
                  // visualDensity: VisualDensity.compact,
                  horizontalTitleGap: 8,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  tileColor: theme.colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  minVerticalPadding: 0,
                  leading: CachedNetworkImage(
                    height: 56,
                    width: 56,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    imageUrl: activity.item2.item1.trainerPhoto,
                    imageBuilder: (final context, final imageProvider) {
                      return CircleAvatar(
                        radius: 28,
                        foregroundImage: imageProvider,
                      );
                    },
                    placeholder: (final context, final url) => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                    errorWidget:
                        (final context, final url, final dynamic error) =>
                            const FontIcon(FontIconData(IconsCG.logo)),
                  ),
                  title: Text(
                    activity.item2.item1.trainerName,
                    style: theme.textTheme.bodyText1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    (activity.item2.item1.classesType?.toCategories())
                            ?.map((final category) => category.translation)
                            .join(', ') ??
                        '',
                    style: theme.textTheme.bodyText2?.copyWith(
                      color: theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      FontIcon(FontIconData(IconsCG.angleRight, height: 24)),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<CombinedActivityModel>('activity', activity))
        ..add(
          DiagnosticsProperty<Duration>(
            'timeLeftBeforeStart',
            timeLeftBeforeStart,
          ),
        )
        ..add(
          ObjectFlagProperty<void Function()? Function(UserRecordModel?)>.has(
            'onPressed',
            onPressed,
          ),
        )
        ..add(
          ObjectFlagProperty<void Function()>.has(
            'onBackButtonPressed',
            onBackButtonPressed,
          ),
        )
        ..add(DiagnosticsProperty<bool>('onMain', onMain)),
    );
  }
}

/// The card for the date picker on [ActivitiesScreen].
class ActivitiesDateFilterCard extends ConsumerWidget {
  /// The card for the date picker on [ActivitiesScreen].
  const ActivitiesDateFilterCard(
    final this.date, {
    required final this.selected,
    required final this.onSelected,
    final Key? key,
  }) : super(key: key);

  /// The date to show on this card.
  final DateTime date;

  /// If this card is currently selected
  final bool selected;

  /// The callback on this card.
  final void Function() onSelected;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 40,
        child: MaterialButton(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          disabledColor: theme.colorScheme.onSurface,
          onPressed: !selected ? onSelected : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              /// Weekday
              Text(
                DateFormat.E(ref.watch(localeProvider).toString()).format(date),
                style: theme.textTheme.overline?.copyWith(
                  color: selected ? theme.colorScheme.surface : theme.hintColor,
                ),
              ),

              /// Day
              Text(
                date.day.toString(),
                style: (selected
                        ? theme.textTheme.subtitle1
                        : theme.textTheme.subtitle2)
                    ?.copyWith(
                  color: selected
                      ? theme.colorScheme.surface
                      : theme.colorScheme.onSurface,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<DateTime>('date', date))
        ..add(DiagnosticsProperty<bool>('selected', selected))
        ..add(
          ObjectFlagProperty<void Function()>.has('onSelected', onSelected),
        ),
    );
  }
}

/// Shows a bottom sheet for picking filters for [ActivitiesScreen].
Future<void> showActivitiesFiltersBottomSheet(
  final BuildContext context, {
  final void Function()? onResetPressed,
}) async {
  final theme = Theme.of(context);
  return showMaterialModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (final context) {
      return BottomSheetBase(
        borderRadius: 14,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppBar(
              primary: false,
              toolbarHeight: 40,
              centerTitle: true,
              title: Text(
                TR.miscFilterTitle.tr(),
                style: theme.textTheme.headline3,
              ),
              backgroundColor: Colors.transparent,
              leading: IconButton(
                iconSize: 16,
                splashRadius: 16,
                tooltip: TR.tooltipsClose.tr(),
                color: theme.colorScheme.onSurface,
                icon: const Icon(IconsCG.closeSlim),
                onPressed: Navigator.maybeOf(context)?.maybePop,
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: MaterialButton(
                    visualDensity: VisualDensity.comfortable,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    onPressed: onResetPressed,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        TR.miscFilterReset.tr(),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                primary: false,
                controller: ModalScrollController.of(context),
                padding: const EdgeInsets.all(16),
                child: const FiltersScreen(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// The screen for picking filters for [ActivitiesScreen].
class FiltersScreen extends ConsumerWidget {
  /// The screen for picking filters for [ActivitiesScreen].
  const FiltersScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // /// Studio Filter
        // Column(
        //   mainAxisSize: MainAxisSize.min,
        //   crossAxisAlignment: CrossAxisAlignment.stretch,
        //   children: <Widget>[
        //     Text(TR.miscFilterStudio.tr(), style: theme.textTheme.bodyText1),
        //     const SizedBox(height: 8),
        //     Flexible(
        //       child: Consumer(
        //         builder: (final context, final ref, final child) {
        //           final studios = ref.watch(combinedStudiosProvider);
        //           return Wrap(
        //             runSpacing: -4,
        //             spacing: 16,
        //             children: <Widget>[
        //               for (final studio in studios)
        //                 Consumer(
        //                   builder: (final context, final ref, final child) {
        //                     return FilterButton(
        //                       text: studio.item1.studioName,
        //                       avatarUrl: studio.avatarUrl,
        //                       borderColor: Colors.grey.shade300,
        //                       backgroundColor: theme.colorScheme.surface,
        //                       margin: const EdgeInsets.symmetric(vertical: 6),
        //                       selected: ref.watch(
        //                         activitiesStudiosFilterProvider
        //                             .select((final selectedStudios) {
        //                           return selectedStudios.contains(studio);
        //                         }),
        //                       ),
        //                       onSelected: (final value) {
        //                         final studiosNotifier = ref.read(
        //                           activitiesStudiosFilterProvider.notifier,
        //                         );
        //                         value
        //                             ? studiosNotifier.add(studio)
        //                             : studiosNotifier.remove(studio);
        //                       },
        //                     );
        //                   },
        //                 )
        //             ],
        //           );
        //         },
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 8),

        // /// Categories Filter
        // Column(
        //   mainAxisSize: MainAxisSize.min,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: <Widget>[
        //     Text(TR.miscFilterClass.tr(), style: theme.textTheme.bodyText1),
        //     const SizedBox(height: 8),
        //     Flexible(
        //       child: Wrap(
        //         runSpacing: -4,
        //         spacing: 16,
        //         children: <Widget>[
        //           for (final category in ref.watch(smClassesGalleryProvider))
        //             Consumer(
        //               builder: (final context, final ref, final child) {
        //                 return FilterButton(
        //                   text: category.classesName,
        //                   borderColor: Colors.grey.shade300,
        //                   backgroundColor: theme.colorScheme.surface,
        //                   margin: const EdgeInsets.symmetric(vertical: 4),
        //                   selected: ref.watch(
        //                     activitiesCategoriesFilterProvider
        //                         .select((final selectedCategories) {
        //                       return selectedCategories.contains(category);
        //                     }),
        //                   ),
        //                   onSelected: (final value) {
        //                     final categoriesNotifier = ref.read(
        //                       activitiesCategoriesFilterProvider.notifier,
        //                     );
        //                     value
        //                         ? categoriesNotifier.add(category)
        //                         : categoriesNotifier.remove(category);
        //                   },
        //                 );
        //               },
        //             )
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 8),

        /// Time Filter
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(TR.miscFilterTime.tr(), style: theme.textTheme.bodyText1),
            const SizedBox(height: 8),
            Flexible(
              child: Wrap(
                runSpacing: -4,
                spacing: 16,
                children: <Widget>[
                  for (final time
                      in ActivityTime.values.toList()..remove(ActivityTime.all))
                    Consumer(
                      builder: (final context, final ref, final child) {
                        return FilterButton(
                          text: time.translate(),
                          borderColor: Colors.grey.shade300,
                          backgroundColor: theme.colorScheme.surface,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          selected: ref.watch(
                            activitiesTimeFilterProvider
                                .select((final selectedTime) {
                              return selectedTime.contains(time);
                            }),
                          ),
                          onSelected: (final value) {
                            final timeNotifier = ref.read(
                              activitiesTimeFilterProvider.notifier,
                            );
                            value
                                ? timeNotifier.add(time)
                                : timeNotifier.remove(time);
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        /// Trainer Filter
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(TR.miscFilterTrainer.tr(), style: theme.textTheme.bodyText1),
            const SizedBox(height: 8),
            Flexible(
              child: Consumer(
                builder: (final context, final ref, final child) {
                  final trainers = ref
                      .watch(smTrainersProvider)
                      .toList(growable: false)
                    ..sort();
                  final children = <Widget>[
                    for (final trainer in trainers)
                      Consumer(
                        builder: (final context, final ref, final child) {
                          return FilterButton(
                            text: trainer.trainerName,
                            avatarUrl: trainer.trainerPhoto,
                            borderColor: Colors.grey.shade300,
                            backgroundColor: theme.colorScheme.surface,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            selected: ref.watch(
                              activitiesTrainersFilterProvider
                                  .select((final selectedTrainers) {
                                return selectedTrainers.contains(trainer);
                              }),
                            ),
                            onSelected: (final value) {
                              final trainersNotifier = ref.read(
                                activitiesTrainersFilterProvider.notifier,
                              );
                              value
                                  ? trainersNotifier.add(trainer)
                                  : trainersNotifier.remove(trainer);
                            },
                          );
                        },
                      ),
                  ];
                  return NativeDeviceOrientationReader(
                    builder: (final context) {
                      final orientation =
                          NativeDeviceOrientationReader.orientation(context);
                      return [
                        NativeDeviceOrientation.landscapeLeft,
                        NativeDeviceOrientation.landscapeRight
                      ].contains(orientation)
                          ? Wrap(
                              runSpacing: -4,
                              spacing: 16,
                              children: children,
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: children,
                            );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The search implemented on [ActivitiesScreen].
class ActivitiesSearch extends HookConsumerWidget {
  /// The search implemented on [ActivitiesScreen].
  const ActivitiesSearch({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final searchKey = useMemoized(() => GlobalKey());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: 0,
        toolbarHeight: 40,
        leading: const SizedBox.shrink(),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: theme.brightness,
          statusBarIconBrightness: theme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light,
        ),
        title: TextField(
          key: searchKey,
          autofocus: true,
          cursorColor: theme.hintColor,
          style: theme.textTheme.bodyText2,
          controller: searchController,
          focusNode: searchFocusNode,
          onChanged: (final value) =>
              (ref.read(activitiesSearchProvider)).state = value,
          decoration: InputDecorationStyle.search
              .fromTheme(theme, hintText: TR.activitiesSearch.tr())
              .copyWith(
                filled: true,
                fillColor: theme.colorScheme.surface,
                prefixIcon: const SizedBox.shrink(),
                prefixIconConstraints:
                    const BoxConstraints(maxWidth: 0, maxHeight: 0),
              ),
        ),
        actions: <Widget>[
          Align(
            child: MaterialButton(
              onPressed: () async {
                ref.read(activitiesSearchProvider).state = '';
                searchController.clear();
                searchFocusNode.unfocus();
                await Navigator.of(context).maybePop();
              },
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Text(
                TR.activitiesSearchCancel.tr(),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8)
        ],
      ),
      body: Column(
        children: const <Widget>[
          Divider(height: 1),
          Flexible(child: ActivitiesSearchResults()),
        ],
      ),
    );
  }
}

/// The results of the [ActivitiesSearch].
class ActivitiesSearchResults extends ConsumerWidget {
  /// The results of the [ActivitiesSearch].
  const ActivitiesSearchResults({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);

    final search = ref.watch(activitiesSearchProvider).state;
    final categories = ref.watch(
      combinedClassesProvider.select((final classes) {
        return classes.where((final _class) {
          return search.isEmpty ||
              (_class.item0.translation.toLowerCase())
                  .contains(search.toLowerCase());
        });
      }),
    );
    final trainers = ref.watch(
      smTrainersProvider.select((final smTrainers) {
        if (search.isEmpty) {
          return const Iterable<SMTrainerModel>.empty();
        }
        return smTrainers.where((final smTrainer) {
          return (smTrainer.trainerName.toLowerCase())
              .contains(search.toLowerCase());
        });
      }),
    );
    final studios = ref.watch(
      combinedStudiosProvider.select((final smStudios) {
        if (search.isEmpty) {
          return const Iterable<CombinedStudioModel>.empty();
        }
        return smStudios.where((final smStudio) {
          return (smStudio.item1.studioName.toLowerCase())
              .contains(search.toLowerCase());
        });
      }),
    );

    Widget searchResult({
      required final String title,
      required final String? imageUrl,
      required final void Function() onTap,
    }) {
      const num height = 30;
      const num width = 50;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          dense: true,
          onTap: onTap,
          visualDensity: VisualDensity.compact,
          minLeadingWidth: width.toDouble(),
          minVerticalPadding: 0,
          horizontalTitleGap: 16,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          leading: imageUrl != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      child: CachedNetworkImage(
                        cacheKey: 'h32w50_$imageUrl',
                        alignment: Alignment.topCenter,
                        height: height.toDouble(),
                        width: width.toDouble(),
                        maxHeightDiskCache: height.toInt(),
                        maxWidthDiskCache: width.toInt(),
                        memCacheHeight: height.toInt(),
                        memCacheWidth: width.toInt(),
                        imageUrl: imageUrl,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                  ],
                )
              : null,
          title: Text(
            title,
            style: theme.textTheme.subtitle2?.copyWith(letterSpacing: 0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: 1,
          ),
        ),
      );
    }

    final navigator = Navigator.of(context);
    return ListView.builder(
      primary: false,
      itemCount: categories.length + trainers.length + studios.length,
      prototypeItem: searchResult(title: '', imageUrl: null, onTap: () {}),
      itemBuilder: (final context, final index) {
        if (index < studios.length) {
          final studio = studios.elementAt(index);
          return searchResult(
            imageUrl: studio.avatarUrl,
            title: studio.item1.studioName,
            onTap: () async {
              final notifier =
                  ref.read(activitiesStudiosFilterProvider.notifier);
              if (!notifier.state.contains(studio)) {
                await notifier.add(studio);
              }
              await navigator.maybePop();
              ref.read(activitiesSearchProvider).state = '';
            },
          );
        } else if (index - studios.length < trainers.length) {
          final trainer = trainers.elementAt(index - studios.length);
          return searchResult(
            imageUrl: trainer.trainerPhoto,
            title: trainer.trainerName,
            onTap: () async {
              final notifier =
                  ref.read(activitiesTrainersFilterProvider.notifier);
              if (!notifier.state.contains(trainer)) {
                await notifier.add(trainer);
              }
              await navigator.maybePop();
              ref.read(activitiesSearchProvider).state = '';
            },
          );
        } else {
          final category = categories.elementAt(
            index - studios.length - trainers.length,
          );
          return searchResult(
            imageUrl: category.item1.gallery.split(',').first,
            title: category.item0.translation,
            onTap: () async {
              final notifier =
                  ref.read(activitiesCategoriesFilterProvider.notifier);
              if (!notifier.state.contains(category)) {
                await notifier.add(category);
              }
              await navigator.maybePop();
              ref.read(activitiesSearchProvider).state = '';
            },
          );
        }
      },
    );
  }
}

/// The picker of the [activitiesDayProvider] current state.
class ActivitiesScreenDayPicker extends SliverPersistentHeaderDelegate {
  /// The picker of the [activitiesDayProvider] current state.
  const ActivitiesScreenDayPicker();

  @override
  double get minExtent => 68;

  @override
  double get maxExtent => 68;

  @override
  Widget build(
    final BuildContext context,
    final double shrinkOffset,
    final bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 44,
          child: Consumer(
            builder: (final context, final ref, final child) {
              final day = ref.watch(activitiesDayProvider).state;
              final activitiesDays = ref.watch(activitiesDaysProvider);
              return ListView.builder(
                // controller: dayController,
                primary: false,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: activitiesDays.length,
                itemExtent: 56,
                itemBuilder: (final context, final index) {
                  final date = activitiesDays.elementAt(index);
                  return ActivitiesDateFilterCard(
                    date,
                    selected: day.year == date.year &&
                        day.month == date.month &&
                        day.day == date.day,
                    onSelected: () {
                      ref.read(activitiesDayProvider).state = date;
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(final ActivitiesScreenDayPicker oldDelegate) => false;
}
