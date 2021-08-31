import 'package:easy_localization/easy_localization.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/utils/enum_to_string.dart';

/// The categories of [SMTrainerModel] and [SMStudioModel].
enum ClassCategory {
  trx,
  stretching,
  barreSignature,
  pilates,
  barre20,
  hotStretching,
  hotBarre,
  hotPilates,
  danceWorkout,
  fitBoxing
}

/// The extra data provided for [ClassCategory].
extension CategoriesData on ClassCategory {
  /// The translation of this category.
  String get translation => '${TR.category}.${enumToString(this)}'.tr();
}
