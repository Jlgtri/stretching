import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
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

/// The studios provider for SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/studii
final StateNotifierProvider<SaveToHiveIterableNotifier<SMStudioModel, String>,
        Iterable<SMStudioModel>> smStudiosProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<SMStudioModel, String>,
        Iterable<SMStudioModel>>((final ref) {
  return SaveToHiveIterableNotifier<SMStudioModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'smStudios',
    converter:
        const StringToIterableConverter(IterableConverter(smStudioConverter)),
    defaultValue: const Iterable<SMStudioModel>.empty(),
  );
});

/// The trainers provider for SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/shtab_v2
final StateNotifierProvider<SaveToHiveIterableNotifier<SMTrainerModel, String>,
        Iterable<SMTrainerModel>> smTrainersProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<SMTrainerModel, String>,
        Iterable<SMTrainerModel>>((final ref) {
  return SaveToHiveIterableNotifier<SMTrainerModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'smTrainers',
    converter: const StringToIterableConverter(
      IterableConverter(smTrainerConverter),
    ),
    defaultValue: const Iterable<SMTrainerModel>.empty(),
  );
});
