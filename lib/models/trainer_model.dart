// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The enum that shows if the online payment is available.
enum PrepaidType {
  /// The payment is allowed.
  allowed,

  /// The payment is forbidden.
  forbidden
}

/// The converter for [PrepaidType] enum.
const EnumConverter<PrepaidType> prepaidConverter =
    EnumConverter(PrepaidType.values);

/// The converter of the [TrainerModel].
const TrainerConverter trainerConverter = TrainerConverter._();

/// The converter of the [TrainerModel].
class TrainerConverter
    implements JsonConverter<TrainerModel, Map<String, Object?>> {
  const TrainerConverter._();

  @override
  TrainerModel fromJson(final Map<String, Object?> data) =>
      TrainerModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final TrainerModel data) => data.toMap();
}

/// The trainer model of the YClients API book_staff method.
@immutable
class TrainerModel {
  /// The trainer model of the YClients API book_staff method.
  const TrainerModel({
    required final this.id,
    required final this.apiId,
    required final this.name,
    required final this.specialization,
    required final this.rating,
    required final this.showRating,
    required final this.avatar,
    required final this.avatarBig,
    required final this.commentsCount,
    required final this.votesCount,
    required final this.bookable,
    required final this.imageGroup,
    required final this.information,
    required final this.positionId,
    required final this.scheduleTill,
    required final this.weight,
    required final this.fired,
    required final this.status,
    required final this.hidden,
    required final this.user,
    required final this.prepaid,
    required final this.position,
  });

  /// The id of this trainer in YClients API.
  final int id;

  /// The outer id of this trainer.
  final String? apiId;

  /// The name of this trainer.
  final String name;

  /// The specialization of this trainer.
  final String specialization;

  /// The rating of this trainer.
  final int rating;

  /// If the rating of this trainer should be shown.
  final bool showRating;

  /// The link to the avatar of this trainer.
  final String avatar;

  /// The link to the big avatar of this trainer.
  final String avatarBig;

  /// The count of comments of this trainer.
  final int commentsCount;

  /// The count of votes of this trainer.
  final int votesCount;

  /// If this trainer is bookable.
  final bool bookable;

  /// The images of this trainer.
  final TrainerImageGroupModel? imageGroup;

  /// The information about this trainer.
  final String information;

  /// The position id of this trainer.
  final int positionId;

  /// The last date this trainer is scheduled till.
  final DateTime scheduleTill;

  /// The weight of this trainer (in kg).
  final int weight;

  /// If this trainer is fired.
  final bool fired;

  /// If this trainer is currently active.
  final bool status;

  /// If this trainer is hidden.
  final bool hidden;
  final Object? user;

  /// The prepaid type of this trainer.
  final PrepaidType prepaid;

  /// The position of this trainer.
  final TrainerPositionModel? position;

