// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The record model from YClients API.
///
/// See: https://developers.yclients.com/ru/#operation/Получить%20запись
@immutable
class RecordModel {
  /// The record model from YClients API.
  ///
  /// See: https://developers.yclients.com/ru/#operation/Получить%20запись
  const RecordModel({
    required final this.id,
    required final this.companyId,
    required final this.staffId,
    required final this.services,
    required final this.goodsTransactions,
    required final this.staff,
    required final this.client,
    required final this.comer,
    required final this.clientsCount,
    required final this.date,
    required final this.datetime,
    required final this.createDate,
    required final this.comment,
    required final this.online,
    required final this.visitAttendance,
    required final this.attendance,
    required final this.confirmed,
    required final this.seanceLength,
    required final this.length,
    required final this.smsBefore,
    required final this.smsNow,
    required final this.smsNowText,
    required final this.emailNow,
    required final this.notified,
    required final this.masterRequest,
    required final this.apiId,
    required final this.fromUrl,
    required final this.reviewRequested,
    required final this.visitId,
    required final this.createdUserId,
    required final this.deleted,
    required final this.paidFull,
    required final this.prepaid,
    required final this.prepaidConfirmed,
    required final this.lastChangeDate,
    required final this.customColor,
    required final this.customFontColor,
    required final this.recordLabels,
    required final this.activityId,
    required final this.customFields,
    required final this.documents,
    required final this.smsRemainHours,
    required final this.emailRemainHours,
    required final this.paymentStatus,
  });

  /// The id of this record in the YClients API.
  final int id;

  /// The id of the company of this record in the YClients API.
  final int companyId;

  /// The id of the staff member of this record in the YClients API.
  final int staffId;

  /// The services of this record.
  final Iterable<RecordServiceModel> services;

  /// The transactions of goods specified in this record.
  final Iterable<Object?> goodsTransactions;

  /// The staff member of this record.
  final RecordStaffModel staff;

  /// The client of this record.
  final RecordClientModel? client;

  final Object? comer;

  /// The count of clients of this record.
  final int clientsCount;

  /// The date and time of this record.
  final DateTime date;

  /// The date and time of this record (in iso format).
  final DateTime datetime;

  /// The date and time this record was created.
  final DateTime createDate;

  /// The comment provided for this record.
  final String comment;

  /// If record was made online. False if record was created by administrator.
  final bool online;

  /// The status of [client]'s visit of this record:
  ///
  /// * 2: client has confirmed the record.
  /// * 1: client arrived, the [services] are finished.
  /// * 0: waiting for client.
  /// * -1: client missed to the record.
  final int visitAttendance;

  /// The status of this record:
  ///
  /// * 2: client has confirmed the record.
  /// * 1: client arrived, the [services] are finished.
  /// * 0: waiting for client.
  /// * -1: client missed to the record.
  final int attendance;

  /// If this record is confirmed.
  final bool confirmed;

  /// The length of the activity of this record.
  final Duration seanceLength;

  /// The length of the activity of this record.
  final Duration length;

  /// If the notification sms should be sent to a user.
  final bool smsBefore;

  /// If the sms notification was sent to a user while booking.
  final bool smsNow;

  /// The text of the sms notification that was sent to a user while booking.
  final String smsNowText;

  /// If the email notification was sent to a user while booking.
  final bool emailNow;

  /// If the administrator of the [companyId] is notified about this record.
  final bool notified;

  /// If the specific staff member was requested while booking.
  final bool masterRequest;

  /// The outer id of this record.
  final int apiId;

  /// The url from which the user navigated to the booking page.
  final String fromUrl;

  /// If the review rating is asked from a client after the activity itself.
  final bool reviewRequested;

  /// The id of this record's visit.
  final int visitId;

  /// The id of a user that created this record.
  final int createdUserId;

  /// If this record is deleted.
  final bool deleted;

  /// If this record is paid fully.
  final int paidFull;

  /// If the online payment is available.
  final bool prepaid;

  /// The status of the [prepaid] online payment.
  final bool prepaidConfirmed;

  /// The date and time of the last time this record was changed.
  final DateTime lastChangeDate;

  /// The color of this record in the journal.
  final String customColor;

