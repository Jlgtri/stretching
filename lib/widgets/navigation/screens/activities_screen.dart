import 'dart:async';
import 'dart:math';

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
import 'package:stretching/hooks/refresh_content_hook.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models/smstretching/sm_classes_gallery_model.dart';
import 'package:stretching/models/smstretching/sm_record_model.dart';
import 'package:stretching/models/smstretching/sm_studio_model.dart';
import 'package:stretching/models/smstretching/sm_trainer_model.dart';
import 'package:stretching/models/smstretching/sm_wishlist_model.dart';
import 'package:stretching/models/yclients/activity_model.dart';
import 'package:stretching/models/yclients/company_model.dart';
import 'package:stretching/models/yclients/record_model.dart';
import 'package:stretching/models/yclients/user_record_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/content_provider.dart';
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
import 'package:stretching/widgets/components/limit_loading_count.dart';
import 'package:stretching/widgets/content_screen.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:stretching/widgets/navigation/components/filters.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/trainers_screen.dart';

/// The id converter of the [StudioModel] and [SMStudioModel].
final Provider<StudioIdConverter> studioIdConverterProvider =
    Provider<StudioIdConverter>(StudioIdConverter._);

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
        Iterable<CombinedStudioModel>>(
  (final ref) => SaveToHiveIterableNotifier<CombinedStudioModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_studios',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(studioIdConverterProvider)),
    ),
    defaultValue: const Iterable<CombinedStudioModel>.empty(),
  ),
);

/// The provider of filters for [SMTrainerModel].
final StateNotifierProvider<
        SaveToHiveIterableNotifier<CombinedClassesModel, String>,
        Iterable<CombinedClassesModel>> activitiesCategoriesFilterProvider =
    StateNotifierProvider<
        SaveToHiveIterableNotifier<CombinedClassesModel, String>,
        Iterable<CombinedClassesModel>>(
  (final ref) => SaveToHiveIterableNotifier<CombinedClassesModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_categories',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(combinedClassesIdConverterProvider)),
    ),
    defaultValue: const Iterable<CombinedClassesModel>.empty(),
  ),
);

/// The provider of filters for [SMTrainerModel].
final StateNotifierProvider<SaveToHiveIterableNotifier<SMTrainerModel, String>,
        Iterable<SMTrainerModel>> activitiesTrainersFilterProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<SMTrainerModel, String>,
        Iterable<SMTrainerModel>>(
  (final ref) => SaveToHiveIterableNotifier<SMTrainerModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_trainers',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(smTrainerIdConverterProvider)),
    ),
    onValueCreated: (final trainers) =>
        trainers.toList(growable: false)..sort(),
    defaultValue: const Iterable<SMTrainerModel>.empty(),
  ),
);

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
  String translate([final TimeOfDay time = filterTime]) =>
      '${TR.miscFilterTime}_${enumToString(this)}'.tr(
        args: <String>[
          <Object>[time.hour, time.minute.toString().padLeft(2, '0')].join(':')
        ],
      );

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
        Iterable<ActivityTime>>(
  (final ref) => SaveToHiveIterableNotifier<ActivityTime, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_time',
    converter: const StringToIterableConverter(
      IterableConverter(EnumConverter(ActivityTime.values)),
    ),
    defaultValue: const Iterable<ActivityTime>.empty(),
  ),
);

