// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// The model of the client in the YClients API.
///
/// See: https://api.yclients.com/api/v1/company/{company_id}/clients/search
@immutable
class ClientModel {
  /// The model of the client in the YClients API.
  ///
  /// See: https://api.yclients.com/api/v1/company/{company_id}/clients/search
  const ClientModel({
    required final this.id,
    required final this.name,
    required final this.phone,
    required final this.email,
    required final this.discount,
    required final this.firstVisitDate,
    required final this.lastVisitDate,
    required final this.soldAmount,
  });

  /// The id of this client in the YClients API.
  final int id;

  /// The name of this client.
  final String name;

  /// The phone number of this client.
  final String phone;

  /// The email of this client.
  final String email;

  /// The total discount of this client.
  final num discount;

  /// The first visit date of this client.
  final DateTime? firstVisitDate;

  /// The last visit date of this client.
  final DateTime? lastVisitDate;

  /// The amount sold to this client.
  final num soldAmount;

  /// Return the copy of this model.
  ClientModel copyWith({
    final int? id,
    final String? name,
    final String? phone,
    final String? email,
    final num? discount,
    final DateTime? firstVisitDate,
    final DateTime? lastVisitDate,
    final num? soldAmount,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      discount: discount ?? this.discount,
      firstVisitDate: firstVisitDate ?? this.firstVisitDate,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      soldAmount: soldAmount ?? this.soldAmount,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'discount': discount,
      'first_visit_date': firstVisitDate?.toIso8601String(),
      'last_visit_date': lastVisitDate?.toIso8601String(),
      'sold_amount': soldAmount,
    };
  }

  /// Convert the map with string keys to this model.
  factory ClientModel.fromMap(final Map<String, Object?> map) {
    return ClientModel(
      id: map['id']! as int,
      name: map['name']! as String,
      phone: map['phone']! as String,
      email: map['email']! as String,
      discount: map['discount']! as num,
      firstVisitDate: DateTime.tryParse(map['first_visit_date']! as String),
      lastVisitDate: DateTime.tryParse(map['last_visit_date']! as String),
      soldAmount: map['sold_amount']! as num,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory ClientModel.fromJson(final String source) =>
      ClientModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is ClientModel &&
            other.id == id &&
            other.name == name &&
            other.phone == phone &&
            other.email == email &&
            other.discount == discount &&
            other.firstVisitDate == firstVisitDate &&
            other.lastVisitDate == lastVisitDate &&
            other.soldAmount == soldAmount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        discount.hashCode ^
        firstVisitDate.hashCode ^
        lastVisitDate.hashCode ^
        soldAmount.hashCode;
  }

  @override
  String toString() {
    return 'ClientModel(id: $id, name: $name, phone: $phone, email: $email, '
        'discount: $discount, firstVisitDate: $firstVisitDate, '
        'lastVisitDate: $lastVisitDate, soldAmount: $soldAmount)';
  }
}

/// The full model of the client in the YClients API.
///
/// See: https://api.yclients.com/api/v1/clients/{company_id}
@immutable
class FullClientModel {
  /// The full model of the client in the YClients API.
  ///
  /// See: https://api.yclients.com/api/v1/clients/{company_id}
  const FullClientModel({
    required final this.id,
    required final this.name,
    required final this.phone,
    required final this.email,
    required final this.card,
    required final this.birthDate,
    required final this.comment,
    required final this.discount,
    required final this.visits,
    required final this.sexId,
    required final this.sex,
    required final this.smsCheck,
    required final this.smsBot,
    required final this.smsNot,
    required final this.spent,
    required final this.paid,
    required final this.balance,
    required final this.importanceId,
    required final this.importance,
    required final this.categories,
    required final this.lastChangeDate,
    required final this.customFields,
  });

  /// The id of this client in the YClients API.
  final int id;

  /// The name of this client.
  final String name;

  /// The phone of this client.
  final String phone;

  /// The email of this client.
  final String email;

  /// The card of this client.
  final String card;

  /// The birth date of this client.
  final String birthDate;

  /// The comment of this client.
  final String comment;

  /// The discount of this client.
  final int discount;

  /// The total count of visits of this client.
  final int visits;

  /// The id of the gender of this client.
  final int sexId;

  /// The gender of this client.
  final String sex;

  /// If the sms checking is enabled for this client.
  final int smsCheck;

  final int smsBot;

  final int smsNot;

  /// The total amount that this client has spent.
  final num spent;

  /// The total amount that this client has been paid.
  final num paid;

  /// The current balance of this client.
  final num balance;

  /// The id of the importance of this client.
  final int importanceId;

  /// The importance of this client.
  final String importance;

  /// The categories of this client
  final Iterable<dynamic> categories;

  /// last date and time of the last time this client had been changed.
  final DateTime lastChangeDate;

  /// The custom fields of this client.
  final Map<String, Object?> customFields;