  /// The color of the font of this record in the journal.
  final String customFontColor;

  /// The categories of this record.
  final Iterable<RecordLabelModel> recordLabels;

  /// The id of the activity of this record in the YClients API.
  final int activityId;

  /// The extra fields provided for this record.
  final Iterable<Object?> customFields;

  /// The documents provided to this record.
  final Iterable<RecordDocumentModel> documents;

  /// The remaining hours before sending a sms notification to the [client].
  final int? smsRemainHours;

  /// The remaining hours before sending an email notification to the [client].
  final int? emailRemainHours;

  final int? paymentStatus;

  /// Return the copy of this model.
  RecordModel copyWith({
    final int? id,
    final int? companyId,
    final int? staffId,
    final Iterable<RecordServiceModel>? services,
    final Iterable<Object?>? goodsTransactions,
    final RecordStaffModel? staff,
    final RecordClientModel? client,
    final Object? comer,
    final int? clientsCount,
    final DateTime? date,
    final DateTime? datetime,
    final DateTime? createDate,
    final String? comment,
    final bool? online,
    final int? visitAttendance,
    final int? attendance,
    final bool? confirmed,
    final Duration? seanceLength,
    final Duration? length,
    final bool? smsBefore,
    final bool? smsNow,
    final String? smsNowText,
    final bool? emailNow,
    final bool? notified,
    final bool? masterRequest,
    final int? apiId,
    final String? fromUrl,
    final bool? reviewRequested,
    final int? visitId,
    final int? createdUserId,
    final bool? deleted,
    final int? paidFull,
    final bool? prepaid,
    final bool? prepaidConfirmed,
    final DateTime? lastChangeDate,
    final String? customColor,
    final String? customFontColor,
    final Iterable<RecordLabelModel>? recordLabels,
    final int? activityId,
    final Iterable<Object?>? customFields,
    final Iterable<RecordDocumentModel>? documents,
    final int? smsRemainHours,
    final int? emailRemainHours,
    final int? paymentStatus,
  }) {
    return RecordModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      staffId: staffId ?? this.staffId,
      services: services ?? this.services,
      goodsTransactions: goodsTransactions ?? this.goodsTransactions,
      staff: staff ?? this.staff,
      client: client ?? this.client,
      comer: comer ?? this.comer,
      clientsCount: clientsCount ?? this.clientsCount,
      date: date ?? this.date,
      datetime: datetime ?? this.datetime,
      createDate: createDate ?? this.createDate,
      comment: comment ?? this.comment,
      online: online ?? this.online,
      visitAttendance: visitAttendance ?? this.visitAttendance,
      attendance: attendance ?? this.attendance,
      confirmed: confirmed ?? this.confirmed,
      seanceLength: seanceLength ?? this.seanceLength,
      length: length ?? this.length,
      smsBefore: smsBefore ?? this.smsBefore,
      smsNow: smsNow ?? this.smsNow,
      smsNowText: smsNowText ?? this.smsNowText,
      emailNow: emailNow ?? this.emailNow,
      notified: notified ?? this.notified,
      masterRequest: masterRequest ?? this.masterRequest,
      apiId: apiId ?? this.apiId,
      fromUrl: fromUrl ?? this.fromUrl,
      reviewRequested: reviewRequested ?? this.reviewRequested,
      visitId: visitId ?? this.visitId,
      createdUserId: createdUserId ?? this.createdUserId,
      deleted: deleted ?? this.deleted,
      paidFull: paidFull ?? this.paidFull,
      prepaid: prepaid ?? this.prepaid,
      prepaidConfirmed: prepaidConfirmed ?? this.prepaidConfirmed,
      lastChangeDate: lastChangeDate ?? this.lastChangeDate,
      customColor: customColor ?? this.customColor,
      customFontColor: customFontColor ?? this.customFontColor,
      recordLabels: recordLabels ?? this.recordLabels,
      activityId: activityId ?? this.activityId,
      customFields: customFields ?? this.customFields,
      documents: documents ?? this.documents,
      smsRemainHours: smsRemainHours ?? this.smsRemainHours,
      emailRemainHours: emailRemainHours ?? this.emailRemainHours,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'staff_id': staffId,
      'services': services
          .map((final service) => service.toMap())
          .toList(growable: false),
      'goods_transactions': goodsTransactions.toList(growable: false),
      'staff': staff.toMap(),
      'client': client?.toMap(),
      'comer': comer,
      'clients_count': clientsCount,
      'date': date.toString(),
      'datetime': datetime.toIso8601String(),
      'create_date': createDate.toIso8601String(),
      'comment': comment,
      'online': online,
      'visit_attendance': visitAttendance,
      'attendance': attendance,
      'confirmed': boolToIntConverter.toJson(confirmed),
      'seance_length': seanceLength.inSeconds,
      'length': length.inSeconds,
      'sms_before': boolToIntConverter.toJson(smsBefore),
      'sms_now': boolToIntConverter.toJson(smsNow),
      'sms_now_text': smsNowText,
      'email_now': boolToIntConverter.toJson(emailNow),
      'notified': boolToIntConverter.toJson(notified),
      'master_request': boolToIntConverter.toJson(masterRequest),
      'api_id': apiId.toString(),
      'from_url': fromUrl,
      'review_requested': boolToIntConverter.toJson(reviewRequested),
      'visit_id': visitId,
      'created_user_id': createdUserId,
      'deleted': deleted,
      'paid_full': paidFull,
      'prepaid': prepaid,
      'prepaid_confirmed': prepaidConfirmed,
      'last_change_date': lastChangeDate.toIso8601String(),
      'custom_color': customColor,
      'custom_font_color': customFontColor,
      'record_labels': recordLabels
          .map((final recordLabel) => recordLabel.toMap())
          .toList(growable: false),
      'activity_id': activityId,
      'custom_fields': customFields.toList(growable: false),
      'documents': documents
          .map((final document) => document.toMap())
          .toList(growable: false),
      'sms_remain_hours': smsRemainHours,
      'email_remain_hours': emailRemainHours,
      'payment_status': paymentStatus,
    };
  }

  /// Convert the map with string keys to this model.
  factory RecordModel.fromMap(final Map<String, Object?> map) {
    return RecordModel(
      id: map['id']! as int,
      companyId: map['company_id']! as int,
      staffId: map['staff_id']! as int,
      services: (map['services']! as Iterable)
          .cast<Map<String, Object?>>()
          .map(RecordServiceModel.fromMap),
      goodsTransactions: map['goods_transactions']! as Iterable,
      staff: RecordStaffModel.fromMap(map['staff']! as Map<String, Object?>),
      client: map['client'] != null
          ? RecordClientModel.fromMap(map['client']! as Map<String, Object?>)
          : null,
      comer: map['comer'],
      clientsCount: map['clients_count']! as int,
      date: DateTime.parse(map['date']! as String),
      datetime: DateTime.parse(map['datetime']! as String),
      createDate: DateTime.parse(map['create_date']! as String),
      comment: map['comment']! as String,
      online: map['online']! as bool,
      visitAttendance: map['visit_attendance']! as int,
      attendance: map['attendance']! as int,
      confirmed: boolToIntConverter.fromJson(map['confirmed']! as int),
      seanceLength: Duration(seconds: map['seance_length']! as int),
      length: Duration(seconds: map['length']! as int),
      smsBefore: boolToIntConverter.fromJson(map['sms_before']! as int),
      smsNow: boolToIntConverter.fromJson(map['sms_now']! as int),
      smsNowText: map['sms_now_text']! as String,
      emailNow: boolToIntConverter.fromJson(map['email_now']! as int),
      notified: boolToIntConverter.fromJson(map['notified']! as int),
      masterRequest: boolToIntConverter.fromJson(map['master_request']! as int),
      apiId: int.parse(map['api_id']! as String),
      fromUrl: map['from_url']! as String,
      reviewRequested:
          boolToIntConverter.fromJson(map['review_requested']! as int),
      visitId: map['visit_id']! as int,
      createdUserId: map['created_user_id']! as int,
      deleted: map['deleted']! as bool,
      paidFull: map['paid_full']! as int,
      prepaid: map['prepaid']! as bool,
      prepaidConfirmed: map['prepaid_confirmed']! as bool,
      lastChangeDate: DateTime.parse(map['last_change_date']! as String),
      customColor: map['custom_color']! as String,
      customFontColor: map['custom_font_color']! as String,
      recordLabels: (map['record_labels']! as Iterable)
          .cast<Map<String, Object?>>()
          .map(RecordLabelModel.fromMap),
      activityId: map['activity_id']! as int,
      customFields: map['custom_fields']! as Iterable,
      documents: (map['documents']! as Iterable)
          .cast<Map<String, Object?>>()
          .map(RecordDocumentModel.fromMap),
      smsRemainHours: map['sms_remain_hours'] as int?,
      emailRemainHours: map['email_remain_hours'] as int?,
      paymentStatus: map['payment_status'] as int?,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory RecordModel.fromJson(final String source) =>
      RecordModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is RecordModel &&
            other.id == id &&
            other.companyId == companyId &&
            other.staffId == staffId &&
            other.services == services &&
            other.goodsTransactions == goodsTransactions &&
            other.staff == staff &&
            other.client == client &&
            other.comer == comer &&
            other.clientsCount == clientsCount &&
            other.date == date &&
            other.datetime == datetime &&
            other.createDate == createDate &&
            other.comment == comment &&
            other.online == online &&
            other.visitAttendance == visitAttendance &&
            other.attendance == attendance &&
            other.confirmed == confirmed &&
            other.seanceLength == seanceLength &&
            other.length == length &&
            other.smsBefore == smsBefore &&
            other.smsNow == smsNow &&
            other.smsNowText == smsNowText &&
            other.emailNow == emailNow &&
            other.notified == notified &&
            other.masterRequest == masterRequest &&
            other.apiId == apiId &&
            other.fromUrl == fromUrl &&
            other.reviewRequested == reviewRequested &&
            other.visitId == visitId &&
            other.createdUserId == createdUserId &&
            other.deleted == deleted &&
            other.paidFull == paidFull &&
            other.prepaid == prepaid &&
            other.prepaidConfirmed == prepaidConfirmed &&
            other.lastChangeDate == lastChangeDate &&
            other.customColor == customColor &&
            other.customFontColor == customFontColor &&
            other.recordLabels == recordLabels &&
            other.activityId == activityId &&
            other.customFields == customFields &&
            other.documents == documents &&
            other.smsRemainHours == smsRemainHours &&
            other.emailRemainHours == emailRemainHours &&
            other.paymentStatus == paymentStatus;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        staffId.hashCode ^
        services.hashCode ^
        goodsTransactions.hashCode ^
        staff.hashCode ^
        client.hashCode ^
        comer.hashCode ^
        clientsCount.hashCode ^
        date.hashCode ^
        datetime.hashCode ^
        createDate.hashCode ^
        comment.hashCode ^
        online.hashCode ^
        visitAttendance.hashCode ^
        attendance.hashCode ^
        confirmed.hashCode ^
        seanceLength.hashCode ^
        length.hashCode ^
        smsBefore.hashCode ^
        smsNow.hashCode ^
        smsNowText.hashCode ^
        emailNow.hashCode ^
        notified.hashCode ^
        masterRequest.hashCode ^
        apiId.hashCode ^
        fromUrl.hashCode ^
        reviewRequested.hashCode ^
        visitId.hashCode ^
        createdUserId.hashCode ^
        deleted.hashCode ^
        paidFull.hashCode ^
        prepaid.hashCode ^
        prepaidConfirmed.hashCode ^
        lastChangeDate.hashCode ^
        customColor.hashCode ^
        customFontColor.hashCode ^
        recordLabels.hashCode ^
        activityId.hashCode ^
        customFields.hashCode ^
        documents.hashCode ^
        smsRemainHours.hashCode ^
        emailRemainHours.hashCode ^
        paymentStatus.hashCode;
  }

  @override
  String toString() {
    return 'RecordModel(id: $id, companyId: $companyId, staffId: $staffId, '
        'services: $services, goodsTransactions: $goodsTransactions, '
        'staff: $staff, client: $client, comer: $comer, '
        'clientsCount: $clientsCount, date: $date, datetime: $datetime, '
        'createDate: $createDate, comment: $comment, online: $online, '
        'visitAttendance: $visitAttendance, attendance: $attendance, '
        'confirmed: $confirmed, seanceLength: $seanceLength, length: $length, '
        'smsBefore: $smsBefore, smsNow: $smsNow, smsNowText: $smsNowText, '
        'emailNow: $emailNow, notified: $notified, '
        'masterRequest: $masterRequest, apiId: $apiId, fromUrl: $fromUrl, '
        'reviewRequested: $reviewRequested, visitId: $visitId, '
        'createdUserId: $createdUserId, deleted: $deleted, '
        'paidFull: $paidFull, prepaid: $prepaid, '
        'prepaidConfirmed: $prepaidConfirmed, lastChangeDate: $lastChangeDate, '
        'customColor: $customColor, customFontColor: $customFontColor, '
        'recordLabels: $recordLabels, activityId: $activityId, '
        'customFields: $customFields, documents: $documents, '
        'smsRemainHours: $smsRemainHours, emailRemainHours: $emailRemainHours, '
        'paymentStatus: $paymentStatus)';
  }
}

