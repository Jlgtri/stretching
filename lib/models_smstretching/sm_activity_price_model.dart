// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/models_yclients/activity_model.dart';

/// The model of the [ActivityModel] pricing from the SMStretching API.
///
/// See: https://smstretching.ru/mobile/options/{token}/get_price
@immutable
class SMActivityPriceModel {
  /// The model of the [ActivityModel] pricing from the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/options/{token}/get_price
  const SMActivityPriceModel({
    required final this.regularPrice,
    required final this.ySalePrice,
  });

  /// The regular price of the activity.
  final SMActivityPriceOptionValueModel regularPrice;

  /// The regular price of the activity with the discount.
  final SMActivityPriceOptionValueModel ySalePrice;

  /// The empty value for prices.
  const SMActivityPriceModel.zero()
      : regularPrice = const SMActivityPriceOptionValueModel(0),
        ySalePrice = const SMActivityPriceOptionValueModel(0);

  /// Return the copy of this model.
  SMActivityPriceModel copyWith({
    final SMActivityPriceOptionValueModel? regularPrice,
    final SMActivityPriceOptionValueModel? ySalePrice,
  }) {
    return SMActivityPriceModel(
      regularPrice: regularPrice ?? this.regularPrice,
      ySalePrice: ySalePrice ?? this.ySalePrice,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'regular_price': regularPrice.toMap(),
      'y_sale_price': ySalePrice.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory SMActivityPriceModel.fromMap(final Map<String, Object?> map) {
    return SMActivityPriceModel(
      regularPrice: SMActivityPriceOptionValueModel.fromMap(
        map['regular_price']! as Map<String, Object?>,
      ),
      ySalePrice: SMActivityPriceOptionValueModel.fromMap(
        map['y_sale_price']! as Map<String, Object?>,
      ),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMActivityPriceModel.fromJson(final String source) =>
      SMActivityPriceModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMActivityPriceModel &&
            other.regularPrice == regularPrice &&
            other.ySalePrice == ySalePrice;
  }

  @override
  int get hashCode => regularPrice.hashCode ^ ySalePrice.hashCode;

  @override
  String toString() {
    return 'SMActivityPriceModel(regularPrice: $regularPrice, '
        'ySalePrice: $ySalePrice)';
  }
}

/// The model of [optionValue] for [SMActivityPriceModel].
@immutable
class SMActivityPriceOptionValueModel {
  /// The model of [optionValue] for [SMActivityPriceModel].
  const SMActivityPriceOptionValueModel(final this.optionValue);

  /// The specified option value.
  final num optionValue;

  /// Return the copy of this model.
  SMActivityPriceOptionValueModel copyWith({final num? optionValue}) {
    return SMActivityPriceOptionValueModel(optionValue ?? this.optionValue);
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{'option_value': optionValue};
  }

  /// Convert the map with string keys to this model.
  factory SMActivityPriceOptionValueModel.fromMap(
    final Map<String, Object?> map,
  ) {
    return SMActivityPriceOptionValueModel(
      num.parse(map['option_value']! as String),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMActivityPriceOptionValueModel.fromJson(final String source) {
    return SMActivityPriceOptionValueModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMActivityPriceOptionValueModel &&
            other.optionValue == optionValue;
  }

  @override
  int get hashCode => optionValue.hashCode;

  @override
  String toString() {
    return 'SMActivityPriceOptionValueModel(optionValue: $optionValue)';
  }
}
