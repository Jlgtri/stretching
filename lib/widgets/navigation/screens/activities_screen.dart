import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:darq/darq.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/company_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/providers/yclients_providers.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/focus_wrapper.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/components/filters.dart';
import 'package:stretching/widgets/navigation/components/scrollbar.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

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
final StateNotifierProvider<SaveToHiveIterableNotifier<ClassCategory, String>,
        Iterable<ClassCategory>> activitiesCategoriesFilterProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<ClassCategory, String>,
        Iterable<ClassCategory>>((final ref) {
  return SaveToHiveIterableNotifier<ClassCategory, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_categories',
    converter: const StringToIterableConverter(
      IterableConverter(EnumConverter(ClassCategory.values)),
    ),
    defaultValue: const Iterable<ClassCategory>.empty(),
  );
});

/// The provider of filters for [SMTrainerModel].
final StateNotifierProvider<
        SaveToHiveIterableNotifier<CombinedTrainerModel, String>,
        Iterable<CombinedTrainerModel>> activitiesTrainersFilterProvider =
    StateNotifierProvider<
        SaveToHiveIterableNotifier<CombinedTrainerModel, String>,
        Iterable<CombinedTrainerModel>>((final ref) {
  return SaveToHiveIterableNotifier<CombinedTrainerModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_trainers',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(trainerIdConverterProvider)),
    ),
    defaultValue: const Iterable<CombinedTrainerModel>.empty(),
  );
});

/// The filter for the [ActivityModel] time.
enum ActivityTime {
  /// Means the time is before 16:45.
  before,

  /// Means the time is after 16:45.
  after
}

/// The extra data provided for [ActivityTime].
extension ActivityTimeData on ActivityTime {
  /// Return the translation of this time for the specified [time].
  String translate(final TimeOfDay time) {
    return '${TR.miscFilterTime}_${enumToString(this)}'.tr(
      args: <String>[
        <Object>[time.hour, time.minute.toString().padLeft(2, '0')].join(':')
      ],
    );
  }

  /// Check if [date] is [before] or [after] `16:45` on it's day.
  bool isWithin(final DateTime date) {
    final time = DateTime(date.year, date.month, date.day, 16, 45);
    switch (this) {
      case ActivityTime.before:
        return date.isBefore(time);
      case ActivityTime.after:
        return date.isAfter(time);
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
    StateProvider<DateTime>((final ref) => DateTime.now());

/// The provider of search query on [ActivitiesScreen].
final StateProvider<String> activitiesSearchProvider =
    StateProvider<String>((final ref) => '');

/// The provider of count of activities filters.
final Provider<int> activitiesFiltersCountProvider = Provider<int>((final ref) {
  int len(final Iterable<Object> iterable) => iterable.length;
  return (ref.watch(activitiesTimeFilterProvider.select(len)) +
          ref.watch(activitiesCategoriesFilterProvider.select(len)) +
          ref.watch(activitiesStudiosFilterProvider.select(len)) +
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
  final now = DateTime.now();
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
            (trainers.isEmpty || trainers.contains(activity.item2)) &&
            (categories.isEmpty ||
                categories.all(activity.item0.labels.contains)) &&
            (time.isEmpty ||
                time.all((final time) => time.isWithin(activity.item0.date)));
      }).toList()
        ..sort((final activityA, final activityB) {
          return activityA.item0.compareTo(activityB.item0);
        });
    }),
  );
});

