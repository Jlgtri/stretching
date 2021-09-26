// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [SMStoryModel].
const SMStoryConverter smStoryConverter = SMStoryConverter._();

/// The converter of the [SMStoryModel].
class SMStoryConverter
    implements JsonConverter<SMStoryModel, Map<String, Object?>> {
  const SMStoryConverter._();

  @override
  SMStoryModel fromJson(final Map<String, Object?> data) =>
      SMStoryModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final SMStoryModel data) => data.toMap();
}

/// The model of a story in the SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/stories
@immutable
class SMStoryModel {
  /// The model of a story in the SMStretching API.
  ///
  /// See: https://smstretching.ru/wp-json/jet-cct/stories
  const SMStoryModel({
    required final this.id,
    required final this.cctStatus,
    required final this.media,
    required final this.link,
    required final this.cctAuthorId,
    required final this.cctCreated,
    required final this.cctModified,
    required final this.mediaLink,
    required final this.previewMedia,
    required final this.textPreview,
    required final this.mediaPreviewV2,
    required final this.storiesImgV2,
    required final this.cctSlug,
  });

  /// The id of this story in the SMStretching API.
  final int id;

  /// The private status of this gallery in the SMStretching API.
  final String cctStatus;

  /// The id of this media in the YClients API.
  final int media;

  /// The link to this story.
  final String link;

  /// The creator of this gallery in SMStretching API.
  final int cctAuthorId;

  /// The date and time this gallery was created in SMStretching API.
  final DateTime cctCreated;

  /// The date and time of the last time this gallery was modified in
  /// SMStretching API.
  final DateTime cctModified;

  /// The link to this media in the SMStretching API.
  final String mediaLink;

  /// The link to the previes of this media in the SMStretching API.
  final String previewMedia;

  /// The short description of this story media.
  final String textPreview;

  /// The new version of the media.
  final SMStoryContentModel? mediaPreviewV2;

  /// The new version of the media.
  final Iterable<SMStoryContentModel>? storiesImgV2;

  /// The type of this model in the SMStretching API.
  final String cctSlug;

  /// Return the copy of this model.
  SMStoryModel copyWith({
    final int? id,
    final String? cctStatus,
    final int? media,
    final String? link,
    final int? cctAuthorId,
    final DateTime? cctCreated,
    final DateTime? cctModified,
    final String? mediaLink,
    final String? previewMedia,
    final String? textPreview,
    final SMStoryContentModel? mediaPreviewV2,
    final Iterable<SMStoryContentModel>? storiesImgV2,
    final String? cctSlug,
  }) {
    return SMStoryModel(
      id: id ?? this.id,
      cctStatus: cctStatus ?? this.cctStatus,
      media: media ?? this.media,
      link: link ?? this.link,
      cctAuthorId: cctAuthorId ?? this.cctAuthorId,
      cctCreated: cctCreated ?? this.cctCreated,
      cctModified: cctModified ?? this.cctModified,
      mediaLink: mediaLink ?? this.mediaLink,
      previewMedia: previewMedia ?? this.previewMedia,
      textPreview: textPreview ?? this.textPreview,
      mediaPreviewV2: mediaPreviewV2 ?? this.mediaPreviewV2,
      storiesImgV2: storiesImgV2 ?? this.storiesImgV2,
      cctSlug: cctSlug ?? this.cctSlug,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      '_ID': id.toString(),
      'cct_status': cctStatus,
      'media': media.toString(),
      'link': link,
      'cct_author_id': cctAuthorId.toString(),
      'cct_created': cctCreated.toString().split('.').first,
      'cct_modified': cctModified.toString().split('.').first,
      'media_link': mediaLink,
      'preview_media': previewMedia,
      'text_preview': textPreview,
      'media_preview_v2': mediaPreviewV2?.toMap(),
      'stories_img_v2': storiesImgV2
          ?.map((final storyImgV2) => storyImgV2.toMap())
          .toList(growable: false),
      'cct_slug': cctSlug,
    };
  }

  /// Convert the map with string keys to this model.
  factory SMStoryModel.fromMap(final Map<String, Object?> map) {
    return SMStoryModel(
      id: int.parse(map['_ID']! as String),
      cctStatus: map['cct_status']! as String,
      media: int.parse(map['media']! as String),
      link: map['link']! as String,
      cctAuthorId: int.parse(map['cct_author_id']! as String),
      cctCreated: DateTime.parse(map['cct_created']! as String),
      cctModified: DateTime.parse(map['cct_modified']! as String),
      mediaLink: map['media_link']! as String,
      previewMedia: map['preview_media']! as String,
      textPreview: map['text_preview']! as String,
      mediaPreviewV2: map['media_preview_v2'] != null
          ? SMStoryContentModel.fromMap(
              map['media_preview_v2']! as Map<String, Object?>,
            )
          : null,
      storiesImgV2: map['stories_img_v2'] != null
          ? (map['stories_img_v2']! as Iterable)
              .cast<Map<String, Object?>>()
              .map(SMStoryContentModel.fromMap)
          : null,
      cctSlug: map['cct_slug']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMStoryModel.fromJson(final String source) =>
      SMStoryModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMStoryModel &&
            other.id == id &&
            other.cctStatus == cctStatus &&
            other.media == media &&
            other.link == link &&
            other.cctAuthorId == cctAuthorId &&
            other.cctCreated == cctCreated &&
            other.cctModified == cctModified &&
            other.mediaLink == mediaLink &&
            other.previewMedia == previewMedia &&
            other.textPreview == textPreview &&
            other.mediaPreviewV2 == mediaPreviewV2 &&
            other.storiesImgV2 == storiesImgV2 &&
            other.cctSlug == cctSlug;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cctStatus.hashCode ^
        media.hashCode ^
        link.hashCode ^
        cctAuthorId.hashCode ^
        cctCreated.hashCode ^
        cctModified.hashCode ^
        mediaLink.hashCode ^
        previewMedia.hashCode ^
        textPreview.hashCode ^
        mediaPreviewV2.hashCode ^
        storiesImgV2.hashCode ^
        cctSlug.hashCode;
  }

  @override
  String toString() {
    return 'SMStoryModel(id: $id, cctStatus: $cctStatus, media: $media, '
        'link: $link, cctAuthorId: $cctAuthorId, cctCreated: $cctCreated, '
        'cctModified: $cctModified, mediaLink: $mediaLink, '
        'previewMedia: $previewMedia, textPreview: $textPreview, '
        'mediaPreviewV2: $mediaPreviewV2, storiesImgV2: $storiesImgV2, '
        'cctSlug: $cctSlug)';
  }
}

/// The content of the [SMStoryModel].
@immutable
class SMStoryContentModel {
  /// The content of the [SMStoryModel].
  const SMStoryContentModel({
    required final this.id,
    required final this.url,
  });

  /// The id of this content.
  final int id;

  /// The id of this content.
  final String url;

  /// Return the copy of this model.
  SMStoryContentModel copyWith({final int? id, final String? url}) {
    return SMStoryContentModel(id: id ?? this.id, url: url ?? this.url);
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{'id': id, 'url': url};
  }

  /// Convert the map with string keys to this model.
  factory SMStoryContentModel.fromMap(final Map<String, Object?> map) {
    return SMStoryContentModel(
      id: map['id']! as int,
      url: map['url']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMStoryContentModel.fromJson(final String source) =>
      SMStoryContentModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMStoryContentModel && other.id == id && other.url == url;
  }

  @override
  int get hashCode => id.hashCode ^ url.hashCode;

  @override
  String toString() => 'SMStoryContentModel(id: $id, url: $url)';
}
