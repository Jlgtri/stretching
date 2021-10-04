// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The payment model in the SMStretching API.
///
/// See: https://smstretching.ru/mobile/payment/{token}/get
@immutable
class SMPaymentModel {
  /// The payment model in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/payment/{token}/get
  const SMPaymentModel({
    required final this.orderId,
    required final this.status,
    required final this.canceled,
    required final this.paymentId,
    required final this.amount,
    required final this.email,
    required final this.description,
    required final this.redirect,
    required final this.recurrent,
    required final this.token,
    required final this.timestamp,
    required final this.companyId,
    required final this.documentId,
    required final this.recordId,
    required final this.userPhone,
  });

  /// The id of this payment in the SMStretching API.
  final int orderId;

  /// The status of this payment.
  final String? status;

  /// If this payment is canceled.
  final bool canceled;

  /// The payment id of this payment.
  final int? paymentId;

  /// The amount (price in cents) of this payment.
  final int? amount;

  /// The email of the user of this payment.
  final String? email;

  /// The description of this payment.
  final String? description;

  /// If this payment is a redirect.
  final String? redirect;

  /// If this payment is reccurent.
  final String? recurrent;

  /// The token of this payment.
  final String? token;

  /// The date and time of this payment.
  final DateTime timestamp;

  /// The company to which this payment was appointed.
  final int companyId;

  /// The document id of this payment.
  final int? documentId;

  /// The record id of this payment.
  final int recordId;

  /// The phone number of the user of this payment.
  final String userPhone;

  /// Return the copy of this model.
  SMPaymentModel copyWith({
    final int? orderId,
    final String? status,
    final bool? canceled,
    final int? paymentId,
    final int? amount,
    final String? email,
    final String? description,
    final String? redirect,
    final String? recurrent,
    final String? token,
    final DateTime? timestamp,
    final int? companyId,
    final int? documentId,
    final int? recordId,
    final String? userPhone,
  }) =>
      SMPaymentModel(
        orderId: orderId ?? this.orderId,
        status: status ?? this.status,
        canceled: canceled ?? this.canceled,
        paymentId: paymentId ?? this.paymentId,
        amount: amount ?? this.amount,
        email: email ?? this.email,
        description: description ?? this.description,
        redirect: redirect ?? this.redirect,
        recurrent: recurrent ?? this.recurrent,
        token: token ?? this.token,
        timestamp: timestamp ?? this.timestamp,
        companyId: companyId ?? this.companyId,
        documentId: documentId ?? this.documentId,
        recordId: recordId ?? this.recordId,
        userPhone: userPhone ?? this.userPhone,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        'order_id': orderId.toString(),
        'status': status?.toString(),
        'canceled': boolToIntConverter.toJson(canceled).toString(),
        'PaymentId': paymentId?.toString(),
        'Amount': amount?.toString(),
        'Email': email?.toString(),
        'Description': description?.toString(),
        'Redirect': redirect?.toString(),
        'Recurrent': recurrent?.toString(),
        'Token': token?.toString(),
        'timestamp': timestamp.toString().split('.').first,
        'company_id': companyId.toString(),
        'document_id': documentId?.toString(),
        'record_id': recordId.toString(),
        'user_phone': userPhone,
      };

  /// Convert the map with string keys to this model.
  factory SMPaymentModel.fromMap(final Map<String, Object?> map) =>
      SMPaymentModel(
        orderId: int.parse(map['order_id']! as String),
        status: map['status'] as String?,
        canceled: boolToIntConverter.fromJson(
          int.parse(map['canceled']! as String),
        ),
        paymentId: map['PaymentId'] != null
            ? int.parse(map['PaymentId']! as String)
            : null,
        amount:
            map['Amount'] != null ? int.parse(map['Amount']! as String) : null,
        email: map['Email'] as String?,
        description: map['Description'] as String?,
        redirect: map['Redirect'] as String?,
        recurrent: map['Recurrent'] as String?,
        token: map['Token'] as String?,
        timestamp: DateTime.parse(map['timestamp']! as String),
        companyId: int.parse(map['company_id']! as String),
        documentId: map['document_id'] != null
            ? int.parse(map['document_id']! as String)
            : null,
        recordId: int.parse(map['record_id']! as String),
        userPhone: map['user_phone']! as String,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory SMPaymentModel.fromJson(final String source) =>
      SMPaymentModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is SMPaymentModel &&
          other.orderId == orderId &&
          other.status == status &&
          other.canceled == canceled &&
          other.paymentId == paymentId &&
          other.amount == amount &&
          other.email == email &&
          other.description == description &&
          other.redirect == redirect &&
          other.recurrent == recurrent &&
          other.token == token &&
          other.timestamp == timestamp &&
          other.companyId == companyId &&
          other.documentId == documentId &&
          other.recordId == recordId &&
          other.userPhone == userPhone;

  @override
  int get hashCode =>
      orderId.hashCode ^
      status.hashCode ^
      canceled.hashCode ^
      paymentId.hashCode ^
      amount.hashCode ^
      email.hashCode ^
      description.hashCode ^
      redirect.hashCode ^
      recurrent.hashCode ^
      token.hashCode ^
      timestamp.hashCode ^
      companyId.hashCode ^
      documentId.hashCode ^
      recordId.hashCode ^
      userPhone.hashCode;

  @override
  String toString() => 'SMPaymentModel(orderId: $orderId, status: $status, '
      'canceled: $canceled, paymentId: $paymentId, amount: $amount, '
      'email: $email, description: $description, redirect: $redirect, '
      'recurrent: $recurrent, token: $token, timestamp: $timestamp, '
      'companyId: $companyId, documentId: $documentId, recordId: $recordId, '
      'userPhone: $userPhone)';
}