  /// Return the copy of this model.
  TrainerModel copyWith({
    final int? id,
    final String? apiId,
    final String? name,
    final String? specialization,
    final int? rating,
    final bool? showRating,
    final String? avatar,
    final String? avatarBig,
    final int? commentsCount,
    final int? votesCount,
    final bool? bookable,
    final TrainerImageGroupModel? imageGroup,
    final String? information,
    final int? positionId,
    final DateTime? scheduleTill,
    final int? weight,
    final bool? fired,
    final bool? status,
    final bool? hidden,
    final Object? user,
    final PrepaidType? prepaid,
    final TrainerPositionModel? position,
  }) {
    return TrainerModel(
      id: id ?? this.id,
      apiId: apiId ?? this.apiId,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      rating: rating ?? this.rating,
      showRating: showRating ?? this.showRating,
      avatar: avatar ?? this.avatar,
      avatarBig: avatarBig ?? this.avatarBig,
      commentsCount: commentsCount ?? this.commentsCount,
      votesCount: votesCount ?? this.votesCount,
      bookable: bookable ?? this.bookable,
      imageGroup: imageGroup ?? this.imageGroup,
      information: information ?? this.information,
      positionId: positionId ?? this.positionId,
      scheduleTill: scheduleTill ?? this.scheduleTill,
      weight: weight ?? this.weight,
      fired: fired ?? this.fired,
      status: status ?? this.status,
      hidden: hidden ?? this.hidden,
      user: user ?? this.user,
      prepaid: prepaid ?? this.prepaid,
      position: position ?? this.position,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'api_id': apiId,
      'name': name,
      'specialization': specialization,
      'rating': rating,
      'show_rating': boolToIntConverter.toJson(showRating),
      'avatar': avatar,
      'avatar_big': avatarBig,
      'comments_count': commentsCount,
      'votes_count': votesCount,
      'bookable': bookable,
      'image_group': imageGroup?.toMap(),
      'information': information,
      'position_id': positionId,
      'schedule_till': "${scheduleTill.year.toString().padLeft(4, '0')}-"
          "${scheduleTill.month.toString().padLeft(2, '0')}-"
          "${scheduleTill.day.toString().padLeft(2, '0')}",
      'weight': weight,
      'fired': boolToIntConverter.toJson(fired),
      'status': boolToIntConverter.toJson(status),
      'hidden': boolToIntConverter.toJson(hidden),
      'user': user,
      'prepaid': prepaidConverter.toJson(prepaid),
      'position': position?.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory TrainerModel.fromMap(final Map<String, Object?> map) {
    return TrainerModel(
      id: map['id']! as int,
      apiId: map['api_id'] as String?,
      name: map['name']! as String,
      specialization: map['specialization']! as String,
      rating: map['rating']! as int,
      showRating: boolToIntConverter.fromJson(map['show_rating']! as int),
      avatar: map['avatar']! as String,
      avatarBig: map['avatar_big']! as String,
      commentsCount: map['comments_count']! as int,
      votesCount: map['votes_count']! as int,
      bookable: map['bookable']! as bool,
      imageGroup: map['image_group'] != null && map['image_group'] is! Iterable
          ? TrainerImageGroupModel.fromMap(
              map['image_group']! as Map<String, Object?>,
            )
          : null,
      information: map['information']! as String,
      positionId: map['position_id']! as int,
      scheduleTill: dateTimeConverter.fromJson(map['schedule_till']),
      weight: map['weight']! as int,
      fired: boolToIntConverter.fromJson(map['fired']! as int),
      status: boolToIntConverter.fromJson(map['status']! as int),
      hidden: boolToIntConverter.fromJson(map['hidden']! as int),
      user: map['user'],
      prepaid: prepaidConverter.fromJson(map['prepaid']! as String),
      position: map['position'] != null && map['position'] is! Iterable
          ? TrainerPositionModel.fromMap(
              map['position']! as Map<String, Object?>,
            )
          : null,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TrainerModel.fromJson(final String source) =>
      TrainerModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TrainerModel &&
            other.id == id &&
            other.apiId == apiId &&
            other.name == name &&
            other.specialization == specialization &&
            other.rating == rating &&
            other.showRating == showRating &&
            other.avatar == avatar &&
            other.avatarBig == avatarBig &&
            other.commentsCount == commentsCount &&
            other.votesCount == votesCount &&
            other.bookable == bookable &&
            other.imageGroup == imageGroup &&
            other.information == information &&
            other.positionId == positionId &&
            other.scheduleTill == scheduleTill &&
            other.weight == weight &&
            other.fired == fired &&
            other.status == status &&
            other.hidden == hidden &&
            other.user == user &&
            other.prepaid == prepaid &&
            other.position == position;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        apiId.hashCode ^
        name.hashCode ^
        specialization.hashCode ^
        rating.hashCode ^
        showRating.hashCode ^
        avatar.hashCode ^
        avatarBig.hashCode ^
        commentsCount.hashCode ^
        votesCount.hashCode ^
        bookable.hashCode ^
        imageGroup.hashCode ^
        information.hashCode ^
        positionId.hashCode ^
        scheduleTill.hashCode ^
        weight.hashCode ^
        fired.hashCode ^
        status.hashCode ^
        hidden.hashCode ^
        user.hashCode ^
        prepaid.hashCode ^
        position.hashCode;
  }

  @override
  String toString() {
    return 'TrainerModel(id: $id, apiId: $apiId, name: $name, '
        'specialization: $specialization, rating: $rating, '
        'showRating: $showRating, avatar: $avatar, avatarBig: $avatarBig, '
        'commentsCount: $commentsCount, votesCount: $votesCount, '
        'bookable: $bookable, imageGroup: $imageGroup, '
        'information: $information, positionId: $positionId, '
        'scheduleTill: $scheduleTill, weight: $weight, fired: $fired, '
        'status: $status, hidden: $hidden, user: $user, prepaid: $prepaid, '
        'position: $position)';
  }
}

/// The class with all available unique [TrainerModelImageVersion] images.
@immutable
class TrainerImageGroupModel {
  /// The class with all available unique [TrainerModelImageVersion] images.
  const TrainerImageGroupModel({
    required final this.id,
    required final this.entity,
    required final this.entityId,
    required final this.images,
  });

  /// The id of this image group.
  final int id;

  final String entity;
  final String entityId;

  /// The all available unique [TrainerModelImageVersion] images.
  final TrainerImageGroupImagesModel images;

  /// Return the copy of this model.
  TrainerImageGroupModel copyWith({
    final int? id,
    final String? entity,
    final String? entityId,
    final TrainerImageGroupImagesModel? images,
  }) {
    return TrainerImageGroupModel(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      images: images ?? this.images,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'entity': entity,
      'entity_id': entityId,
      'images': images.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory TrainerImageGroupModel.fromMap(final Map<String, Object?> map) {
    return TrainerImageGroupModel(
      id: map['id']! as int,
      entity: map['entity']! as String,
      entityId: map['entity_id']! as String,
      images: TrainerImageGroupImagesModel.fromMap(
        map['images']! as Map<String, Object?>,
      ),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TrainerImageGroupModel.fromJson(final String source) =>
      TrainerImageGroupModel.fromMap(
          json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TrainerImageGroupModel &&
            other.id == id &&
            other.entity == entity &&
            other.entityId == entityId &&
            other.images == images;
  }

  @override
  int get hashCode {
    return id.hashCode ^ entity.hashCode ^ entityId.hashCode ^ images.hashCode;
  }

  @override
  String toString() {
    return 'TrainerImageGroupModel(id: $id, entity: $entity, '
        'entityId: $entityId, images: $images)';
  }
}

/// The class with all available unique [TrainerModelImageVersion] images.
@immutable
class TrainerImageGroupImagesModel {
  /// The class with all available unique [TrainerModelImageVersion] images.
  const TrainerImageGroupImagesModel({
    required final this.sm,
    required final this.norm,
    required final this.origin,
  });

  /// The image with [TrainerModelImageVersion.sm].
  final TrainerImageGroupImagesImageModel sm;

  /// The image with [TrainerModelImageVersion.norm].
  final TrainerImageGroupImagesImageModel norm;

  /// The image with [TrainerModelImageVersion.origin].
  final TrainerImageGroupImagesImageModel origin;

  /// Return the copy of this model.
  TrainerImageGroupImagesModel copyWith({
    final TrainerImageGroupImagesImageModel? sm,
    final TrainerImageGroupImagesImageModel? norm,
    final TrainerImageGroupImagesImageModel? origin,
  }) {
    return TrainerImageGroupImagesModel(
      sm: sm ?? this.sm,
      norm: norm ?? this.norm,
      origin: origin ?? this.origin,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'sm': sm.toMap(),
      'norm': norm.toMap(),
      'origin': origin.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory TrainerImageGroupImagesModel.fromMap(final Map<String, Object?> map) {
    return TrainerImageGroupImagesModel(
      sm: TrainerImageGroupImagesImageModel.fromMap(
        map['sm']! as Map<String, Object?>,
      ),
      norm: TrainerImageGroupImagesImageModel.fromMap(
        map['norm']! as Map<String, Object?>,
      ),
      origin: TrainerImageGroupImagesImageModel.fromMap(
        map['origin']! as Map<String, Object?>,
      ),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TrainerImageGroupImagesModel.fromJson(final String source) =>
      TrainerImageGroupImagesModel.fromMap(
          json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TrainerImageGroupImagesModel &&
            other.sm == sm &&
            other.norm == norm &&
            other.origin == origin;
  }

  @override
  int get hashCode => sm.hashCode ^ norm.hashCode ^ origin.hashCode;

  @override
  String toString() {
    return 'TrainerImageGroupImagesModel(sm: $sm, norm: $norm, '
        'origin: $origin)';
  }
}

/// The version of the [TrainerImageGroupImagesImageModel].
enum TrainerModelImageVersion { sm, norm, origin }

/// The converter for [PrepaidType] enum.
const EnumConverter<TrainerModelImageVersion> trainerImageConverter =
    EnumConverter<TrainerModelImageVersion>(TrainerModelImageVersion.values);

/// A specific [version] image for a trainer.
@immutable
class TrainerImageGroupImagesImageModel {
  /// A specific [version] image for a trainer.
  const TrainerImageGroupImagesImageModel({
    required final this.id,
    required final this.path,
    required final this.width,
    required final this.height,
    required final this.type,
    required final this.imageGroupId,
    required final this.version,
  });

  /// The id of this image in YClients API.
  final String id;

  /// The path of this image.
  final String path;

  /// The width of this image.
  final String width;

  /// The height of this image.
  final String height;

  /// The type of this image.
  final String type;

  /// The id of the group this image is in.
  final int imageGroupId;

  /// The version of this image.
  final TrainerModelImageVersion version;

  /// Return the copy of this model.
  TrainerImageGroupImagesImageModel copyWith({
    final String? id,
    final String? path,
    final String? width,
    final String? height,
    final String? type,
    final int? imageGroupId,
    final TrainerModelImageVersion? version,
  }) {
    return TrainerImageGroupImagesImageModel(
      id: id ?? this.id,
      path: path ?? this.path,
      width: width ?? this.width,
      height: height ?? this.height,
      type: type ?? this.type,
      imageGroupId: imageGroupId ?? this.imageGroupId,
      version: version ?? this.version,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'path': path,
      'width': width,
      'height': height,
      'type': type,
      'image_group_id': imageGroupId,
      'version': trainerImageConverter.toJson(version),
    };
  }

  /// Convert the map with string keys to this model.
  factory TrainerImageGroupImagesImageModel.fromMap(
    final Map<String, Object?> map,
  ) {
    return TrainerImageGroupImagesImageModel(
      id: map['id']! as String,
      path: map['path']! as String,
      width: map['width']! as String,
      height: map['height']! as String,
      type: map['type']! as String,
      imageGroupId: map['image_group_id']! as int,
      version: trainerImageConverter.fromJson(map['version']! as String),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TrainerImageGroupImagesImageModel.fromJson(final String source) =>
      TrainerImageGroupImagesImageModel.fromMap(
          json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TrainerImageGroupImagesImageModel &&
            other.id == id &&
            other.path == path &&
            other.width == width &&
            other.height == height &&
            other.type == type &&
            other.imageGroupId == imageGroupId &&
            other.version == version;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        path.hashCode ^
        width.hashCode ^
        height.hashCode ^
        type.hashCode ^
        imageGroupId.hashCode ^
        version.hashCode;
  }

  @override
  String toString() {
    return 'TrainerImageGroupImagesImageModel(id: $id, path: $path, '
        'width: $width, height: $height, type: $type, '
        'imageGroupId: $imageGroupId, version: $version)';
  }
}

/// The position model for [TrainerModel].
@immutable
class TrainerPositionModel {
  /// The position model for [TrainerModel].
  const TrainerPositionModel({
    required final this.id,
    required final this.title,
  });

  /// The id of this position.
  final int id;

  /// The title of this position.
  final String title;

  /// Return the copy of this model.
  TrainerPositionModel copyWith({
    final int? id,
    final String? title,
  }) {
    return TrainerPositionModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{'id': id, 'title': title};
  }

  /// Convert the map with string keys to this model.
  factory TrainerPositionModel.fromMap(final Map<String, Object?> map) {
    return TrainerPositionModel(
      id: map['id']! as int,
      title: map['title']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TrainerPositionModel.fromJson(final String source) =>
      TrainerPositionModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TrainerPositionModel && other.id == id && other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() => 'TrainerPositionModel(id: $id, title: $title)';
}
