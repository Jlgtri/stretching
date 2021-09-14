import 'dart:math';

import 'package:animations/animations.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:darq/darq.dart';
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
import 'package:stretching/models_smstretching/sm_gallery_model.dart';
import 'package:stretching/models_smstretching/sm_record_model.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/models_smstretching/sm_wishlist_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/company_model.dart';
import 'package:stretching/models_yclients/user_record_model.dart';
import 'package:stretching/providers/combined_providers.dart';
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
    final nullableCombinedStudios =
        _ref.read(combinedStudiosProvider).cast<CombinedStudioModel?>();
    return nullableCombinedStudios.firstWhere(
      (final studio) => studio!.item0.id == id,
      orElse: () => null,
    );
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
        SaveToHiveIterableNotifier<SMClassesGalleryModel, String>,
        Iterable<SMClassesGalleryModel>> activitiesCategoriesFilterProvider =
    StateNotifierProvider<
        SaveToHiveIterableNotifier<SMClassesGalleryModel, String>,
        Iterable<SMClassesGalleryModel>>((final ref) {
  return SaveToHiveIterableNotifier<SMClassesGalleryModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities_categories',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(smClassesGalleryIdConverterProvider)),
    ),
    defaultValue: const Iterable<SMClassesGalleryModel>.empty(),
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
    StateProvider<DateTime>((final ref) => DateTime.now());

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
            (trainers.isEmpty || trainers.contains(activity.item2.item1)) &&
            (categories.isEmpty ||
                categories.any((final category) {
                  return category.classesYId == activity.item0.service.id;
                })) &&
            (time.isEmpty ||
                time.all((final time) => time.isWithin(activity.item0.date)));
      }).toList(growable: false)
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

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);

    final dayController = useScrollController();
    final refreshController = useMemoized(() => RefreshController());
    final tempNow = DateTime.now();
    final firstNow = useRef(tempNow);
    final now = useMemoized(() => firstNow.value = DateTime.now(), <Object>[
      tempNow.year != firstNow.value.year ||
          tempNow.month != firstNow.value.month ||
          tempNow.day != firstNow.value.day
    ]);

    final categories = ref.watch(activitiesCategoriesFilterProvider);
    final filtersCount = ref.watch(activitiesFiltersCountProvider);
    final activities = ref.watch(filteredActivitiesProvider);
    final day = ref.watch(activitiesDayProvider).state;
    final activeDayKey = useMemoized(() => GlobalKey(), [day]);
    ref.watch(widgetsBindingProvider).addPostFrameCallback((final _) async {
      final context = activeDayKey.currentContext;
      if (context != null) {
        await Scrollable.ensureVisible(context);
      }
    });
    final areActivitiesPresent = ref.watch(
      scheduleProvider.select((final activities) {
        final todayActivities = activities.where((final activity) {
          return activity.date.year == day.year &&
              activity.date.month == day.month &&
              activity.date.day == day.day;
        });
        return todayActivities.isNotEmpty &&
            todayActivities.any((final activity) {
              return activity.date.isAfter(now);
            });
      }),
    );

    final refresh = useFuture(
      useMemoized(() async {
        await Future.wait(<Future<void>>[
          ref.read(scheduleProvider.notifier).refresh(),
          ref.read(smClassesGalleryProvider.notifier).refresh(),
          ref.read(userRecordsProvider.notifier).refresh(),
        ]);
      }),
    );
    return
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

        SmartRefresher(
      controller: refreshController,
      onLoading: refreshController.loadComplete,
      onRefresh: () async {
        await Future.wait(<Future<void>>[
          ref.read(scheduleProvider.notifier).refresh(),
          ref.read(smClassesGalleryProvider.notifier).refresh(),
          ref.read(userRecordsProvider.notifier).refresh(),
        ]);
        refreshController.refreshCompleted();
      },
      child: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          /// A search field, categories and dates.
          SliverAppBar(
            primary: false,
            floating: activities.isEmpty,
            backgroundColor: Colors.transparent,
            toolbarHeight: InputDecorationStyle.search.toolbarHeight + 52,
            titleSpacing: 0,
            title: Material(
              color: theme.scaffoldBackgroundColor,
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
                            readOnly: true,
                            onTap: () =>
                                Navigator.of(context, rootNavigator: true)
                                    .push<void>(
                              MaterialPageRoute(
                                builder: (final context) =>
                                    const ActivitiesSearch(),
                              ),
                            ),
                            onChanged: (final value) =>
                                (ref.read(activitiesSearchProvider)).state =
                                    value,
                            decoration: InputDecorationStyle.search
                                .fromTheme(
                                  theme,
                                  hintText: TR.activitiesSearch.tr(),
                                )
                                .copyWith(
                                  prefixIconConstraints: const BoxConstraints(
                                    maxHeight: 24,
                                    maxWidth: 36,
                                  ),
                                ),
                          ),
                        ),
                        Badge(
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
                        )
                      ],
                    ),
                  ),
                  Consumer(
                    builder: (final context, final ref, final child) {
                      return getSelectorWidget<SMClassesGalleryModel>(
                        theme: theme,
                        text: (final smClassGallery) =>
                            smClassGallery.classesName,
                        selected: (final value) => ref
                            .read(activitiesCategoriesFilterProvider)
                            .contains(value),
                        values: ref.watch(smClassesGalleryProvider),
                        onSelected: (final category, final value) {
                          final categoriesNotifier = ref.read(
                            activitiesCategoriesFilterProvider.notifier,
                          );
                          value
                              ? categoriesNotifier.add(category)
                              : categoriesNotifier.remove(category);
                        },
                        padding: const EdgeInsets.only(top: 16),
                      );
                    },
                  )
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44 + 16),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 44,
                  child: ListView.builder(
                    controller: dayController,
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
          ),

          if (activities.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (final context, final index) {
                  final activity = activities.elementAt(index);
                  return ActivityCardContainer(
                    activity,
                    timeLeftBeforeStart: activity.item0.date.difference(now),
                  );
                },
                childCount: activities.length,
              ),
            )
          else if (areActivitiesPresent)
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
                        dayController.jumpTo(0);
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
    );
  }
}

