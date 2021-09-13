// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [UserModel].
const UserConverter userConverter = UserConverter._();

/// The converter of the [UserModel].
class UserConverter implements JsonConverter<UserModel, Map<String, Object?>> {
  const UserConverter._();

  @override
  UserModel fromJson(final Map<String, Object?> data) =>
      UserModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final UserModel data) => data.toMap();
}

/// The user model in the YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/-/9/0
@immutable
class UserModel {
  /// The user model in the YClients API.
  ///
  /// See: https://yclientsru.docs.apiary.io/#reference/-/9/0
  const UserModel({
    required final this.id,
    required final this.userToken,
    required final this.name,
    required final this.phone,
    required final this.login,
    required final this.email,
    required final this.avatar,
    required final this.hash,
  });

  /// The id of this user in the YClients API.
  final int id;

  /// The authorization token of this user.
  final String userToken;

  /// The name of this user.
  final String name;

  /// The phone number of this user.
  final String phone;

  /// The login of this user.
  ///
  /// Is equal to [phone] if user was logged in by phone.
  final String login;

  /// The email of this user.
  final String email;

  /// The link to the avatar of this user.
  final String avatar;

  /// The authorization hash of this user.
  final String hash;

  /// If this user is a tester.
  bool get test => phone.endsWith('9956567535');

  /// Return the copy of this model.
  UserModel copyWith({
    final int? id,
    final String? userToken,
    final String? name,
    final String? phone,
    final String? login,
    final String? email,
    final String? avatar,
    final String? hash,
  }) {
    return UserModel(
      id: id ?? this.id,
      userToken: userToken ?? this.userToken,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      login: login ?? this.login,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      hash: hash ?? this.hash,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'user_token': userToken,
      'name': name,
      'phone': phone,
      'login': login,
      'email': email,
      'avatar': avatar,
      '0': hash,
    };
  }

  /// Convert the map with string keys to this model.
  factory UserModel.fromMap(final Map<String, Object?> map) {
    return UserModel(
      id: map['id']! as int,
      userToken: map['user_token']! as String,
      name: map['name']! as String,
      phone: map['phone']! as String,
      login: map['login']! as String,
      email: map['email']! as String,
      avatar: map['avatar']! as String,
      hash: map['0']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory UserModel.fromJson(final String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is UserModel &&
            other.id == id &&
            other.userToken == userToken &&
            other.name == name &&
            other.phone == phone &&
            other.login == login &&
            other.email == email &&
            other.avatar == avatar &&
            other.hash == hash;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userToken.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        login.hashCode ^
        email.hashCode ^
        avatar.hashCode ^
        hash.hashCode;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, userToken: $userToken, name: $name, '
        'phone: $phone, login: $login, email: $email, avatar: $avatar, '
        'hash: $hash)';
  }
}
