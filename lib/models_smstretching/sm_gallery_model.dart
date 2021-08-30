// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';

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
  final String classInfo;
  final String takeThis;

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
      'cct_created': cctCreated.toString(),
      'cct_modified': cctModified.toString(),
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
      classInfo: map['class_info']! as String,
      takeThis: map['take_this']! as String,
      cctSlug: map['cct_slug']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMClassesGalleryModel.fromJson(final String source) =>
      SMClassesGalleryModel.fromMap(
        json.decode(source) as Map<String, Object?>,
      );

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
