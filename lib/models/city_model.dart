import 'dart:convert';

import 'package:meta/meta.dart';

// ignore_for_file: sort_constructors_first

/// The city model of the yclient's cities method.
///
/// See: https://yclientsru.docs.apiary.io/#reference/40/0/0
@immutable
class CityModel {
  /// The city model of the yclient's cities method.
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
  }) {
    return CityModel(
      id: id ?? this.id,
      countryId: countryId ?? this.countryId,
      title: title ?? this.title,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'countryId': countryId,
      'title': title,
    };
  }

  /// Convert the map with string keys to this model.
  factory CityModel.fromMap(final Map<String, Object?> map) {
    return CityModel(
      id: map['id']! as int,
      countryId: map['country_id']! as int,
      title: map['title']! as String,
    );
  }

  /// Convert this model to an encoded object.
  String toJson() => json.encode(toMap());

  /// Convert the encoded object to this model.
  factory CityModel.fromJson(final String source) =>
      CityModel.fromMap(json.decode(source));

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is CityModel &&
            other.id == id &&
            other.countryId == countryId &&
            other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ countryId.hashCode ^ title.hashCode;

  @override
  String toString() {
    return 'CityModel(id: $id, countryId: $countryId, title: $title)';
  }
}
