import 'package:darq/darq.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/hook_consumer_stateful_widget.dart';
import 'package:stretching/models_yclients/user_record_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/hide_appbar_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/profile/profile_screen.dart';

/// The screen that shows a user his previous records.
class HistoryScreen extends HookConsumerStatefulWidget {
  /// The screen that shows a user his previous records.
  const HistoryScreen({final Key? key}) : super(key: key);

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

/// The screen that shows a user his previous records.
class HistoryScreenState extends ConsumerState<HistoryScreen>
    with HideAppBarRouteAware {
  @override
  NavigationScreen get screenType => NavigationScreen.profile;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final locale = ref.watch(localeProvider).toString();
    final monthFormat = useMemoized(() => DateFormat('LLLL', locale), [locale]);
    final monthAndYearFormat =
        useMemoized(() => DateFormat('LLLL yyyy', locale), [locale]);
    final dateFormat =
        useMemoized(() => DateFormat('dd.MM.yy', locale), [locale]);
    final timeFormat = useMemoized(() => DateFormat.Hm(locale), [locale]);

    final userYearAndMonthRecords = ref.watch(
      userRecordsProvider.select((final userRecords) {
        final companyIds = ref.watch(
          combinedStudiosProvider.select((final studios) {
            return studios.map((final studio) => studio.item0.id);
          }),
        );
        final data = <Tuple2<int, int>, List<UserRecordModel>>{};
        for (final userRecord in userRecords.toList(growable: false)
          ..sort((final userRecordA, final userRecordB) {
            return userRecordB.date.compareTo(userRecordA.date);
          })) {
          if (!userRecord.deleted &&
              userRecord.date.add(userRecord.length).isBefore(now) &&
              companyIds.contains(userRecord.company.id)) {
            final key = Tuple2(userRecord.date.year, userRecord.date.month);
            data.putIfAbsent(key, () => <UserRecordModel>[]);
            data[key]!.add(userRecord);
          }
        }
        return data;
      }),
    );

    Widget childRecord(final UserRecordModel userRecord) {
      return Container(
        constraints: const BoxConstraints(minHeight: 80),
        decoration: ShapeDecoration(
          color: theme.colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  dateFormat.format(userRecord.date),
                  style: theme.textTheme.bodyText2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Flexible(
                  child: Text(
                    timeFormat.format(userRecord.date),
                    style: theme.textTheme.bodyText2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  userRecord.services.first.title,
                  style: theme.textTheme.bodyText1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  userRecord.staff.name,
                  style: theme.textTheme.caption?.copyWith(
                    color: theme.hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userRecord.company.title,
                  style: theme.textTheme.caption?.copyWith(
                    color: theme.hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget recordGroup(
      final MapEntry<Tuple2<int, int>, List<UserRecordModel>> entry,
    ) {
      final date = DateTime(entry.key.item0, entry.key.item1);
      final dateText =
          (date.year == now.year ? monthFormat : monthAndYearFormat)
              .format(date);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16)
            .copyWith(top: 0),
        child: Column(
          children: <Widget>[
            Text(
              dateText.isNotEmpty
                  ? dateText.substring(0, 1).toUpperCase() +
                      dateText.substring(1).toLowerCase()
                  : dateText,
              style:
                  theme.textTheme.bodyText1?.copyWith(color: theme.hintColor),
            ),
            ...entry.value.map(childRecord)
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: NavigationRoot.navBarHeight),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: 50,
          backgroundColor: theme.backgroundColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: theme.brightness,
            statusBarIconBrightness: theme.brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
          ),
          centerTitle: true,
          title: Text(
            ProfileNavigationScreen.history.translation,
            style: theme.textTheme.headline3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: FontIconBackButton(
            color: theme.colorScheme.onSurface,
            onPressed: Navigator.of(context).maybePop,
          ),
        ),
        body: userYearAndMonthRecords.isEmpty
            ? NativeDeviceOrientationReader(
                builder: (final context) => Align(
                  child: SingleChildScrollView(
                    key: UniqueKey(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 65),
                          child: Text(
                            TR.profileHistoryEmptyTitle.tr(),
                            style: theme.textTheme.headline2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 45),
                          child: Text(
                            TR.profileHistoryEmptyBody.tr(),
                            style: theme.textTheme.bodyText2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 65),
                          child: BottomButtons<dynamic>(
                            inverse: true,
                            firstText: TR.profileHistoryEmptyButton.tr(),
                            onFirstPressed: (final context) async {
                              (ref.read(navigationProvider)).jumpToTab(
                                NavigationScreen.schedule.index,
                              );
                              await Navigator.of(context).maybePop();
                            },
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              )
            : ListView(
                primary: false,
                padding: const EdgeInsets.only(top: 16),
                children: (userYearAndMonthRecords.entries.map(recordGroup))
                    .toList(growable: false),
              ),
      ),
    );
  }
}
