import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stretching/utils/enum_to_string.dart';

/// Convert a json object to the object of type [T].
typedef FromJson<T extends Object?, S extends Object?> = T Function(S? map);

/// Convert an object of type [T] to the json object.
typedef ToJson<T extends Object?, S extends Object?> = S? Function(T);

/// The class to convert an object of type [T] to the object of type [S].
mixin JsonConverter<T extends Object?, S extends Object?> on Object {
  /// Convert an object of type [T] to the object of type [S].
  S toJson(final T data);

  /// Convert an object of type [S] of to the object of type [T].
  T fromJson(final S data);
}

/// The optional dummy converter of type [T].
class OptionalDummyConverter<T extends Object?>
    implements JsonConverter<T?, T?> {
  @override
  T? toJson(final T? data) => data;

  @override
  T? fromJson(final T? data) => data;
}

/// The dummy converter of type [T].
class DummyConverter<T extends Object> implements JsonConverter<T, T> {
  @override
  T toJson(final T data) => data;

  @override
  T fromJson(final T data) => data;
}

/// The default converter of the [DefaultBoolToIntConverter] with
/// `defaultValue = false`.
const DefaultBoolToStringConverter falseBoolToStringConverter =
    DefaultBoolToStringConverter._false();

/// The default converter of the [DefaultBoolToIntConverter] with
/// `defaultValue = true`.
const DefaultBoolToStringConverter trueBoolToStringConverter =
    DefaultBoolToStringConverter._true();

/// The bool to int converter.
class DefaultBoolToStringConverter implements JsonConverter<bool, String?> {
  /// The bool to int converter with `[defaultValue] = false`.
  const DefaultBoolToStringConverter._false() : defaultValue = false;

  /// The bool to int converter with `[defaultValue] = true`.
  const DefaultBoolToStringConverter._true() : defaultValue = true;

  /// The default value to return if condition is null.
  final bool defaultValue;

  static final RegExp _trueRegExp = RegExp(
    'yes|on|true|1',
    caseSensitive: false,
  );

  static final RegExp _falseRegExp = RegExp(
    'no|off|false|0',
    caseSensitive: false,
  );

  @override
  String toJson(final bool data) => data.toString();

  @override
  bool fromJson(final String? data) => data != null
      ? _trueRegExp.hasMatch(data) ||
          (!_falseRegExp.hasMatch(data) && defaultValue)
      : defaultValue;
}

/// The default converter of the [BoolToStringConverter].
const BoolToStringConverter boolToStringConverter = BoolToStringConverter._();

/// The bool to int converter.
class BoolToStringConverter implements JsonConverter<bool, String> {
  /// The bool to int converter.
  const BoolToStringConverter._();

  static final RegExp _trueRegExp = RegExp(
    'yes|on|true|1',
    caseSensitive: false,
  );

  @override
  String toJson(final bool data) => data.toString();

  @override
  bool fromJson(final String data) => _trueRegExp.hasMatch(data);
}

/// The default converter of the [DefaultBoolToIntConverter] with
/// `defaultValue = false`.
const DefaultBoolToIntConverter falseBoolToIntConverter =
    DefaultBoolToIntConverter._false();

/// The default converter of the [DefaultBoolToIntConverter] with
/// `defaultValue = true`.
const DefaultBoolToIntConverter trueBoolToIntConverter =
    DefaultBoolToIntConverter._true();

/// The bool to int converter.
class DefaultBoolToIntConverter implements JsonConverter<bool, int?> {
  /// The bool to int converter with `[defaultValue] = false`.
  const DefaultBoolToIntConverter._false() : defaultValue = false;

  /// The bool to int converter with `[defaultValue] = true`.
  const DefaultBoolToIntConverter._true() : defaultValue = true;

  /// The default value to return if condition is null.
  final bool defaultValue;

  @override
  int toJson(final bool value) => value ? 1 : 0;

