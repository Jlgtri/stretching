// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';

/// The model of the transaction in the YClients API.
///
/// See: https://api.yclients.com/api/v1/company/{company_id}/sale/{document_id}/payment
@immutable
class TransactionModel {
  /// The model of the transaction in the YClients API.
  ///
  /// See: https://api.yclients.com/api/v1/company/{company_id}/sale/{document_id}/payment
  const TransactionModel({
    required final this.state,
    required final this.kkmState,
    required final this.paymentMethods,
  });

  /// The state of this transaction.
  final TransactionStateModel state;

  /// The kkm state of this transaction.
  final TransactionKKMStateModel kkmState;

  /// The payment methods of this transaction.
  final Iterable<TransactionPaymentMethodModel> paymentMethods;

  /// Return the copy of this model.
  TransactionModel copyWith({
    final TransactionStateModel? state,
    final TransactionKKMStateModel? kkmState,
    final Iterable<TransactionPaymentMethodModel>? paymentMethods,
  }) {
    return TransactionModel(
      state: state ?? this.state,
      kkmState: kkmState ?? this.kkmState,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'state': state.toMap(),
      'kkm_state': kkmState.toMap(),
      'payment_methods': paymentMethods
          .map((final paymentMethod) => paymentMethod.toMap())
          .toList(growable: false),
    };
  }

  /// Convert the map with string keys to this model.
  factory TransactionModel.fromMap(final Map<String, Object?> map) {
    return TransactionModel(
      state:
          TransactionStateModel.fromMap(map['state']! as Map<String, Object?>),
      kkmState: TransactionKKMStateModel.fromMap(
        map['kkm_state']! as Map<String, Object?>,
      ),
      paymentMethods: (map['payment_methods']! as Iterable)
          .cast<Map<String, Object?>>()
          .map((final map) => TransactionPaymentMethodModel.fromMap(map)),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert this model to a json string.
  factory TransactionModel.fromJson(final String source) =>
      TransactionModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TransactionModel &&
            other.state == state &&
            other.kkmState == kkmState &&
            other.paymentMethods == paymentMethods;
  }

  @override
  int get hashCode =>
      state.hashCode ^ kkmState.hashCode ^ paymentMethods.hashCode;

  @override
  String toString() {
    return 'TransactionModel(state: $state, kkmState: $kkmState, '
        'paymentMethods: $paymentMethods)';
  }
}

/// The kkm state model for the [TransactionModel].
@immutable
class TransactionKKMStateModel {
  /// The kkm state model for the [TransactionModel].
  const TransactionKKMStateModel({
    required final this.showPayerInfo,
    required final this.showPositionsInfo,
    required final this.lastOperationType,
    required final this.receiptPdfLink,
    required final this.transactions,
  });

  final bool showPayerInfo;

  final bool showPositionsInfo;

  /// The last operation type of this kkm.
  final int lastOperationType;

  /// The link to the generated pdf of this kkm.
  final String receiptPdfLink;

  /// The transactions of this kkm.
  final Iterable<dynamic> transactions;

  /// Return the copy of this model.
  TransactionKKMStateModel copyWith({
    final bool? showPayerInfo,
    final bool? showPositionsInfo,
    final int? lastOperationType,
    final String? receiptPdfLink,
    final Iterable<dynamic>? transactions,
  }) {
    return TransactionKKMStateModel(
      showPayerInfo: showPayerInfo ?? this.showPayerInfo,
      showPositionsInfo: showPositionsInfo ?? this.showPositionsInfo,
      lastOperationType: lastOperationType ?? this.lastOperationType,
      receiptPdfLink: receiptPdfLink ?? this.receiptPdfLink,
      transactions: transactions ?? this.transactions,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'show_payer_info': showPayerInfo,
      'show_positions_info': showPositionsInfo,
      'last_operation_type': lastOperationType,
      'receipt_pdf_link': receiptPdfLink,
      'transactions': transactions.toList(growable: false),
    };
  }

