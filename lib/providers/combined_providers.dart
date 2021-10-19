import 'dart:math';

import 'package:add_2_calendar/add_2_calendar.dart' as add_2_cal;
import 'package:darq/darq.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models/smstretching/sm_abonement_model.dart';
import 'package:stretching/models/smstretching/sm_classes_gallery_model.dart';
import 'package:stretching/models/smstretching/sm_studio_model.dart';
import 'package:stretching/models/smstretching/sm_studio_options_model.dart';
import 'package:stretching/models/smstretching/sm_trainer_model.dart';
import 'package:stretching/models/smstretching/sm_user_abonement_model.dart';
import 'package:stretching/models/yclients/activity_model.dart';
import 'package:stretching/models/yclients/company_model.dart';
import 'package:stretching/models/yclients/trainer_model.dart';
import 'package:stretching/models/yclients/user_abonement_model.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:timezone/timezone.dart';

/// The pair of [ClassCategory] and [SMClassesGalleryModel].
typedef CombinedClassesModel = Tuple2<ClassCategory?, SMClassesGalleryModel>;

/// The provider of [ClassCategory] and [SMClassesGalleryModel] pairs.
final Provider<Iterable<CombinedClassesModel>> combinedClassesProvider =
    Provider<Iterable<CombinedClassesModel>>((final ref) {
  final classes = <int, ClassCategory>{
    for (final _class in ClassCategory.values) _class.id: _class
  };
  return <CombinedClassesModel>[
    for (final smClassGallery in ref.watch(smClassesGalleryProvider))
      Tuple2(classes[smClassGallery.classesYId], smClassGallery)
  ];
});

/// The trio of [SMAbonementModel], [UserAbonementModel] and
/// optional [SMUserAbonementModel].
typedef CombinedAbonementModel
    = Tuple3<SMAbonementModel, UserAbonementModel, SMUserAbonementModel?>;

/// The provider of [SMAbonementModel], [UserAbonementModel] and
/// optional [SMUserAbonementModel] trios.
final Provider<Iterable<CombinedAbonementModel>> combinedAbonementsProvider =
    Provider<Iterable<CombinedAbonementModel>>((final ref) {
  final smUserAbonements = ref.watch(
    smUserAbonementsProvider.select(
      (final smUserAbonements) => <int, SMUserAbonementModel>{
        for (final smUserAbonement in smUserAbonements)
          smUserAbonement.documentId: smUserAbonement
      },
    ),
  );
  final smAbonements = ref.watch(
    smAbonementsProvider.select(
      (final smAbonements) => <int, SMAbonementModel>{
        for (final smAbonement in smAbonements) smAbonement.yId: smAbonement
      },
    ),
  );
  return <CombinedAbonementModel>[
    for (final userAbonement in (ref.watch(userAbonementsProvider))
        .distinct((final userAbonement) => userAbonement.id))
      if (smAbonements.keys.contains(userAbonement.type.id))
        CombinedAbonementModel(
          smAbonements[userAbonement.type.id]!,
          userAbonement,
          smUserAbonements[int.tryParse(
            userAbonement.number
                .substring(0, max(0, userAbonement.number.length - 6))
                .split('_')
                .last,
          )],
        )
  ]..sort(
      (final abonementA, final abonementB) =>
          abonementA.item1.compareTo(abonementB.item1),
    );
});

/// The pair of [StudioModel] and [SMStudioModel].
typedef CombinedStudioModel
    = Tuple3<StudioModel, SMStudioModel, SMStudioOptionsModel>;

/// The extra data provided for [CombinedStudioModel].
extension CombinedStudioModelData on CombinedStudioModel {
  /// Return the avatar from this studios.
  String get avatarUrl {
    final media =
        item1.mediaGallerySite.where((final media) => media.url != null);
    String? url;
    if (media.isNotEmpty) {
      url = media.first.url;
    }
    return url ?? (item0.photos.isNotEmpty ? item0.photos.first : item0.logo);
  }
}