/// The transition between [ActivityCard] and [ActivityScreenCard].
class ActivityCardContainer extends HookConsumerWidget {
  /// The transition between [ActivityCard] and [ActivityScreenCard].
  const ActivityCardContainer(
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
    final navigator = Navigator.of(context, rootNavigator: true);
    final isLoading = useRef<bool>(false);

    Future<void> cancelBook(final UserRecordModel appliedRecord) async {
      isLoading.value = true;
      try {
        final smRecord = await (ref.read(businessLogicProvider)).cancelBook(
          user: ref.read(userProvider)!,
          userRecord: appliedRecord,
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
              ref.refresh(userDepositProvider);
              await ref.read(userDepositProvider.future);
              await showRefundedModalBottomSheet(
                context: context,
                title: TR.cancelBookDepositTitle.tr(),
                child: refundedBody(
                  TR.cancelBookDepositBody.tr(),
                  TR.cancelBookDepositButton.tr(),
                ),
              );
              break;
            case ActivityPaidBy.abonement:
              await showRefundedModalBottomSheet(
                context: context,
                title: TR.cancelBookAbonementTitle.tr(),
                child: refundedBody(
                  TR.cancelBookAbonementBody.tr(),
                  TR.cancelBookAbonementButton.tr(),
                ),
              );
              break;
            case ActivityPaidBy.none:
          }
          await ref.read(userRecordsProvider.notifier).refresh();
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
        isLoading.value = false;
      }
    }

    Future<void> book() async {
      isLoading.value = true;
      try {
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
        // switch (result.item1) {
        //   case BookResult.depositRegular:
        //   case BookResult.depositDiscount:
        //   case BookResult.abonement:
        //   case BookResult.newAbonement:
        //   case BookResult.regular:
        //   case BookResult.discount:
        // }
        if (result.item1 == BookResult.depositRegular ||
            result.item1 == BookResult.depositDiscount) {
          ref.refresh(userDepositProvider);
          await ref.read(userDepositProvider.future);
        }
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
                ),
              ),
            )
          ]);
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> addToWishList() async {
      isLoading.value = true;
      try {
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
      } on Exception catch (e) {
        logger.e(e);
      } finally {
        isLoading.value = false;
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
      closedBuilder: (final context, final action) => MaterialButton(
        onPressed: action,
        child: ActivityCard(
          activity,
          timeLeftBeforeStart: timeLeftBeforeStart,
          onPressed: (final appliedRecord) => !isLoading.value
              ? ref.watch(unauthorizedProvider)
                  ? () => Navigator.of(context, rootNavigator: true)
                      .pushNamed(Routes.auth.name)
                  : appliedRecord != null
                      ? timeLeftBeforeStart.inHours < 12
                          ? null
                          : () => cancelBook(appliedRecord)
                      : activity.item0.recordsLeft <= 0
                          ? addToWishList
                          : book
              : null,
        ),
      ),
      openBuilder: (final context, final action) => ActivityScreenCard(
        activity,
        onBackButtonPressed: action,
        timeLeftBeforeStart: timeLeftBeforeStart,
        onPressed: (final appliedRecord) => !isLoading.value
            ? ref.watch(unauthorizedProvider)
                ? () => Navigator.of(context, rootNavigator: true)
                    .pushNamed(Routes.auth.name)
                : appliedRecord != null
                    ? timeLeftBeforeStart.inHours < 12
                        ? null
                        : () => cancelBook(appliedRecord)
                    : activity.item0.recordsLeft <= 0
                        ? addToWishList
                        : book
            : null,
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

/// The activity card to display on [ActivitiesScreen].
class ActivityCard extends ConsumerWidget {
  /// The activity card to display on [ActivitiesScreen].
  const ActivityCard(
    final this.activity, {
    required final this.timeLeftBeforeStart,
    required final this.onPressed,
    final Key? key,
  }) : super(key: key);

  /// The activity to display in this widget.
  final CombinedActivityModel activity;

  /// The amount of time left before this [activity] is starting.
  final Duration timeLeftBeforeStart;

  /// The callback with found record that returns a callback on this card.
  final void Function()? Function(UserRecordModel? appliedRecord) onPressed;

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
                      onPressed: onPressed(appliedRecord),
                      child: Text(
                        activity.item0.recordsLeft > 0
                            ? appliedRecord != null
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
                  if (appliedRecord != null &&
                      timeLeftBeforeStart.inHours < 12) ...[
                    EmojiText('⏱'),
                    Text(
                      TR.activities12h.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.overline,
                    ),
                  ] else
                    ActivityCardRecordsCount(
                      activity.item0.recordsLeft,
                      showDefault: false,
                    ),
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
        )
        ..add(
          ObjectFlagProperty<void Function()? Function(UserRecordModel?)>.has(
            'onPressed',
            onPressed,
          ),
        ),
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
      type: NavigationScreen.schedule,
      onBackButtonPressed: onBackButtonPressed,
      title: activity.item3.classesName,
      subtitle: formatSubTitle(),
      secondSubtitle: activity.item1.item1.studioAddress,
      trailing: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 54),
            child: ActivityCardRecordsCount(activity.item0.recordsLeft),
          ),
          const SizedBox(height: 24),
        ],
        // width: 54,
        // height: 48,
        // child: ,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
                        child: CircularProgressIndicator.adaptive()),
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

        /// Categories Filter
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
                  for (final category in ref.watch(smClassesGalleryProvider))
                    Consumer(
                      builder: (final context, final ref, final child) {
                        return FilterButton(
                          text: category.classesName,
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
                    )
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
                  for (final time
                      in ActivityTime.values.toList()..remove(ActivityTime.all))
                    Consumer(
                      builder: (final context, final ref, final child) {
                        return FilterButton(
                          text: time.translate(),
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
      smClassesGalleryProvider.select((final smClassesGallery) {
        if (search.isEmpty) {
          return const Iterable<SMClassesGalleryModel>.empty();
        }
        return smClassesGallery.where((final smClassGallery) {
          return (smClassGallery.classesName.toLowerCase())
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          leading: imageUrl != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
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
            imageUrl: category.gallery.split(',').first,
            title: category.classesName,
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
