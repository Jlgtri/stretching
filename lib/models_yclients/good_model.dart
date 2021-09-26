// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [GoodModel].
const GoodConverter goodConverter = GoodConverter._();

/// The converter of the [GoodModel].
class GoodConverter implements JsonConverter<GoodModel, Map<String, Object?>> {
  const GoodConverter._();

  @override
  GoodModel fromJson(final Map<String, Object?> data) =>
      GoodModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final GoodModel data) => data.toMap();
}

/// The good model in the YClients API.
///
/// See: https://api.yclients.com/api/v1/goods/{company_id}/{good_id}
@immutable
class GoodModel implements Comparable<GoodModel> {
  /// The good model in the YClients API.
  ///
  /// See: https://api.yclients.com/api/v1/goods/{company_id}/{good_id}
  const GoodModel({
    required final this.id,
    required final this.title,
    required final this.unit,
    required final this.value,
    required final this.label,
    required final this.article,
    required final this.category,
    required final this.categoryId,
    required final this.salonId,
    required final this.goodId,
    required final this.cost,
    required final this.unitId,
    required final this.unitShortTitle,
    required final this.serviceUnitId,
    required final this.serviceUnitShortTitle,
    required final this.actualCost,
    required final this.unitActualCost,
    required final this.unitActualCostFormat,
    required final this.unitEquals,
    required final this.barcode,
    required final this.loyaltyAbonementTypeId,
    required final this.loyaltyCertificateTypeId,
    required final this.loyaltyAllowEmptyCode,
    required final this.actualAmounts,
    required final this.lastChangeDate,
  });

  /// The id of this good in YClients API.
  final int? id;

  /// The title of this good.
  final String title;

  /// The unit of this good.
  final String? unit;

  /// The value of this good.
  final String value;

  /// The label of this good with vendor code if any.
  final String label;

  /// The vendor code of this good if any.
  final String article;

  /// The name of the category of this good.
  final String category;

  /// The id of the category of this good.
  final int categoryId;

  /// The id of the company of this good.
  final int salonId;

  /// The id of this good in the YClients API.
  final int goodId;

  /// The price of this good.
  final int cost;

  /// The id of the unit for selling of this good.
  final int unitId;

  /// The short title of the unit for selling of this good.
  final String unitShortTitle;

  /// The id of the unit for write-off of this good.
  final int serviceUnitId;

  /// The short title of the unit for write-off of this good.
  final String serviceUnitShortTitle;

  /// The cost price of this good.
  final double actualCost;

  /// The cost price per unit of this good.
  final double unitActualCost;

  /// The cost format per unit of this good.
  final String unitActualCostFormat;

  /// If [unitId] equals [serviceUnitId].
  final int unitEquals;

  /// The barcode of this good.
  final String barcode;

  /// The id of the abonement for this good if this good is an abonement.
  final int? loyaltyAbonementTypeId;

  /// The id of the certificate for this good if this good is a certificate.
  final int? loyaltyCertificateTypeId;

  /// If selling of this good without the code is allowed.
  final bool loyaltyAllowEmptyCode;

  /// The amount of this good currently available.
  final Iterable<GoodActualAmountModel> actualAmounts;

  /// The date and time of the last time this good was changed in the
  /// YClients API.
  final DateTime lastChangeDate;

