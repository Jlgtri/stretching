// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/models_smstretching/sm_classes_gallery_model.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/navigation/components/filters.dart';

/// The converter of the [SMStudioModel].
const SMStudioConverter smStudioConverter = SMStudioConverter._();

/// The converter of the [SMStudioModel].
class SMStudioConverter
    implements JsonConverter<SMStudioModel, Map<String, Object?>> {
  const SMStudioConverter._();

  @override
  SMStudioModel fromJson(final Map<String, Object?> data) =>
      SMStudioModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final SMStudioModel data) => data.toMap();
}

/// The model of a studio from SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/studii
@immutable
class SMStudioModel implements Comparable<SMStudioModel> {
  /// The model of a studio from SMStretching API.
  ///
  /// See: https://smstretching.ru/wp-json/jet-cct/studii
  const SMStudioModel({
    required final this.id,
    required final this.cctStatus,
    required final this.studioName,
    required final this.studioAddress,
    required final this.studioTags,
    required final this.studioUrlAbout,
    required final this.studioUrlCalendar,
    required final this.mediaGallery,
    required final this.cctAuthorId,
    required final this.cctCreated,
    required final this.cctModified,
    required final this.studioYId,
    required final this.mediaGallerySite,
    required final this.cctSinglePostId,
    required final this.link,
    required final this.instagram,
    required final this.phone,
    required final this.about,
    required final this.where,
    required final this.whatTodo,
    required final this.howToFind,
    required final this.cctSlug,
  });

  /// The id of this studio in SMStretching API.
  final int id;

  /// The private status of this trainer in SMStretching API.
  final String cctStatus;

  /// The name of this studio.
  final String studioName;

  /// The address of this studio.
  final String studioAddress;

  /// The tags of this studio.
  final SMStudioTagsModel studioTags;

  /// The link to the info page of this studio.
  final String studioUrlAbout;

  /// The link to the activities calendar of this studio.
  final String studioUrlCalendar;

  /// The main media from the media gallery provided for this studio.
  final String mediaGallery;

  /// The creator of this studio in SMStretching API.
  final int cctAuthorId;

  /// The date and time this studio was created in SMStretching API.
  final DateTime cctCreated;

  /// The data and time of the last time this studio was modified in
  /// SMStretching API.
  final DateTime cctModified;

  /// The id of this studio in YClients API.
  final int studioYId;

  /// The media gallery provided for this studio.
  final Iterable<SMStudioMediaModel> mediaGallerySite;

  final int cctSinglePostId;

  /// The link to this studio's profile page.
  final String link;

  /// The link to this studio's Instagram page.
  final String instagram;

  /// The phone number of this studio.
  final String phone;

  /// The description of this studio.
  final String about;

  /// The link to the on-map location of this studio.
  final String where;

  final String whatTodo;

  final String howToFind;

  /// The type of this model in the SMStretching API.
  final String cctSlug;

  @override
  int compareTo(final SMStudioModel other) => id.compareTo(other.id);