  @override
  bool fromJson(final int? data) => (data ?? toJson(defaultValue)) == 1;
}

/// The default converter of the [BoolToIntConverter].
const BoolToIntConverter boolToIntConverter = BoolToIntConverter._();

/// The bool to int converter.
class BoolToIntConverter implements JsonConverter<bool, int> {
  /// The bool to int converter.
  const BoolToIntConverter._();

  @override
  int toJson(final bool data) => data ? 1 : 0;

  @override
  bool fromJson(final int json) => json == 1;
}

extension on String {
  /// Creates a new Locale object from [Locale.toLanguageTag].
  ///
  /// The subtag values are _case sensitive_ and must be valid subtags according
  /// to CLDR supplemental data:
  /// [language](https://github.com/unicode-org/cldr/blob/master/common/validity/language.xml),
  /// [script](https://github.com/unicode-org/cldr/blob/master/common/validity/script.xml) and
  /// [region](https://github.com/unicode-org/cldr/blob/master/common/validity/region.xml) for
  /// each of languageCode, scriptCode and countryCode respectively.
  ///
  /// Validity is not checked by default, but some methods may throw away
  /// invalid data.
  Locale toLanguageTag({final String separator = '-'}) {
    assert(isNotEmpty, 'language tag should not be empty');
    final tags = split(separator);
    switch (tags.length) {
      case 2:
        return Locale.fromSubtags(
          languageCode: tags.first,
          countryCode: tags.last,
        );
      case 3:
        return Locale.fromSubtags(
          languageCode: tags.first,
          scriptCode: tags.elementAt(1),
          countryCode: tags.last,
        );
      default:
        return Locale(tags.first);
    }
  }
}

/// The default converter of the [OptionalLocaleConverter].
const OptionalLocaleConverter optionalLocaleConverter =
    OptionalLocaleConverter._();

/// The custom converter for nullable [Locale].
class OptionalLocaleConverter implements JsonConverter<Locale?, String?> {
  /// The custom converter for nullable [Locale].
  const OptionalLocaleConverter._();

  @override
  Locale? fromJson(final Object? data) {
    return data is Locale?
        ? data
        : data is String
            ? data.toLanguageTag()
            : null;
  }

  @override
  String? toJson(final Locale? locale) => locale?.toLanguageTag();
}

/// The default converter of the [LocaleConverter].
const LocaleConverter localeConverter = LocaleConverter._();

/// The custom converter for [Locale].
class LocaleConverter implements JsonConverter<Locale, String> {
  /// The custom converter for [Locale].
  const LocaleConverter._();

  @override
  Locale fromJson(final Object? data) {
    return data is Locale ? data : (data! as String).toLanguageTag();
  }

  @override
  String toJson(final Locale locale) => locale.toLanguageTag();
}

/// The custom converter for nullable [Iterable].
class OptionalIterableConverter<T extends Object?, S extends Object?>
    implements JsonConverter<Iterable<T>, Iterable<S>> {
  /// The custom converter for nullable [Iterable].
  const OptionalIterableConverter(this.converter);

  /// The converter for the children.
  final JsonConverter<T?, S?> converter;

  @override
  Iterable<T> fromJson(final Object? data) {
    if (data is Iterable<T?>) {
      return data.whereType<T>();
    } else if (data is Iterable<Object?>) {
      return data.whereType<S>().map(converter.fromJson).whereType<T>();
    } else {
      return Iterable<T>.empty();
    }
  }

  @override
  Iterable<S> toJson(final Iterable<Object?>? iterable) =>
      iterable?.whereType<T>().map(converter.toJson).whereType<S>() ??
      Iterable<S>.empty();
}

