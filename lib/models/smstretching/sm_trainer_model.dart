// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/models/smstretching/sm_classes_gallery_model.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [SMTrainerModel].
const SMStudioConverter smTrainerConverter = SMStudioConverter._();

/// The converter of the [SMTrainerModel].
class SMStudioConverter
    implements JsonConverter<SMTrainerModel, Map<String, Object?>> {
  const SMStudioConverter._();

  @override
  SMTrainerModel fromJson(final Map<String, Object?> data) =>
      SMTrainerModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final SMTrainerModel data) => data.toMap();
}

/// The model of the trainer in the SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/shtab_v2
@immutable
class SMTrainerModel implements Comparable<SMTrainerModel> {
  /// The model of the trainer in the SMStretching API.
  ///
  /// See: https://smstretching.ru/wp-json/jet-cct/shtab_v2
  const SMTrainerModel({
    required final this.id,
    required final this.cctStatus,
    required final this.trainerId,
    required final this.trainerName,
    required final this.mediaPhoto,
    required final this.shortlyAbout,
    required final this.trainerPhoto,
    required final this.cctAuthorId,
    required final this.cctCreated,
    required final this.cctModified,
    required final this.classesType,
    required final this.cctSlug,
  });

  /// The id of this trainer in the SMStretching API.
  final int id;

  /// The private status of this studio in SMStretching API.
  final String cctStatus;

  /// The id of this trainer in the YClients API.
  final int trainerId;

  /// The name of this trainer.
  final String trainerName;

  /// The profile video of this trainer.
  final String mediaPhoto;

  /// The short description of this trainer.
  final String shortlyAbout;

  /// The avatar of this trainer.
  final String trainerPhoto;

  /// The creator of this studio in SMStretching API.
  final int cctAuthorId;

  /// The date and time this studio was created in SMStretching API.
  final DateTime cctCreated;

  /// The data and time of the last time this studio was modified in
  /// SMStretching API.
  final DateTime cctModified;

  /// The supported classes of this trainer.
  final SMTrainerClassesModel? classesType;

  /// The type of this model in the SMStretching API.
  final String cctSlug;

  /// Return the copy of this model.
  SMTrainerModel copyWith({
    final int? id,
    final String? cctStatus,
    final int? trainerId,
    final String? trainerName,
    final String? mediaPhoto,
    final String? shortlyAbout,
    final String? trainerPhoto,
    final int? cctAuthorId,
    final DateTime? cctCreated,
    final DateTime? cctModified,
    final SMTrainerClassesModel? classesType,
    final String? cctSlug,
  }) =>
      SMTrainerModel(
        id: id ?? this.id,
        cctStatus: cctStatus ?? this.cctStatus,
        trainerId: trainerId ?? this.trainerId,
        trainerName: trainerName ?? this.trainerName,
        mediaPhoto: mediaPhoto ?? this.mediaPhoto,
        shortlyAbout: shortlyAbout ?? this.shortlyAbout,
        trainerPhoto: trainerPhoto ?? this.trainerPhoto,
        cctAuthorId: cctAuthorId ?? this.cctAuthorId,
        cctCreated: cctCreated ?? this.cctCreated,
        cctModified: cctModified ?? this.cctModified,
        classesType: classesType ?? this.classesType,
        cctSlug: cctSlug ?? this.cctSlug,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        '_ID': id.toString(),
        'cct_status': cctStatus,
        'trainer_id': trainerId.toString(),
        'trainer_name': trainerName,
        'media_photo': mediaPhoto,
        'shortly_about': shortlyAbout,
        'trainer_photo': trainerPhoto,
        'cct_author_id': cctAuthorId.toString(),
        'cct_created': cctCreated.toString().split('.').first,
        'cct_modified': cctModified.toString().split('.').first,
        'classestype': classesType?.toMap(),
        'cct_slug': cctSlug,
      };