/// The label model for the [RecordModel].
@immutable
class RecordLabelModel {
  /// The label model for the [RecordModel].
  const RecordLabelModel({
    required final this.id,
    required final this.title,
    required final this.color,
    required final this.icon,
    required final this.fontColor,
  });

  /// The id of this label in the YClients API.
  final String id;

  /// The title of this label.
  final String title;

  /// The color of this label.
  final String color;

  /// The icon of this label.
  final String icon;

  /// The font color of this label.
  final String fontColor;

  /// Return the copy of this model.
  RecordLabelModel copyWith({
    final String? id,
    final String? title,
    final String? color,
    final String? icon,
    final String? fontColor,
  }) {
    return RecordLabelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      fontColor: fontColor ?? this.fontColor,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'color': color,
      'icon': icon,
      'font_color': fontColor,
    };
  }

  /// Convert the map with string keys to this model.
  factory RecordLabelModel.fromMap(final Map<String, Object?> map) {
    return RecordLabelModel(
      id: map['id']! as String,
      title: map['title']! as String,
      color: map['color']! as String,
      icon: map['icon']! as String,
      fontColor: map['fontColor']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory RecordLabelModel.fromJson(final String source) =>
      RecordLabelModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is RecordLabelModel &&
            other.id == id &&
            other.title == title &&
            other.color == color &&
            other.icon == icon &&
            other.fontColor == fontColor;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        color.hashCode ^
        icon.hashCode ^
        fontColor.hashCode;
  }

  @override
  String toString() {
    return 'RecordLabelModel(id: $id, title: $title, color: $color, '
        'icon: $icon, fontColor: $fontColor)';
  }
}