/// The custom converter for [Iterable].
class IterableConverter<T extends Object, S extends Object>
    implements JsonConverter<Iterable<T>, Iterable<S>> {
  /// The custom converter for [Iterable].
  const IterableConverter(this.converter);

  /// The converter for the children.
  final JsonConverter<T, S> converter;

  @override
  Iterable<T> fromJson(final Object? data) {
    return data is Iterable<T>
        ? data
        : (data! as Iterable)
            .whereType<S>()
            .map(converter.fromJson)
            .whereType<T>();
  }

  @override
  Iterable<S> toJson(final Iterable<T> iterable) =>
      iterable.map(converter.toJson);
}

/// The custom converter to convert to String.
class StringConverter<T extends Object, S extends Object>
    implements JsonConverter<T, String> {
  /// The custom converter to convert to String.
  const StringConverter(this.converter);

  /// The converter for the children.
  final JsonConverter<T, S> converter;

  @override
  T fromJson(final Object? data) {
    return data is T
        ? data
        : converter.fromJson(json.decode(data! as String) as S);
  }

  @override
  String toJson(final T data) => json.encode(converter.toJson(data));
}

/// The custom converter to convert to String.
class StringToIterableConverter<T extends Object, S extends Object>
    implements JsonConverter<Iterable<T>, String> {
  /// The custom converter to convert to String.
  const StringToIterableConverter(this.converter);

  /// The converter for the children.
  final JsonConverter<Iterable<T>, Iterable<S>> converter;

  @override
  Iterable<T> fromJson(final Object? data) {
    return data is Iterable<T>
        ? data
        : converter.fromJson(
            (json.decode(data! as String) as List).cast<S>(),
          );
  }

  @override
  String toJson(final Iterable<T> data) =>
      json.encode(converter.toJson(data).toList(growable: false));
}

/// The custom converter to convert to String.
class OptionalStringConverter<T extends Object>
    implements JsonConverter<T?, String?> {
  /// The custom converter to convert to String.
  const OptionalStringConverter(this.converter);

  /// The converter for the children.
  final JsonConverter<T?, Object?> converter;

  @override
  T? fromJson(final Object? data) {
    return data is T
        ? data
        : data is String
            ? converter.fromJson(json.decode(data))
            : null;
  }

  @override
  String? toJson(final T? data) =>
      data != null ? json.encode(converter.toJson(data)) : null;
}

/// The default converter of the [OptionalPermissionConverter].
const OptionalPermissionConverter optionalPermissionConverter =
    OptionalPermissionConverter._();

/// The custom converter for nullable [Permission].
class OptionalPermissionConverter implements JsonConverter<Permission?, int?> {
  /// The custom converter for nullable [Permission].
  const OptionalPermissionConverter._();

  @override
  Permission? fromJson(final Object? data) {
    if (data is Permission?) {
      return data;
    } else if (data is int) {
      return Permission.byValue(data);
    } else if (data is String) {
      final permissionValue = int.tryParse(data);
      if (permissionValue != null) {
        return Permission.byValue(permissionValue);
      }
    }
  }

  @override
  int? toJson(final Permission? permission) => permission?.value;
}

/// The default converter of the [PermissionConverter].
const PermissionConverter permissionConverter = PermissionConverter._();

/// The custom converter for [Permission].
class PermissionConverter implements JsonConverter<Permission, int> {
  /// The custom converter for [Permission].
  const PermissionConverter._();

  @override
  Permission fromJson(final Object? data) {
    return data is Permission ? data : Permission.byValue(data! as int);
  }

  @override
  int toJson(final Permission permission) => permission.value;
}

/// The default converter of the [OptionalDateTimeConverter].
const OptionalDateTimeConverter optionalDateTimeConverter =
    OptionalDateTimeConverter._();

/// The custom converter for nullable [DateTime].
class OptionalDateTimeConverter implements JsonConverter<DateTime?, String?> {
  /// The custom converter for nullable [DateTime].
  const OptionalDateTimeConverter._();

