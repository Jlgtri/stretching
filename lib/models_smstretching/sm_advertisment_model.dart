// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [SMAdvertismentModel].
const SMAdvertismentConverter smAdvertismentConverter =
    SMAdvertismentConverter._();

/// The converter of the [SMAdvertismentModel].
class SMAdvertismentConverter
    implements JsonConverter<SMAdvertismentModel, Map<String, Object?>> {
  const SMAdvertismentConverter._();

  @override
  SMAdvertismentModel fromJson(final Map<String, Object?> data) =>
      SMAdvertismentModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final SMAdvertismentModel data) => data.toMap();
}

/// The advertisment model is the SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/adv_banner
@immutable
class SMAdvertismentModel {
  /// The advertisment model is the SMStretching API.
  ///
  /// See: https://smstretching.ru/wp-json/jet-cct/adv_banner
  const SMAdvertismentModel({
    required final this.id,
    required final this.cctStatus,
    required final this.advImage,
    required final this.advLink,
    required final this.cctAuthorId,
    required final this.cctCreated,
    required final this.cctModified,
    required final this.cctSlug,
  });

  /// The id of this advertisment in SMStretching API.
  final int id;

  /// The private status of this advertisment in SMStretching API.
  final String cctStatus;

  /// The link to the image of this advertisment.
  final String advImage;

  /// The link to this advertisment.
  final String advLink;

  /// The creator of this gallery in SMStretching API.
  final int cctAuthorId;

  /// The date and time this gallery was created in SMStretching API.
  final DateTime cctCreated;

  /// The date and time of the last time this gallery was modified in
  /// SMStretching API.
  final DateTime cctModified;

  /// The type of this model in the SMStretching API.
  final String cctSlug;

  /// Return the copy of this model.
  SMAdvertismentModel copyWith({
    final int? id,
    final String? cctStatus,
    final String? advImage,
    final String? advLink,
    final int? cctAuthorId,
    final DateTime? cctCreated,
    final DateTime? cctModified,
    final String? cctSlug,
  }) {
    return SMAdvertismentModel(
      id: id ?? this.id,
      cctStatus: cctStatus ?? this.cctStatus,
      advImage: advImage ?? this.advImage,
      advLink: advLink ?? this.advLink,
      cctAuthorId: cctAuthorId ?? this.cctAuthorId,
      cctCreated: cctCreated ?? this.cctCreated,
      cctModified: cctModified ?? this.cctModified,
      cctSlug: cctSlug ?? this.cctSlug,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      '_ID': id.toString(),
      'cct_status': cctStatus,
      'adv_image': advImage,
      'adv_link': advLink,
      'cct_author_id': cctAuthorId.toString().split('.').first,
      'cct_created': cctCreated.toString().split('.').first,
      'cct_modified': cctModified.toString(),
      'cct_slug': cctSlug,
    };
  }

  /// Convert the map with string keys to this model.
  factory SMAdvertismentModel.fromMap(final Map<String, Object?> map) {
    return SMAdvertismentModel(
      id: int.parse(map['_ID']! as String),
      cctStatus: map['cct_status']! as String,
      advImage: map['adv_image']! as String,
      advLink: map['adv_link']! as String,
      cctAuthorId: int.parse(map['cct_author_id']! as String),
      cctCreated: DateTime.parse(map['cct_created']! as String),
      cctModified: DateTime.parse(map['cct_modified']! as String),
      cctSlug: map['cct_slug']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMAdvertismentModel.fromJson(final String source) =>
      SMAdvertismentModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMAdvertismentModel &&
            other.id == id &&
            other.cctStatus == cctStatus &&
            other.advImage == advImage &&
            other.advLink == advLink &&
            other.cctAuthorId == cctAuthorId &&
            other.cctCreated == cctCreated &&
            other.cctModified == cctModified &&
            other.cctSlug == cctSlug;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cctStatus.hashCode ^
        advImage.hashCode ^
        advLink.hashCode ^
        cctAuthorId.hashCode ^
        cctCreated.hashCode ^
        cctModified.hashCode ^
        cctSlug.hashCode;
  }

  @override
  String toString() {
    return 'SMAdvertismentModel(id: $id, cctStatus: $cctStatus, '
        'advImage: $advImage, advLink: $advLink, cctAuthorId: $cctAuthorId, '
        'cctCreated: $cctCreated, cctModified: $cctModified, '
        'cctSlug: $cctSlug)';
  }
}