/// The model of a client for the [RecordModel].
@immutable
class RecordClientModel {
  /// The model of a client for the [RecordModel].
  const RecordClientModel({
    required final this.id,
    required final this.name,
    required final this.phone,
    required final this.card,
    required final this.email,
    required final this.successVisitsCount,
    required final this.failVisitsCount,
    required final this.discount,
  });

  /// The id of this client in the YClients API.
  final int id;

  /// The name of this client.
  final String name;

  /// The phone number of this client.
  final String phone;

  /// The card of this client.
  final String card;

  /// The email of this client.
  final String email;

  /// The count of successful visits of this client.
  final int successVisitsCount;

  /// The count of failed visits of this client.
  final int failVisitsCount;

  /// The discount of this client.
  final int discount;

  /// Return the copy of this model.
  RecordClientModel copyWith({
    final int? id,
    final String? name,
    final String? phone,
    final String? card,
    final String? email,
    final int? successVisitsCount,
    final int? failVisitsCount,
    final int? discount,
  }) {
    return RecordClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      card: card ?? this.card,
      email: email ?? this.email,
      successVisitsCount: successVisitsCount ?? this.successVisitsCount,
      failVisitsCount: failVisitsCount ?? this.failVisitsCount,
      discount: discount ?? this.discount,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'phone': phone,
      'card': card,
      'email': email,
      'success_visits_count': successVisitsCount,
      'fail_visits_count': failVisitsCount,
      'discount': discount,
    };
  }

  /// Convert the map with string keys to this model.
  factory RecordClientModel.fromMap(final Map<String, Object?> map) {
    return RecordClientModel(
      id: map['id']! as int,
      name: map['name']! as String,
      phone: map['phone']! as String,
      card: map['card']! as String,
      email: map['email']! as String,
      successVisitsCount: map['success_visits_count']! as int,
      failVisitsCount: map['fail_visits_count']! as int,
      discount: map['discount']! as int,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory RecordClientModel.fromJson(final String source) =>
      RecordClientModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is RecordClientModel &&
            other.id == id &&
            other.name == name &&
            other.phone == phone &&
            other.card == card &&
            other.email == email &&
            other.successVisitsCount == successVisitsCount &&
            other.failVisitsCount == failVisitsCount &&
            other.discount == discount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        card.hashCode ^
        email.hashCode ^
        successVisitsCount.hashCode ^
        failVisitsCount.hashCode ^
        discount.hashCode;
  }

  @override
  String toString() {
    return 'RecordClientModel(id: $id, name: $name, phone: $phone, '
        'card: $card, email: $email, successVisitsCount: $successVisitsCount, '
        'failVisitsCount: $failVisitsCount, discount: $discount)';
  }
}