  /// Return the copy of this model.
  SMStudioModel copyWith({
    final int? id,
    final String? cctStatus,
    final String? studioName,
    final String? studioAddress,
    final SMStudioTagsModel? studioTags,
    final String? studioUrlAbout,
    final String? studioUrlCalendar,
    final String? mediaGallery,
    final int? cctAuthorId,
    final DateTime? cctCreated,
    final DateTime? cctModified,
    final int? studioYId,
    final Iterable<SMStudioMediaModel>? mediaGallerySite,
    final int? cctSinglePostId,
    final String? link,
    final String? instagram,
    final String? phone,
    final String? about,
    final String? where,
    final String? whatTodo,
    final String? howToFind,
    final String? cctSlug,
  }) {
    return SMStudioModel(
      id: id ?? this.id,
      cctStatus: cctStatus ?? this.cctStatus,
      studioName: studioName ?? this.studioName,
      studioAddress: studioAddress ?? this.studioAddress,
      studioTags: studioTags ?? this.studioTags,
      studioUrlAbout: studioUrlAbout ?? this.studioUrlAbout,
      studioUrlCalendar: studioUrlCalendar ?? this.studioUrlCalendar,
      mediaGallery: mediaGallery ?? this.mediaGallery,
      cctAuthorId: cctAuthorId ?? this.cctAuthorId,
      cctCreated: cctCreated ?? this.cctCreated,
      cctModified: cctModified ?? this.cctModified,
      studioYId: studioYId ?? this.studioYId,
      mediaGallerySite: mediaGallerySite ?? this.mediaGallerySite,
      cctSinglePostId: cctSinglePostId ?? this.cctSinglePostId,
      link: link ?? this.link,
      instagram: instagram ?? this.instagram,
      phone: phone ?? this.phone,
      about: about ?? this.about,
      where: where ?? this.where,
      whatTodo: whatTodo ?? this.whatTodo,
      howToFind: howToFind ?? this.howToFind,
      cctSlug: cctSlug ?? this.cctSlug,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      '_ID': id.toString(),
      'cct_status': cctStatus,
      'studio_name': studioName,
      'studio_address': studioAddress,
      'studio_tags': studioTags.toMap(),
      'studio_url_about': studioUrlAbout,
      'studio_url_calendar': studioUrlCalendar,
      'media_gallery': mediaGallery,
      'cct_author_id': cctAuthorId.toString(),
      'cct_created': cctCreated.toString().split('.').first,
      'cct_modified': cctModified.toString().split('.').first,
      'studio_yid': studioYId.toString(),
      'media_gallery_site':
          mediaGallerySite.map((final x) => x.toMap()).toList(growable: false),
      'cct_single_post_id': cctSinglePostId.toString(),
      'link': link,
      'instagram': instagram,
      'phone': phone,
      'about': about,
      '_where': where,
      'what_todo': whatTodo,
      '_how_to_find': howToFind,
      'cct_slug': cctSlug,
    };
  }

  /// Convert the map with string keys to this model.
  factory SMStudioModel.fromMap(final Map<String, Object?> map) {
    return SMStudioModel(
      id: int.parse(map['_ID']! as String),
      cctStatus: map['cct_status']! as String,
      studioName: map['studio_name']! as String,
      studioAddress: map['studio_address']! as String,
      studioTags: SMStudioTagsModel.fromMap(
        map['studio_tags']! as Map<String, Object?>,
      ),
      studioUrlAbout: map['studio_url_about']! as String,
      studioUrlCalendar: map['studio_url_calendar']! as String,
      mediaGallery: map['media_gallery']! as String,
      cctAuthorId: int.parse(map['cct_author_id']! as String),
      cctCreated: DateTime.parse(map['cct_created']! as String),
      cctModified: DateTime.parse(map['cct_modified']! as String),
      studioYId: int.parse(map['studio_yid']! as String),
      mediaGallerySite: (map['media_gallery_site']! as Iterable)
          .cast<Map<String, Object?>>()
          .map(SMStudioMediaModel.fromMap),
      cctSinglePostId: int.parse(map['cct_single_post_id']! as String),
      link: map['link']! as String,
      instagram: map['instagram']! as String,
      phone: map['phone']! as String,
      about: map['about']! as String,
      where: map['_where']! as String,
      whatTodo: map['what_todo']! as String,
      howToFind: map['_how_to_find']! as String,
      cctSlug: map['cct_slug']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMStudioModel.fromJson(final String source) =>
      SMStudioModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMStudioModel &&
            other.id == id &&
            other.cctStatus == cctStatus &&
            other.studioName == studioName &&
            other.studioAddress == studioAddress &&
            other.studioTags == studioTags &&
            other.studioUrlAbout == studioUrlAbout &&
            other.studioUrlCalendar == studioUrlCalendar &&
            other.mediaGallery == mediaGallery &&
            other.cctAuthorId == cctAuthorId &&
            other.cctCreated == cctCreated &&
            other.cctModified == cctModified &&
            other.studioYId == studioYId &&
            other.mediaGallerySite == mediaGallerySite &&
            other.cctSinglePostId == cctSinglePostId &&
            other.link == link &&
            other.instagram == instagram &&
            other.phone == phone &&
            other.about == about &&
            other.where == where &&
            other.whatTodo == whatTodo &&
            other.howToFind == howToFind &&
            other.cctSlug == cctSlug;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        cctStatus.hashCode ^
        studioName.hashCode ^
        studioAddress.hashCode ^
        studioTags.hashCode ^
        studioUrlAbout.hashCode ^
        studioUrlCalendar.hashCode ^
        mediaGallery.hashCode ^
        cctAuthorId.hashCode ^
        cctCreated.hashCode ^
        cctModified.hashCode ^
        studioYId.hashCode ^
        mediaGallerySite.hashCode ^
        cctSinglePostId.hashCode ^
        link.hashCode ^
        instagram.hashCode ^
        phone.hashCode ^
        about.hashCode ^
        where.hashCode ^
        whatTodo.hashCode ^
        howToFind.hashCode ^
        cctSlug.hashCode;
  }

  @override
  String toString() {
    return 'SMStudioModel(id: $id, cctStatus: $cctStatus, '
        'studioName: $studioName, studioAddress: $studioAddress, '
        'studioTags: $studioTags, studioUrlAbout: $studioUrlAbout, '
        'studioUrlCalendar: $studioUrlCalendar, mediaGallery: $mediaGallery, '
        'cctAuthorId: $cctAuthorId, cctCreated: $cctCreated, '
        'cctModified: $cctModified, studioYId: $studioYId, '
        'mediaGallerySite: $mediaGallerySite, '
        'cctSinglePostId: $cctSinglePostId, link: $link, '
        'instagram: $instagram, phone: $phone, about: $about, where: $where, '
        'whatTodo: $whatTodo, howToFind: $howToFind, cctSlug: $cctSlug)';
  }
}

/// The model of the media provided for the [SMStudioModel].
@immutable
class SMStudioMediaModel {
  /// The model of the media provided for the [SMStudioModel].
  const SMStudioMediaModel({
    required final this.id,
    required final this.url,
  });

