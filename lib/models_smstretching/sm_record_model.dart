// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/utils/json_converters.dart';

/// The type of payment on [SMRecordModel].
enum ActivityPaidBy {
  /// Means activity was not payed yet.
  none,

  /// Means activity was payed regularly (by credit card).
  regular,

  /// Means activity was payed by abonement.
  abonement,

  /// Means activity was payed by deposit.
  deposit
}

/// The status of the [SMRecordModel].
enum ActivityRecordStatus {
  /// Means activity was booked but not paid yet.
  booked,

  /// Means activity was booked and paid.
  paid,

  /// Means activity was canceled by user.
  canceled,

  /// Means activity was canceled by administration.
  deleted
}

/// The record model for the SMStretching API.
///
/// See: https://smstretching.ru/mobile/records/{token}/get/{record_id}
@immutable
class SMRecordModel implements Comparable<SMRecordModel> {
  /// The record model for the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/records/{token}/get/{record_id}
  const SMRecordModel({
    required final this.id,
    required final this.activityId,
    required final this.recordId,
    required final this.companyId,
    required final this.date,
    required final this.dateEvent,
    required final this.payment,
    required final this.abonement,
    required final this.userPhone,
    required final this.userActive,
    required final this.orderId,
    required final this.mobile,
    required final this.rating,
    required final this.serviceId,
    required final this.serviceName,
    required final this.trenerName,
    required final this.sendPush,
    required final this.isAbonement,
    required final this.comment,
  });

  /// Creates this record to be sent via json payload.
  SMRecordModel.fromActivity(
    final ActivityModel activity, {
    required final this.recordId,
    required final this.date,
    required final this.userPhone,
    final this.payment = ActivityPaidBy.none,
    final this.userActive = ActivityRecordStatus.booked,
    final this.abonement,
    final this.orderId,
    final this.rating = 0,
    final this.mobile = true,
  })  : id = 0,
        activityId = activity.id,
        companyId = activity.companyId,
        dateEvent = activity.date,
        serviceId = activity.serviceId,
        serviceName = activity.service.title,
        trenerName = activity.staff.name,
        sendPush = false,
        isAbonement = abonement != null,
        comment = '';

  /// The id of this record in the SMStretching API.
  final int id;

  /// The id of the activity of this record in the YClients API.
  final int activityId;

  /// The id of this record in the YClients API.
  final int recordId;

  /// The id of the company of this record in the YClients API.
  final int companyId;

  /// The date and time this record was created.
  final DateTime date;

  /// The date and time the activity of this record will take place.
  final DateTime dateEvent;

  /// The type of payment of this record.
  final ActivityPaidBy payment;

  /// The id of abonement used to create this record if any.
  final int? abonement;

  /// The phone number of the user that is assigned to this record.
  final String userPhone;

  /// The current status of this record.
  final ActivityRecordStatus userActive;

  /// The order id of this record if this record was payed via Tinkoff.
  final int? orderId;

  /// If this record was made via mobile.
  final bool mobile;

  /// The rating assigned to this record.
  final num rating;

  /// The id of the service of this record's activity in the YClients API.
  final int serviceId;

  /// The name of the service of this record's activity.
  final String serviceName;

  /// The name of the staff of this record.
  final String trenerName;

  /// If push notifications should be sent to a user before this record starts.
  final bool sendPush;

  /// If this record was paid by abonement.
  final bool isAbonement;

  /// The comment for this record.
  final String comment;

  @override
  int compareTo(final SMRecordModel other) => date.compareTo(other.date);

  /// Return the copy of this model.
  SMRecordModel copyWith({
    final int? id,
    final int? activityId,
    final int? recordId,
    final int? companyId,
    final DateTime? date,
    final DateTime? dateEvent,
    final ActivityPaidBy? payment,
    final int? abonement,
    final String? userPhone,
    final ActivityRecordStatus? userActive,
    final int? orderId,
    final bool? mobile,
    final num? rating,
    final int? serviceId,
    final String? serviceName,
    final String? trenerName,
    final bool? sendPush,
    final bool? isAbonement,
    final String? comment,
  }) {
    return SMRecordModel(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      recordId: recordId ?? this.recordId,
      companyId: companyId ?? this.companyId,
      date: date ?? this.date,
      dateEvent: dateEvent ?? this.dateEvent,
      payment: payment ?? this.payment,
      abonement: abonement ?? this.abonement,
      userPhone: userPhone ?? this.userPhone,
      userActive: userActive ?? this.userActive,
      orderId: orderId ?? this.orderId,
      mobile: mobile ?? this.mobile,
      rating: rating ?? this.rating,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      trenerName: trenerName ?? this.trenerName,
      sendPush: sendPush ?? this.sendPush,
      isAbonement: isAbonement ?? this.isAbonement,
      comment: comment ?? this.comment,
    );
  }

