// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [CityModel].
const CityConverter cityConverter = CityConverter._();

/// The converter of the [CityModel].
class CityConverter implements JsonConverter<CityModel, Map<String, Object?>> {
  const CityConverter._();

  @override
  CityModel fromJson(final Map<String, Object?> data) =>
      CityModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final CityModel data) => data.toMap();
}

/// The city model of the YClients API cities method.
///
/// See: https://yclientsru.docs.apiary.io/#reference/40/0/0
@immutable
class CityModel {
  /// The city model of the YClients API cities method.
  ///
  /// See: https://yclientsru.docs.apiary.io/#reference/40/0/0
  const CityModel({
    required final this.id,
    required final this.countryId,
    required final this.title,
  });

  /// The id of this city.
  final int id;

  /// The id of this city's country.
  final int countryId;

  /// The title of this city.
  final String title;

  /// Return the copy of this model.
  CityModel copyWith({
    final int? id,
    final int? countryId,
    final String? title,
  }) =>
      CityModel(
        id: id ?? this.id,
        countryId: countryId ?? this.countryId,
        title: title ?? this.title,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'country_id': countryId,
        'title': title,
      };

  /// Convert the map with string keys to this model.
  factory CityModel.fromMap(final Map<String, Object?> map) => CityModel(
        id: map['id']! as int,
        countryId: map['country_id']! as int,
        title: map['title']! as String,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory CityModel.fromJson(final String source) =>
      CityModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is CityModel &&
          other.id == id &&
          other.countryId == countryId &&
          other.title == title;

  @override
  int get hashCode => id.hashCode ^ countryId.hashCode ^ title.hashCode;

  @override
  String toString() =>
      'CityModel(id: $id, countryId: $countryId, title: $title)';
}
