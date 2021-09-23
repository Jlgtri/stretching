import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:darq/darq.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models_smstretching/sm_abonement_model.dart';
import 'package:stretching/models_smstretching/sm_classes_gallery_model.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_studio_options_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/models_smstretching/sm_user_abonement_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/company_model.dart';
import 'package:stretching/models_yclients/trainer_model.dart';
import 'package:stretching/models_yclients/user_abonement_model.dart';
import 'package:stretching/utils/json_converters.dart';

/// The pair of [ClassCategory] and [SMClassesGalleryModel].
typedef CombinedClassesModel = Tuple2<ClassCategory, SMClassesGalleryModel>;

/// The provider of [ClassCategory] and [SMClassesGalleryModel] pairs.
final Provider<Iterable<CombinedClassesModel>> combinedClassesProvider =
    Provider<Iterable<CombinedClassesModel>>((final ref) {
  final smClassesGallery = ref.watch(
    smClassesGalleryProvider.select((final smClassesGallery) {
      return <int, SMClassesGalleryModel>{
        for (final smClassGallery in smClassesGallery)
          smClassGallery.classesYId: smClassGallery
      };
    }),
  );
  return <CombinedClassesModel>[
    for (final classes in ClassCategory.values)
      if (smClassesGallery.keys.contains(classes.id))
        Tuple2(classes, smClassesGallery[classes.id]!)
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
    smUserAbonementsProvider.select((final smUserAbonements) {
      return <int, SMUserAbonementModel>{
        for (final smUserAbonement in smUserAbonements)
          smUserAbonement.abonementId: smUserAbonement
      };
    }),
  );
  final smAbonements = ref.watch(
    smAbonementsProvider.select((final smAbonements) {
      return <int, SMAbonementModel>{
        for (final smAbonement in smAbonements) smAbonement.yId: smAbonement
      };
    }),
  );
  final f = ref.watch(userAbonementsProvider).toList();
  final ff = (ref.watch(userAbonementsProvider))
      .distinct((final userAbonement) => userAbonement.id)
      .toList();

  return <CombinedAbonementModel>[
    for (final userAbonement in (ref.watch(userAbonementsProvider))
        .distinct((final userAbonement) => userAbonement.id))
      if (smAbonements.keys.contains(userAbonement.type.id))
        CombinedAbonementModel(
          smAbonements[userAbonement.type.id]!,
          userAbonement,
          smUserAbonements[userAbonement.type.id],
        )
  ]..sort((final abonementA, final abonementB) {
      return abonementA.item1.compareTo(abonementB.item1);
    });
});

/// The pair of [StudioModel] and [SMStudioModel].
typedef CombinedStudioModel
    = Tuple3<StudioModel, SMStudioModel, SMStudioOptionsModel>;

/// The extra data provided for [CombinedStudioModel].
extension CombinedStudioModelData on CombinedStudioModel {
  /// Return the avatar from this studios.
  String get avatarUrl {
    return item1.mediaGallerySite.isNotEmpty
        ? item1.mediaGallerySite.first.url
        : item0.photos.isNotEmpty
            ? item0.photos.first
            : item0.logo;
  }
}

/// The provider of [StudioModel] and [SMStudioModel] pairs.
final Provider<Iterable<CombinedStudioModel>> combinedStudiosProvider =
    Provider<Iterable<CombinedStudioModel>>((final ref) {
  final studios = ref.watch(
    studiosProvider.select((final studios) {
      return <int, StudioModel>{
        for (final studio in studios) studio.id: studio
      };
    }),
  );
  final studiosOptions = ref.watch(
    smStudiosOptionsProvider.select((final studiosOptions) {
      return <int, SMStudioOptionsModel>{
        for (final studioOptions in studiosOptions)
          studioOptions.studioId: studioOptions
      };
    }),
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
  ]..sort((final studioA, final studioB) {
      return studioA.item1.compareTo(studioB.item1);
    });
});

/// The pair of [TrainerModel] and [SMTrainerModel].
typedef CombinedTrainerModel = Tuple2<TrainerModel, SMTrainerModel>;

/// The id converter of the [TrainerModel] and [SMTrainerModel].
final Provider<SMTrainerIdConverter> smTrainerIdConverterProvider =
    Provider<SMTrainerIdConverter>((final ref) => SMTrainerIdConverter._(ref));

