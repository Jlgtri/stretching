// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [UserAbonementModel].
const UserAbonementConverter abonementConverter = UserAbonementConverter._();

/// The converter of the [UserAbonementModel].
class UserAbonementConverter
    implements JsonConverter<UserAbonementModel, Map<String, Object?>> {
  const UserAbonementConverter._();

  @override
  UserAbonementModel fromJson(final Map<String, Object?> data) =>
      UserAbonementModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final UserAbonementModel data) => data.toMap();
}

/// The abonement model in the YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/28/0
@immutable
class UserAbonementModel implements Comparable<UserAbonementModel> {
  /// The abonement model in the YClients API.
  ///
  /// See: https://yclientsru.docs.apiary.io/#reference/28/0
  const UserAbonementModel({
    required final this.id,
    required final this.number,
    required final this.balanceString,
    required final this.createdDate,
    required final this.activatedDate,
    required final this.isFrozen,
    required final this.freezePeriod,
    required final this.period,
    required final this.periodUnitId,
    required final this.expirationDate,
    required final this.status,
    required final this.isUnitedBalance,
    required final this.unitedBalanceServicesCount,
    required final this.balanceContainer,
    required final this.type,
  });

  /// The id of this abonement in the YClients API.
  final int id;

  /// The hash number of this abonement.
  final String number;

  /// The name of the balance string of this abonement.
  final String balanceString;

  /// The date and time this abonement was created.
  final DateTime createdDate;

  /// The date and time this abonement was activated.
  final DateTime? activatedDate;

  /// If this abonement is currently frozen.
  final bool isFrozen;

  /// The total period this abonement was frozen.
  final int freezePeriod;

  /// The period of validity of this abonement.
  final int period;

  /// The unit of this abonement's [period].
  ///
  /// * 1 - day
  /// * 2 - week
  /// * 3 - month
  /// * 4 - year
  final int periodUnitId;

  /// The date and time this abonement is considered expired.
  final DateTime? expirationDate;

  /// The status of this abonement.
  final UserAbonementStatusModel status;

  final bool isUnitedBalance;
  final int unitedBalanceServicesCount;

  /// The object that contains a list of
  /// [UserAbonementBalanceContainerLinkModel].
  final UserAbonementBalanceContainerModel balanceContainer;

  /// The extra data provided for this abonement.
  final UserAbonementTypeModel type;