/// The document model for the [RecordModel].
@immutable
class RecordDocumentModel {
  /// The document model for the [RecordModel].
  const RecordDocumentModel({
    required final this.id,
    required final this.typeId,
    required final this.storageId,
    required final this.userId,
    required final this.companyId,
    required final this.number,
    required final this.comment,
    required final this.dateCreated,
    required final this.categoryId,
    required final this.visitId,
    required final this.recordId,
    required final this.typeTitle,
  });

  /// The id of this document in the YClients API.
  final int id;

  /// The type of this document.
  final int typeId;

  /// The id of the storage assigned for this document.
  final int storageId;

  /// The id of the user that created this document.
  final int userId;

  /// The id of the company that created this document.
  final int companyId;

  /// The number of this document.
  final int number;

  /// The comment of this document.
  final String comment;

  /// The date and time this document was created.
  final DateTime dateCreated;

  /// The id of the category of this document.
  final int categoryId;

  /// The id of the visit of this document.
  final int visitId;

  /// The id of the record of this document.
  final int recordId;

  /// The name of the type of this document.
  final String typeTitle;

  /// Return the copy of this model.
  RecordDocumentModel copyWith({
    final int? id,
    final int? typeId,
    final int? storageId,
    final int? userId,
    final int? companyId,
    final int? number,
    final String? comment,
    final DateTime? dateCreated,
    final int? categoryId,
    final int? visitId,
    final int? recordId,
    final String? typeTitle,
  }) {
    return RecordDocumentModel(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      storageId: storageId ?? this.storageId,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      number: number ?? this.number,
      comment: comment ?? this.comment,
      dateCreated: dateCreated ?? this.dateCreated,
      categoryId: categoryId ?? this.categoryId,
      visitId: visitId ?? this.visitId,
      recordId: recordId ?? this.recordId,
      typeTitle: typeTitle ?? this.typeTitle,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'type_id': typeId,
      'storage_id': storageId,
      'user_id': userId,
      'company_id': companyId,
      'number': number,
      'comment': comment,
      'date_created': dateCreated.toString(),
      'category_id': categoryId,
      'visit_id': visitId,
      'record_id': recordId,
      'type_title': typeTitle,
    };
  }