  /// Convert the map with string keys to this model.
  factory SMTrainerModel.fromMap(final Map<String, Object?> map) =>
      SMTrainerModel(
        id: int.parse(map['_ID']! as String),
        cctStatus: map['cct_status']! as String,
        trainerId: int.parse(map['trainer_id']! as String),
        trainerName: map['trainer_name']! as String,
        mediaPhoto: map['media_photo']! as String,
        shortlyAbout: map['shortly_about']! as String,
        trainerPhoto: map['trainer_photo']! as String,
        cctAuthorId: int.parse(map['cct_author_id']! as String),
        cctCreated: DateTime.parse(map['cct_created']! as String),
        cctModified: DateTime.parse(map['cct_modified']! as String),
        classesType: map['classestype'] != null
            ? SMTrainerClassesModel.fromMap(
                map['classestype']! as Map<String, Object?>,
              )
            : null,
        cctSlug: map['cct_slug']! as String,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMTrainerModel.fromJson(final String source) =>
      SMTrainerModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  int compareTo(final SMTrainerModel other) =>
      trainerName.toLowerCase().compareTo(other.trainerName.toLowerCase());

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is SMTrainerModel &&
          other.id == id &&
          other.cctStatus == cctStatus &&
          other.trainerId == trainerId &&
          other.trainerName == trainerName &&
          other.mediaPhoto == mediaPhoto &&
          other.shortlyAbout == shortlyAbout &&
          other.trainerPhoto == trainerPhoto &&
          other.cctAuthorId == cctAuthorId &&
          other.cctCreated == cctCreated &&
          other.cctModified == cctModified &&
          other.classesType == classesType &&
          other.cctSlug == cctSlug;

  @override
  int get hashCode =>
      id.hashCode ^
      cctStatus.hashCode ^
      trainerId.hashCode ^
      trainerName.hashCode ^
      mediaPhoto.hashCode ^
      shortlyAbout.hashCode ^
      trainerPhoto.hashCode ^
      cctAuthorId.hashCode ^
      cctCreated.hashCode ^
      cctModified.hashCode ^
      classesType.hashCode ^
      cctSlug.hashCode;

  @override
  String toString() => 'SMTrainerModel(id: $id, cctStatus: $cctStatus, '
      'trainerId: $trainerId, trainerName: $trainerName, '
      'mediaPhoto: $mediaPhoto, shortlyAbout: $shortlyAbout, '
      'trainerPhoto: $trainerPhoto, cctAuthorId: $cctAuthorId, '
      'cctCreated: $cctCreated, cctModified: $cctModified, '
      'classesType: $classesType, cctSlug: $cctSlug)';
}

/// The model of trainer's classses in the [SMTrainerModel].
@immutable
class SMTrainerClassesModel {
  /// The model of trainer's classses in the [SMTrainerModel].
  const SMTrainerClassesModel({
    required final this.trx,
    required final this.stretching,
    required final this.barreSignature,
    required final this.pilates,
    required final this.barre20,
    required final this.hotStretching,
    required final this.hotBarre,
    required final this.hotPilates,
    required final this.danceWorkout,
    required final this.fitBoxing,
  });

  /// If TRX is in the studio tags.
  final bool trx;

  /// If Stretching is in the studio tags.
  final bool stretching;

  /// If Barre Signature is in the studio tags.
  final bool barreSignature;

  /// If Pilates is in the studio tags.
  final bool pilates;

  /// If Barre 2.0 is in the studio tags.
  final bool barre20;

  /// If Hot  Stretching is in the studio tags.
  final bool hotStretching;

  /// If Hot Barre is in the studio tags.
  final bool hotBarre;

  /// If Hot Pilates is in the studio tags.
  final bool hotPilates;

  /// If Dance workout is in the studio tags.
  final bool danceWorkout;

  /// If Fit Boxing is in the studio tags.
  final bool fitBoxing;

  /// Return the categories of this model.
  Iterable<ClassCategory> toCategories({final bool onlyActive = true}) =>
      <ClassCategory>[
        if (!onlyActive || trx) ClassCategory.trx,
        if (!onlyActive || stretching) ClassCategory.stretching,
        if (!onlyActive || barreSignature) ClassCategory.barreSignature,
        if (!onlyActive || pilates) ClassCategory.pilates,
        if (!onlyActive || barre20) ClassCategory.barre20,
        if (!onlyActive || hotStretching) ClassCategory.hotStretching,
        if (!onlyActive || hotBarre) ClassCategory.hotBarre,
        if (!onlyActive || hotPilates) ClassCategory.hotPilates,
        if (!onlyActive || danceWorkout) ClassCategory.danceWorkout,
        if (!onlyActive || fitBoxing) ClassCategory.fitBoxing
      ];