/// The id converter of the [TrainerModel] and [SMTrainerModel].
class SMTrainerIdConverter implements JsonConverter<SMTrainerModel?, int> {
  const SMTrainerIdConverter._(final this._ref);
  final ProviderRefBase _ref;

  @override
  SMTrainerModel? fromJson(final int id) {
    for (final trainer in _ref.read(smTrainersProvider)) {
      if (trainer.id == id) {
        return trainer;
      }
    }
  }

  @override
  int toJson(final SMTrainerModel? data) => data!.id;
}

/// The id converter of the [TrainerModel] and [SMTrainerModel].
final Provider<CombinedClassesIdConverter> combinedClassesIdConverterProvider =
    Provider<CombinedClassesIdConverter>((final ref) {
  return CombinedClassesIdConverter._(ref);
});

/// The id converter of the [TrainerModel] and [SMTrainerModel].
class CombinedClassesIdConverter
    implements JsonConverter<CombinedClassesModel?, int> {
  const CombinedClassesIdConverter._(final this._ref);
  final ProviderRefBase _ref;

  @override
  CombinedClassesModel? fromJson(final int id) {
    for (final smGallery in _ref.read(combinedClassesProvider)) {
      if (smGallery.item0.id == id) {
        return smGallery;
      }
    }
  }

  @override
  int toJson(final CombinedClassesModel? data) => data!.item0.id;
}

/// The provider of [TrainerModel] and [SMTrainerModel] pairs.
final Provider<Iterable<CombinedTrainerModel>> combinedTrainersProvider =
    Provider<Iterable<CombinedTrainerModel>>((final ref) {
  final trainers = ref.watch(normalizedTrainersProvider);
  final t = ref.watch(smTrainersProvider).toList();
  return <CombinedTrainerModel>[
    for (final smTrainer in t)
      for (final trainer in trainers)
        if (trainer.name == smTrainer.trainerName)
          CombinedTrainerModel(trainer, smTrainer)
  ]..sort((final trainerA, final trainerB) {
      return trainerA.item1.compareTo(trainerB.item1);
    });
});

/// The [ActivityModel] with [CombinedTrainerModel] and [CombinedStudioModel].
typedef CombinedActivityModel = Tuple4<ActivityModel, CombinedStudioModel,
    CombinedTrainerModel, SMClassesGalleryModel>;

/// The extra data provided for [CombinedActivityModel].
extension CombinedActivityModelData on CombinedActivityModel {
  /// Add this activity to calendar.
  Future<bool> addToCalendar() {
    return Add2Calendar.addEvent2Cal(
      Event(
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
  }
}

/// The provider of [ActivityModel] with [CombinedTrainerModel] and
/// [CombinedStudioModel] pairs.
final Provider<Iterable<CombinedActivityModel>> combinedActivitiesProvider =
    Provider<Iterable<CombinedActivityModel>>((final ref) {
  final trainers = ref.watch(
    combinedTrainersProvider.select((final trainers) {
      return <int, CombinedTrainerModel>{
        for (final trainer in trainers) trainer.item0.id: trainer
      };
    }),
  );
  final studios = ref.watch(
    combinedStudiosProvider.select((final studios) {
      return <int, CombinedStudioModel>{
        for (final studio in studios) studio.item0.id: studio
      };
    }),
  );
  final categories = ref.watch(
    smClassesGalleryProvider.select((final smClassesGallery) {
      return <int, SMClassesGalleryModel>{
        for (final smClassGallery in smClassesGallery)
          smClassGallery.classesYId: smClassGallery
      };
    }),
  );

  return <CombinedActivityModel>[
    for (final activity in ref.watch(scheduleProvider))
      if (studios.keys.contains(activity.companyId))
        if (trainers.keys.contains(activity.staffId))
          if (categories.keys.contains(activity.service.id))
            CombinedActivityModel(
              activity,
              studios[activity.companyId]!,
              trainers[activity.staffId]!,
              categories[activity.service.id]!,
            )
  ]..sort((final activityA, final activityB) {
      return activityA.item0.compareTo(activityB.item0);
    });
});