  /// Convert the map with string keys to this model.
  factory RecordDocumentModel.fromMap(final Map<String, Object?> map) {
    return RecordDocumentModel(
      id: map['id']! as int,
      typeId: map['type_id']! as int,
      storageId: map['storage_id']! as int,
      userId: map['user_id']! as int,
      companyId: map['company_id']! as int,
      number: map['number']! as int,
      comment: map['comment']! as String,
      dateCreated: DateTime.parse(map['date_created']! as String),
      categoryId: map['category_id']! as int,
      visitId: map['visit_id']! as int,
      recordId: map['record_id']! as int,
      typeTitle: map['type_title']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory RecordDocumentModel.fromJson(final String source) =>
      RecordDocumentModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is RecordDocumentModel &&
            other.id == id &&
            other.typeId == typeId &&
            other.storageId == storageId &&
            other.userId == userId &&
            other.companyId == companyId &&
            other.number == number &&
            other.comment == comment &&
            other.dateCreated == dateCreated &&
            other.categoryId == categoryId &&
            other.visitId == visitId &&
            other.recordId == recordId &&
            other.typeTitle == typeTitle;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        typeId.hashCode ^
        storageId.hashCode ^
        userId.hashCode ^
        companyId.hashCode ^
        number.hashCode ^
        comment.hashCode ^
        dateCreated.hashCode ^
        categoryId.hashCode ^
        visitId.hashCode ^
        recordId.hashCode ^
        typeTitle.hashCode;
  }

  @override
  String toString() {
    return 'RecordDocumentModel(id: $id, typeId: $typeId, '
        'storageId: $storageId, userId: $userId, companyId: $companyId, '
        'number: $number, comment: $comment, dateCreated: $dateCreated, '
        'categoryId: $categoryId, visitId: $visitId, recordId: $recordId, '
        'typeTitle: $typeTitle)';
  }
}

/// The service model for the [RecordModel].
@immutable
class RecordServiceModel {
  /// The service model for the [RecordModel].
  const RecordServiceModel({
    required final this.id,
    required final this.title,
    required final this.cost,
    required final this.manualCost,
    required final this.costPerUnit,
    required final this.discount,
    required final this.firstCost,
    required final this.amount,
  });