/// The current selected day of activities.
final StateProvider<SpecificDay> activitiesDayProvider =
    StateProvider<SpecificDay>((final ref) {
  final specificDay = ref.watch(
    activitiesCurrentTimeProvider.select(
      (final currentTime) => currentTime.maybeWhen(
        data: (final now) => Tuple3(now.year, now.month, now.day),
        orElse: () {
          final now = DateTime.now();
          return Tuple3(now.year, now.month, now.day);
        },
      ),
    ),
  );
  final day = ref.watch(
    activitiesDaysProvider.select((final days) {
      for (final day in days) {
        if (day == specificDay) {
          return day;
        }
      }
    }),
  );
  return day ?? specificDay;
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
final Provider<int> activitiesFiltersCountProvider = Provider<int>(
  (final ref) =>
      ref.watch(activitiesTimeFilterProvider).length +
      ref.watch(activitiesCategoriesFilterProvider).length +
      // ref.watch(activitiesStudiosFilterProvider).length +
      ref.watch(activitiesTrainersFilterProvider).length,
);

/// The provider of filtered activities.
final Provider<Iterable<CombinedActivityModel>> filteredActivitiesProvider =
    Provider<Iterable<CombinedActivityModel>>((final ref) {
  final day = ref.watch(activitiesDayProvider).state;
  final time = ref.watch(activitiesTimeFilterProvider);
  final categories = ref.watch(activitiesCategoriesFilterProvider);
  final studios = ref.watch(activitiesStudiosFilterProvider);
  final trainers = ref.watch(activitiesTrainersFilterProvider);
  final now = (ref.watch(activitiesCurrentTimeProvider)).maybeWhen(
    data: (final currentTime) => currentTime,
    orElse: DateTime.now,
  );
  return ref.watch(
    /// First of all, checks if any activities are present.
    /// Then, applies time, studios, trainers and classes filters.
    combinedActivitiesProvider.select(
      (final activities) => activities
          .where(
            (final activity) =>
                activity.item0.date.isAfter(now) &&
                activity.item0.date.year == day.item0 &&
                activity.item0.date.month == day.item1 &&
                activity.item0.date.day == day.item2 &&
                (studios.isEmpty || studios.contains(activity.item1)) &&
                (trainers.isEmpty || trainers.contains(activity.item2.item1)) &&
                (categories.isEmpty ||
                    categories.any(
                      (final category) =>
                          category.item0.id == activity.item0.service.id,
                    )) &&
                (time.isEmpty ||
                    time.any(
                      (final time) => time.isWithin(activity.item0.date),
                    )),
          )
          .toList(growable: false)
        ..sort(
          (final activityA, final activityB) =>
              activityA.item0.compareTo(activityB.item0),
        ),
    ),
  );
});

/// The provider of the current time for using activities.
final StreamProvider<DateTime> activitiesCurrentTimeProvider =
    StreamProvider<DateTime>((final ref) async* {
  final activititesDates = ref.watch(
    combinedActivitiesProvider.select(
      (final activities) =>
          <DateTime>{for (final activity in activities) activity.item0.date},
    ),
  );
  final now = DateTime.now();
  var previousDate = Tuple3(now.year, now.month, now.day);
  var previousActivitiesDates = const <DateTime>[];
  for (;;) {
    final now = DateTime.now();
    final _activititesDates = (activititesDates
        .where((final day) => day.isAfter(now))).toList(growable: false);
    if (!listEquals(previousActivitiesDates, _activititesDates)) {
      previousActivitiesDates = _activititesDates;
      previousDate = Tuple3(now.year, now.month, now.day);
      yield now;
    } else if (activititesDates.isNotEmpty &&
        previousDate != Tuple3(now.year, now.month, now.day) &&
        now.isBefore(activititesDates.first)) {
      previousDate = Tuple3(now.year, now.month, now.day);
      yield now;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
});

/// The alias for the specific day in sequance year, month, day.
typedef SpecificDay = Tuple3<int, int, int>;

/// The provider of the current days of the [scheduleProvider].
final Provider<Iterable<SpecificDay>> activitiesDaysProvider =
    Provider<Iterable<SpecificDay>>((final ref) {
  Iterable<SpecificDay> result([DateTime? now]) {
    now ??= DateTime.now();
    return ref.watch(
      combinedActivitiesProvider.select(
        (final activities) {
          final dates = <DateTime>[
            ...<DateTime>{
              for (final activity in activities)
                if (activity.item0.date.isAfter(now!)) activity.item0.date
            }
          ]..sort();
          if (now!.difference(dates.first).inDays.abs() <= 1) {
            dates.add(now);
          }
          return <SpecificDay>{
            for (final date in dates.toList(growable: false)..sort())
              if (date.difference(now).inDays < DateTime.daysPerWeek * 2)
                Tuple3(date.year, date.month, date.day)
          };
        },
      ),
    );
  }

  return (ref.watch(activitiesCurrentTimeProvider))
      .maybeWhen(data: result, orElse: result);
});

/// If the activities are present for the current selected day.
final Provider<bool> areActivitiesPresentProvider = Provider<bool>((final ref) {
  final now = (ref.watch(activitiesCurrentTimeProvider)).maybeWhen(
    data: (final currentTime) => currentTime,
    orElse: DateTime.now,
  );
  final day = ref.watch(activitiesDayProvider.select((final day) => day.state));
  return ref.watch(
    combinedActivitiesProvider.select(
      (final activities) => activities.any(
        (final activity) =>
            activity.item0.date.isAfter(now) &&
            activity.item0.date.year == day.item0 &&
            activity.item0.date.month == day.item1 &&
            activity.item0.date.day == day.item2,
      ),
    ),
  );
});

/// The screen for the [NavigationScreen.trainers].
class ActivitiesScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.trainers].
  const ActivitiesScreen({final Key? key}) : super(key: key);

  /// The count of maximum simultaneous loading [ActivityCard].
  static const int maxLoadingCount = 3;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final scrollController = ref
        .watch(navigationScrollControllerProvider(NavigationScreen.schedule));
    final activities = ref.watch(filteredActivitiesProvider);
    final areDayActivitiesPresent = ref.watch(areActivitiesPresentProvider);
    final areActivitiesPresent = ref.watch(
      combinedActivitiesProvider
          .select((final activities) => activities.isNotEmpty),
    );
    final areDaysPresent = ref.watch(
      activitiesDaysProvider
          .select((final activityDays) => activityDays.isNotEmpty),
    );
    final refresh = useRefreshController(
      extraRefresh: () async {
        while (ref.read(connectionErrorProvider).state) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      },
      notifiers: <ContentNotifier>[
        ref.read(scheduleProvider.notifier),
        ref.read(smClassesGalleryProvider.notifier),
        ref.read(userRecordsProvider.notifier),
      ],
    );

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
            controller: refresh.item0,
            onLoading: refresh.item0.loadComplete,
            onRefresh: refresh.item1,
            scrollController: scrollController,
            child: CustomScrollView(
              primary: false,
              controller: scrollController,
              slivers: <Widget>[
                /// A search field, categories and dates.
                SliverPadding(
                  padding: const EdgeInsets.only(top: 6),
                  sliver: SliverAppBar(
                    primary: false,
                    backgroundColor: Colors.transparent,
                    toolbarHeight: 110,
                    titleSpacing: 0,
                    title: Material(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: const <Widget>[
                                Expanded(child: ActivitiesSearchField()),
                                ActivitiesFiltersCounter(),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: ActivitiesCategoriesPicker(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// Date Picker
                if (areDaysPresent)
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    sliver: SliverPersistentHeader(
                      floating: true,
                      pinned: true,
                      delegate: ActivitiesScreenDayPicker(context),
                    ),
                  ),

                /// Cards
                if (activities.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (final context, final index) => ActivityCardContainer(
                        activities.elementAt(index),
                      ),
                      childCount: activities.length,
                    ),
                  )

                /// Empty Filter
                else if (areDayActivitiesPresent)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 32),
                        const EmojiText('😣', style: TextStyle(fontSize: 30)),
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
                              ref.refresh(activitiesDayProvider);
                            },
                            child: Text(
                              TR.activitiesEmptyFilterReset.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  )

                /// Empty
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    sliver: SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        children: <Widget>[
                          if (!areDaysPresent) const SizedBox(height: 50),
                          const SizedBox(height: 75),
                          const EmojiText('😣', style: TextStyle(fontSize: 30)),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: mediaQuery.textScaleFactor <= 1
                                  ? 262
                                  : double.infinity,
                            ),
                            child: Text(
                              !areDaysPresent
                                  ? TR.activitiesEmptyDates.tr()
                                  : !areActivitiesPresent
                                      ? TR.activitiesEmptyApi.tr()
                                      : TR.activitiesEmpty.tr(),
                              style: theme.textTheme.subtitle2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
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
    final mediaQuery = MediaQuery.of(context);
    final selectedStudios = ref.watch(activitiesStudiosFilterProvider);
    return Material(
      color: theme.appBarTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: DropdownButtonHideUnderline(
                child: DropdownBelow<CombinedStudioModel?>(
                  elevation: 12,
                  boxHeight: 30 * mediaQuery.textScaleFactor,
                  boxWidth: 160 * mediaQuery.textScaleFactor,
                  itemWidth: 160 * mediaQuery.textScaleFactor,
                  icon: FontIcon(
                    FontIconData(
                      IconsCG.angleDown,
                      height: 10 * mediaQuery.textScaleFactor,
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
                  value: selectedStudios.length == 1
                      ? selectedStudios.single
                      : null,
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
                  onChanged: (final studio) async {
                    final filteredStudiosNotifier =
                        ref.read(activitiesStudiosFilterProvider.notifier);
                    if (studio != null) {
                      await filteredStudiosNotifier.setStateAsync([studio]);
                      final classes = ref.read(combinedClassesProvider).where(
                            (final _class) => studio.item1.studioTags
                                .toCategories()
                                .contains(_class.item0),
                          );
                      final categoriesNotifiter =
                          ref.read(activitiesCategoriesFilterProvider.notifier);
                      await categoriesNotifiter.setStateAsync(
                        categoriesNotifiter.state.where(classes.contains),
                      );
                    } else {
                      await filteredStudiosNotifier.clear();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The widget for displaying a value of [activitiesFiltersCountProvider].
class ActivitiesFiltersCounter extends ConsumerWidget {
  /// The widget for displaying a value of [activitiesFiltersCountProvider].
  const ActivitiesFiltersCounter({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final filtersCount = ref.watch(
      activitiesFiltersCountProvider.select((final count) => count),
    );
    return Badge(
      padding: const EdgeInsets.all(4),
      animationType: BadgeAnimationType.scale,
      animationDuration: const Duration(milliseconds: 300),
      position: filtersCount >= 10
          ? const BadgePosition(end: 4, top: 4)
          : const BadgePosition(end: 8, top: 6),
      badgeContent: Text(
        filtersCount.toString(),
        style: theme.textTheme.caption?.copyWith(
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
            onResetPressed: () => resetFilters(ref),
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
  }
}

/// The picker of categories for the [ActivitiesScreen].
class ActivitiesCategoriesPicker extends ConsumerWidget {
  /// The picker of categories for the [ActivitiesScreen].
  const ActivitiesCategoriesPicker({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final studios = ref.watch(activitiesStudiosFilterProvider);
    final classes = ref.watch(
      combinedClassesProvider.select(
        (final classes) => classes.where(
          (final _class) =>
              studios.isEmpty ||
              studios.any(
                (final studio) => (studio.item1.studioTags.toCategories())
                    .contains(_class.item0),
              ),
        ),
      ),
    );
    final categories = ref.watch(activitiesCategoriesFilterProvider);
    return getSelectorWidget<CombinedClassesModel>(
      text: (final smClassGallery) => smClassGallery.item0.translation,
      selected: categories.contains,
      values: classes,
      onSelected: (final category, final value) {
        final categoriesNotifier = ref.read(
          activitiesCategoriesFilterProvider.notifier,
        );
        (value ? categoriesNotifier.add : categoriesNotifier.remove)(category);
      },
      padding: const EdgeInsets.only(top: 16),
    );
  }
}

/// The search field on [ActivitiesScreen].
class ActivitiesSearchField extends ConsumerWidget {
  /// The search field on [ActivitiesScreen].
  const ActivitiesSearchField({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return TextField(
      readOnly: true,
      onTap: () => Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute(builder: (final context) => const ActivitiesSearch()),
      ),
      onChanged: (final value) =>
          (ref.read(activitiesSearchProvider)).state = value,
      decoration: InputDecorationStyle.search
          .fromTheme(theme, hintText: TR.activitiesSearch.tr())
          .copyWith(
            border: const OutlineInputBorder(borderSide: BorderSide.none),
            errorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
            enabledBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            focusedBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            disabledBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            focusedErrorBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.all(8),
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                bottom: 4,
                left: 4 * mediaQuery.textScaleFactor,
              ),
              child: Center(
                child: FontIcon(
                  FontIconData(
                    IconsCG.search,
                    color: theme.hintColor,
                    height: 24 * mediaQuery.textScaleFactor,
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

/// The loader of the [ActivityCardContainer] for the each
/// [ActivityCardContainer.activity].
final StateProviderFamily<bool, int> activityCardLoadingProvider =
    StateProvider.family<bool, int>(
  (final ref, final activityId) => false,
);

/// The transition between [ActivityCard] and [ActivityScreenCard].
class ActivityCardContainer extends StatelessWidget {
  /// The transition between [ActivityCard] and [ActivityScreenCard].
  const ActivityCardContainer(
    final this.activity, {
    final this.onMain = false,
    final Key? key,
  }) : super(key: key);

  /// The activity to display in this widget.
  final CombinedActivityModel activity;

  /// If this card is placed on main.
  final bool onMain;

  @override
  Widget build(final BuildContext context) {
    FutureOr<void> Function()? onPressed(
      final BuildContext context,
      final WidgetRef ref, {
      required final bool fullscreen,
      required final bool Function() isMounted,
      final UserRecordModel? appliedRecord,
    }) {
      final theme = Theme.of(context);
      final navigator = Navigator.of(context);
      final rootNavigator = Navigator.of(context, rootNavigator: true);

      final user = ref.watch(userProvider);
      final currentTime = (ref.watch(activitiesCurrentTimeProvider)).maybeWhen(
        data: (final currentTime) => currentTime,
        orElse: DateTime.now,
      );
      final timeLeftBeforeStart = activity.item0.date.difference(currentTime);
      final isLoading =
          ref.watch(activityCardLoadingProvider(activity.item0.id));
      final loadingData =
          ref.watch(loadingDataProvider(NavigationScreen.schedule));
      final isLoadingList = loadingData.state.contains(activity.item0.id) ||
          loadingData.state.length >= ActivitiesScreen.maxLoadingCount;

      Future<void> logFirebase(final String name) => analytics.logEvent(
            name: name,
            parameters: <String, String>{
              'studio': translit(activity.item1.item1.studioName),
              'class': activity.item0.service.title,
              'trainer': translit(activity.item2.item1.trainerName),
              'date_time': faTime(ref.read(smServerTimeProvider)),
            },
          );

      Future<bool> cancelBook(final UserRecordModel appliedRecord) async {
        isLoading.state = true;
        loadingData.update(
          (final loadingData) => <Object>[...loadingData, activity.item0.id],
        );
        try {
          await logFirebase(
            fullscreen ? FAKeys.cancelBookScreen : FAKeys.cancelBook,
          );
          final SMRecordModel? smRecord;
          try {
            smRecord = await (ref.read(businessLogicProvider)).cancelBook(
              recordId: appliedRecord.id,
              recordDate: appliedRecord.date,
              userPhone: user!.phone,
              discount: ref.read(onCancelDiscountProvider),
            );
          } finally {
            loadingData.update(
              (final loadingData) => <Object>[
                for (final data in loadingData)
                  if (data != activity.item0.id) data
              ],
            );
          }
          if (smRecord != null) {
            Widget refundedBody(final String body, final String button) =>
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(body, style: theme.textTheme.subtitle2),
                      const SizedBox(height: 24),
                      BottomButtons<dynamic>(
                        firstText: button,
                        onFirstPressed: (final context, final ref) async {
                          try {
                            (ref.read(navigationProvider))
                                .jumpToTab(NavigationScreen.profile.index);
                          } finally {
                            await Navigator.of(context).maybePop();
                          }
                        },
                      ),
                    ],
                  ),
                );

            switch (smRecord.payment) {
              case ActivityPaidBy.deposit:
              case ActivityPaidBy.regular:
                ref.refresh(smUserDepositProvider);
                await Future.wait(<Future<void>>[
                  ref.read(smUserDepositProvider.future),
                  showRefundedModalBottomSheet(
                    context: context,
                    title: TR.cancelBookDepositTitle.tr(),
                    child: refundedBody(
                      TR.cancelBookDepositBody.tr(),
                      TR.cancelBookDepositButton.tr(),
                    ),
                  ),
                ]);
                continue all;
              case ActivityPaidBy.abonement:
                await Future.wait(<Future<void>>[
                  ref.read(userAbonementsProvider.notifier).refresh(),
                  showRefundedModalBottomSheet(
                    context: context,
                    title: TR.cancelBookAbonementTitle.tr(),
                    child: refundedBody(
                      TR.cancelBookAbonementBody.tr(),
                      TR.cancelBookAbonementButton.tr(),
                    ),
                  ),
                ]);
                continue all;
              all:
              case ActivityPaidBy.none:
                if (loadingData.state.isEmpty) {
                  await ref.read(userRecordsProvider.notifier).refresh();
                }
                navigator.popUntil(Routes.root.withName);
            }
            return true;
          }
        } on CancelBookException catch (exception) {
          logger.e(exception.type, exception);
          switch (exception.type) {
            case CancelBookExceptionType.notFound:
              if (loadingData.state.isEmpty) {
                await ref.read(userRecordsProvider.notifier).refresh();
              }
              break;
            case CancelBookExceptionType.timeHacking:
          }
        } finally {
          isLoading.state = false;
          if (fullscreen && onMain) {
            await navigator.maybePop();
          }
        }
        return false;
      }

      Future<bool> book() async {
        isLoading.state = true;
        loadingData.update(
          (final loadingData) => <Object>[...loadingData, activity.item0.id],
        );
        try {
          await logFirebase(fullscreen ? FAKeys.bookScreen : FAKeys.book);
          final Tuple2<RecordModel, BookResult> result;
          try {
            final businessLogic = ref.read(businessLogicProvider);
            result = await businessLogic.book(
              timeout: bookTimeout,
              navigator: rootNavigator,
              user: user!,
              activity: activity,
              useDiscount: ref.read(discountProvider),
              abonements: ref.read(combinedAbonementsProvider),
              updateAndTryAgain: isMounted()
                  ? (final record) async {
                      await Future.wait(<Future<void>>[
                        ref.read(userAbonementsProvider.notifier).refresh(),
                        ref.read(smUserAbonementsProvider.notifier).refresh()
                      ]);
                      return businessLogic.book(
                        prevRecord: record,
                        navigator: rootNavigator,
                        user: user,
                        activity: activity,
                        useDiscount: ref.read(discountProvider),
                        abonements: ref.read(combinedAbonementsProvider),
                      );
                    }
                  : null,
            );
          } finally {
            loadingData.update(
              (final loadingData) => <Object>[
                for (final data in loadingData)
                  if (data != activity.item0.id) data
              ],
            );
          }

          logger.i(result.item1);
          switch (result.item1) {
            case BookResult.depositDiscount:
            case BookResult.depositRegular:
              ref.refresh(smUserDepositProvider);
              await ref.read(smUserDepositProvider.future);
              continue all;
            case BookResult.newAbonement:
              unawaited(
                ref.read(smUserAbonementsProvider.notifier).refresh(ref),
              );
              continue abonement;
            abonement:
            case BookResult.abonement:
              unawaited(ref.read(userAbonementsProvider.notifier).refresh(ref));
              continue all;
            all:
            case BookResult.discount:
            case BookResult.regular:
              if (loadingData.state.isEmpty) {
                unawaited(ref.read(userRecordsProvider.notifier).refresh(ref));
              }
              await rootNavigator.push<void>(
                MaterialPageRoute(
                  builder: (final context) => SuccessfulBookScreen(
                    activity: activity,
                    record: result.item0,
                    abonement: result.item1 == BookResult.newAbonement,
                  ),
                ),
              );
              navigator.popUntil(Routes.root.withName);
              rootNavigator.popUntil(Routes.root.withName);
          }
          return true;
        } on BookException catch (exception) {
          logger.e(exception.type, exception);
          if (exception.type != BookExceptionType.dismiss) {
            await Future.wait(<Future<void>>[
              if (isMounted() &&
                  loadingData.state.isEmpty &&
                  exception.type == BookExceptionType.alreadyApplied)
                ref.read(userRecordsProvider.notifier).refresh(ref),
              rootNavigator.push<void>(
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
                            navigator.popUntil(Routes.root.withName);
                            rootNavigator.popUntil(Routes.root.withName);
                          }
                        : exception.type == BookExceptionType.alreadyApplied ||
                                exception.type == BookExceptionType.full
                            ? () {
                                navigator.popUntil(Routes.root.withName);
                                rootNavigator.popUntil(Routes.root.withName);
                              }
                            : null,
                  ),
                ),
              )
            ]);
          }
        } finally {
          isLoading.state = false;
        }
        return false;
      }

      Future<void> addToWishList() async {
        isLoading.state = true;
        loadingData.update(
          (final loadingData) => <Object>[...loadingData, activity.item0.id],
        );
        try {
          await logFirebase(
            fullscreen ? FAKeys.wishlistScreen : FAKeys.wishlist,
          );
          final userWishlist = await smStretching.getWishlist(user!.phone);
          final alreadyApplied = userWishlist.any(
            (final userWishlist) =>
                userWishlist.activityId == activity.item0.id,
          );
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

          await rootNavigator.push(
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
          isLoading.state = false;
          loadingData.update(
            (final loadingData) => <Object>[
              for (final data in loadingData)
                if (data != activity.item0.id) data
            ],
          );
        }
      }

      if (!isLoadingList && !isLoading.state) {
        return user == null
            ? () => rootNavigator.pushNamed(Routes.auth.name)
            : appliedRecord != null
                ? !appliedRecord.yanked && timeLeftBeforeStart.inHours < 12
                    ? null
                    : () => cancelBook(appliedRecord)
                : activity.item0.recordsLeft <= 0
                    ? addToWishList
                    : book;
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
      closedBuilder: (final context, final action) => Consumer(
        builder: (final context, final ref, final child) => Loader(
          isLoading:
              ref.watch(activityCardLoadingProvider(activity.item0.id)).state,
          child: ActivityCard(
            activity,
            onMain: onMain,
            onOpenButtonPressed: action,
            onPressed: (
              final context,
              final ref, {
              required final isMounted,
              final appliedRecord,
            }) =>
                onPressed(
              context,
              ref,
              isMounted: isMounted,
              appliedRecord: appliedRecord,
              fullscreen: false,
            ),
          ),
        ),
      ),
      openBuilder: (final context, final action) => Consumer(
        builder: (final context, final ref, final child) => Loader(
          willNotPopOnLoad: true,
          isLoading:
              ref.watch(activityCardLoadingProvider(activity.item0.id)).state,
          child: ActivityScreenCard(
            activity,
            onMain: onMain,
            onBackButtonPressed: action,
            onPressed: (
              final context,
              final ref, {
              required final isMounted,
              final appliedRecord,
            }) =>
                onPressed(
              context,
              ref,
              isMounted: isMounted,
              appliedRecord: appliedRecord,
              fullscreen: true,
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
        ..add(DiagnosticsProperty<bool>('onMain', onMain)),
    );
  }
}

/// The activity card to display on [ActivitiesScreen].
class ActivityCard extends HookConsumerWidget {
  /// The activity card to display on [ActivitiesScreen].
  const ActivityCard(
    final this.activity, {
    required final this.onPressed,
    required final this.onOpenButtonPressed,
    final this.onMain = false,
    final Key? key,
  }) : super(key: key);

  /// The activity to display in this widget.
  final CombinedActivityModel activity;

  /// The callback with found record that returns a callback on this card.
  final ActivityAction onPressed;

  /// The callback on the back button of this card.
  final void Function() onOpenButtonPressed;

  /// If this card is gonna be put on main screen.
  final bool onMain;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final grey = theme.colorScheme.onSurface.withOpacity(2 / 3);

    final isMounted = useIsMounted();
    final appliedRecord = ref.watch(
      userRecordsProvider.select((final userRecords) {
        for (final record in userRecords) {
          if (record.activityId == activity.item0.id && !record.deleted) {
            return record;
          }
        }
      }),
    );

    final _onPressed = onPressed(
      context,
      ref,
      appliedRecord: appliedRecord,
      isMounted: isMounted,
    );
    return Padding(
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
            padding: const EdgeInsets.all(16).copyWith(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /// Time
                    Text(
                      <Object>[
                        activity.item0.date.hour,
                        activity.item0.date.minute.toString().padLeft(2, '0')
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
                      style: theme.textTheme.headline6?.copyWith(color: grey),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    /// Trainer Avatar
                    Flexible(
                      child: CachedNetworkImage(
                        imageUrl: activity.item2.item0.avatar,
                        cacheKey: 'x52_${activity.item2.item0.avatar}',
                        height: 40 * mediaQuery.textScaleFactor,
                        width: 40 * mediaQuery.textScaleFactor,
                        memCacheWidth: 52,
                        memCacheHeight: 52,
                        fadeInDuration: Duration.zero,
                        fadeOutDuration: Duration.zero,
                        imageBuilder: (final context, final imageProvider) =>
                            CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.transparent,
                          radius: 20 * mediaQuery.textScaleFactor,
                          foregroundImage: imageProvider,
                        ),
                        errorWidget:
                            (final context, final url, final dynamic error) =>
                                const SizedBox.shrink(),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            style:
                                theme.textTheme.caption?.copyWith(color: grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          /// Studio Name
                          EmojiText(
                            // appliedRecord?.online != null
                            //     ? '🔗 ${TR.homeClassesOnline.tr()}'
                            //     :
                            activity.item1.item1.studioName,
                            style:
                                theme.textTheme.caption?.copyWith(color: grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Flexible(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Opacity(
                            opacity: _onPressed == null ? 1 / 2 : 1,
                            child: SizedBox(
                              height: 24,
                              width: onMain ? 120 : 160,
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
                                onPressed: _onPressed,
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ActivityCardExtraData(
                  activity,
                  appliedRecord: appliedRecord,
                  onMain: onMain,
                )
              ],
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
        ..add(ObjectFlagProperty<ActivityAction>.has('onPressed', onPressed))
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

/// The extra data for the [ActivityCard].
class ActivityCardExtraData extends HookConsumerWidget {
  /// The extra data for the [ActivityCard].
  const ActivityCardExtraData(
    final this.activity, {
    required final this.appliedRecord,
    required final this.onMain,
    final Key? key,
  }) : super(key: key);

  /// The activity to display in this widget.
  final CombinedActivityModel activity;

  /// The applied record for [activity].
  final UserRecordModel? appliedRecord;

  /// The same as [ActivityCard.onMain].
  final bool onMain;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final date = activity.item0.date;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final locale = ref.watch(localeProvider);
    final isToday = ref.watch(
      activitiesCurrentTimeProvider.select(
        (final currentTime) {
          final time = currentTime.when(
            data: (final currentTime) => currentTime,
            loading: (final currentTime) => DateTime.now(),
            error: (final error, final stackTrace, final currentTime) =>
                DateTime.now(),
          );
          return date.year == time.year &&
              date.month == time.month &&
              date.day == time.day;
        },
      ),
    );

    final timeLeftBeforeStart = ref.watch(
      activitiesCurrentTimeProvider.select(
        (final currentTime) => activity.item0.date.difference(
          currentTime.when(
            data: (final currentTime) => currentTime,
            loading: (final currentTime) => DateTime.now(),
            error: (final error, final stackTrace, final currentTime) =>
                DateTime.now(),
          ),
        ),
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 90 * mediaQuery.textScaleFactor,
      ),
      child: Column(
        mainAxisAlignment:
            onMain ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (appliedRecord != null) ...<Widget>[
            /// Extra Data on Main
            if (onMain)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  /// Activity Date
                  Material(
                    color: appliedRecord!.yanked
                        ? theme.colorScheme.error
                        : isToday
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.primary,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ) *
                          mediaQuery.textScaleFactor,
                      child: Text(
                        isToday
                            ? TR.homeClassesToday.tr()
                            : DateFormat.MMMMd(locale.toString())
                                .format(activity.item0.date),
                        style: theme.textTheme.overline?.copyWith(
                          color: theme.colorScheme.surface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Activity Weekday or Error
                  if (appliedRecord!.yanked)
                    Flexible(
                      child: Text(
                        TR.activitiesCardError.tr(),
                        style: theme.textTheme.overline
                            ?.copyWith(color: theme.colorScheme.error),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    )
                  else if (!isToday)
                    Text(
                      () {
                        var weekDay =
                            DateFormat.EEEE(locale.toString()).format(date);
                        if (weekDay.isNotEmpty) {
                          weekDay = weekDay.substring(0, 1).toUpperCase() +
                              weekDay.substring(1).toLowerCase();
                        }
                        return weekDay;
                      }(),
                      style: theme.textTheme.overline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    )
                ],
              ),

            /// If it is too late too cancel the activity.
            if (!appliedRecord!.yanked && timeLeftBeforeStart.inHours < 12)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (!onMain)
                    EmojiText(
                      '⏱',
                      style: TextStyle(color: theme.hintColor),
                    ),
                  Flexible(
                    child: Text(
                      TR.activities12h.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.overline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 1,
                    ),
                  ),
                ],
              )
          ] else if (!onMain)
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: ActivityCardRecordsCount(
                activity.item0.recordsLeft,
                showDefault: false,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<CombinedActivityModel>('activity', activity))
        ..add(
          DiagnosticsProperty<UserRecordModel>(
            'appliedRecord',
            appliedRecord,
          ),
        ),
    );
    properties.add(DiagnosticsProperty<bool>('onMain', onMain));
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
            style: theme.textTheme.overline,
          ),
        if (recordsCount <= 3 || showDefault)
          Flexible(
            child: Text(
              TR.activitiesFullness.plural(max(0, recordsCount)),
              textAlign: TextAlign.center,
              style: theme.textTheme.overline
                  ?.copyWith(color: theme.colorScheme.onSurface),
            ),
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

/// The callback on the [ActivityCard] and [ActivityScreenCard].
typedef ActivityAction = FutureOr<void> Function()? Function(
  BuildContext context,
  WidgetRef ref, {
  required bool Function() isMounted,
  UserRecordModel? appliedRecord,
});

/// The fullscreen version of the [ActivityCard].
class ActivityScreenCard extends HookConsumerWidget {
  /// The fullscreen version of the [ActivityCard].
  const ActivityScreenCard(
    final this.activity, {
    required final this.onPressed,
    required final this.onBackButtonPressed,
    final this.onMain = false,
    final Key? key,
  }) : super(key: key);

  /// The activity to display in this widget.
  final CombinedActivityModel activity;

  /// The callback with found record that returns a callback on this card.
  final ActivityAction onPressed;

  /// The callback on the back button of this card.
  final void Function() onBackButtonPressed;

  /// If this card is gonna be put on main screen.
  final bool onMain;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final images = activity.item3.item1.gallery.split(',');

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

    final isMounted = useIsMounted();
    final timeLeftBeforeStart = ref.watch(
      activitiesCurrentTimeProvider.select(
        (final currentTime) => activity.item0.date.difference(
          currentTime.maybeWhen(
            data: (final currentTime) => currentTime,
            orElse: DateTime.now,
          ),
        ),
      ),
    );

    final appliedRecord = ref.watch(
      userRecordsProvider.select((final userRecords) {
        for (final record in userRecords) {
          if (record.activityId == activity.item0.id && !record.deleted) {
            return record;
          }
        }
      }),
    );

    return ContentScreen(
      type: onMain ? NavigationScreen.home : NavigationScreen.schedule,
      onBackButtonPressed: onBackButtonPressed,
      title: activity.item3.item0.translation,
      subtitle: formatSubTitle(),
      secondSubtitle: activity.item1.item1.studioAddress,
      trailing: Padding(
        padding: const EdgeInsets.only(left: 12, top: 8),
        child: SizedBox(
          width: 56 * mediaQuery.textScaleFactor,
          child: ActivityCardRecordsCount(activity.item0.recordsLeft),
        ),
      ),
      carousel: CarouselSlider.builder(
        options: CarouselOptions(
          height: 280 + mediaQuery.viewPadding.top,
          viewportFraction: 1,
          enableInfiniteScroll: images.length > 1,
        ),
        itemCount: images.length,
        itemBuilder: (final context, final index, final realIndex) =>
            CachedNetworkImage(
          imageUrl: images.elementAt(index),
          fit: BoxFit.cover,
          errorWidget: (final context, final url, final dynamic error) =>
              const SizedBox.shrink(),
        ),
      ),
      paragraphs: <ContentParagraph>[
        if (activity.item3.item1.classInfo != null)
          ContentParagraph(body: activity.item3.item1.classInfo!),
        if (activity.item3.item1.takeThis != null)
          ContentParagraph(
            title: TR.activitiesActivityImportantInfo.tr(),
            body: activity.item3.item1.takeThis!,
            expandable: false,
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
          onFirstPressed: () {
            final _onPressed = onPressed(
              context,
              ref,
              appliedRecord: appliedRecord,
              isMounted: isMounted,
            );
            return _onPressed != null
                ? (final dynamic context, final dynamic ref) => _onPressed()
                : null;
          }(),
          secondText: appliedRecord != null && !appliedRecord.yanked
              ? TR.activitiesActivityAddToCalendar.tr()
              : '',
          onSecondPressed: appliedRecord != null && !appliedRecord.yanked
              ? (final context, final ref) => activity.add2Calendar()
              : null,
        ),
      ],
      bottomNavigationBar: appliedRecord != null &&
              (timeLeftBeforeStart.inHours < 12 || appliedRecord.yanked)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16)
                  .copyWith(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      appliedRecord.yanked
                          ? TR.activitiesActivityCancelError.tr()
                          : TR.activitiesActivityCancelBook12h.tr(),
                      style: theme.textTheme.headline6?.copyWith(
                        color: appliedRecord.yanked
                            ? theme.colorScheme.error
                            : theme.hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
            closedBuilder: (final context, final action) => SizedBox(
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
                  imageBuilder: (final context, final imageProvider) =>
                      CircleAvatar(
                    radius: 28,
                    foregroundImage: imageProvider,
                  ),
                  placeholder: (final context, final url) => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  errorWidget:
                      (final context, final url, final dynamic error) =>
                          const SizedBox.shrink(),
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
            ),
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
        ..add(ObjectFlagProperty<ActivityAction>.has('onPressed', onPressed))
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
class ActivitiesDateFilterCard extends HookConsumerWidget {
  /// The card for the date picker on [ActivitiesScreen].
  const ActivitiesDateFilterCard(
    final this.day, {
    required final this.selected,
    required final this.onSelected,
    final Key? key,
  }) : super(key: key);

  /// The date to show on this card.
  final SpecificDay day;

  /// If this card is currently selected
  final bool selected;

  /// The callback on this card.
  final void Function() onSelected;

  /// The margin of this widget.
  static const EdgeInsets padding = EdgeInsets.all(4);

  /// The size of this widget.
  static Size size(
    final ThemeData theme, [
    final double textScaleFactor = 1,
  ]) {
    final overline = theme.textTheme.overline!;
    final overlineFontSize = overline.height! * overline.fontSize!;
    final subtitle1 = theme.textTheme.subtitle1!;
    final subtitle2 = theme.textTheme.subtitle2!;
    final maxSubtitleFontSize = max(
      subtitle1.height! * subtitle1.fontSize!,
      subtitle2.height! * subtitle2.fontSize!,
    );
    final height = padding.vertical +
        (maxSubtitleFontSize + overlineFontSize) * textScaleFactor;
    return Size(height - 4, height);
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final weekFormat = useMemoized(
      () => DateFormat.E(ref.watch(localeProvider).toString()),
    );
    return InkWell(
      onTap: !selected ? onSelected : null,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Material(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        color: selected ? theme.colorScheme.onSurface : Colors.transparent,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /// Weekday
              Text(
                weekFormat.format(DateTime(day.item0, day.item1, day.item2)),
                style: theme.textTheme.overline?.copyWith(
                  color: selected ? theme.colorScheme.surface : theme.hintColor,
                ),
              ),

              /// Day
              Expanded(
                child: Text(
                  day.last.toString(),
                  style: (selected
                          ? theme.textTheme.subtitle1
                          : theme.textTheme.subtitle2)
                      ?.copyWith(
                    color: selected
                        ? theme.colorScheme.surface
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
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
        ..add(DiagnosticsProperty<SpecificDay>('day', day))
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
  final mediaQuery = MediaQuery.of(context);
  return showMaterialModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (final context) => BottomSheetBase(
      borderRadius: 14,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppBar(
            primary: false,
            toolbarHeight: 40 * mediaQuery.textScaleFactor,
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
    ),
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
        //                      margin: const EdgeInsets.symmetric(vertical: 6),
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
                      builder: (final context, final ref, final child) =>
                          FilterButton(
                        text: time.translate(),
                        borderColor: Colors.grey.shade300,
                        backgroundColor: theme.colorScheme.surface,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        selected: ref.watch(
                          activitiesTimeFilterProvider.select(
                            (final selectedTime) => selectedTime.contains(time),
                          ),
                        ),
                        onSelected: (final value) {
                          final timeNotifier = ref.read(
                            activitiesTimeFilterProvider.notifier,
                          );
                          value
                              ? timeNotifier.add(time)
                              : timeNotifier.remove(time);
                        },
                      ),
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
                        builder: (final context, final ref, final child) =>
                            FilterButton(
                          text: trainer.trainerName,
                          avatarUrl: trainer.trainerPhoto,
                          borderColor: Colors.grey.shade300,
                          backgroundColor: theme.colorScheme.surface,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          selected: ref.watch(
                            activitiesTrainersFilterProvider.select(
                              (final selectedTrainers) =>
                                  selectedTrainers.contains(trainer),
                            ),
                          ),
                          onSelected: (final value) {
                            final trainersNotifier = ref.read(
                              activitiesTrainersFilterProvider.notifier,
                            );
                            value
                                ? trainersNotifier.add(trainer)
                                : trainersNotifier.remove(trainer);
                          },
                        ),
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
    final searchKey = useMemoized(GlobalKey.new);

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
      combinedClassesProvider.select(
        (final classes) => classes.where(
          (final _class) =>
              search.isEmpty ||
              (_class.item0.translation.toLowerCase())
                  .contains(search.toLowerCase()) ||
              (_class.item1.classesName.toLowerCase())
                  .contains(search.toLowerCase()),
        ),
      ),
    );
    final trainers = ref.watch(
      smTrainersProvider.select(
        (final smTrainers) => search.isEmpty
            ? const Iterable<SMTrainerModel>.empty()
            : smTrainers.where(
                (final smTrainer) => (smTrainer.trainerName.toLowerCase())
                    .contains(search.toLowerCase()),
              ),
      ),
    );
    final studios = ref.watch(
      combinedStudiosProvider.select(
        (final smStudios) => search.isEmpty
            ? const Iterable<CombinedStudioModel>.empty()
            : smStudios.where(
                (final smStudio) => (smStudio.item1.studioName.toLowerCase())
                    .contains(search.toLowerCase()),
              ),
      ),
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
              ? CachedNetworkImage(
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
                  imageBuilder: (final context, final imageProvider) =>
                      Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      image: DecorationImage(image: imageProvider),
                    ),
                  ),
                  errorWidget:
                      (final context, final url, final dynamic error) =>
                          const SizedBox.shrink(),
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

    final rootNavigator = Navigator.of(context);
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
              await notifier.clear();
              if (!notifier.state.contains(studio)) {
                await notifier.add(studio);
              }
              await rootNavigator.maybePop();
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
              await rootNavigator.maybePop();
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
              await rootNavigator.maybePop();
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
  const ActivitiesScreenDayPicker(final this._context);
  final BuildContext _context;

  @override
  double get minExtent {
    final size = ActivitiesDateFilterCard.size(
      Theme.of(_context),
      MediaQuery.of(_context).textScaleFactor,
    );
    return size.height + spacing;
  }

  @override
  double get maxExtent => minExtent;

  /// The margin of this widget.
  static const double spacing = 16;

  @override
  Widget build(
    final BuildContext context,
    final double shrinkOffset,
    final bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final cardSize = ActivitiesDateFilterCard.size(theme, textScaleFactor);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: spacing / 2),
        child: Consumer(
          builder: (final context, final ref, final child) {
            final activitiesDays = ref.watch(
              activitiesDaysProvider
                  .select((final activitiesDays) => activitiesDays),
            );
            return ListView.builder(
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: spacing / 2),
              itemCount: activitiesDays.length,
              itemExtent: cardSize.width + spacing,
              itemBuilder: (final context, final index) {
                final date = activitiesDays.elementAt(index);
                return Consumer(
                  builder: (final context, final ref, final child) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: spacing / 2),
                    child: ActivitiesDateFilterCard(
                      date,
                      selected: ref.watch(
                        activitiesDayProvider.notifier
                            .select((final notifier) => notifier.state == date),
                      ),
                      onSelected: () =>
                          ref.read(activitiesDayProvider).state = date,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(final ActivitiesScreenDayPicker oldDelegate) => false;
}