  /// Return the copy of this model.
  FullClientModel copyWith({
    final int? id,
    final String? name,
    final String? phone,
    final String? email,
    final String? card,
    final String? birthDate,
    final String? comment,
    final int? discount,
    final int? visits,
    final int? sexId,
    final String? sex,
    final int? smsCheck,
    final int? smsBot,
    final int? smsNot,
    final num? spent,
    final num? paid,
    final num? balance,
    final int? importanceId,
    final String? importance,
    final Iterable<dynamic>? categories,
    final DateTime? lastChangeDate,
    final Map<String, Object?>? customFields,
  }) {
    return FullClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      card: card ?? this.card,
      birthDate: birthDate ?? this.birthDate,
      comment: comment ?? this.comment,
      discount: discount ?? this.discount,
      visits: visits ?? this.visits,
      sexId: sexId ?? this.sexId,
      sex: sex ?? this.sex,
      smsCheck: smsCheck ?? this.smsCheck,
      smsBot: smsBot ?? this.smsBot,
      smsNot: smsNot ?? this.smsNot,
      spent: spent ?? this.spent,
      paid: paid ?? this.paid,
      balance: balance ?? this.balance,
      importanceId: importanceId ?? this.importanceId,
      importance: importance ?? this.importance,
      categories: categories ?? this.categories,
      lastChangeDate: lastChangeDate ?? this.lastChangeDate,
      customFields: customFields ?? this.customFields,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'card': card,
      'birth_date': birthDate,
      'comment': comment,
      'discount': discount,
      'visits': visits,
      'sex_id': sexId,
      'sex': sex,
      'sms_check': smsCheck,
      'sms_bot': smsBot,
      'sms_not': smsNot,
      'spent': spent,
      'paid': paid,
      'balance': balance,
      'importance_id': importanceId,
      'importance': importance,
      'categories': categories.toList(growable: false),
      'last_change_date': lastChangeDate,
      'custom_fields': customFields,
    };
  }

  /// Convert the map with string keys to this model.
  factory FullClientModel.fromMap(final Map<String, Object?> map) {
    return FullClientModel(
      id: map['id']! as int,
      name: map['name']! as String,
      phone: map['phone']! as String,
      email: map['email']! as String,
      card: map['card']! as String,
      birthDate: map['birth_date']! as String,
      comment: map['comment']! as String,
      discount: map['discount']! as int,
      visits: map['visits']! as int,
      sexId: map['sex_id']! as int,
      sex: map['sex']! as String,
      smsCheck: map['sms_check']! as int,
      smsBot: map['sms_bot']! as int,
      smsNot: map['sms_not']! as int,
      spent: map['spent']! as num,
      paid: map['paid']! as num,
      balance: map['balance']! as num,
      importanceId: map['importance_id']! as int,
      importance: map['importance']! as String,
      categories: map['categories']! as Iterable,
      lastChangeDate: DateTime.parse(map['last_change_date']! as String),
      customFields: map['custom_fields']! as Map<String, Object?>,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory FullClientModel.fromJson(final String source) =>
      FullClientModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is FullClientModel &&
            other.id == id &&
            other.name == name &&
            other.phone == phone &&
            other.email == email &&
            other.card == card &&
            other.birthDate == birthDate &&
            other.comment == comment &&
            other.discount == discount &&
            other.visits == visits &&
            other.sexId == sexId &&
            other.sex == sex &&
            other.smsCheck == smsCheck &&
            other.smsBot == smsBot &&
            other.smsNot == smsNot &&
            other.spent == spent &&
            other.paid == paid &&
            other.balance == balance &&
            other.importanceId == importanceId &&
            other.importance == importance &&
            other.categories == categories &&
            other.lastChangeDate == lastChangeDate &&
            mapEquals(other.customFields, customFields);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        card.hashCode ^
        birthDate.hashCode ^
        comment.hashCode ^
        discount.hashCode ^
        visits.hashCode ^
        sexId.hashCode ^
        sex.hashCode ^
        smsCheck.hashCode ^
        smsBot.hashCode ^
        smsNot.hashCode ^
        spent.hashCode ^
        paid.hashCode ^
        balance.hashCode ^
        importanceId.hashCode ^
        importance.hashCode ^
        categories.hashCode ^
        lastChangeDate.hashCode ^
        customFields.hashCode;
  }

  @override
  String toString() {
    return 'FullClientModel(id: $id, name: $name, phone: $phone, '
        'email: $email, card: $card, birthDate: $birthDate, comment: $comment, '
        'discount: $discount, visits: $visits, sexId: $sexId, sex: $sex, '
        'smsCheck: $smsCheck, smsBot: $smsBot, smsNot: $smsNot, spent: $spent, '
        'paid: $paid, balance: $balance, importanceId: $importanceId, '
        'importance: $importance, categories: $categories, '
        'lastChangeDate: $lastChangeDate, customFields: $customFields)';
  }
}
