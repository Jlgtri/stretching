// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [SMUserAbonementModel].
const SMUserAbonementConverter smUserAbonementConverter =
    SMUserAbonementConverter._();

/// The converter of the [SMUserAbonementModel].
class SMUserAbonementConverter
    implements JsonConverter<SMUserAbonementModel, Map<String, Object?>> {
  const SMUserAbonementConverter._();

  @override
  SMUserAbonementModel fromJson(final Map<String, Object?> data) =>
      SMUserAbonementModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final SMUserAbonementModel data) => data.toMap();
}

/// The abonement model in the SMStretching API.
///
/// See: https://smstretching.ru/mobile/goods/{token}/get_all_user
@immutable
class SMUserAbonementModel {
  /// The abonement model in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/goods/{token}/get_all_user
  const SMUserAbonementModel({
    required final this.id,
    required final this.abonementId,
    required final this.documentId,
    required final this.companyId,
    required final this.userPhone,
    required final this.dateStart,
    required final this.dateEnd,
    required final this.active,
    required final this.the8,
    required final this.del,
    required final this.the9,
    required final this.mobile,
  });

  /// The id of this abonement in the SMStretching API.
  final int id;

  /// The id of this abonement in the YClients API.
  final int abonementId;

  /// The document id of this abonement in the YClients API.
  final int documentId;

  /// The company id of this abonement in the YClients API.
  final int companyId;

  /// The phone number of the owner of this abonement.
  final int userPhone;

  /// The date and time this abonement has started.
  final DateTime dateStart;

  /// The date and time this abonement has ended.
  final DateTime dateEnd;

  /// If this abonement is active.
  final bool active;

  /// The eighth property of this model ([del]).
  final bool the8;

  /// If this abonement is deleted.
  final bool del;

  /// The ninth property of this model ([mobile]).
  final bool the9;

  /// If this abonement was created in the mobile app.
  final bool mobile;

  /// Return the copy of this model.
  SMUserAbonementModel copyWith({
    final int? id,
    final int? abonementId,
    final int? documentId,
    final int? companyId,
    final int? userPhone,
    final DateTime? dateStart,
    final DateTime? dateEnd,
    final bool? active,
    final bool? the8,
    final bool? del,
    final bool? the9,
    final bool? mobile,
  }) =>
      SMUserAbonementModel(
        id: id ?? this.id,
        abonementId: abonementId ?? this.abonementId,
        documentId: documentId ?? this.documentId,
        companyId: companyId ?? this.companyId,
        userPhone: userPhone ?? this.userPhone,
        dateStart: dateStart ?? this.dateStart,
        dateEnd: dateEnd ?? this.dateEnd,
        active: active ?? this.active,
        the8: the8 ?? this.the8,
        del: del ?? this.del,
        the9: the9 ?? this.the9,
        mobile: mobile ?? this.mobile,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id.toString(),
        'abonement_id': abonementId.toString(),
        'document_id': documentId.toString(),
        'company_id': companyId.toString(),
        'user_phone': userPhone.toString(),
        'date_start': dateStart.toString().split('.').first,
        'date_end': dateEnd.toString().split('.').first,
        'active': boolToIntConverter.toJson(active).toString(),
        '8': boolToIntConverter.toJson(the8).toString(),
        'del': boolToIntConverter.toJson(del).toString(),
        '9': boolToIntConverter.toJson(the9).toString(),
        'mobile': boolToIntConverter.toJson(mobile).toString(),
      };

  /// Convert the map with string keys to this model.
  factory SMUserAbonementModel.fromMap(final Map<String, Object?> map) =>
      SMUserAbonementModel(
        id: int.parse(map['id']! as String),
        abonementId: int.parse(map['abonement_id']! as String),
        documentId: int.parse(map['document_id']! as String),
        companyId: int.parse(map['company_id']! as String),
        userPhone: int.parse(map['user_phone']! as String),
        dateStart: DateTime.parse(map['date_start']! as String),
        dateEnd: DateTime.parse(map['date_end']! as String),
        active:
            boolToIntConverter.fromJson(int.parse(map['active']! as String)),
        the8: boolToIntConverter.fromJson(int.parse(map['8']! as String)),
        del: boolToIntConverter.fromJson(int.parse(map['del']! as String)),
        the9: boolToIntConverter.fromJson(int.parse(map['9']! as String)),
        mobile:
            boolToIntConverter.fromJson(int.parse(map['mobile']! as String)),
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMUserAbonementModel.fromJson(final String source) =>
      SMUserAbonementModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is SMUserAbonementModel &&
          other.id == id &&
          other.abonementId == abonementId &&
          other.documentId == documentId &&
          other.companyId == companyId &&
          other.userPhone == userPhone &&
          other.dateStart == dateStart &&
          other.dateEnd == dateEnd &&
          other.active == active &&
          other.the8 == the8 &&
          other.del == del &&
          other.the9 == the9 &&
          other.mobile == mobile;

  @override
  int get hashCode =>
      id.hashCode ^
      abonementId.hashCode ^
      documentId.hashCode ^
      companyId.hashCode ^
      userPhone.hashCode ^
      dateStart.hashCode ^
      dateEnd.hashCode ^
      active.hashCode ^
      the8.hashCode ^
      del.hashCode ^
      the9.hashCode ^
      mobile.hashCode;

  @override
  String toString() =>
      'SMUserAbonementModel(id: $id, abonementId: $abonementId, '
      'documentId: $documentId, companyId: $companyId, '
      'userPhone: $userPhone, dateStart: $dateStart, dateEnd: $dateEnd, '
      'active: $active, the8: $the8, del: $del, the9: $the9, '
      'mobile: $mobile)';
}