/// The provider of [StudioModel] and [SMStudioModel] pairs.
final Provider<Iterable<CombinedStudioModel>> combinedStudiosProvider =
    Provider<Iterable<CombinedStudioModel>>((final ref) {
  final studios = ref.watch(
    studiosProvider.select(
      (final studios) =>
          <int, StudioModel>{for (final studio in studios) studio.id: studio},
    ),
  );
  final studiosOptions = ref.watch(
    smStudiosOptionsProvider.select(
      (final studiosOptions) => <int, SMStudioOptionsModel>{
        for (final studioOptions in studiosOptions)
          studioOptions.studioId: studioOptions
      },
    ),
  );
  return <CombinedStudioModel>[
    for (final smStudio in ref.watch(smStudiosProvider))
      if (studios.keys.contains(smStudio.studioYId))
        if (studiosOptions.keys.contains(smStudio.studioYId))
          CombinedStudioModel(
            studios[smStudio.studioYId]!,
            smStudio,
            studiosOptions[smStudio.studioYId]!,
          )
  ]..sort(
      (final studioA, final studioB) => studioA.item1.compareTo(studioB.item1),
    );
});

/// The pair of [TrainerModel] and [SMTrainerModel].
typedef CombinedTrainerModel = Tuple2<TrainerModel, SMTrainerModel>;

/// The id converter of the [TrainerModel] and [SMTrainerModel].
final Provider<TrainerIdConverter> trainerIdConverterProvider =
    Provider<TrainerIdConverter>(
  (final ref) => TrainerIdConverter._(ref.watch(combinedTrainersProvider)),
);

/// The id converter of the [TrainerModel] and [SMTrainerModel].
class TrainerIdConverter implements JsonConverter<CombinedTrainerModel?, int> {
  const TrainerIdConverter._(final this._trainers);
  final Iterable<CombinedTrainerModel> _trainers;

  @override
  CombinedTrainerModel? fromJson(final int id) {
    for (final trainer in _trainers) {
      if (trainer.item1.id == id) {
        return trainer;
      }
    }
  }

  @override
  int toJson(final CombinedTrainerModel? data) => data!.item1.id;
}

/// The provider of [TrainerModel] and [SMTrainerModel] pairs.
final Provider<Iterable<CombinedTrainerModel>> combinedTrainersProvider =
    Provider<Iterable<CombinedTrainerModel>>(
  (final ref) => <CombinedTrainerModel>[
    for (final trainer in ref.watch(normalizedTrainersProvider))
      for (final smTrainer in ref.watch(smTrainersProvider))
        if (trainer.id == smTrainer.trainerId)
          CombinedTrainerModel(trainer, smTrainer)
  ]..sort(
      (final trainerA, final trainerB) =>
          trainerA.item1.compareTo(trainerB.item1),
    ),
);

/// The [ActivityModel] with [CombinedTrainerModel] and [CombinedStudioModel].
typedef CombinedActivityModel = Tuple4<ActivityModel, CombinedStudioModel,
    CombinedTrainerModel, CombinedClassesModel>;

/// The type of the [AddToCalendarException].
enum AddToCalendarExceptionType {
  /// Means user has denied Calendar permission.
  permission,

  /// Means the new calendar couldn't be created.
  createCalendar,

  /// Means the event wasn't added to the calendar.
  createEvent,

  /// Means the event is already added to the calendar.
  alreadyAdded
}

/// The exception on [CombinedActivityModelData.addToCalendar];
class AddToCalendarException implements Exception {
  /// The exception on [CombinedActivityModelData.addToCalendar];
  const AddToCalendarException(final this.type);

  /// The type of this exception.
  final AddToCalendarExceptionType type;
}

/// The extra data provided for [CombinedActivityModel].
extension CombinedActivityModelData on CombinedActivityModel {
  static final DeviceCalendarPlugin _deviceCalendarPlugin =
      DeviceCalendarPlugin();

  /// Add this activity to calendar.
  Future<bool> add2Calendar() => add_2_cal.Add2Calendar.addEvent2Cal(
        add_2_cal.Event(
          title: '${item0.service.title}, '
              '${item1.item1.studioName}',
          description: TR.successfulBookCalendarTrainer.tr(
            args: <String>[
              item2.item1.trainerName,
            ],
          ),
          location: item1.item1.studioAddress,
          startDate: item0.date,
          endDate: item0.date.add(item0.length),
        ),
      );

