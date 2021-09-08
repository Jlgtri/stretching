import 'package:darq/darq.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/company_model.dart';
import 'package:stretching/models_yclients/trainer_model.dart';
import 'package:stretching/providers/smstretching_providers.dart';
import 'package:stretching/providers/yclients_providers.dart';
import 'package:stretching/utils/json_converters.dart';

/// The pair of [StudioModel] and [SMStudioModel].
typedef CombinedStudioModel = Tuple2<StudioModel, SMStudioModel>;

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
  return <CombinedStudioModel>[
    for (final smStudio in ref.watch(smStudiosProvider))
      if (studios.keys.contains(smStudio.studioYId))
        CombinedStudioModel(studios[smStudio.studioYId]!, smStudio)
  ]..sort((final studioA, final studioB) {
      return studioA.item1.compareTo(studioB.item1);
    });
});

/// The pair of [TrainerModel] and [SMTrainerModel].
typedef CombinedTrainerModel = Tuple2<TrainerModel, SMTrainerModel>;

/// The id converter of the [TrainerModel] and [SMTrainerModel].
final Provider<TrainerIdConverter> trainerIdConverterProvider =
    Provider<TrainerIdConverter>((final ref) => TrainerIdConverter._(ref));

/// The id converter of the [TrainerModel] and [SMTrainerModel].
class TrainerIdConverter implements JsonConverter<CombinedTrainerModel?, int> {
  const TrainerIdConverter._(final this._ref);
  final ProviderRefBase _ref;

  @override
  CombinedTrainerModel? fromJson(final int id) {
    final nullableCombinedTrainers =
        _ref.read(combinedTrainersProvider).cast<CombinedTrainerModel?>();
    return nullableCombinedTrainers.firstWhere(
      (final trainer) => trainer!.item0.id == id,
      orElse: () => null,
    );
  }

  @override
  int toJson(final CombinedTrainerModel? data) => data!.item0.id;
}

/// The provider of [TrainerModel] and [SMTrainerModel] pairs.
final Provider<Iterable<CombinedTrainerModel>> combinedTrainersProvider =
    Provider<Iterable<CombinedTrainerModel>>((final ref) {
  final trainers = ref.watch(
    normalizedTrainersProvider.select((final trainers) {
      return <int, TrainerModel>{
        for (final trainer in trainers) trainer.id: trainer
      };
    }),
  );
  return <CombinedTrainerModel>[
    for (final smTrainer in ref.watch(smTrainersProvider))
      if (trainers.keys.contains(smTrainer.trainerId))
        CombinedTrainerModel(trainers[smTrainer.trainerId]!, smTrainer)
  ]..sort((final trainerA, final trainerB) {
      return trainerA.item1.compareTo(trainerB.item1);
    });
});

/// The [ActivityModel] with [CombinedTrainerModel] and [CombinedStudioModel].
typedef CombinedActivityModel
    = Tuple3<ActivityModel, CombinedStudioModel, CombinedTrainerModel>;

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
  return <CombinedActivityModel>[
    for (final activity in ref.watch(scheduleProvider))
      if (studios.keys.contains(activity.companyId))
        if (trainers.keys.contains(activity.staffId))
          CombinedActivityModel(
            activity,
            studios[activity.companyId]!,
            trainers[activity.staffId]!,
          )
  ]..sort((final activityA, final activityB) {
      return activityA.item0.compareTo(activityB.item0);
    });
});