  /// Return the copy of this model.
  GoodModel copyWith({
    final int? id,
    final String? title,
    final String? unit,
    final String? value,
    final String? label,
    final String? article,
    final String? category,
    final int? categoryId,
    final int? salonId,
    final int? goodId,
    final int? cost,
    final int? unitId,
    final String? unitShortTitle,
    final int? serviceUnitId,
    final String? serviceUnitShortTitle,
    final double? actualCost,
    final double? unitActualCost,
    final String? unitActualCostFormat,
    final int? unitEquals,
    final String? barcode,
    final int? loyaltyAbonementTypeId,
    final int? loyaltyCertificateTypeId,
    final bool? loyaltyAllowEmptyCode,
    final Iterable<GoodActualAmountModel>? actualAmounts,
    final DateTime? lastChangeDate,
  }) {
    return GoodModel(
      id: id ?? this.id,
      title: title ?? this.title,
      unit: unit ?? this.unit,
      value: value ?? this.value,
      label: label ?? this.label,
      article: article ?? this.article,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      salonId: salonId ?? this.salonId,
      goodId: goodId ?? this.goodId,
      cost: cost ?? this.cost,
      unitId: unitId ?? this.unitId,
      unitShortTitle: unitShortTitle ?? this.unitShortTitle,
      serviceUnitId: serviceUnitId ?? this.serviceUnitId,
      serviceUnitShortTitle:
          serviceUnitShortTitle ?? this.serviceUnitShortTitle,
      actualCost: actualCost ?? this.actualCost,
      unitActualCost: unitActualCost ?? this.unitActualCost,
      unitActualCostFormat: unitActualCostFormat ?? this.unitActualCostFormat,
      unitEquals: unitEquals ?? this.unitEquals,
      barcode: barcode ?? this.barcode,
      loyaltyAbonementTypeId:
          loyaltyAbonementTypeId ?? this.loyaltyAbonementTypeId,
      loyaltyCertificateTypeId:
          loyaltyCertificateTypeId ?? this.loyaltyCertificateTypeId,
      loyaltyAllowEmptyCode:
          loyaltyAllowEmptyCode ?? this.loyaltyAllowEmptyCode,
      actualAmounts: actualAmounts ?? this.actualAmounts,
      lastChangeDate: lastChangeDate ?? this.lastChangeDate,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'title': title,
      if (unit != null) 'unit': unit,
      'value': value,
      'label': label,
      'article': article,
      'category': category,
      'category_id': categoryId,
      'salon_id': salonId,
      'good_id': goodId,
      'cost': cost,
      'unit_id': unitId,
      'unit_short_title': unitShortTitle,
      'service_unit_id': serviceUnitId,
      'service_unit_short_title': serviceUnitShortTitle,
      'actual_cost': actualCost,
      'unit_actual_cost': unitActualCost,
      'unit_actual_cost_format': unitActualCostFormat,
      'unit_equals': unitEquals,
      'barcode': barcode,
      'loyalty_abonement_type_id': loyaltyAbonementTypeId ?? 0,
      'loyalty_certificate_type_id': loyaltyCertificateTypeId ?? 0,
      'loyalty_allow_empty_code':
          boolToIntConverter.toJson(loyaltyAllowEmptyCode),
      'actual_amounts': actualAmounts
          .map((final actualAmount) => actualAmount.toMap())
          .toList(growable: false),
      'last_change_date': lastChangeDate.toIso8601String(),
    };
  }

