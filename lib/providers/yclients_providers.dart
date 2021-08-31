import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/models_yclients/abonement_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/company_model.dart';
import 'package:stretching/models_yclients/record_model.dart';
import 'package:stretching/models_yclients/trainer_model.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/utils/json_converters.dart';

// /// The cities provider for YClients API.
// ///
// /// See: https://yclientsru.docs.apiary.io/#reference/40/0/0
// final StateNotifierProvider<SaveToHiveIterableNotifier<CityModel, String>,
//         Iterable<CityModel>> citiesProvider =
//     StateNotifierProvider<SaveToHiveIterableNotifier<CityModel, String>,
//         Iterable<CityModel>>((final ref) {
//   return SaveToHiveIterableNotifier<CityModel, String>(
//     hive: ref.watch(hiveProvider),
//     saveName: 'cities',
//     converter:
//         const StringToIterableConverter(IterableConverter(cityConverter)),
//     defaultValue: const Iterable<CityModel>.empty(),
//   );
// });

/// The model of the smstretching studio.
typedef StudioModel = CompanyModel;

/// The studios provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/2/0/0
final StateNotifierProvider<SaveToHiveIterableNotifier<StudioModel, String>,
        Iterable<StudioModel>> studiosProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<StudioModel, String>,
        Iterable<StudioModel>>((final ref) {
  return SaveToHiveIterableNotifier<StudioModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'studios',
    converter:
        const StringToIterableConverter(IterableConverter(companyConverter)),
    defaultValue: const Iterable<StudioModel>.empty(),
  );
});

/// The trainers provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/6/0//
final StateNotifierProvider<TrainersNotifier, Iterable<TrainerModel>>
    trainersProvider =
    StateNotifierProvider<TrainersNotifier, Iterable<TrainerModel>>(
        (final ref) {
  return TrainersNotifier(ref);
});

/// The notifier for the [trainersProvider];
class TrainersNotifier
    extends SaveToHiveIterableNotifier<TrainerModel, String> {
  /// The notifier for the [trainersProvider];
  TrainersNotifier(final ProviderRefBase _ref)
      : super(
          hive: _ref.watch(hiveProvider),
          saveName: 'trainers',
          converter: const StringToIterableConverter(
            IterableConverter(trainerConverter),
          ),
          defaultValue: const Iterable<TrainerModel>.empty(),
          onValueCreated: normalizeTrainers,
        );

  @override
  set state(final Iterable<TrainerModel> value) {
    super.state = normalizeTrainers(value);
  }

  /// Return sorted and valid trainers for this provider.
  static Iterable<TrainerModel> normalizeTrainers(
    final Iterable<TrainerModel> value,
  ) {
    return value.toList()
      ..removeWhere((final trainer) {
        return trainer.specialization == 'Не удалять' ||
            trainer.name.contains('Сотрудник');
      })
      ..removeWhere((final trainer) {
        return <String>[
          'https://api.yclients.com/images/no-master.png',
          'https://api.yclients.com/images/no-master-sm.png'
        ].contains(trainer.avatarBig);
      })
      ..sort((final trainerA, final trainerB) {
        // int isDefault(final String link) => <String>[
        //       'https://api.yclients.com/images/no-master.png',
        //       'https://api.yclients.com/images/no-master-sm.png'
        //     ].contains(link)
        //         ? -1
        //         : 0;
        // final hasAvatar = isDefault(trainerB.avatarBig)
        //     .compareTo(isDefault(trainerA.avatarBig));
        // if (hasAvatar != 0) {
        //   return hasAvatar;
        // }
        return trainerA.name
            .toLowerCase()
            .compareTo(trainerB.name.toLowerCase());
      });
  }
}

/// The schedule provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/12/0/4
final StateNotifierProvider<SaveToHiveIterableNotifier<ActivityModel, String>,
        Iterable<ActivityModel>> scheduleProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<ActivityModel, String>,
        Iterable<ActivityModel>>((final ref) {
  return SaveToHiveIterableNotifier<ActivityModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities',
    converter:
        const StringToIterableConverter(IterableConverter(activityConverter)),
    defaultValue: const Iterable<ActivityModel>.empty(),
  );
});

/// The user abonements provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/28/0
final StateNotifierProvider<SaveToHiveIterableNotifier<AbonementModel, String>,
        Iterable<AbonementModel>> userAbonementsProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<AbonementModel, String>,
        Iterable<AbonementModel>>((final ref) {
  return SaveToHiveIterableNotifier<AbonementModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'abonements',
    converter:
        const StringToIterableConverter(IterableConverter(abonementConverter)),
    defaultValue: const Iterable<AbonementModel>.empty(),
  );

  // await ref.read(hiveProvider).delete('abonements');
});

/// The user recordrs provider for YClients API.
///
/// See: https://developers.yclients.com/ru/#operation/Получить%20записи%20пользователя
final StateNotifierProvider<SaveToHiveIterableNotifier<RecordModel, String>,
        Iterable<RecordModel>> userRecordsProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<RecordModel, String>,
        Iterable<RecordModel>>((final ref) {
  return SaveToHiveIterableNotifier<RecordModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'records',
    converter: const StringToIterableConverter(
      IterableConverter<RecordModel, Map<String, Object?>>(recordConverter),
    ),
    defaultValue: const Iterable<RecordModel>.empty(),
  );

  // await ref.read(hiveProvider).delete('records');
});
