import 'dart:async';

import 'package:darq/darq.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models_yclients/user_record_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/profile/profile_screen.dart';

/// The screen that shows a user his previous records.
class HistoryScreen extends HookConsumerWidget {
  /// The screen that shows a user his previous records.
  const HistoryScreen({required final this.onBackButton, final Key? key})
      : super(key: key);

  /// The callback to go back to previous screen.
  final FutureOr<void> Function() onBackButton;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final locale = ref.watch(localeProvider);
    final monthFormat = DateFormat('LLLL', locale.toString());
    final monthAndYearFormat = DateFormat('LLLL yyyy', locale.toString());
    final dateFormat = DateFormat('dd.MM.yy', locale.toString());
    final timeFormat = DateFormat.Hm(locale.toString());

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
          if (userRecord.date.isAfter(now) ||
              userRecord.deleted ||
              !companyIds.contains(userRecord.company.id)) {
            continue;
          }
          final key = Tuple2(userRecord.date.year, userRecord.date.month);
          data.putIfAbsent(key, () => <UserRecordModel>[]);
          data[key]!.add(userRecord);
        }
        return data;
      }),
    );

    Widget childRecord(final UserRecordModel userRecord) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                dateFormat.format(userRecord.date),
                style: theme.textTheme.bodyText2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                timeFormat.format(userRecord.date),
                style: theme.textTheme.bodyText2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                userRecord.services.first.title,
                style: theme.textTheme.bodyText1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                userRecord.staff.name,
                style: theme.textTheme.bodyText2?.copyWith(
                  color: theme.hintColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // const SizedBox(height: 4),
              Text(
                userRecord.company.title,
                style: theme.textTheme.bodyText2?.copyWith(
                  color: theme.hintColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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

    return WillPopScope(
      onWillPop: () async {
        await onBackButton();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: cancelAppBar(
          theme,
          title: ProfileNavigationScreen.history.translation,
          leading: FontIconBackButton(
            color: theme.colorScheme.onSurface,
            onPressed: onBackButton,
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
                            onFirstPressed: (final context) {
                              Navigator.of(context).popUntil(
                                ModalRoute.withName(Routes.root.name),
                              );
                              (ref.read(navigationProvider)).jumpToTab(
                                NavigationScreen.schedule.index,
                              );
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
                children: userYearAndMonthRecords.entries
                    .map(recordGroup)
                    .toList(growable: false),
              ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(ObjectFlagProperty<void Function()>.has(
            'onBackButton', onBackButton)),
    );
  }
}