  /// The id of this media.
  final int id;

  /// The url to this media.
  final String url;

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{'id': id, 'url': url};
  }

  /// Convert the map with string keys to this model.
  factory SMStudioMediaModel.fromMap(final Map<String, Object?> map) {
    return SMStudioMediaModel(
      id: map['id']! as int,
      url: map['url']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMStudioMediaModel.fromJson(final String source) {
    return SMStudioMediaModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  /// Return the copy of this model.
  SMStudioMediaModel copyWith({final int? id, final String? url}) {
    return SMStudioMediaModel(id: id ?? this.id, url: url ?? this.url);
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMStudioMediaModel && other.id == id && other.url == url;
  }

  @override
  int get hashCode => id.hashCode ^ url.hashCode;

  @override
  String toString() => 'SMStudioMediaModel(id: $id, url: $url)';
}

/// The model of the present tags in the [SMStudioModel].
@immutable
class SMStudioTagsModel {
  /// The model of the present tags in the [SMStudioModel].
  const SMStudioTagsModel({
    required final this.trx,
    required final this.stretching,
    required final this.barreSignature,
    required final this.pilates,
    required final this.barre20,
    required final this.hot36Stretching,
    required final this.hot36Barre,
    required final this.hot36Pilates,
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

  /// If Hot 36 Stretching is in the studio tags.
  final bool hot36Stretching;

  /// If Hot 36 Barre is in the studio tags.
  final bool hot36Barre;

  /// If Hot 36 Pilates is in the studio tags.
  final bool hot36Pilates;

  /// If Dance workout is in the studio tags.
  final bool danceWorkout;

  /// If Fit Boxing is in the studio tags.
  final bool fitBoxing;

  /// Return the categories of this model.
  Iterable<ClassCategory> toCategories({final bool onlyActive = true}) {
    return <ClassCategory>[
      if (!onlyActive || trx) ClassCategory.trx,
      if (!onlyActive || stretching) ClassCategory.stretching,
      if (!onlyActive || barreSignature) ClassCategory.barreSignature,
      if (!onlyActive || pilates) ClassCategory.pilates,
      if (!onlyActive || barre20) ClassCategory.barre20,
      if (!onlyActive || hot36Stretching) ClassCategory.hotStretching,
      if (!onlyActive || hot36Barre) ClassCategory.hotBarre,
      if (!onlyActive || hot36Pilates) ClassCategory.hotPilates,
      if (!onlyActive || danceWorkout) ClassCategory.danceWorkout,
      if (!onlyActive || fitBoxing) ClassCategory.fitBoxing
    ];
  }

  /// Return the copy of this model.
  SMStudioTagsModel copyWith({
    final bool? trx,
    final bool? stretching,
    final bool? barreSignature,
    final bool? pilates,
    final bool? barre20,
    final bool? hot36Stretching,
    final bool? hot36Barre,
    final bool? hot36Pilates,
    final bool? danceWorkout,
    final bool? fitBoxing,
  }) {
    return SMStudioTagsModel(
      trx: trx ?? this.trx,
      stretching: stretching ?? this.stretching,
      barreSignature: barreSignature ?? this.barreSignature,
      pilates: pilates ?? this.pilates,
      barre20: barre20 ?? this.barre20,
      hot36Stretching: hot36Stretching ?? this.hot36Stretching,
      hot36Barre: hot36Barre ?? this.hot36Barre,
      hot36Pilates: hot36Pilates ?? this.hot36Pilates,
      danceWorkout: danceWorkout ?? this.danceWorkout,
      fitBoxing: fitBoxing ?? this.fitBoxing,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'TRX': boolToStringConverter.toJson(trx),
      'Stretching': boolToStringConverter.toJson(stretching),
      'Barre Signature': boolToStringConverter.toJson(barreSignature),
      'Pilates': boolToStringConverter.toJson(pilates),
      'Barre 2.0': boolToStringConverter.toJson(barre20),
      'Hot 36° Stretching': boolToStringConverter.toJson(hot36Stretching),
      'Hot 36° Barre': boolToStringConverter.toJson(hot36Barre),
      'Hot 36° Pilates': boolToStringConverter.toJson(hot36Pilates),
      'Dance workout': boolToStringConverter.toJson(danceWorkout),
      'Fit Boxing': boolToStringConverter.toJson(fitBoxing),
    };
  }

  /// Convert the map with string keys to this model.
  factory SMStudioTagsModel.fromMap(final Map<String, Object?> map) {
    return SMStudioTagsModel(
      trx: boolToStringConverter.fromJson(map['TRX']! as String),
      stretching: boolToStringConverter.fromJson(map['Stretching']! as String),
      barreSignature: boolToStringConverter.fromJson(
        map['Barre Signature']! as String,
      ),
      pilates: boolToStringConverter.fromJson(map['Pilates']! as String),
      barre20: boolToStringConverter.fromJson(map['Barre 2.0']! as String),
      hot36Stretching: boolToStringConverter.fromJson(
        map['Hot 36° Stretching']! as String,
      ),
      hot36Barre: boolToStringConverter.fromJson(
        map['Hot 36° Barre']! as String,
      ),
      hot36Pilates: boolToStringConverter.fromJson(
        map['Hot 36° Pilates']! as String,
      ),
      danceWorkout: boolToStringConverter.fromJson(
        map['Dance workout']! as String,
      ),
      fitBoxing: boolToStringConverter.fromJson(map['Fit Boxing']! as String),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMStudioTagsModel.fromJson(final String source) =>
      SMStudioTagsModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMStudioTagsModel &&
            other.trx == trx &&
            other.stretching == stretching &&
            other.barreSignature == barreSignature &&
            other.pilates == pilates &&
            other.barre20 == barre20 &&
            other.hot36Stretching == hot36Stretching &&
            other.hot36Barre == hot36Barre &&
            other.hot36Pilates == hot36Pilates &&
            other.danceWorkout == danceWorkout &&
            other.fitBoxing == fitBoxing;
  }

  @override
  int get hashCode {
    return trx.hashCode ^
        stretching.hashCode ^
        barreSignature.hashCode ^
        pilates.hashCode ^
        barre20.hashCode ^
        hot36Stretching.hashCode ^
        hot36Barre.hashCode ^
        hot36Pilates.hashCode ^
        danceWorkout.hashCode ^
        fitBoxing.hashCode;
  }

  @override
  String toString() {
    return 'SMStudioTagsModel(trx: $trx, stretching: $stretching, '
        'barreSignature: $barreSignature, pilates: $pilates, '
        'barre20: $barre20, hot36Stretching: $hot36Stretching, '
        'hot36Barre: $hot36Barre, hot36Pilates: $hot36Pilates, '
        'danceWorkout: $danceWorkout, fitBoxing: $fitBoxing)';
  }
}
