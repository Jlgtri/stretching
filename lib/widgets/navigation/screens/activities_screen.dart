import 'dart:math';

import 'package:darq/darq.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/company_model.dart';
import 'package:stretching/models_yclients/trainer_model.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/yclients_providers.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/components/focus_wrapper.dart';
import 'package:stretching/widgets/navigation/components/filters.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The id converter of the [CompanyModel].
final Provider<CompanyIdConverter> companyIdConverterProvider =
    Provider((final ref) => CompanyIdConverter._(ref));

/// The id converter of the [CompanyModel].
class CompanyIdConverter implements JsonConverter<CompanyModel?, int> {
  const CompanyIdConverter._(final this._ref);
  final ProviderRefBase _ref;

  @override
  CompanyModel? fromJson(final int id) {
    final nullableStudios = _ref.read(studiosProvider).cast<StudioModel?>();
    return nullableStudios.firstWhere(
      (final studio) => studio!.id == id,
      orElse: () => null,
    );
  }

  @override
  int toJson(final CompanyModel? data) => data!.id;
}

/// The provider of filters for [SMTrainerModel].
final StateNotifierProvider<SaveToHiveIterableNotifier<StudioModel, String>,
        Iterable<StudioModel>> activitiesStudiosFilterProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<StudioModel, String>,
        Iterable<StudioModel>>((final ref) {
  return SaveToHiveIterableNotifier<StudioModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_studios',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(companyIdConverterProvider)),
    ),
    defaultValue: const Iterable<StudioModel>.empty(),
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
final StateNotifierProvider<SaveToHiveIterableNotifier<TrainerModel, String>,
        Iterable<TrainerModel>> activitiesTrainersFilterProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<TrainerModel, String>,
        Iterable<TrainerModel>>((final ref) {
  return SaveToHiveIterableNotifier<TrainerModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_trainers',
    converter:
        const StringToIterableConverter(IterableConverter(trainerConverter)),
    defaultValue: const Iterable<TrainerModel>.empty(),
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
  /// Check if [activity]'s date is [before] or [after] 16:45 on it's day.
  bool isWithin(final ActivityModel activity) {
    final date = activity.date;
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

/// The screen for the [NavigationScreen.trainers].
class ActivitiesScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.trainers].
  const ActivitiesScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(activitiesCategoriesFilterProvider);

    final search = useState<String>('');
    final scrollController = useScrollController();
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();
    final searchKey = useMemoized(() => GlobalKey());
    final scrollNotificationExample = useRef<ScrollUpdateNotification?>(null);

    late final bool areActivitiesPresent;
    late final int filtersCount;
    final activities = ref.watch(
      /// First of all, checks if any activities are present.
      /// Then, applies time, studios, trainers and classes filters.
      scheduleProvider.select((final activities) {
        areActivitiesPresent = activities.isNotEmpty;
        final time = ref.watch(activitiesTimeFilterProvider);
        final categories = ref.watch(activitiesCategoriesFilterProvider);
        final studiosIds = ref.watch(
          activitiesStudiosFilterProvider.select((final studios) {
            return studios.map((final studio) => studio.id);
          }),
        );
        final trainersIds = ref.watch(
          activitiesTrainersFilterProvider.select((final trainer) {
            return trainer.map((final trainer) => trainer.id);
          }),
        );
        filtersCount = time.length +
            categories.length +
            studiosIds.length +
            trainersIds.length;
        return activities.where((final activity) {
          return (studiosIds.isEmpty ||
                  studiosIds.contains(activity.companyId)) &&
              (trainersIds.isEmpty || trainersIds.contains(activity.staffId)) &&
              (categories.isEmpty ||
                  categories.all(activity.labels.contains)) &&
              (time.isEmpty ||
                  time.all((final time) => time.isWithin(activity)));
        });
      }),
    );

    return FocusWrapper(
      unfocussableKeys: <GlobalKey>[searchKey],
      child: DraggableScrollbar.semicircle(
        controller: scrollController,
        // Shows the scrollbar only if current trainers length is greater
        // than 6 (3 rows).
        heightScrollThumb: activities.length < 4 ? 0 : 40,
        padding: EdgeInsets.zero,
        backgroundColor: theme.colorScheme.onSurface,
        labelTextBuilder: (final offset) {
          /// Creates a label for the scrollbar with the first letter of
          /// current trainer.
          final index = max(0, scrollController.offset - 84) /
              scrollController.position.maxScrollExtent *
              activities.length;
          final activity = activities.elementAt(
            scrollController.hasClients
                ? min(index.ceil(), activities.length - 1)
                : 0,
          );
          return Text(
            '${activity.date.hour}:${activity.date.minute}',
            style: theme.textTheme.subtitle2
                ?.copyWith(color: theme.colorScheme.surface),
          );
        },
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemExtent: MediaQuery.of(context).size.height - 84,
          children: <Widget>[
            /// Is used for moving the scrollbar to the initial position when
            /// search is reset. Needs to access [DraggableScrollbar] context.
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
                        toolbarHeight:
                            InputDecorationStyle.search.toolbarHeight + 84,
                        titleSpacing: 12,
                        title: Material(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextField(
                                key: searchKey,
                                cursorColor: theme.hintColor,
                                style: theme.textTheme.bodyText2,
                                controller: searchController,
                                focusNode: searchFocusNode,
                                onChanged: (final value) =>
                                    search.value = value,
                                decoration:
                                    InputDecorationStyle.search.fromTheme(
                                  theme,
                                  suffixCount: filtersCount,
                                  onSuffix: () {
                                    search.value = '';
                                    searchController.clear();
                                    searchFocusNode.unfocus();
                                  },
                                ),
                              ),
                              categories.getSelectorWidget(
                                theme,
                                (final category, final value) {
                                  final categoriesNotifier = ref.read(
                                    activitiesCategoriesFilterProvider.notifier,
                                  );
                                  value
                                      ? categoriesNotifier.add(category)
                                      : categoriesNotifier.remove(category);
                                },
                              ),
                            ],
                          ),
                        ),
                        bottom: null,
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

// /// The search implemented on [ActivitiesScreen].
// class ActivitiesSearch extends HookConsumerWidget {
//   /// The search implemented on [ActivitiesScreen].
//   const ActivitiesSearch({final Key? key}) : super(key: key);

//   @override
//   Widget build(final BuildContext context, final WidgetRef ref) {
//     final theme = Theme.of(context);
//     final categories = ref.watch(activitiesCategoryFilterProvider);

//     final search = useState<String>('');
//   }
// }