  /// Add this activity to calendar.
  ///
  /// Steps:
  ///   1. Request Calendar permission.
  ///   2. Get local timezone (GMT == America/Danmarkshavn).
  ///   3. Create or get existing calendar with name [calendarName].
  ///   4. Lookup the similar events by date and title in the calendar.
  ///   5. Delete all the previously created events but one.
  ///   6. Create the event or edit the existing one.
  ///
  /// Returns the created event's id.
  Future<String> addToCalendar() async {
    if (!((await _deviceCalendarPlugin.hasPermissions()).data ?? false)) {
      if (!((await _deviceCalendarPlugin.requestPermissions()).data ?? false)) {
        throw const AddToCalendarException(
          AddToCalendarExceptionType.permission,
        );
      }
    }

    var timezone = await FlutterNativeTimezone.getLocalTimezone();
    if (timezone == 'GMT') {
      timezone = 'America/Danmarkshavn';
    }

    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarsResult.data;

    final String calendarId;
    String? defaultCalendarId;
    if (calendars != null) {
      for (final calendar in calendars) {
        if (calendar.name == calendarName) {
          defaultCalendarId = calendar.id;
          break;
        }
      }
    }
    if (defaultCalendarId != null) {
      calendarId = defaultCalendarId;
    } else {
      final calendarIdResult = await _deviceCalendarPlugin.createCalendar(
        calendarName,
        calendarColor: Colors.black,
      );
      final _calendarId = calendarIdResult.data;
      if (_calendarId == null) {
        throw const AddToCalendarException(
          AddToCalendarExceptionType.createCalendar,
        );
      }
      calendarId = _calendarId;
    }

    final startDate = TZDateTime.fromMillisecondsSinceEpoch(
      timeZoneDatabase.locations[timezone]!,
      item0.date.millisecondsSinceEpoch,
    );
    final endDate = TZDateTime.fromMillisecondsSinceEpoch(
      timeZoneDatabase.locations[timezone]!,
      item0.date.add(item0.length).millisecondsSinceEpoch,
    );
    final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: startDate, endDate: endDate),
    );
    final events = eventsResult.data;

    final title = '${item0.service.title}, '
        '${item1.item1.studioName}';
    final description = TR.successfulBookCalendarTrainer.tr(
      args: <String>[item2.item1.trainerName],
    );
    final reminders = <Reminder>[
      Reminder(minutes: TimeOfDay.minutesPerHour * 2)
    ];
    const availability = Availability.Busy;

    String? editEventId;
    var eventCreated = false;
    if (events != null) {
      for (final event in events) {
        if (event.start?.toUtc() == startDate.toUtc() &&
            event.end?.toUtc() == endDate.toUtc() &&
            event.title == title) {
          if (description != event.description ||
              !listEquals(reminders, event.reminders) ||
              availability != event.availability) {
            if (!eventCreated && editEventId == null) {
              editEventId = event.eventId;
            } else {
              await _deviceCalendarPlugin.deleteEvent(
                calendarId,
                event.eventId,
              );
            }
          } else {
            eventCreated = true;
          }
        }
      }
    }

    final eventIdResult = await _deviceCalendarPlugin.createOrUpdateEvent(
      Event(
        calendarId,
        eventId: editEventId,
        title: title,
        description: description,
        start: startDate,
        end: endDate,
        reminders: reminders,
        availability: availability,
      ),
    );
    final eventId = eventIdResult?.data;
    if (eventId == null) {
      throw const AddToCalendarException(
        AddToCalendarExceptionType.createEvent,
      );
    }
    return eventId;
  }
}

/// The provider of [ActivityModel] with [CombinedTrainerModel] and
/// [CombinedStudioModel] pairs.
final Provider<Iterable<CombinedActivityModel>> combinedActivitiesProvider =
    Provider<Iterable<CombinedActivityModel>>((final ref) {
  final trainers = ref.watch(
    combinedTrainersProvider.select(
      (final trainers) => <int, CombinedTrainerModel>{
        for (final trainer in trainers) trainer.item0.id: trainer
      },
    ),
  );
  final studios = ref.watch(
    combinedStudiosProvider.select(
      (final studios) => <int, CombinedStudioModel>{
        for (final studio in studios) studio.item0.id: studio
      },
    ),
  );
  final classes = ref.watch(
    combinedClassesProvider.select(
      (final classes) => <int, CombinedClassesModel>{
        for (final _class in classes) _class.item1.classesYId: _class
      },
    ),
  );

  return <CombinedActivityModel>[
    for (final activity in ref.watch(scheduleProvider))
      if (studios.keys.contains(activity.companyId))
        if (trainers.keys.contains(activity.staffId))
          if (classes.keys.contains(activity.service.id))
            CombinedActivityModel(
              activity,
              studios[activity.companyId]!,
              trainers[activity.staffId]!,
              classes[activity.service.id]!,
            )
  ]..sort(
      (final activityA, final activityB) =>
          activityA.item0.compareTo(activityB.item0),
    );
});
