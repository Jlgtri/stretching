import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stretching/utils/enum_to_string.dart';

/// Convert a json object to the object of type [T].
typedef FromJson<T extends Object> = T Function(Object? map);

/// Convert an object of type [T] to the json object.
typedef ToJson<T extends Object> = Object? Function(T);

/// The class to convert an object of type [T] to the object of type [S].
mixin JsonConverter<T extends Object?, S extends Object?> on Object {
  /// Convert an object of type [T] to the object of type [S].
  S toJson(final T data);

  /// Convert an object of type [S] of to the object of type [T].
  T fromJson(final S data);
}

/// The default converter of the [OptionalBoolToIntConverter] with
/// `defaultValue = false`.
const falseBoolToIntConverter = OptionalBoolToIntConverter._false();

/// The default converter of the [OptionalBoolToIntConverter] with
/// `defaultValue = true`.
const trueBoolToIntConverter = OptionalBoolToIntConverter._true();

/// The bool to int converter.
class OptionalBoolToIntConverter implements JsonConverter<bool, int?> {
  /// The bool to int converter with `[defaultValue] = false`.
  const OptionalBoolToIntConverter._false({final this.defaultValue = false});

  /// The bool to int converter with `[defaultValue] = true`.
  const OptionalBoolToIntConverter._true({final this.defaultValue = true});

  /// The default value to return if condition is null.
  final bool defaultValue;

  @override
  int toJson(final bool value) => value ? 1 : 0;

  @override
  bool fromJson(final int? data) => (data ?? toJson(defaultValue)) == 1;
}

/// The default converter of the [BoolToIntConverter].
const boolToIntConverter = BoolToIntConverter._();

/// The bool to int converter.
class BoolToIntConverter implements JsonConverter<bool, int> {
  /// The bool to int converter.
  const BoolToIntConverter._();

  @override
  bool fromJson(final int json) => json == 1;

  @override
  int toJson(final bool data) => data ? 1 : 0;
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
const optionalLocaleConverter = OptionalLocaleConverter._();

/// The custom converter for nullable [Locale].
class OptionalLocaleConverter implements JsonConverter<Locale?, Object?> {
  /// The custom converter for nullable [Locale].
  const OptionalLocaleConverter._();

  @override
  Locale? fromJson(final Object? data) {
    return data is Locale? ? data : (data as String).toLanguageTag();
  }

  @override
  Object? toJson(final Locale? locale) => locale?.toLanguageTag();
}

/// The default converter of the [LocaleConverter].
const localeConverter = LocaleConverter._();

/// The custom converter for [Locale].
class LocaleConverter implements JsonConverter<Locale, Object?> {
  /// The custom converter for [Locale].
  const LocaleConverter._();

  @override
  Locale fromJson(final Object? data) {
    return data is Locale ? data : (data! as String).toLanguageTag();
  }

  @override
  Object? toJson(final Locale locale) => locale.toLanguageTag();
}

/// The custom converter for nullable [Iterable].
class OptionalIterableConverter<T extends Object?>
    implements JsonConverter<Iterable<T?>?, Object?> {
  /// The custom converter for nullable [Iterable].
  const OptionalIterableConverter(this.converter);

  /// The converter for the children.
  final JsonConverter<T, Object?> converter;

  @override
  Iterable<T?>? fromJson(final Object? data) {
    if (data is Iterable<T?>?) {
      return data;
    }
    return (data as Iterable).map(converter.fromJson);
  }

  @override
  Object? toJson(final Iterable<T?>? iterable) => iterable
      ?.map((final child) => child != null ? converter.toJson(child) : null)
      .toList();
}

/// The custom converter for [Iterable].
class IterableConverter<T extends Object?>
    implements JsonConverter<Iterable<T>, Object?> {
  /// The custom converter for [Iterable].
  const IterableConverter(this.converter);

  /// The converter for the children.
  final JsonConverter<T, Object?> converter;

  @override
  Iterable<T> fromJson(final Object? data) {
    if (data is Iterable<T>) {
      return data;
    }

    final iterable = data! as Iterable;
    return iterable.map(converter.fromJson).whereType<T>();
  }

  @override
  Object? toJson(final Iterable<T> iterable) =>
      iterable.map(converter.toJson).toList();
}

/// The default converter of the [OptionalPermissionConverter].
const optionalPermissionConverter = OptionalPermissionConverter._();

/// The custom converter for nullable [Permission].
class OptionalPermissionConverter
    implements JsonConverter<Permission?, Object?> {
  /// The custom converter for nullable [Permission].
  const OptionalPermissionConverter._();

  @override
  Permission? fromJson(final Object? data) {
    if (data is Permission?) {
      return data;
    }

    final permissionValue = int.tryParse(data as String);
    return permissionValue != null ? Permission.byValue(permissionValue) : null;
  }

  @override
  Object? toJson(final Permission? permission) => permission?.value;
}

/// The default converter of the [PermissionConverter].
const permissionConverter = PermissionConverter._();

/// The custom converter for [Permission].
class PermissionConverter implements JsonConverter<Permission, Object?> {
  /// The custom converter for [Permission].
  const PermissionConverter._();

  @override
  Permission fromJson(final Object? data) {
    return data is Permission ? data : Permission.byValue(data! as int);
  }

  @override
  Object? toJson(final Permission permission) => permission.value;
}

/// The default converter of the [OptionalDateTimeConverter].
const optionalDateTimeConverter = OptionalDateTimeConverter._();

/// The custom converter for nullable [DateTime].
class OptionalDateTimeConverter implements JsonConverter<DateTime?, Object?> {
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
  Object? toJson(final DateTime? dateTime) => dateTime?.toIso8601String();
}

/// The default converter of the [DateTimeConverter].
const dateTimeConverter = DateTimeConverter._();

/// The custom converter for [DateTime].
class DateTimeConverter implements JsonConverter<DateTime, Object?> {
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
  Object? toJson(final DateTime dateTime) => dateTime.toIso8601String();
}

/// The default converter of the [OptionalColorConverter].
const optionalColorConverter = OptionalColorConverter._();

/// The custom converter for nullable [Color].
class OptionalColorConverter implements JsonConverter<Color?, Object?> {
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
  Object? toJson(final Color? color) {
    return color?.value.toRadixString(16).substring(2);
  }
}

/// The default converter of the [ColorConverter].
const ColorConverter colorConverter = ColorConverter._();

/// The custom converter for [Color].
class ColorConverter implements JsonConverter<Color, Object?> {
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
  Object? toJson(final Color color) {
    return color.value.toRadixString(16).substring(2);
  }
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
      return data as T?;
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