  /// Convert the map with string keys to this model.
  factory GoodModel.fromMap(final Map<String, Object?> map) {
    final loyaltyAbonementTypeId = map['loyalty_abonement_type_id'] as int?;
    final loyaltyCertificateTypeId = map['loyalty_certificate_type_id'] as int?;
    return GoodModel(
      id: map['id'] as int?,
      title: map['title']! as String,
      unit: map['unit'] as String?,
      value: map['value']! as String,
      label: map['label']! as String,
      article: map['article']! as String,
      category: map['category']! as String,
      categoryId: map['category_id']! as int,
      salonId: map['salon_id']! as int,
      goodId: map['good_id']! as int,
      cost: map['cost']! as int,
      unitId: map['unit_id']! as int,
      unitShortTitle: map['unit_short_title']! as String,
      serviceUnitId: map['service_unit_id']! as int,
      serviceUnitShortTitle: map['service_unit_short_title']! as String,
      actualCost: (map['actual_cost']! as num).toDouble(),
      unitActualCost: (map['unit_actual_cost']! as num).toDouble(),
      unitActualCostFormat: map['unit_actual_cost_format']! as String,
      unitEquals: map['unit_equals']! as int,
      barcode: map['barcode']! as String,
      loyaltyAbonementTypeId:
          loyaltyAbonementTypeId == 0 ? null : loyaltyAbonementTypeId,
      loyaltyCertificateTypeId:
          loyaltyCertificateTypeId == 0 ? null : loyaltyCertificateTypeId,
      loyaltyAllowEmptyCode:
          boolToIntConverter.fromJson(map['loyalty_allow_empty_code']! as int),
      actualAmounts: (map['actual_amounts']! as Iterable)
          .cast<Map<String, Object?>>()
          .map(GoodActualAmountModel.fromMap),
      lastChangeDate: DateTime.parse(map['last_change_date']! as String),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory GoodModel.fromJson(final String source) =>
      GoodModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  int compareTo(final GoodModel other) => salonId.compareTo(other.salonId);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is GoodModel &&
            other.id == id &&
            other.title == title &&
            other.unit == unit &&
            other.value == value &&
            other.label == label &&
            other.article == article &&
            other.category == category &&
            other.categoryId == categoryId &&
            other.salonId == salonId &&
            other.goodId == goodId &&
            other.cost == cost &&
            other.unitId == unitId &&
            other.unitShortTitle == unitShortTitle &&
            other.serviceUnitId == serviceUnitId &&
            other.serviceUnitShortTitle == serviceUnitShortTitle &&
            other.actualCost == actualCost &&
            other.unitActualCost == unitActualCost &&
            other.unitActualCostFormat == unitActualCostFormat &&
            other.unitEquals == unitEquals &&
            other.barcode == barcode &&
            other.loyaltyAbonementTypeId == loyaltyAbonementTypeId &&
            other.loyaltyCertificateTypeId == loyaltyCertificateTypeId &&
            other.loyaltyAllowEmptyCode == loyaltyAllowEmptyCode &&
            other.actualAmounts == actualAmounts &&
            other.lastChangeDate == lastChangeDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        unit.hashCode ^
        value.hashCode ^
        label.hashCode ^
        article.hashCode ^
        category.hashCode ^
        categoryId.hashCode ^
        salonId.hashCode ^
        goodId.hashCode ^
        cost.hashCode ^
        unitId.hashCode ^
        unitShortTitle.hashCode ^
        serviceUnitId.hashCode ^
        serviceUnitShortTitle.hashCode ^
        actualCost.hashCode ^
        unitActualCost.hashCode ^
        unitActualCostFormat.hashCode ^
        unitEquals.hashCode ^
        barcode.hashCode ^
        loyaltyAbonementTypeId.hashCode ^
        loyaltyCertificateTypeId.hashCode ^
        loyaltyAllowEmptyCode.hashCode ^
        actualAmounts.hashCode ^
        lastChangeDate.hashCode;
  }

  @override
  String toString() {
    return 'GoodModel(id: $id, title: $title, unit: $unit, value: $value, '
        'label: $label, article: $article, category: $category, '
        'categoryId: $categoryId, salonId: $salonId, goodId: $goodId, '
        'cost: $cost, unitId: $unitId, unitShortTitle: $unitShortTitle, '
        'serviceUnitId: $serviceUnitId, '
        'serviceUnitShortTitle: $serviceUnitShortTitle, '
        'actualCost: $actualCost, unitActualCost: $unitActualCost, '
        'unitActualCostFormat: $unitActualCostFormat, unitEquals: $unitEquals, '
        'barcode: $barcode, loyaltyAbonementTypeId: $loyaltyAbonementTypeId, '
        'loyaltyCertificateTypeId: $loyaltyCertificateTypeId, '
        'loyaltyAllowEmptyCode: $loyaltyAllowEmptyCode, '
        'actualAmounts: $actualAmounts, lastChangeDate: $lastChangeDate)';
  }
}

/// The actual amount model for [GoodModel].
@immutable
class GoodActualAmountModel implements Comparable<GoodActualAmountModel> {
  /// The actual amount model for [GoodModel].
  const GoodActualAmountModel({
    required final this.storageId,
    required final this.amount,
  });

  /// The id of the storage where the [amount] of good is at.
  final int storageId;

  /// The amount of good in the [storageId].
  final int amount;

  /// Return the copy of this model.
  GoodActualAmountModel copyWith({
    final int? storageId,
    final int? amount,
  }) {
    return GoodActualAmountModel(
      storageId: storageId ?? this.storageId,
      amount: amount ?? this.amount,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{'storage_id': storageId, 'amount': amount};
  }

  /// Convert the map with string keys to this model.
  factory GoodActualAmountModel.fromMap(final Map<String, Object?> map) {
    return GoodActualAmountModel(
      storageId: map['storage_id']! as int,
      amount: map['amount']! as int,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory GoodActualAmountModel.fromJson(final String source) {
    return GoodActualAmountModel.fromMap(
      json.decode(source)! as Map<String, Object?>,
    );
  }

  @override
  int compareTo(final GoodActualAmountModel other) =>
      amount.compareTo(other.amount);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is GoodActualAmountModel &&
            other.storageId == storageId &&
            other.amount == amount;
  }

  @override
  int get hashCode => storageId.hashCode ^ amount.hashCode;

  @override
  String toString() {
    return 'GoodActualAmountModel(storageId: $storageId, amount: $amount)';
  }
}