/// The screen for the [NavigationScreen.trainers].
class ActivitiesScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.trainers].
  const ActivitiesScreen({final Key? key}) : super(key: key);

  /// The height of the categories picker widget.
  static const double categoriesHeight = 84;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(activitiesCategoriesFilterProvider);

    final tempNow = DateTime.now();
    final firstNow = useRef(tempNow);
    final now = useMemoized(() => firstNow.value = DateTime.now(), <Object>[
      tempNow.year != firstNow.value.year ||
          tempNow.month != firstNow.value.month ||
          tempNow.day != firstNow.value.day
    ]);
    final day = ref.watch(activitiesDayProvider).state;

    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final searchKey = useMemoized(() => GlobalKey());

    final areActivitiesPresent = ref.watch(
      scheduleProvider.select((final activities) => activities.isNotEmpty),
    );
    final filtersCount = ref.watch(activitiesFiltersCountProvider);
    final activities = ref.watch(filteredActivitiesProvider);

    void resetFilters() {
      ref.read(activitiesTimeFilterProvider.notifier).state =
          const Iterable<ActivityTime>.empty();
      ref.read(activitiesCategoriesFilterProvider.notifier).state =
          const Iterable<ClassCategory>.empty();
      ref.read(activitiesStudiosFilterProvider.notifier).state =
          const Iterable<CombinedStudioModel>.empty();
      ref.read(activitiesTrainersFilterProvider.notifier).state =
          const Iterable<CombinedTrainerModel>.empty();
    }

    return FocusWrapper(
      unfocussableKeys: <GlobalKey>[searchKey],
      child: CustomDraggableScrollBar(
        itemsCount: activities.length,
        visible: activities.length > 4,
        leadingChildHeight:
            InputDecorationStyle.search.toolbarHeight + categoriesHeight + 44,
        labelTextBuilder: (final index) {
          final activity = activities.elementAt(index);
          return Text(
            <Object>[
              activity.item0.date.hour,
              activity.item0.date.minute.toString().padLeft(2, '0')
            ].join(':'),
            style: theme.textTheme.subtitle2
                ?.copyWith(color: theme.colorScheme.surface),
          );
        },
        builder: (final context, final scrollController) {
          return CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              /// A search field, categories and dates.
              SliverAppBar(
                primary: false,
                backgroundColor: Colors.transparent,
                toolbarHeight: InputDecorationStyle.search.toolbarHeight +
                    categoriesHeight,
                titleSpacing: 0,
                title: Material(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                key: searchKey,
                                cursorColor: theme.hintColor,
                                style: theme.textTheme.bodyText2,
                                controller: searchController,
                                focusNode: searchFocusNode,
                                onChanged: (final value) =>
                                    (ref.read(activitiesSearchProvider)).state =
                                        value,
                                decoration:
                                    InputDecorationStyle.search.fromTheme(
                                  theme,
                                  hintText: TR.activitiesSearch.tr(),
                                  onSuffix: () {
                                    ref.read(activitiesSearchProvider).state =
                                        '';
                                    searchController.clear();
                                    searchFocusNode.unfocus();
                                  },
                                ),
                              ),
                            ),
                            Badge(
                              padding: const EdgeInsets.all(4),
                              animationType: BadgeAnimationType.scale,
                              animationDuration:
                                  const Duration(milliseconds: 300),
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
                                    onResetPressed: resetFilters,
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
                            )
                          ],
                        ),
                      ),
                      categories.getSelectorWidget(
                        theme,
                        (final category, final value) {
                          final activitiesNotifier = ref.read(
                            activitiesCategoriesFilterProvider.notifier,
                          );
                          value
                              ? activitiesNotifier.add(category)
                              : activitiesNotifier.remove(category);
                        },
                      )
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(44),
                  child: SizedBox(
                    height: 44,
                    child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: DateTime.daysPerWeek * 2,
                      itemExtent: 56,
                      itemBuilder: (final context, final index) {
                        final date = now.add(Duration(days: index));
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
                    ),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (final context, final index) {
                    final activity = activities.elementAt(index);
                    return ActivityCard(
                      activity,
                      timeLeftBeforeStart: activity.item0.date.difference(now),
                    );
                  },
                  childCount: activities.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The activity card to display on [ActivitiesScreen].
class ActivityCard extends ConsumerWidget {
  /// The activity card to display on [ActivitiesScreen].
  const ActivityCard(
    final this.activity, {
    required final this.timeLeftBeforeStart,
    final Key? key,
  }) : super(key: key);

  /// The activity to display in this widget.
  final CombinedActivityModel activity;

  /// The amount of time left before this [activity] is starting.
  final Duration timeLeftBeforeStart;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final duration = Duration(seconds: activity.item0.length);
    final grey = theme.colorScheme.onSurface.withOpacity(2 / 3);
    final recordLeftCount =
        activity.item0.capacity - activity.item0.recordsCount;
    final unauthorized = ref.watch(unauthorizedProvider);
    final applied = !unauthorized &&
        ref.watch(
          userRecordsProvider.select((final userRecords) {
            return userRecords
                .map((final record) => record.activityId)
                .contains(activity.item0.id);
          }),
        );
    return Container(
      height: 124,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Column(
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
                  duration.inMinutes < 60
                      ? TR.activitiesDurationMinuteShort
                          .tr(args: <String>[duration.inMinutes.toString()])
                      : TR.activitiesDurationHour.plural(
                          duration.inHours,
                          args: <String>[duration.inHours.toString()],
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
            flex: 2,
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
                      style: theme.textTheme.caption?.copyWith(color: grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    /// Studio Name
                    Text(
                      activity.item1.item1.studioName,
                      style: theme.textTheme.caption?.copyWith(color: grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Flexible(
                  child: SizedBox(
                    height: 24,
                    child: TextButton(
                      style: (TextButtonStyle.light.fromTheme(theme)).copyWith(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 4),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        textStyle: MaterialStateProperty.all(
                          theme.textTheme.caption,
                        ),
                      ),
                      onPressed: unauthorized
                          ? () => Navigator.of(context, rootNavigator: true)
                              .pushNamed(Routes.auth.name)
                          : applied
                              ? timeLeftBeforeStart.inHours < 12
                                  ? null
                                  : () {}
                              : recordLeftCount <= 0
                                  ? () {}
                                  : () => ref.read(smUserProvider.future),
                      child: Text(
                        recordLeftCount > 0
                            ? applied
                                ? TR.activitiesCancel.tr()
                                : TR.activitiesApply.tr()
                            : TR.activitiesWaitingList.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (timeLeftBeforeStart.inHours < 12 && applied) ...[
                    EmojiText('⏱'),
                    Text(
                      TR.activities12h.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.overline,
                    ),
                  ] else if (recordLeftCount <= 0) ...[
                    EmojiText('😱'),
                    Text(
                      TR.activitiesFullnessFull.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.overline
                          ?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ] else if (recordLeftCount <= 5) ...[
                    EmojiText('🔥'),
                    Text(
                      TR.activitiesFullnessLow.plural(
                        recordLeftCount,
                        args: <String>[recordLeftCount.toString()],
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.overline
                          ?.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ],
                ],
              ),
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
          DiagnosticsProperty<Duration>(
            'timeLeftBeforeStart',
            timeLeftBeforeStart,
          ),
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
                  letterSpacing: 1,
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
            ObjectFlagProperty<void Function()>.has('onSelected', onSelected)),
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
      return SafeArea(
        child: Material(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /// Studio Filter
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(TR.miscFilterStudio.tr(), style: theme.textTheme.bodyText1),
            Flexible(
              child: Consumer(
                builder: (final context, final ref, final child) {
                  final studios = ref.watch(combinedStudiosProvider);
                  return Wrap(
                    runSpacing: -4,
                    spacing: 16,
                    children: <Widget>[
                      for (final studio in studios)
                        Consumer(
                          builder: (final context, final ref, final child) {
                            return FilterButton(
                              text: studio.item1.studioName,
                              avatarUrl: studio.avatarUrl,
                              borderColor: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              selected: ref.watch(
                                activitiesStudiosFilterProvider
                                    .select((final selectedStudios) {
                                  return selectedStudios.contains(studio);
                                }),
                              ),
                              onSelected: (final value) {
                                final studiosNotifier = ref.read(
                                  activitiesStudiosFilterProvider.notifier,
                                );
                                value
                                    ? studiosNotifier.add(studio)
                                    : studiosNotifier.remove(studio);
                              },
                            );
                          },
                        )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        /// Time Filter
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(TR.miscFilterClass.tr(), style: theme.textTheme.bodyText1),
            Flexible(
              child: Wrap(
                runSpacing: -4,
                spacing: 16,
                children: <Widget>[
                  for (final category in ClassCategory.values)
                    Consumer(
                      builder: (final context, final ref, final child) {
                        return FilterButton(
                          text: category.translation,
                          borderColor: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          selected: ref.watch(
                            activitiesCategoriesFilterProvider
                                .select((final selectedCategories) {
                              return selectedCategories.contains(category);
                            }),
                          ),
                          onSelected: (final value) {
                            final categoriesNotifier = ref.read(
                              activitiesCategoriesFilterProvider.notifier,
                            );
                            value
                                ? categoriesNotifier.add(category)
                                : categoriesNotifier.remove(category);
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

        /// Time Filter
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(TR.miscFilterTime.tr(), style: theme.textTheme.bodyText1),
            Flexible(
              child: Wrap(
                runSpacing: -4,
                spacing: 16,
                children: <Widget>[
                  for (final time in ActivityTime.values)
                    Consumer(
                      builder: (final context, final ref, final child) {
                        return FilterButton(
                          text: time.translate(filterTime),
                          borderColor: Colors.grey.shade300,
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
            Flexible(
              child: Consumer(
                builder: (final context, final ref, final child) {
                  final trainers = ref.watch(combinedTrainersProvider);
                  final children = <Widget>[
                    for (final trainer in trainers)
                      Consumer(
                        builder: (final context, final ref, final child) {
                          return FilterButton(
                            text: trainer.item1.trainerName,
                            avatarUrl: trainer.item1.trainerPhoto,
                            borderColor: Colors.grey.shade300,
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