  /// Convert the map with string keys to this model.
  factory TransactionKKMStateModel.fromMap(final Map<String, Object?> map) {
    return TransactionKKMStateModel(
      showPayerInfo: map['show_payer_info']! as bool,
      showPositionsInfo: map['show_positions_info']! as bool,
      lastOperationType: map['last_operation_type']! as int,
      receiptPdfLink: map['receipt_pdf_link']! as String,
      transactions: map['transactions']! as Iterable,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionKKMStateModel.fromJson(final String source) {
    return TransactionKKMStateModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TransactionKKMStateModel &&
            other.showPayerInfo == showPayerInfo &&
            other.showPositionsInfo == showPositionsInfo &&
            other.lastOperationType == lastOperationType &&
            other.receiptPdfLink == receiptPdfLink &&
            other.transactions == transactions;
  }

  @override
  int get hashCode {
    return showPayerInfo.hashCode ^
        showPositionsInfo.hashCode ^
        lastOperationType.hashCode ^
        receiptPdfLink.hashCode ^
        transactions.hashCode;
  }

  @override
  String toString() {
    return 'TransactionKKMStateModel(showPayerInfo: $showPayerInfo, '
        'showPositionsInfo: $showPositionsInfo, '
        'lastOperationType: $lastOperationType, '
        'receiptPdfLink: $receiptPdfLink, transactions: $transactions)';
  }
}

/// The payment method model for [TransactionModel].
@immutable
class TransactionPaymentMethodModel {
  /// The payment method model for [TransactionModel].
  const TransactionPaymentMethodModel({
    required final this.slug,
    required final this.isApplicable,
    required final this.applicableAmount,
    required final this.applicableCount,
    required final this.applicableValue,
    required final this.accountId,
    required final this.account,
    required final this.loyaltyProgramId,
    required final this.loyaltyProgram,
  });

  /// The slug of this payment method.
  final String slug;

  /// If this payment method is applicable.
  final bool isApplicable;

  /// The amount that is applicable for this payment method.
  final int applicableAmount;

  /// The count that is applicable for this payment method.
  final int applicableCount;

  /// The value that is applicable for this payment method.
  final int applicableValue;

  /// The id of the [account] of this payment method.
  final int? accountId;

  /// The account model of this payment method.
  final TransactionPaymentMethodAccountModel? account;

  /// The id of the [loyaltyProgram] of this payment method in YClients API
  /// if any.
  final int? loyaltyProgramId;

  /// The loyalty program of this payment method if any.
  final TransactionPaymentMethodLoyaltyProgramModel? loyaltyProgram;

  /// Return the copy of this model.
  TransactionPaymentMethodModel copyWith({
    final String? slug,
    final bool? isApplicable,
    final int? applicableAmount,
    final int? applicableCount,
    final int? applicableValue,
    final int? accountId,
    final TransactionPaymentMethodAccountModel? account,
    final int? loyaltyProgramId,
    final TransactionPaymentMethodLoyaltyProgramModel? loyaltyProgram,
  }) {
    return TransactionPaymentMethodModel(
      slug: slug ?? this.slug,
      isApplicable: isApplicable ?? this.isApplicable,
      applicableAmount: applicableAmount ?? this.applicableAmount,
      applicableCount: applicableCount ?? this.applicableCount,
      applicableValue: applicableValue ?? this.applicableValue,
      accountId: accountId ?? this.accountId,
      account: account ?? this.account,
      loyaltyProgramId: loyaltyProgramId ?? this.loyaltyProgramId,
      loyaltyProgram: loyaltyProgram ?? this.loyaltyProgram,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'slug': slug,
      'is_applicable': isApplicable,
      'applicable_amount': applicableAmount,
      'applicable_count': applicableCount,
      'applicable_value': applicableValue,
      'account_id': accountId,
      'account': account?.toMap(),
      'loyalty_program_id': loyaltyProgramId,
      'loyalty_program': loyaltyProgram?.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory TransactionPaymentMethodModel.fromMap(
    final Map<String, Object?> map,
  ) {
    return TransactionPaymentMethodModel(
      slug: map['slug']! as String,
      isApplicable: map['is_applicable']! as bool,
      applicableAmount: map['applicable_amount']! as int,
      applicableCount: map['applicable_count']! as int,
      applicableValue: map['applicable_value']! as int,
      accountId: map['account_id'] as int?,
      account: map['account'] == null
          ? null
          : TransactionPaymentMethodAccountModel.fromMap(
              map['account']! as Map<String, Object?>,
            ),
      loyaltyProgramId: map['loyalty_program_id'] as int?,
      loyaltyProgram: map['loyalty_program'] == null
          ? null
          : TransactionPaymentMethodLoyaltyProgramModel.fromMap(
              map['loyalty_program']! as Map<String, Object?>,
            ),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionPaymentMethodModel.fromJson(final String source) {
    return TransactionPaymentMethodModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TransactionPaymentMethodModel &&
            other.slug == slug &&
            other.isApplicable == isApplicable &&
            other.applicableAmount == applicableAmount &&
            other.applicableCount == applicableCount &&
            other.applicableValue == applicableValue &&
            other.accountId == accountId &&
            other.account == account &&
            other.loyaltyProgramId == loyaltyProgramId &&
            other.loyaltyProgram == loyaltyProgram;
  }

  @override
  int get hashCode {
    return slug.hashCode ^
        isApplicable.hashCode ^
        applicableAmount.hashCode ^
        applicableCount.hashCode ^
        applicableValue.hashCode ^
        accountId.hashCode ^
        account.hashCode ^
        loyaltyProgramId.hashCode ^
        loyaltyProgram.hashCode;
  }

  @override
  String toString() {
    return 'TransactionPaymentMethodModel(slug: $slug, '
        'isApplicable: $isApplicable, applicableAmount: $applicableAmount, '
        'applicableCount: $applicableCount, applicableValue: $applicableValue, '
        'accountId: $accountId, account: $account, '
        'loyaltyProgramId: $loyaltyProgramId, loyaltyProgram: $loyaltyProgram)';
  }
}

/// The account of the [TransactionPaymentMethodModel].
@immutable
class TransactionPaymentMethodAccountModel {
  /// The account of the [TransactionPaymentMethodModel].
  const TransactionPaymentMethodAccountModel({
    required final this.id,
    required final this.title,
    required final this.isCash,
    required final this.isDefault,
  });

  /// The id of this account in the YClients API.
  final int id;

  /// The title of this account.
  final String title;

  /// If this account is in cash.
  final bool isCash;

  /// If this account is default.
  final bool isDefault;

  /// Return the copy of this model.
  TransactionPaymentMethodAccountModel copyWith({
    final int? id,
    final String? title,
    final bool? isCash,
    final bool? isDefault,
  }) {
    return TransactionPaymentMethodAccountModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCash: isCash ?? this.isCash,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'is_cash': isCash,
      'is_default': isDefault,
    };
  }

  /// Convert the map with string keys to this model.
  factory TransactionPaymentMethodAccountModel.fromMap(
    final Map<String, Object?> map,
  ) {
    return TransactionPaymentMethodAccountModel(
      id: map['id']! as int,
      title: map['title']! as String,
      isCash: map['is_cash']! as bool,
      isDefault: map['is_default']! as bool,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionPaymentMethodAccountModel.fromJson(final String source) {
    return TransactionPaymentMethodAccountModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TransactionPaymentMethodAccountModel &&
            other.id == id &&
            other.title == title &&
            other.isCash == isCash &&
            other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ isCash.hashCode ^ isDefault.hashCode;
  }

  @override
  String toString() {
    return 'TransactionPaymentMethodAccountModel(id: $id, title: $title, '
        'isCash: $isCash, isDefault: $isDefault)';
  }
}

/// The loyalty program of the [TransactionPaymentMethodModel].
@immutable
class TransactionPaymentMethodLoyaltyProgramModel {
  /// The loyalty program of the [TransactionPaymentMethodModel].
  const TransactionPaymentMethodLoyaltyProgramModel({
    required final this.id,
    required final this.title,
    required final this.typeId,
    required final this.isValuePercent,
    required final this.type,
    required final this.chain,
  });

  /// The id of this loyalty program in the YClients API.
  final int id;

  /// The title of this loyalty program.
  final String title;

  /// The id of the type of this loyalty program.
  final int typeId;

  /// If the value of this loyalty program is percent.
  final bool isValuePercent;

  /// The type of this loyalty program.
  final TransactionPaymentMethodLoyaltyProgramExpenseModel type;

  /// The chain of this loyalty program.
  final TransactionPaymentMethodLoyaltyProgramExpenseModel chain;

  /// Return the copy of this model.
  TransactionPaymentMethodLoyaltyProgramModel copyWith({
    final int? id,
    final String? title,
    final int? typeId,
    final bool? isValuePercent,
    final TransactionPaymentMethodLoyaltyProgramExpenseModel? type,
    final TransactionPaymentMethodLoyaltyProgramExpenseModel? chain,
  }) {
    return TransactionPaymentMethodLoyaltyProgramModel(
      id: id ?? this.id,
      title: title ?? this.title,
      typeId: typeId ?? this.typeId,
      isValuePercent: isValuePercent ?? this.isValuePercent,
      type: type ?? this.type,
      chain: chain ?? this.chain,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'type_id': typeId,
      'is_value_percent': isValuePercent,
      'type': type.toMap(),
      'chain': chain.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory TransactionPaymentMethodLoyaltyProgramModel.fromMap(
    final Map<String, Object?> map,
  ) {
    return TransactionPaymentMethodLoyaltyProgramModel(
      id: map['id']! as int,
      title: map['title']! as String,
      typeId: map['type_id']! as int,
      isValuePercent: map['is_value_percent']! as bool,
      type: TransactionPaymentMethodLoyaltyProgramExpenseModel.fromMap(
        map['type']! as Map<String, Object?>,
      ),
      chain: TransactionPaymentMethodLoyaltyProgramExpenseModel.fromMap(
        map['chain']! as Map<String, Object?>,
      ),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionPaymentMethodLoyaltyProgramModel.fromJson(
    final String source,
  ) {
    return TransactionPaymentMethodLoyaltyProgramModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TransactionPaymentMethodLoyaltyProgramModel &&
            other.id == id &&
            other.title == title &&
            other.typeId == typeId &&
            other.isValuePercent == isValuePercent &&
            other.type == type &&
            other.chain == chain;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        typeId.hashCode ^
        isValuePercent.hashCode ^
        type.hashCode ^
        chain.hashCode;
  }

  @override
  String toString() {
    return 'TransactionPaymentMethodLoyaltyProgramModel(id: $id, '
        'title: $title, typeId: $typeId, isValuePercent: $isValuePercent, '
        'type: $type, chain: $chain)';
  }
}

/// The expense model of the [TransactionPaymentMethodLoyaltyProgramModel].
@immutable
class TransactionPaymentMethodLoyaltyProgramExpenseModel {
  /// The expense model of the [TransactionPaymentMethodLoyaltyProgramModel].
  const TransactionPaymentMethodLoyaltyProgramExpenseModel({
    required final this.id,
    required final this.title,
  });

  /// The id of this expense in the YClients API.
  final int id;

  /// The title of this expense.
  final String title;

  /// Return the copy of this model.
  TransactionPaymentMethodLoyaltyProgramExpenseModel copyWith({
    final int? id,
    final String? title,
  }) {
    return TransactionPaymentMethodLoyaltyProgramExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{'id': id, 'title': title};
  }

  /// Convert the map with string keys to this model.
  factory TransactionPaymentMethodLoyaltyProgramExpenseModel.fromMap(
    final Map<String, Object?> map,
  ) {
    return TransactionPaymentMethodLoyaltyProgramExpenseModel(
      id: map['id']! as int,
      title: map['title']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionPaymentMethodLoyaltyProgramExpenseModel.fromJson(
    final String source,
  ) {
    return TransactionPaymentMethodLoyaltyProgramExpenseModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TransactionPaymentMethodLoyaltyProgramExpenseModel &&
            other.id == id &&
            other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() {
    return 'TransactionPaymentMethodLoyaltyProgramExpenseModel(id: $id, '
        'title: $title)';
  }
}

/// The state model of the [TransactionModel].
@immutable
class TransactionStateModel {
  /// The state model of the [TransactionModel].
  const TransactionStateModel({
    required final this.items,
    required final this.loyaltyTransactions,
    required final this.paymentTransactions,
  });

  /// The items of this state.
  final Iterable<TransactionStateItemModel> items;

  /// The loyalty transactions of this state.
  final Iterable<dynamic> loyaltyTransactions;

  /// The payment transactions of this state
  final Iterable<TransactionStatePaymentTransactionModel> paymentTransactions;

  /// Return the copy of this model.
  TransactionStateModel copyWith({
    final Iterable<TransactionStateItemModel>? items,
    final Iterable<dynamic>? loyaltyTransactions,
    final Iterable<TransactionStatePaymentTransactionModel>?
        paymentTransactions,
  }) {
    return TransactionStateModel(
      items: items ?? this.items,
      loyaltyTransactions: loyaltyTransactions ?? this.loyaltyTransactions,
      paymentTransactions: paymentTransactions ?? this.paymentTransactions,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'items': items.map((final item) => item.toMap()).toList(growable: false),
      'loyalty_transactions': loyaltyTransactions.toList(growable: false),
      'payment_transactions': paymentTransactions
          .map((final paymentTransaction) => paymentTransaction.toMap())
          .toList(growable: false),
    };
  }

  /// Convert the map with string keys to this model.
  factory TransactionStateModel.fromMap(final Map<String, Object?> map) {
    return TransactionStateModel(
      items: (map['items']! as Iterable)
          .cast<Map<String, Object?>>()
          .map((final map) => TransactionStateItemModel.fromMap(map)),
      loyaltyTransactions: map['loyalty_transactions']! as Iterable,
      paymentTransactions: (map['payment_transactions']! as Iterable)
          .cast<Map<String, Object?>>()
          .map((final map) {
        return TransactionStatePaymentTransactionModel.fromMap(map);
      }),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionStateModel.fromJson(final String source) {
    return TransactionStateModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TransactionStateModel &&
            other.items == items &&
            other.loyaltyTransactions == loyaltyTransactions &&
            other.paymentTransactions == paymentTransactions;
  }

  @override
  int get hashCode =>
      items.hashCode ^
      loyaltyTransactions.hashCode ^
      paymentTransactions.hashCode;

  @override
  String toString() {
    return 'TransactionStateModel(items: $items, '
        'loyaltyTransactions: $loyaltyTransactions, '
        'paymentTransactions: $paymentTransactions)';
  }
}

/// The item model of the [TransactionStateModel].
@immutable
class TransactionStateItemModel {
  /// The item model of the [TransactionStateModel].
  const TransactionStateItemModel({
    required final this.id,
    required final this.type,
    required final this.title,
    required final this.amount,
    required final this.defaultCostPerUnit,
    required final this.defaultCostTotal,
    required final this.clientDiscountPercent,
    required final this.costToPayTotal,
  });

  /// The id of this item in the YClients API.
  final int id;

  /// The type of this item.
  final String type;

  /// The title of this item.
  final String title;

  /// The amount of this item.
  final int amount;

  /// The per-unit-cost of this item.
  final int defaultCostPerUnit;

  /// The default cost of this item.
  final int defaultCostTotal;

  /// The discount percent of this item.
  final int clientDiscountPercent;

  /// The total cost of this item.
  final int costToPayTotal;

  /// Return the copy of this model.
  TransactionStateItemModel copyWith({
    final int? id,
    final String? type,
    final String? title,
    final int? amount,
    final int? defaultCostPerUnit,
    final int? defaultCostTotal,
    final int? clientDiscountPercent,
    final int? costToPayTotal,
  }) {
    return TransactionStateItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      defaultCostPerUnit: defaultCostPerUnit ?? this.defaultCostPerUnit,
      defaultCostTotal: defaultCostTotal ?? this.defaultCostTotal,
      clientDiscountPercent:
          clientDiscountPercent ?? this.clientDiscountPercent,
      costToPayTotal: costToPayTotal ?? this.costToPayTotal,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'type': type,
      'title': title,
      'amount': amount,
      'default_cost_per_unit': defaultCostPerUnit,
      'default_cost_total': defaultCostTotal,
      'client_discount_percent': clientDiscountPercent,
      'cost_to_pay_total': costToPayTotal,
    };
  }

  /// Convert the map with string keys to this model.
  factory TransactionStateItemModel.fromMap(final Map<String, Object?> map) {
    return TransactionStateItemModel(
      id: map['id']! as int,
      type: map['type']! as String,
      title: map['title']! as String,
      amount: map['amount']! as int,
      defaultCostPerUnit: map['default_cost_per_unit']! as int,
      defaultCostTotal: map['default_cost_total']! as int,
      clientDiscountPercent: map['client_discount_percent']! as int,
      costToPayTotal: map['cost_to_pay_total']! as int,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionStateItemModel.fromJson(final String source) {
    return TransactionStateItemModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TransactionStateItemModel &&
            other.id == id &&
            other.type == type &&
            other.title == title &&
            other.amount == amount &&
            other.defaultCostPerUnit == defaultCostPerUnit &&
            other.defaultCostTotal == defaultCostTotal &&
            other.clientDiscountPercent == clientDiscountPercent &&
            other.costToPayTotal == costToPayTotal;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        defaultCostPerUnit.hashCode ^
        defaultCostTotal.hashCode ^
        clientDiscountPercent.hashCode ^
        costToPayTotal.hashCode;
  }

  @override
  String toString() {
    return 'TransactionStateItemModel(id: $id, type: $type, title: $title, '
        'amount: $amount, defaultCostPerUnit: $defaultCostPerUnit, '
        'defaultCostTotal: $defaultCostTotal, '
        'clientDiscountPercent: $clientDiscountPercent, '
        'costToPayTotal: $costToPayTotal)';
  }
}

/// The payment transaction model of the [TransactionStateModel].
@immutable
class TransactionStatePaymentTransactionModel {
  /// The payment transaction model of the [TransactionStateModel].
  const TransactionStatePaymentTransactionModel({
    required final this.id,
    required final this.documentId,
    required final this.saleItemId,
    required final this.saleItemType,
    required final this.expenseId,
    required final this.accountId,
    required final this.amount,
    required final this.createdAt,
    required final this.account,
    required final this.expense,
  });

  /// The id of this payment transaction in the YClients API.
  final int id;

  /// The id of the document of this payment transaction in the YClients API.
  final int documentId;

  /// The id of the sale item of this payment transaction in the YClients API.
  final int saleItemId;

  /// The type of the sale item of this payment transaction.
  final String saleItemType;

  /// The expense id of this payment transaction.
  final int expenseId;

  /// The account id of this payment transaction.
  final int accountId;

  /// The amount of this payment transaction.
  final int amount;

  /// The date and time this payment transaction was created.
  final DateTime createdAt;

  /// The account of this payment transaction.
  final TransactionPaymentMethodAccountModel account;

  /// The expense of this payment transaction.
  final TransactionPaymentMethodLoyaltyProgramExpenseModel expense;

  /// Return the copy of this model.
  TransactionStatePaymentTransactionModel copyWith({
    final int? id,
    final int? documentId,
    final int? saleItemId,
    final String? saleItemType,
    final int? expenseId,
    final int? accountId,
    final int? amount,
    final DateTime? createdAt,
    final TransactionPaymentMethodAccountModel? account,
    final TransactionPaymentMethodLoyaltyProgramExpenseModel? expense,
  }) {
    return TransactionStatePaymentTransactionModel(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      saleItemId: saleItemId ?? this.saleItemId,
      saleItemType: saleItemType ?? this.saleItemType,
      expenseId: expenseId ?? this.expenseId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      account: account ?? this.account,
      expense: expense ?? this.expense,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'document_id': documentId,
      'sale_item_id': saleItemId,
      'sale_item_type': saleItemType,
      'expense_id': expenseId,
      'account_id': accountId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'account': account.toMap(),
      'expense': expense.toMap(),
    };
  }

  /// Convert the map with string keys to this model.
  factory TransactionStatePaymentTransactionModel.fromMap(
    final Map<String, Object?> map,
  ) {
    return TransactionStatePaymentTransactionModel(
      id: map['id']! as int,
      documentId: map['document_id']! as int,
      saleItemId: map['sale_item_id']! as int,
      saleItemType: map['sale_item_type']! as String,
      expenseId: map['expense_id']! as int,
      accountId: map['account_id']! as int,
      amount: map['amount']! as int,
      createdAt: DateTime.parse(map['created_at']! as String),
      account: TransactionPaymentMethodAccountModel.fromMap(
        map['account']! as Map<String, Object?>,
      ),
      expense: TransactionPaymentMethodLoyaltyProgramExpenseModel.fromMap(
        map['expense']! as Map<String, Object?>,
      ),
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionStatePaymentTransactionModel.fromJson(
    final String source,
  ) {
    return TransactionStatePaymentTransactionModel.fromMap(
      json.decode(source) as Map<String, Object?>,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is TransactionStatePaymentTransactionModel &&
            other.id == id &&
            other.documentId == documentId &&
            other.saleItemId == saleItemId &&
            other.saleItemType == saleItemType &&
            other.expenseId == expenseId &&
            other.accountId == accountId &&
            other.amount == amount &&
            other.createdAt == createdAt &&
            other.account == account &&
            other.expense == expense;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        documentId.hashCode ^
        saleItemId.hashCode ^
        saleItemType.hashCode ^
        expenseId.hashCode ^
        accountId.hashCode ^
        amount.hashCode ^
        createdAt.hashCode ^
        account.hashCode ^
        expense.hashCode;
  }

  @override
  String toString() {
    return 'TransactionStatePaymentTransactionModel(id: $id, '
        'documentId: $documentId, saleItemId: $saleItemId, '
        'saleItemType: $saleItemType, expenseId: $expenseId, '
        'accountId: $accountId, amount: $amount, createdAt: $createdAt, '
        'account: $account, expense: $expense)';
  }
}
