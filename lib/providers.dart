import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/models/abonement_model.dart';
import 'package:stretching/models/activity_model.dart';
import 'package:stretching/models/city_model.dart';
import 'package:stretching/models/company_model.dart';
import 'package:stretching/models/record_model.dart';
import 'package:stretching/models/trainer_model.dart';
import 'package:stretching/models/user_model.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/utils/json_converters.dart';

/// The provider of a user.
final StateNotifierProvider<OptionalSaveToHiveNotifier<UserModel?, String>,
        UserModel?> userProvider =
    StateNotifierProvider<OptionalSaveToHiveNotifier<UserModel?, String>,
        UserModel?>((final ref) {
  return OptionalSaveToHiveNotifier<UserModel?, String>(
    hive: ref.watch(hiveProvider),
    converter: const OptionalStringConverter(userConverter),
    saveName: 'user',
  );
});

/// If current [userProvider]'s state is null.
final Provider<bool> userIsNullProvider = Provider<bool>((final ref) {
  return ref.watch(userProvider.select((final user) => user == null));
});

/// The cities provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/40/0/0
final StateNotifierProvider<SaveToHiveIterableNotifier<CityModel, String>,
        Iterable<CityModel>> citiesProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<CityModel, String>,
        Iterable<CityModel>>((final ref) {
  return SaveToHiveIterableNotifier<CityModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'cities',
    converter: const StringConverter(IterableConverter(cityConverter)),
    defaultValue: const Iterable<CityModel>.empty(),
  );
});

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
    converter: const StringConverter(IterableConverter(companyConverter)),
    defaultValue: const Iterable<StudioModel>.empty(),
  );
});

/// The trainers provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/6/0//
final StateNotifierProvider<SaveToHiveIterableNotifier<TrainerModel, String>,
        Iterable<TrainerModel>> trainersProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<TrainerModel, String>,
        Iterable<TrainerModel>>((final ref) {
  return SaveToHiveIterableNotifier<TrainerModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'trainers',
    converter: const StringConverter(IterableConverter(trainerConverter)),
    defaultValue: const Iterable<TrainerModel>.empty(),
  );
});

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
    converter: const StringConverter(IterableConverter(activityConverter)),
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
    converter: const StringConverter(IterableConverter(abonementConverter)),
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
    converter: const StringConverter(IterableConverter(recordConverter)),
    defaultValue: const Iterable<RecordModel>.empty(),
  );

  // await ref.read(hiveProvider).delete('records');
});