  @override
  DateTime? fromJson(final Object? data) {
    if (data is DateTime?) {
      return data;
    }

    final dataString = data as String;
    final milliseconds = int.tryParse(dataString);
    return milliseconds != null
        ? DateTime.fromMillisecondsSinceEpoch(milliseconds)
        : DateTime.tryParse(dataString);
  }

  @override
  String? toJson(final DateTime? dateTime) => dateTime?.toIso8601String();
}

/// The default converter of the [DateTimeConverter].
const DateTimeConverter dateTimeConverter = DateTimeConverter._();

/// The custom converter for [DateTime].
class DateTimeConverter implements JsonConverter<DateTime, String> {
  /// The custom converter for [DateTime].
  const DateTimeConverter._();

  @override
  DateTime fromJson(final Object? data) {
    if (data is DateTime) {
      return data;
    }

    final dataString = data! as String;
    final milliseconds = int.tryParse(dataString);
    return milliseconds != null
        ? DateTime.fromMillisecondsSinceEpoch(milliseconds)
        : DateTime.parse(dataString);
  }

  @override
  String toJson(final DateTime dateTime) => dateTime.toIso8601String();
}

/// The default converter of the [OptionalColorConverter].
const OptionalColorConverter optionalColorConverter =
    OptionalColorConverter._();

/// The custom converter for nullable [Color].
class OptionalColorConverter implements JsonConverter<Color?, String?> {
  /// The custom converter for nullable [Color].
  const OptionalColorConverter._();

  @override
  Color? fromJson(final Object? data) {
    if (data is Color?) {
      return data;
    }

    var color = data as String;
    if (color.length >= 6) {
      color = 'FF${color.substring(color.length - 6)}';
    }
    final colorCode = int.tryParse(color, radix: 16);
    return colorCode != null ? Color(colorCode) : null;
  }

  @override
  String? toJson(final Color? color) =>
      color?.value.toRadixString(16).substring(2);
}

/// The default converter of the [ColorConverter].
const ColorConverter colorConverter = ColorConverter._();

/// The custom converter for [Color].
class ColorConverter implements JsonConverter<Color, String> {
  /// The custom converter for [Color].
  const ColorConverter._();

  @override
  Color fromJson(final Object? data) {
    if (data is Color) {
      return data;
    }

    var color = data! as String;
    if (color.length >= 6) {
      color = 'FF${color.substring(color.length - 6)}';
    }
    return Color(int.parse(color, radix: 16));
  }

  @override
  String toJson(final Color color) =>
      color.value.toRadixString(16).substring(2);
}

/// The custom converter for nullable [Enum].
///
/// * [fromJson] accepts null, [Enum], [String] and [int].
class OptionalEnumConverter<T extends Enum>
    implements JsonConverter<T?, String?> {
  /// The custom converter for nullable [Enum].
  ///
  /// * [fromJson] accepts null, [Enum], [String] and [int].
  const OptionalEnumConverter(this.values);

  /// The values of this enum.
  final Iterable<T> values;

  @override
  T? fromJson(final Object? data) {
    if (values.contains(data)) {
      return data! as T;
    } else if (data is String) {
      return enumFromString(values, data);
    } else {
      for (final value in values) {
        if (value.index == data) {
          return value;
        }
      }
    }
  }

  @override
  String? toJson(final T? value) => value != null ? enumToString(value) : null;
}

/// The custom converter for [Enum].
///
/// * [fromJson] accepts [Enum], [String] and [int].
class EnumConverter<T extends Enum> implements JsonConverter<T, String> {
  /// The custom converter for [Enum].
  ///
  /// * [fromJson] accepts [Enum], [String] and [int].
  const EnumConverter(this.values);

  /// The values of this enum.
  final Iterable<T> values;

  @override
  T fromJson(final Object data) {
    if (values.contains(data)) {
      return data as T;
    } else if (data is String) {
      return enumFromString(values, data);
    } else {
      return values.firstWhere((final enumValue) => enumValue.index == data);
    }
  }

  @override
  String toJson(final T value) => enumToString(value);
}
