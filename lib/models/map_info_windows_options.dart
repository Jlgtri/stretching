// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// The options for the custom info window on [GoogleMap].
@immutable
class InfoWindowOptions {
  /// The options for the custom info window on [GoogleMap].
  const InfoWindowOptions({
    required final this.coordinates,
    final this.size = Size.zero,
    final this.offset = Offset.zero,
  });

  /// The coordinates of the initial point on map for this window.
  final LatLng coordinates;

  /// The size of this window.
  final Size size;

  /// The offset of this window.
  final Offset offset;

  /// Return the copy of this model.
  InfoWindowOptions copyWith({
    final LatLng? coordinates,
    final Size? size,
    final Offset? offset,
  }) {
    return InfoWindowOptions(
      coordinates: coordinates ?? this.coordinates,
      size: size ?? this.size,
      offset: offset ?? this.offset,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'coordinates': coordinates.toJson(),
      'size': <double>[size.width, size.height].join(','),
      'offset': <double>[offset.dx, offset.dy].join(','),
    };
  }

  /// Convert the map with string keys to this model.
  factory InfoWindowOptions.fromMap(final Map<String, Object?> map) {
    final size = (map['size']! as String).split(',');
    final offset = (map['offset']! as String).split(',');
    return InfoWindowOptions(
      coordinates: LatLng.fromJson(map['coordinates'])!,
      size: Size(double.parse(size.first), double.parse(size.last)),
      offset: Offset(double.parse(offset.first), double.parse(offset.last)),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory InfoWindowOptions.fromJson(final String source) {
    return InfoWindowOptions.fromMap(
      json.decode(source)! as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is InfoWindowOptions &&
            other.coordinates == coordinates &&
            other.size == size &&
            other.offset == offset;
  }

  @override
  int get hashCode => coordinates.hashCode ^ size.hashCode ^ offset.hashCode;

  @override
  String toString() {
    return 'InfoWindowOptions(coordinates: $coordinates, size: $size, '
        'offset: $offset)';
  }
}
