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
    required final this.name,
    required final this.companyId,
    required final this.specialization,
    required final this.avatar,
    required final this.avatarBig,
    required final this.fired,
    required final this.status,
    required final this.hidden,
    required final this.position,
  });

  /// The id of this trainer in YClients API.
  final int id;

  /// The name of this trainer.
  final String name;

  /// The id of the company where this trainer works in.
  final int companyId;

  /// The specialization of this trainer.
  final String specialization;

  /// The link to the avatar of this trainer.
  final String avatar;

  /// The link to the big avatar of this trainer.
  final String avatarBig;

  /// If this trainer is fired.
  final bool fired;

  /// If this trainer is currently active.
  final bool status;

  /// If this trainer is hidden.
  final bool hidden;

  /// The position of this trainer.
  final TrainerPositionModel? position;

  /// Return the copy of this model.
  TrainerModel copyWith({
    final int? id,
    final String? name,
    final int? companyId,
    final String? specialization,
    final String? avatar,
    final String? avatarBig,
    final bool? fired,
    final bool? status,
    final bool? hidden,
    final TrainerPositionModel? position,
  }) {
    return TrainerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      companyId: companyId ?? this.companyId,
      specialization: specialization ?? this.specialization,
      avatar: avatar ?? this.avatar,
      avatarBig: avatarBig ?? this.avatarBig,
      fired: fired ?? this.fired,
      status: status ?? this.status,
      hidden: hidden ?? this.hidden,
      position: position ?? this.position,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'company_id': companyId,
      'specialization': specialization,
      'avatar': avatar,
      'avatar_big': avatarBig,
      'fired': boolToIntConverter.toJson(fired),
      'status': boolToIntConverter.toJson(status),
      'hidden': boolToIntConverter.toJson(hidden),
      'position': position?.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory TrainerModel.fromMap(final Map<String, Object?> map) {
    return TrainerModel(
      id: map['id']! as int,
      name: map['name']! as String,
      companyId: map['company_id']! as int,
      specialization: map['specialization']! as String,
      avatar: map['avatar']! as String,
      avatarBig: map['avatar_big']! as String,
      fired: boolToIntConverter.fromJson(map['fired']! as int),
      status: boolToIntConverter.fromJson(map['status']! as int),
      hidden: boolToIntConverter.fromJson(map['hidden']! as int),
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
    if (identical(this, other)) {
      return true;
    }

    return other is TrainerModel &&
        other.id == id &&
        other.name == name &&
        other.companyId == companyId &&
        other.specialization == specialization &&
        other.avatar == avatar &&
        other.avatarBig == avatarBig &&
        other.fired == fired &&
        other.status == status &&
        other.hidden == hidden &&
        other.position == position;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        companyId.hashCode ^
        specialization.hashCode ^
        avatar.hashCode ^
        avatarBig.hashCode ^
        fired.hashCode ^
        status.hashCode ^
        hidden.hashCode ^
        position.hashCode;
  }

  @override
  String toString() {
    return 'TrainerModel(id: $id, name: $name, companyId: $companyId, '
        'specialization: $specialization, avatar: $avatar, '
        'avatarBig: $avatarBig, fired: $fired, status: $status, '
        'hidden: $hidden, position: $position)';
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