  /// The id of this service in the YClients API.
  final int id;

  /// The title of this service.
  final String title;

  /// The final cost of this service.
  final int cost;

  /// The cost of this service that was set manually.
  final int manualCost;

  /// The cost per unit of this service.
  final int costPerUnit;

  /// The discount applied to this service.
  final int discount;

  /// The initial cost of this service (without [discount]).
  final int firstCost;

  /// The amount of this service consumed.
  final int amount;

  /// Return the copy of this model.
  RecordServiceModel copyWith({
    final int? id,
    final String? title,
    final int? cost,
    final int? manualCost,
    final int? costPerUnit,
    final int? discount,
    final int? firstCost,
    final int? amount,
  }) {
    return RecordServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      cost: cost ?? this.cost,
      manualCost: manualCost ?? this.manualCost,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      discount: discount ?? this.discount,
      firstCost: firstCost ?? this.firstCost,
      amount: amount ?? this.amount,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'cost': cost,
      'manual_cost': manualCost,
      'cost_per_unit': costPerUnit,
      'discount': discount,
      'first_cost': firstCost,
      'amount': amount,
    };
  }

  /// Convert the map with string keys to this model.
  factory RecordServiceModel.fromMap(final Map<String, Object?> map) {
    return RecordServiceModel(
      id: map['id']! as int,
      title: map['title']! as String,
      cost: map['cost']! as int,
      manualCost: map['manual_cost']! as int,
      costPerUnit: map['cost_per_unit']! as int,
      discount: map['discount']! as int,
      firstCost: map['first_cost']! as int,
      amount: map['amount']! as int,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory RecordServiceModel.fromJson(final String source) =>
      RecordServiceModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is RecordServiceModel &&
            other.id == id &&
            other.title == title &&
            other.cost == cost &&
            other.manualCost == manualCost &&
            other.costPerUnit == costPerUnit &&
            other.discount == discount &&
            other.firstCost == firstCost &&
            other.amount == amount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        cost.hashCode ^
        manualCost.hashCode ^
        costPerUnit.hashCode ^
        discount.hashCode ^
        firstCost.hashCode ^
        amount.hashCode;
  }

  @override
  String toString() {
    return 'RecordServiceModel(id: $id, title: $title, cost: $cost, '
        'manualCost: $manualCost, costPerUnit: $costPerUnit, '
        'discount: $discount, firstCost: $firstCost, amount: $amount)';
  }
}

/// The model of a staff member for [RecordModel].
@immutable
class RecordStaffModel {
  /// The model of a staff member for [RecordModel].
  const RecordStaffModel({
    required final this.id,
    required final this.apiId,
    required final this.name,
    required final this.specialization,
    required final this.position,
    required final this.avatar,
    required final this.avatarBig,
    required final this.rating,
    required final this.votesCount,
  });