  /// Return the copy of this model.
  UserAbonementModel copyWith({
    final int? id,
    final String? number,
    final String? balanceString,
    final DateTime? createdDate,
    final DateTime? activatedDate,
    final bool? isFrozen,
    final int? freezePeriod,
    final int? period,
    final int? periodUnitId,
    final DateTime? expirationDate,
    final UserAbonementStatusModel? status,
    final bool? isUnitedBalance,
    final int? unitedBalanceServicesCount,
    final UserAbonementBalanceContainerModel? balanceContainer,
    final UserAbonementTypeModel? type,
  }) {
    return UserAbonementModel(
      id: id ?? this.id,
      number: number ?? this.number,
      balanceString: balanceString ?? this.balanceString,
      createdDate: createdDate ?? this.createdDate,
      activatedDate: activatedDate ?? this.activatedDate,
      isFrozen: isFrozen ?? this.isFrozen,
      freezePeriod: freezePeriod ?? this.freezePeriod,
      period: period ?? this.period,
      periodUnitId: periodUnitId ?? this.periodUnitId,
      expirationDate: expirationDate ?? this.expirationDate,
      status: status ?? this.status,
      isUnitedBalance: isUnitedBalance ?? this.isUnitedBalance,
      unitedBalanceServicesCount:
          unitedBalanceServicesCount ?? this.unitedBalanceServicesCount,
      balanceContainer: balanceContainer ?? this.balanceContainer,
      type: type ?? this.type,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'number': number,
      'balance_string': balanceString,
      'created_date': createdDate.toIso8601String(),
      'activated_date': optionalDateTimeConverter.toJson(activatedDate),
      'is_frozen': isFrozen,
      'freeze_period': freezePeriod,
      'period': period,
      'period_unit_id': periodUnitId,
      'expiration_date': optionalDateTimeConverter.toJson(expirationDate),
      'status': status.toMap(),
      'is_united_balance': isUnitedBalance,
      'united_balance_services_count': unitedBalanceServicesCount,
      'balance_container': balanceContainer.toMap(),
      'type': type.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory UserAbonementModel.fromMap(final Map<String, Object?> map) {
    return UserAbonementModel(
      id: map['id']! as int,
      number: map['number']! as String,
      balanceString: map['balance_string']! as String,
      createdDate: dateTimeConverter.fromJson(map['created_date']! as String),
      activatedDate:
          optionalDateTimeConverter.fromJson(map['activated_date'] as String?),
      isFrozen: map['is_frozen']! as bool,
      freezePeriod: map['freeze_period']! as int,
      period: map['period']! as int,
      periodUnitId: map['period_unit_id']! as int,
      expirationDate:
          optionalDateTimeConverter.fromJson(map['expiration_date'] as String?),
      status: UserAbonementStatusModel.fromMap(
        map['status']! as Map<String, Object?>,
      ),
      isUnitedBalance: map['is_united_balance']! as bool,
      unitedBalanceServicesCount: map['united_balance_services_count']! as int,
      balanceContainer: UserAbonementBalanceContainerModel.fromMap(
        map['balance_container']! as Map<String, Object?>,
      ),
      type:
          UserAbonementTypeModel.fromMap(map['type']! as Map<String, Object?>),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory UserAbonementModel.fromJson(final String source) =>
      UserAbonementModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  int compareTo(final UserAbonementModel other) {
    final expirationDateA = expirationDate;
    final expirationDateB = other.expirationDate;
    if (expirationDateA == null) {
      return 1;
    } else if (expirationDateB == null) {
      return -1;
    } else {
      return expirationDateA.compareTo(expirationDateB);
    }
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is UserAbonementModel &&
            other.id == id &&
            other.number == number &&
            other.balanceString == balanceString &&
            other.createdDate == createdDate &&
            other.activatedDate == activatedDate &&
            other.isFrozen == isFrozen &&
            other.freezePeriod == freezePeriod &&
            other.period == period &&
            other.periodUnitId == periodUnitId &&
            other.expirationDate == expirationDate &&
            other.status == status &&
            other.isUnitedBalance == isUnitedBalance &&
            other.unitedBalanceServicesCount == unitedBalanceServicesCount &&
            other.balanceContainer == balanceContainer &&
            other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        number.hashCode ^
        balanceString.hashCode ^
        createdDate.hashCode ^
        activatedDate.hashCode ^
        isFrozen.hashCode ^
        freezePeriod.hashCode ^
        period.hashCode ^
        periodUnitId.hashCode ^
        expirationDate.hashCode ^
        status.hashCode ^
        isUnitedBalance.hashCode ^
        unitedBalanceServicesCount.hashCode ^
        balanceContainer.hashCode ^
        type.hashCode;
  }

  @override
  String toString() {
    return 'UserAbonementModel(id: $id, number: $number, '
        'balanceString: $balanceString, createdDate: $createdDate, '
        'activatedDate: $activatedDate, isFrozen: $isFrozen, '
        'freezePeriod: $freezePeriod, period: $period, '
        'periodUnitId: $periodUnitId, expirationDate: $expirationDate, '
        'status: $status, isUnitedBalance: $isUnitedBalance, '
        'unitedBalanceServicesCount: $unitedBalanceServicesCount, '
        'balanceContainer: $balanceContainer, type: $type)';
  }
}

/// The balance container of the [UserAbonementModel].
@immutable
class UserAbonementBalanceContainerModel {
  /// The balance container of the [UserAbonementModel].
  const UserAbonementBalanceContainerModel({required final this.links});

  /// The links of this container.
  final Iterable<UserAbonementBalanceContainerLinkModel> links;

  /// Return the copy of this model.
  UserAbonementBalanceContainerModel copyWith({
    final Iterable<UserAbonementBalanceContainerLinkModel>? links,
  }) {
    return UserAbonementBalanceContainerModel(links: links ?? this.links);
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'links': links.map((final link) => link.toMap()).toList(growable: false),
    };
  }

  /// Convert the map with string keys to this model.
  factory UserAbonementBalanceContainerModel.fromMap(
    final Map<String, Object?> map,
  ) {
    return UserAbonementBalanceContainerModel(
      links: <UserAbonementBalanceContainerLinkModel>[
        for (final map in map['links']! as Iterable<Object?>)
          if (map is Map<String, Object?>)
            UserAbonementBalanceContainerLinkModel.fromMap(map)
      ],
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory UserAbonementBalanceContainerModel.fromJson(final String source) {
    return UserAbonementBalanceContainerModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is UserAbonementBalanceContainerModel && other.links == links;
  }

  @override
  int get hashCode => links.hashCode;

  @override
  String toString() => 'UserAbonementBalanceContainerModel(links: $links)';
}

/// The link of the [UserAbonementBalanceContainerModel].
///
/// Contains the information about [UserAbonementModel] balance.
@immutable
class UserAbonementBalanceContainerLinkModel {
  /// The link of the [UserAbonementBalanceContainerModel].
  ///
  /// Contains the information about [UserAbonementModel] balance.
  const UserAbonementBalanceContainerLinkModel({
    required final this.count,
    required final this.category,
  });

  /// The count of this link.
  final int count;

  /// This category of this link.
  final UserAbonementBalanceContainerLinkCategoryModel category;

  /// Return the copy of this model.
  UserAbonementBalanceContainerLinkModel copyWith({
    final int? count,
    final UserAbonementBalanceContainerLinkCategoryModel? category,
  }) {
    return UserAbonementBalanceContainerLinkModel(
      count: count ?? this.count,
      category: category ?? this.category,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{'count': count, 'category': category.toMap()};
  }

  /// Convert the map with string keys to this model.
  factory UserAbonementBalanceContainerLinkModel.fromMap(
    final Map<String, Object?> map,
  ) {
    return UserAbonementBalanceContainerLinkModel(
      count: map['count']! as int,
      category: UserAbonementBalanceContainerLinkCategoryModel.fromMap(
        map['category']! as Map<String, Object?>,
      ),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory UserAbonementBalanceContainerLinkModel.fromJson(final String source) {
    return UserAbonementBalanceContainerLinkModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is UserAbonementBalanceContainerLinkModel &&
            other.count == count &&
            other.category == category;
  }

  @override
  int get hashCode => count.hashCode ^ category.hashCode;

  @override
  String toString() {
    return 'UserAbonementBalanceContainerLinkModel(count: $count, '
        'category: $category)';
  }
}

/// The category of the [UserAbonementBalanceContainerLinkModel].
@immutable
class UserAbonementBalanceContainerLinkCategoryModel {
  /// The category of the [UserAbonementBalanceContainerLinkModel].
  const UserAbonementBalanceContainerLinkCategoryModel({
    required final this.id,
    required final this.categoryId,
    required final this.title,
  });

  /// The id of this category in the YClients API.
  final int id;

  /// The local id of this category inside it's parent.
  final int categoryId;

  /// The title of this category.
  final String title;

  /// Return the copy of this model.
  UserAbonementBalanceContainerLinkCategoryModel copyWith({
    final int? id,
    final int? categoryId,
    final String? title,
  }) {
    return UserAbonementBalanceContainerLinkCategoryModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'category_id': categoryId,
      'title': title,
    };
  }

  /// Convert the map with string keys to this model.
  factory UserAbonementBalanceContainerLinkCategoryModel.fromMap(
    final Map<String, Object?> map,
  ) {
    return UserAbonementBalanceContainerLinkCategoryModel(
      id: map['id']! as int,
      categoryId: map['category_id']! as int,
      title: map['title']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory UserAbonementBalanceContainerLinkCategoryModel.fromJson(
    final String source,
  ) {
    return UserAbonementBalanceContainerLinkCategoryModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is UserAbonementBalanceContainerLinkCategoryModel &&
            other.id == id &&
            other.categoryId == categoryId &&
            other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ categoryId.hashCode ^ title.hashCode;

  @override
  String toString() {
    return 'UserAbonementBalanceContainerLinkCategoryModel(id: $id, '
        'categoryId: $categoryId, title: $title)';
  }
}

/// The status of the [UserAbonementModel].
@immutable
class UserAbonementStatusModel {
  /// The status of the [UserAbonementModel].
  const UserAbonementStatusModel({
    required final this.id,
    required final this.title,
    required final this.extendedTitle,
  });

  /// The id of this status in the YClients API.
  final int id;

  /// The title of this status.
  final String title;

  /// The extended title of this status.
  final String extendedTitle;

  /// Return the copy of this model.
  UserAbonementStatusModel copyWith({
    final int? id,
    final String? title,
    final String? extendedTitle,
  }) {
    return UserAbonementStatusModel(
      id: id ?? this.id,
      title: title ?? this.title,
      extendedTitle: extendedTitle ?? this.extendedTitle,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'extended_title': extendedTitle,
    };
  }

  /// Convert the map with string keys to this model.
  factory UserAbonementStatusModel.fromMap(final Map<String, Object?> map) {
    return UserAbonementStatusModel(
      id: map['id']! as int,
      title: map['title']! as String,
      extendedTitle: map['extended_title']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory UserAbonementStatusModel.fromJson(final String source) {
    return UserAbonementStatusModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is UserAbonementStatusModel &&
            other.id == id &&
            other.title == title &&
            other.extendedTitle == extendedTitle;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ extendedTitle.hashCode;

  @override
  String toString() {
    return 'UserAbonementStatusModel(id: $id, title: $title, '
        'extendedTitle: $extendedTitle)';
  }
}

/// The extra data for the [UserAbonementModel].
@immutable
class UserAbonementTypeModel {
  /// The extra data for the [UserAbonementModel].
  const UserAbonementTypeModel({
    required final this.id,
    required final this.salonGroupId,
    required final this.title,
    required final this.period,
    required final this.periodUnitId,
    required final this.allowFreeze,
    required final this.freezeLimit,
    required final this.isAllowEmptyCode,
    required final this.isUnitedBalance,
    required final this.unitedBalanceServicesCount,
    required final this.balanceContainer,
  });

  /// The id of this type in the YClients API.
  final int id;

  /// The id of the salon group of this type.
  final int salonGroupId;

  /// The title of this type.
  final String title;

  final int period;
  final int periodUnitId;

  /// If this type's abonement can be freezed.
  final bool allowFreeze;

  /// The limit of times this type's abonement can be freezed.
  final int freezeLimit;

  final bool isAllowEmptyCode;
  final bool isUnitedBalance;
  final int unitedBalanceServicesCount;

  /// The balance container of this type.
  final UserAbonementBalanceContainerModel balanceContainer;

  /// Return the copy of this model.
  UserAbonementTypeModel copyWith({
    final int? id,
    final int? salonGroupId,
    final String? title,
    final int? period,
    final int? periodUnitId,
    final bool? allowFreeze,
    final int? freezeLimit,
    final bool? isAllowEmptyCode,
    final bool? isUnitedBalance,
    final int? unitedBalanceServicesCount,
    final UserAbonementBalanceContainerModel? balanceContainer,
  }) {
    return UserAbonementTypeModel(
      id: id ?? this.id,
      salonGroupId: salonGroupId ?? this.salonGroupId,
      title: title ?? this.title,
      period: period ?? this.period,
      periodUnitId: periodUnitId ?? this.periodUnitId,
      allowFreeze: allowFreeze ?? this.allowFreeze,
      freezeLimit: freezeLimit ?? this.freezeLimit,
      isAllowEmptyCode: isAllowEmptyCode ?? this.isAllowEmptyCode,
      isUnitedBalance: isUnitedBalance ?? this.isUnitedBalance,
      unitedBalanceServicesCount:
          unitedBalanceServicesCount ?? this.unitedBalanceServicesCount,
      balanceContainer: balanceContainer ?? this.balanceContainer,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'salon_group_id': salonGroupId,
      'title': title,
      'period': period,
      'period_unit_id': periodUnitId,
      'allow_freeze': allowFreeze,
      'freeze_limit': freezeLimit,
      'is_allow_empty_code': isAllowEmptyCode,
      'is_united_balance': isUnitedBalance,
      'united_balance_services_count': unitedBalanceServicesCount,
      'balance_container': balanceContainer.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory UserAbonementTypeModel.fromMap(final Map<String, Object?> map) {
    return UserAbonementTypeModel(
      id: map['id']! as int,
      salonGroupId: map['salon_group_id']! as int,
      title: map['title']! as String,
      period: map['period']! as int,
      periodUnitId: map['period_unit_id']! as int,
      allowFreeze: map['allow_freeze']! as bool,
      freezeLimit: map['freeze_limit']! as int,
      isAllowEmptyCode: map['is_allow_empty_code']! as bool,
      isUnitedBalance: map['is_united_balance']! as bool,
      unitedBalanceServicesCount: map['united_balance_services_count']! as int,
      balanceContainer: UserAbonementBalanceContainerModel.fromMap(
        map['balance_container']! as Map<String, Object?>,
      ),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory UserAbonementTypeModel.fromJson(final String source) {
    return UserAbonementTypeModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is UserAbonementTypeModel &&
            other.id == id &&
            other.salonGroupId == salonGroupId &&
            other.title == title &&
            other.period == period &&
            other.periodUnitId == periodUnitId &&
            other.allowFreeze == allowFreeze &&
            other.freezeLimit == freezeLimit &&
            other.isAllowEmptyCode == isAllowEmptyCode &&
            other.isUnitedBalance == isUnitedBalance &&
            other.unitedBalanceServicesCount == unitedBalanceServicesCount &&
            other.balanceContainer == balanceContainer;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        salonGroupId.hashCode ^
        title.hashCode ^
        period.hashCode ^
        periodUnitId.hashCode ^
        allowFreeze.hashCode ^
        freezeLimit.hashCode ^
        isAllowEmptyCode.hashCode ^
        isUnitedBalance.hashCode ^
        unitedBalanceServicesCount.hashCode ^
        balanceContainer.hashCode;
  }

  @override
  String toString() {
    return 'UserAbonementTypeModel(id: $id, salonGroupId: $salonGroupId, '
        'title: $title, period: $period, periodUnitId: $periodUnitId, '
        'allowFreeze: $allowFreeze, freezeLimit: $freezeLimit, '
        'isAllowEmptyCode: $isAllowEmptyCode, '
        'isUnitedBalance: $isUnitedBalance, '
        'unitedBalanceServicesCount: $unitedBalanceServicesCount, '
        'balanceContainer: $balanceContainer)';
  }
}