  /// Convert this model to map with string keys.
  ///
  /// - If [post] is true, map is prepared to be sent as json payload.
  /// - If [edit] is also true, map is prepared to be sent as json payload
  /// without some field.
  Map<String, Object?> toMap({
    final bool post = false,
    final bool edit = false,
  }) {
    return <String, Object?>{
      if (!post && !edit) 'id': id.toString(),
      if (!edit)
        'activity_id': post || edit ? activityId : activityId.toString(),
      if (!edit) 'record_id': post || edit ? recordId : recordId.toString(),
      'company_id': post || edit ? companyId : companyId.toString(),
      if (!edit) 'date': date.toString().split('.').first,
      'date_event': dateEvent.toString().split('.').first,
      'payment': post || edit ? payment.index : payment.index.toString(),
      'abonement': post || edit ? abonement ?? 0 : (abonement ?? 0).toString(),
      'user_phone': userPhone,
      'user_active':
          post || edit ? userActive.index : userActive.index.toString(),
      if (!post && !edit || orderId != null)
        'order_id': post || edit ? orderId ?? 0 : (orderId ?? 0).toString(),
      'mobile': post || edit
          ? boolToIntConverter.toJson(mobile)
          : boolToIntConverter.toJson(mobile).toString(),
      if (rating > 0) 'rating': post || edit ? rating : rating.toString(),
      'service_id': post || edit ? serviceId : serviceId.toString(),
      'service_name': serviceName,
      'trener_name': trenerName,
      if (!post && !edit)
        'send_push': boolToIntConverter.toJson(sendPush).toString(),
      if (!post && !edit)
        'is_abonement': boolToIntConverter.toJson(isAbonement).toString(),
      if (!post && !edit) 'comment': comment,
    };
  }

  /// Convert the map with string keys to this model.
  factory SMRecordModel.fromMap(final Map<String, Object?> map) {
    final abonement = int.parse(map['abonement']! as String);
    final orderId = int.parse(map['order_id']! as String);
    return SMRecordModel(
      id: int.parse(map['id']! as String),
      activityId: int.parse(map['activity_id']! as String),
      recordId: int.parse(map['record_id']! as String),
      companyId: int.parse(map['company_id']! as String),
      date: DateTime.parse(map['date']! as String),
      dateEvent: DateTime.parse(map['date_event']! as String),
      payment:
          ActivityPaidBy.values.elementAt(int.parse(map['payment']! as String)),
      abonement: abonement == 0 ? null : abonement,
      userPhone: map['user_phone']! as String,
      userActive: ActivityRecordStatus.values
          .elementAt(int.parse(map['user_active']! as String)),
      orderId: orderId == 0 ? null : orderId,
      mobile: boolToIntConverter.fromJson(int.parse(map['mobile']! as String)),
      rating: int.parse(map['rating']! as String),
      serviceId: int.parse(map['service_id']! as String),
      serviceName: map['service_name']! as String,
      trenerName: map['trener_name']! as String,
      sendPush:
          boolToIntConverter.fromJson(int.parse(map['send_push']! as String)),
      isAbonement: boolToIntConverter
          .fromJson(int.parse(map['is_abonement']! as String)),
      comment: map['comment']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMRecordModel.fromJson(final String source) =>
      SMRecordModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is SMRecordModel &&
            other.id == id &&
            other.activityId == activityId &&
            other.recordId == recordId &&
            other.companyId == companyId &&
            other.date == date &&
            other.dateEvent == dateEvent &&
            other.payment == payment &&
            other.abonement == abonement &&
            other.userPhone == userPhone &&
            other.userActive == userActive &&
            other.orderId == orderId &&
            other.mobile == mobile &&
            other.rating == rating &&
            other.serviceId == serviceId &&
            other.serviceName == serviceName &&
            other.trenerName == trenerName &&
            other.sendPush == sendPush &&
            other.isAbonement == isAbonement &&
            other.comment == comment;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        activityId.hashCode ^
        recordId.hashCode ^
        companyId.hashCode ^
        date.hashCode ^
        dateEvent.hashCode ^
        payment.hashCode ^
        abonement.hashCode ^
        userPhone.hashCode ^
        userActive.hashCode ^
        orderId.hashCode ^
        mobile.hashCode ^
        rating.hashCode ^
        serviceId.hashCode ^
        serviceName.hashCode ^
        trenerName.hashCode ^
        sendPush.hashCode ^
        isAbonement.hashCode ^
        comment.hashCode;
  }

  @override
  String toString() {
    return 'SMRecordModel(id: $id, activityId: $activityId, '
        'recordId: $recordId, companyId: $companyId, date: $date, '
        'dateEvent: $dateEvent, payment: $payment, abonement: $abonement, '
        'userPhone: $userPhone, userActive: $userActive, orderId: $orderId, '
        'mobile: $mobile, rating: $rating, serviceId: $serviceId, '
        'serviceName: $serviceName, trenerName: $trenerName, '
        'sendPush: $sendPush, isAbonement: $isAbonement, comment: $comment)';
  }
}
