// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/utils/json_converters.dart';

/// The categories of [SMTrainerModel] and [SMStudioModel].
enum ClassCategory {
  /// See: https://smstretching.ru/classes/trx/
  trx,

  /// See: https://smstretching.ru/classes/stretching/
  stretching,

  /// See: https://smstretching.ru/classes/barre-signature/
  barreSignature,

  /// See: https://smstretching.ru/classes/pilates/
  pilates,

  /// See: https://smstretching.ru/classes/barre-2-0/
  barre20,

  /// See: https://smstretching.ru/classes/hot-stretching/
  hotStretching,

  /// See: https://smstretching.ru/classes/hot-barre/
  hotBarre,

  /// See: https://smstretching.ru/classes/hot-pilates/
  hotPilates,

  /// See: https://smstretching.ru/classes/dance-workout/
  danceWorkout,

  /// See: https://smstretching.ru/classes/fitboxing/
  fitBoxing
}

/// The extra data provided for [ClassCategory].
extension ClassCategoryData on ClassCategory {
  /// The translation of this category.
  String get translation => '${TR.category}.${enumToString(this)}'.tr();

  /// The id of this class in YClients API.
  int get id {
    switch (this) {
      case ClassCategory.trx:
        return 7209549;
      case ClassCategory.stretching:
        return 7209551;
      case ClassCategory.barreSignature:
        return 7209564;
      case ClassCategory.pilates:
        return 7145210;
      case ClassCategory.barre20:
        return 7140664;
      case ClassCategory.hotStretching:
        return 7209559;
      case ClassCategory.hotBarre:
        return 7209565;
      case ClassCategory.hotPilates:
        return 7209568;
      case ClassCategory.danceWorkout:
        return 7140661;
      case ClassCategory.fitBoxing:
        return 7140655;
    }
  }
}

/// The converter of the [SMClassesGalleryModel].
const SMClassesGalleryConverter smClassesGalleryConverter =
    SMClassesGalleryConverter._();

/// The converter of the [SMClassesGalleryModel].
class SMClassesGalleryConverter
    implements JsonConverter<SMClassesGalleryModel, Map<String, Object?>> {
  const SMClassesGalleryConverter._();

  @override
  SMClassesGalleryModel fromJson(final Map<String, Object?> data) =>
      SMClassesGalleryModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final SMClassesGalleryModel data) => data.toMap();
}

/// The model of the media provided for a classes from YClients API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/gallery_for_classes
@immutable
class SMClassesGalleryModel {
  /// The model of the media provided for a classes from YClients API.
  ///
  /// See: https://smstretching.ru/wp-json/jet-cct/gallery_for_classes
  const SMClassesGalleryModel({
    required final this.id,
    required final this.cctStatus,
    required final this.classesName,
    required final this.classesYId,
    required final this.gallery,
    required final this.cctAuthorId,
    required final this.cctCreated,
    required final this.cctModified,
    required final this.classInfo,
    required final this.takeThis,
    required final this.cctSlug,
  });

  /// The id of this gallery in SMStretching API.
  final int id;

  /// The private status of this gallery in SMStretching API.
  final String cctStatus;

  /// The name of the classes this gallery is for.
  final String classesName;

  /// The id of the classes this gallery is for in YClients API.
  final int classesYId;

  /// The link to this gallery in SMStretching API.
  final String gallery;

  /// The creator of this gallery in SMStretching API.
  final int cctAuthorId;

  /// The date and time this gallery was created in SMStretching API.
  final DateTime cctCreated;

  /// The date and time of the last time this gallery was modified in
  /// SMStretching API.
  final DateTime cctModified;

  /// The additional information about this gallery.
  final String? classInfo;

  /// The information abount what to take when training at the [classesYId] of
  /// this gallery.
  final String? takeThis;

  /// The type of this model in the SMStretching API.
  final String cctSlug;

  /// Return the copy of this model.
  SMClassesGalleryModel copyWith({
    final int? id,
    final String? cctStatus,
    final String? classesName,
    final int? classesYId,
    final String? gallery,
    final int? cctAuthorId,
    final DateTime? cctCreated,
    final DateTime? cctModified,
    final String? classInfo,
    final String? takeThis,
    final String? cctSlug,
  }) {
    return SMClassesGalleryModel(
      id: id ?? this.id,
      cctStatus: cctStatus ?? this.cctStatus,
      classesName: classesName ?? this.classesName,
      classesYId: classesYId ?? this.classesYId,
      gallery: gallery ?? this.gallery,
      cctAuthorId: cctAuthorId ?? this.cctAuthorId,
      cctCreated: cctCreated ?? this.cctCreated,
      cctModified: cctModified ?? this.cctModified,
      classInfo: classInfo ?? this.classInfo,
      takeThis: takeThis ?? this.takeThis,
      cctSlug: cctSlug ?? this.cctSlug,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      '_ID': id.toString(),
      'cct_status': cctStatus,
      'classes_name': classesName,
      'classes_yid': classesYId.toString(),
      'gallery': gallery,
      'cct_author_id': cctAuthorId.toString(),
      'cct_created': cctCreated.toString().split('.').first,
      'cct_modified': cctModified.toString().split('.').first,
      'class_info': classInfo,
      'take_this': takeThis,
      'cct_slug': cctSlug,
    };
  }

  /// Convert the map with string keys to this model.
  factory SMClassesGalleryModel.fromMap(final Map<String, Object?> map) {
    return SMClassesGalleryModel(
      id: int.parse(map['_ID']! as String),
      cctStatus: map['cct_status']! as String,
      classesName: map['classes_name']! as String,
      classesYId: int.parse(map['classes_yid']! as String),
      gallery: map['gallery']! as String,
      cctAuthorId: int.parse(map['cct_author_id']! as String),
      cctCreated: DateTime.parse(map['cct_created']! as String),
      cctModified: DateTime.parse(map['cct_modified']! as String),
      classInfo: map['class_info'] as String?,
      takeThis: map['take_this'] as String?,
      cctSlug: map['cct_slug']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMClassesGalleryModel.fromJson(final String source) {
    return SMClassesGalleryModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMClassesGalleryModel &&
            other.id == id &&
            other.cctStatus == cctStatus &&
            other.classesName == classesName &&
            other.classesYId == classesYId &&
            other.gallery == gallery &&
            other.cctAuthorId == cctAuthorId &&
            other.cctCreated == cctCreated &&
            other.cctModified == cctModified &&
            other.classInfo == classInfo &&
            other.takeThis == takeThis &&
            other.cctSlug == cctSlug;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cctStatus.hashCode ^
        classesName.hashCode ^
        classesYId.hashCode ^
        gallery.hashCode ^
        cctAuthorId.hashCode ^
        cctCreated.hashCode ^
        cctModified.hashCode ^
        classInfo.hashCode ^
        takeThis.hashCode ^
        cctSlug.hashCode;
  }

  @override
  String toString() {
    return 'SMClassesGalleryModel(id: $id, cctStatus: $cctStatus, '
        'classesName: $classesName, classesYId: $classesYId, '
        'gallery: $gallery, cctAuthorId: $cctAuthorId, '
        'cctCreated: $cctCreated, cctModified: $cctModified, '
        'classInfo: $classInfo, takeThis: $takeThis, cctSlug: $cctSlug)';
  }
}