  /// The id of this staff member in YClients API.
  final int id;

  /// The outer id of this staff member.
  final Object? apiId;

  /// The name of this staff member.
  final String name;

  /// The specialization of this staff member.
  final String specialization;

  /// The position of this staff member.
  final RecordStaffPositionModel position;

  /// The avatar of this staff member.
  final String avatar;

  /// The big avatar of this staff member.
  final String avatarBig;

  /// The rating of this staff member.
  final int rating;

  /// The count of votes of this staff member.
  final int votesCount;

  /// Return the copy of this model.
  RecordStaffModel copyWith({
    final int? id,
    final Object? apiId,
    final String? name,
    final String? specialization,
    final RecordStaffPositionModel? position,
    final String? avatar,
    final String? avatarBig,
    final int? rating,
    final int? votesCount,
  }) {
    return RecordStaffModel(
      id: id ?? this.id,
      apiId: apiId ?? this.apiId,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      position: position ?? this.position,
      avatar: avatar ?? this.avatar,
      avatarBig: avatarBig ?? this.avatarBig,
      rating: rating ?? this.rating,
      votesCount: votesCount ?? this.votesCount,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'api_id': apiId,
      'name': name,
      'specialization': specialization,
      'position': position.toMap(),
      'avatar': avatar,
      'avatar_big': avatarBig,
      'rating': rating,
      'votes_count': votesCount,
    };
  }

  /// Convert the map with string keys to this model.
  factory RecordStaffModel.fromMap(final Map<String, Object?> map) {
    return RecordStaffModel(
      id: map['id']! as int,
      apiId: map['api_id'],
      name: map['name']! as String,
      specialization: map['specialization']! as String,
      position: RecordStaffPositionModel.fromMap(
        map['position']! as Map<String, Object?>,
      ),
      avatar: map['avatar']! as String,
      avatarBig: map['avatar_big']! as String,
      rating: map['rating']! as int,
      votesCount: map['votes_count']! as int,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory RecordStaffModel.fromJson(final String source) =>
      RecordStaffModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is RecordStaffModel &&
            other.id == id &&
            other.apiId == apiId &&
            other.name == name &&
            other.specialization == specialization &&
            other.position == position &&
            other.avatar == avatar &&
            other.avatarBig == avatarBig &&
            other.rating == rating &&
            other.votesCount == votesCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        apiId.hashCode ^
        name.hashCode ^
        specialization.hashCode ^
        position.hashCode ^
        avatar.hashCode ^
        avatarBig.hashCode ^
        rating.hashCode ^
        votesCount.hashCode;
  }

  @override
  String toString() {
    return 'RecordStaffModel(id: $id, apiId: $apiId, name: $name, '
        'specialization: $specialization, position: $position, '
        'avatar: $avatar, avatarBig: $avatarBig, rating: $rating, '
        'votesCount: $votesCount)';
  }
}

/// The model of a position for [RecordStaffModel].
@immutable
class RecordStaffPositionModel {
  /// The model of a position for [RecordStaffModel].
  const RecordStaffPositionModel({
    required final this.id,
    required final this.title,
  });

  /// The id of this position in the YCLients API.
  final int id;

  /// The title of this position.
  final String title;

  /// Return the copy of this model.
  RecordStaffPositionModel copyWith({
    final int? id,
    final String? title,
  }) {
    return RecordStaffPositionModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{'id': id, 'title': title};
  }

  /// Convert the map with string keys to this model.
  factory RecordStaffPositionModel.fromMap(final Map<String, Object?> map) {
    return RecordStaffPositionModel(
      id: map['id']! as int,
      title: map['title']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory RecordStaffPositionModel.fromJson(final String source) {
    return RecordStaffPositionModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is RecordStaffPositionModel &&
            other.id == id &&
            other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() {
    return 'RecordStaffPositionModel(id: $id, title: $title)';
  }
}
