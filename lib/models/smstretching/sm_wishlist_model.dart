// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';

/// The model of the wishlist in the SMStretching API.
///
/// See: https://smstretching.ru/mobile/wishlist/{token}/get
@immutable
class SMWishlistModel {
  /// The model of the wishlist in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/wishlist/{token}/get
  const SMWishlistModel({
    required final this.activityId,
    required final this.userPhone,
    required final this.addDate,
    required final this.activityDate,
  });

  /// The id of the activity of this wishlist in the YClients API.
  final int activityId;

  /// The phone number of a user of this wishlist.
  final String userPhone;

  /// The date and time this wishlist was created.
  final DateTime addDate;

  /// The date and time of the activity.
  final DateTime activityDate;

  /// Return the copy of this model.
  SMWishlistModel copyWith({
    final int? activityId,
    final String? userPhone,
    final DateTime? addDate,
    final DateTime? activityDate,
  }) =>
      SMWishlistModel(
        activityId: activityId ?? this.activityId,
        userPhone: userPhone ?? this.userPhone,
        addDate: addDate ?? this.addDate,
        activityDate: activityDate ?? this.activityDate,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap({final bool post = false}) => <String, Object?>{
        'activity_id': post ? activityId : activityId.toString(),
        'user_phone': userPhone,
        'add_date': addDate.toString().split('.').first,
        'activity_date': activityDate.toString().split('.').first,
      };

  /// Convert the map with string keys to this model.
  factory SMWishlistModel.fromMap(final Map<String, Object?> map) =>
      SMWishlistModel(
        activityId: int.parse(map['activity_id']! as String),
        userPhone: map['user_phone']! as String,
        addDate: DateTime.parse(map['add_date']! as String),
        activityDate: DateTime.parse(map['activity_date']! as String),
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMWishlistModel.fromJson(final String source) =>
      SMWishlistModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is SMWishlistModel &&
          other.activityId == activityId &&
          other.userPhone == userPhone &&
          other.addDate == addDate &&
          other.activityDate == activityDate;

  @override
  int get hashCode =>
      activityId.hashCode ^
      userPhone.hashCode ^
      addDate.hashCode ^
      activityDate.hashCode;

  @override
  String toString() =>
      'SMWishlistModel(activityId: $activityId, userPhone: $userPhone, '
      'addDate: $addDate, activityDate: $activityDate)';
}