  /// Return the copy of this model.
  SMTrainerClassesModel copyWith({
    final bool? trx,
    final bool? stretching,
    final bool? barreSignature,
    final bool? pilates,
    final bool? barre20,
    final bool? hotStretching,
    final bool? hotBarre,
    final bool? hotPilates,
    final bool? danceWorkout,
    final bool? fitBoxing,
  }) =>
      SMTrainerClassesModel(
        trx: trx ?? this.trx,
        stretching: stretching ?? this.stretching,
        barreSignature: barreSignature ?? this.barreSignature,
        pilates: pilates ?? this.pilates,
        barre20: barre20 ?? this.barre20,
        hotStretching: hotStretching ?? this.hotStretching,
        hotBarre: hotBarre ?? this.hotBarre,
        hotPilates: hotPilates ?? this.hotPilates,
        danceWorkout: danceWorkout ?? this.danceWorkout,
        fitBoxing: fitBoxing ?? this.fitBoxing,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        'Stretching': boolToStringConverter.toJson(stretching),
        'Hot Stretching': boolToStringConverter.toJson(hotStretching),
        'Barre Signature': boolToStringConverter.toJson(barreSignature),
        'Barre 2.0': boolToStringConverter.toJson(barre20),
        'Hot Barre': boolToStringConverter.toJson(hotBarre),
        'Pilates': boolToStringConverter.toJson(pilates),
        'Hot Pilates': boolToStringConverter.toJson(hotPilates),
        'FitBoxing': boolToStringConverter.toJson(fitBoxing),
        'Dance Workout': boolToStringConverter.toJson(danceWorkout),
        'TRX': boolToStringConverter.toJson(trx),
      };

  /// Convert the map with string keys to this model.
  factory SMTrainerClassesModel.fromMap(final Map<String, Object?> map) =>
      SMTrainerClassesModel(
        stretching:
            boolToStringConverter.fromJson(map['Stretching']! as String),
        hotStretching:
            boolToStringConverter.fromJson(map['Hot Stretching']! as String),
        barreSignature:
            boolToStringConverter.fromJson(map['Barre Signature']! as String),
        barre20: boolToStringConverter.fromJson(map['Barre 2.0']! as String),
        hotBarre: boolToStringConverter.fromJson(map['Hot Barre']! as String),
        pilates: boolToStringConverter.fromJson(map['Pilates']! as String),
        hotPilates:
            boolToStringConverter.fromJson(map['Hot Pilates']! as String),
        fitBoxing: boolToStringConverter.fromJson(map['FitBoxing']! as String),
        danceWorkout:
            boolToStringConverter.fromJson(map['Dance Workout']! as String),
        trx: boolToStringConverter.fromJson(map['TRX']! as String),
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMTrainerClassesModel.fromJson(final String source) =>
      SMTrainerClassesModel.fromMap(
        json.decode(source) as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is SMTrainerClassesModel &&
          other.trx == trx &&
          other.stretching == stretching &&
          other.barreSignature == barreSignature &&
          other.pilates == pilates &&
          other.barre20 == barre20 &&
          other.hotStretching == hotStretching &&
          other.hotBarre == hotBarre &&
          other.hotPilates == hotPilates &&
          other.danceWorkout == danceWorkout &&
          other.fitBoxing == fitBoxing;

  @override
  int get hashCode =>
      trx.hashCode ^
      stretching.hashCode ^
      barreSignature.hashCode ^
      pilates.hashCode ^
      barre20.hashCode ^
      hotStretching.hashCode ^
      hotBarre.hashCode ^
      hotPilates.hashCode ^
      danceWorkout.hashCode ^
      fitBoxing.hashCode;

  @override
  String toString() =>
      'SMTrainerClassesModel(trx: $trx, stretching: $stretching, '
      'barreSignature: $barreSignature, pilates: $pilates, '
      'barre20: $barre20, hotStretching: $hotStretching, '
      'hotBarre: $hotBarre, hotPilates: $hotPilates, '
      'danceWorkout: $danceWorkout, fitBoxing: $fitBoxing)';
}
