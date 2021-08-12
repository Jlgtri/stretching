// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The extra options for commiting a request to YClients API.
@immutable
class YClientsRequestExtra<T extends Object> {
  /// The extra options for commiting a request to YClients API.
  const YClientsRequestExtra({
    final this.onData,
    final this.validate = true,
  });

  /// Convert the resulting data to the object of type [T].
  final FromJson<T>? onData;

  /// If true, throw an exception if [YClientsResponse.success] is not true.
  final bool validate;

  /// Return the copy of this model.
  YClientsRequestExtra<T> copyWith({
    final FromJson<T>? onData,
    final bool? validate,
  }) {
    return YClientsRequestExtra<T>(
      onData: onData ?? this.onData,
      validate: validate ?? this.validate,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'onData': onData,
      'validate': validate,
    };
  }

  /// Convert the map with string keys to this model.
  factory YClientsRequestExtra.fromMap(final Map<String, Object?> map) {
    return YClientsRequestExtra<T>(
      onData: map['onData']! as FromJson<T>,
      validate: map['validate']! as bool,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory YClientsRequestExtra.fromJson(final String source) =>
      YClientsRequestExtra.fromMap(json.decode(source));

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is YClientsRequestExtra<T> &&
            other.onData == onData &&
            other.validate == validate;
  }

  @override
  int get hashCode => onData.hashCode ^ validate.hashCode;

  @override
  String toString() {
    return 'YClientsRequestExtra(onData: $onData, validate: $validate)';
  }
}

/// The response from the YClients API.
///
/// See: https://yclientsru.docs.apiary.io/
@immutable
class YClientsResponse<T extends Object> {
  /// The response from the YClients API.
  ///
  /// See: https://yclientsru.docs.apiary.io/
  const YClientsResponse({
    required final this.success,
    required final this.data,
    required final this.meta,
  });

  /// If this response is successful.
  final bool success;

  /// The data of this response.
  final T? data;

  /// The metadata of this response.
  final YClientsResponseMeta? meta;

  /// Return the copy of this model.
  YClientsResponse copyWith({
    final bool? success,
    final T? data,
    final YClientsResponseMeta? meta,
  }) {
    return YClientsResponse(
      success: success ?? this.success,
      data: data ?? this.data,
      meta: meta ?? this.meta,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap({final ToJson<T>? onData}) {
    return <String, Object?>{
      'success': success,
      'data': data != null && onData != null ? onData(data!) : data,
      'meta': meta?.toMap() ?? const [],
    };
  }

  /// Convert the map with string keys to this model.
  factory YClientsResponse.fromMap(
    final Map<String, Object?> map, {
    final FromJson<T>? onData,
  }) {
    return YClientsResponse<T>(
      success: map['success']! as bool,
      data: onData != null ? onData(map['data']) : map['data'] as T?,
      meta: map['meta'] != null && map['meta'] is! Iterable
          ? YClientsResponseMeta.fromMap(map['meta']! as Map<String, Object?>)
          : null,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory YClientsResponse.fromJson(final String source) =>
      YClientsResponse.fromMap(json.decode(source));

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is YClientsResponse<T> &&
            other.success == success &&
            other.data == data &&
            other.meta == meta;
  }

  @override
  int get hashCode => success.hashCode ^ data.hashCode ^ meta.hashCode;

  @override
  String toString() {
    return 'YClientsResponse(success: $success, data: $data, meta: $meta)';
  }
}

/// The metadata received on [YClientsResponse].
@immutable
class YClientsResponseMeta {
  /// The metadata received on [YClientsResponse].
  const YClientsResponseMeta({
    final this.count,
    final this.message,
  });

  /// The count of items received.
  final int? count;

  /// The message received on exception.
  final String? message;

  /// Return the copy of this model.
  YClientsResponseMeta copyWith({
    final int? count,
    final String? message,
  }) {
    return YClientsResponseMeta(
      count: count ?? this.count,
      message: message ?? this.message,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (count != null) 'count': count,
      if (message != null) 'message': message,
    };
  }

  /// Convert the map with string keys to this model.
  factory YClientsResponseMeta.fromMap(final Map<String, Object?> map) {
    return YClientsResponseMeta(
      count: map['count'] as int?,
      message: map['message'] as String?,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory YClientsResponseMeta.fromJson(final String source) =>
      YClientsResponseMeta.fromMap(json.decode(source));

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is YClientsResponseMeta &&
            other.count == count &&
            other.message == message;
  }

  @override
  int get hashCode => count.hashCode ^ message.hashCode;

  @override
  String toString() => 'YClientsResponseMeta(count: $count, message: $message)';
}
