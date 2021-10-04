// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/models/yclients/good_model.dart';

/// The model of the transaction in the YClients API.
///
/// See: https://api.yclients.com/api/v1/storage_operations/goods_transactions/{company_id}
@immutable
class GoodTransactionModel {
  /// The model of the transaction in the YClients API.
  ///
  /// See: https://api.yclients.com/api/v1/storage_operations/goods_transactions/{company_id}
  const GoodTransactionModel({
    required final this.id,
    required final this.documentId,
    required final this.typeId,
    required final this.type,
    required final this.companyId,
    required final this.goodId,
    required final this.amount,
    required final this.serviceAmount,
    required final this.saleAmount,
    required final this.costPerUnit,
    required final this.discount,
    required final this.cost,
    required final this.unitId,
    required final this.serviceUnitId,
    required final this.saleUnitId,
    required final this.operationUnitType,
    required final this.storageId,
    required final this.supplierId,
    required final this.goodSpecialNumber,
    required final this.clientId,
    required final this.masterId,
    required final this.createDate,
    required final this.comment,
    required final this.deleted,
    required final this.unit,
    required final this.good,
    required final this.saleUnit,
    required final this.serviceUnit,
    required final this.storage,
    required final this.supplier,
    required final this.client,
    required final this.master,
  });

  /// The id of this transaction in the YClients API.
  final int id;

  /// The id of the document of this transaction in the YClients API.
  final int documentId;

  /// The id of the type of this transaction in the YClients API.
  final int typeId;

  /// The type of this transaction.
  final TransactionStorageModel type;

  /// The id of the company of this transaction in the YClients API.
  final int companyId;

  /// The id of the good of this transaction in the YClients API.
  final int goodId;

  /// The amount of the good of this transaction.
  final int amount;

  /// The service amount of the good of this transaction.
  final int serviceAmount;

  /// The sale amount of the good of this transaction.
  final int saleAmount;

  /// The per-unit-cost of the good of this transaction.
  final int costPerUnit;

  /// The discount of this transaction.
  final int discount;

  /// The cost of this transaction.
  final int cost;

  /// The id of the unit of this transaction in the YClients API.
  final int unitId;

  /// The id of the service unit of this transaction in the YClients API.
  final int serviceUnitId;

  /// The id of the sale unit of this transaction in the YClients API.
  final int saleUnitId;

  /// The type of the unit of this transaction.
  ///
  /// - 1 is for sale.
  /// - 2 is for write-off.
  final int operationUnitType;

  /// The id of the storage of this transaction in the YClients API.
  final int storageId;

  /// The id of the supplier of this transaction in the YClients API.
  final int supplierId;

  /// The unique number of this transaction.
  final String goodSpecialNumber;

  /// The id of the client of this transaction in the YClients API.
  final int clientId;

  /// The id of the master of this transaction in the YClients API.
  final int masterId;

  /// The date and time this transaction was created.
  final DateTime createDate;

  /// The comment for this transaction..
  final String comment;

  /// If this transaction is deleted.
  final bool deleted;

  /// The unit of this transaction.
  final TransactionUnitModel unit;

  /// the good of this transaction.
  final GoodModel good;

  /// The sale unit of this transaction.
  final TransactionUnitModel? saleUnit;

  /// The service unit of this transaction.
  final TransactionUnitModel? serviceUnit;

  /// The storage of this transaction.
  final TransactionStorageModel storage;

  /// The supplier of this transaction.
  final Iterable<dynamic> supplier;

  /// The client of this transaction.
  final TransactionClientModel client;

  /// The master of this transaction.
  final TransactionMasterModel master;

  /// Return the copy of this model.
  GoodTransactionModel copyWith({
    final int? id,
    final int? documentId,
    final int? typeId,
    final TransactionStorageModel? type,
    final int? companyId,
    final int? goodId,
    final int? amount,
    final int? serviceAmount,
    final int? saleAmount,
    final int? costPerUnit,
    final int? discount,
    final int? cost,
    final int? unitId,
    final int? serviceUnitId,
    final int? saleUnitId,
    final int? operationUnitType,
    final int? storageId,
    final int? supplierId,
    final String? goodSpecialNumber,
    final int? clientId,
    final int? masterId,
    final DateTime? createDate,
    final String? comment,
    final bool? deleted,
    final TransactionUnitModel? unit,
    final GoodModel? good,
    final TransactionUnitModel? saleUnit,
    final TransactionUnitModel? serviceUnit,
    final TransactionStorageModel? storage,
    final Iterable<dynamic>? supplier,
    final TransactionClientModel? client,
    final TransactionMasterModel? master,
  }) =>
      GoodTransactionModel(
        id: id ?? this.id,
        documentId: documentId ?? this.documentId,
        typeId: typeId ?? this.typeId,
        type: type ?? this.type,
        companyId: companyId ?? this.companyId,
        goodId: goodId ?? this.goodId,
        amount: amount ?? this.amount,
        serviceAmount: serviceAmount ?? this.serviceAmount,
        saleAmount: saleAmount ?? this.saleAmount,
        costPerUnit: costPerUnit ?? this.costPerUnit,
        discount: discount ?? this.discount,
        cost: cost ?? this.cost,
        unitId: unitId ?? this.unitId,
        serviceUnitId: serviceUnitId ?? this.serviceUnitId,
        saleUnitId: saleUnitId ?? this.saleUnitId,
        operationUnitType: operationUnitType ?? this.operationUnitType,
        storageId: storageId ?? this.storageId,
        supplierId: supplierId ?? this.supplierId,
        goodSpecialNumber: goodSpecialNumber ?? this.goodSpecialNumber,
        clientId: clientId ?? this.clientId,
        masterId: masterId ?? this.masterId,
        createDate: createDate ?? this.createDate,
        comment: comment ?? this.comment,
        deleted: deleted ?? this.deleted,
        unit: unit ?? this.unit,
        good: good ?? this.good,
        saleUnit: saleUnit ?? this.saleUnit,
        serviceUnit: serviceUnit ?? this.serviceUnit,
        storage: storage ?? this.storage,
        supplier: supplier ?? this.supplier,
        client: client ?? this.client,
        master: master ?? this.master,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'document_id': documentId,
        'type_id': typeId,
        'type': type.toMap(),
        'company_id': companyId,
        'good_id': goodId,
        'amount': amount,
        'service_amount': serviceAmount,
        'sale_amount': saleAmount,
        'cost_per_unit': costPerUnit,
        'discount': discount,
        'cost': cost,
        'unit_id': unitId,
        'service_unit_id': serviceUnitId,
        'sale_unit_id': saleUnitId,
        'operation_unit_type': operationUnitType,
        'storage_id': storageId,
        'supplier_id': supplierId,
        'good_special_number': goodSpecialNumber,
        'client_id': clientId,
        'master_id': masterId,
        'create_date': createDate.toString(),
        'comment': comment,
        'deleted': deleted,
        'unit': unit.toMap(),
        'good': good.toMap(),
        'sale_unit': saleUnit?.toMap(),
        'service_unit': serviceUnit?.toMap(),
        'storage': storage.toMap(),
        'supplier': supplier.toList(growable: false),
        'client': client.toMap(),
        'master': master.toMap(),
      };

  /// Convert the map with string keys to this model.
  factory GoodTransactionModel.fromMap(final Map<String, Object?> map) =>
      GoodTransactionModel(
        id: map['id']! as int,
        documentId: map['document_id']! as int,
        typeId: map['type_id']! as int,
        type: TransactionStorageModel.fromMap(
          map['type']! as Map<String, Object?>,
        ),
        companyId: map['company_id']! as int,
        goodId: map['good_id']! as int,
        amount: map['amount']! as int,
        serviceAmount: map['service_amount']! as int,
        saleAmount: map['sale_amount']! as int,
        costPerUnit: map['cost_per_unit']! as int,
        discount: map['discount']! as int,
        cost: map['cost']! as int,
        unitId: map['unit_id']! as int,
        serviceUnitId: map['service_unit_id']! as int,
        saleUnitId: map['sale_unit_id']! as int,
        operationUnitType: map['operation_unit_type']! as int,
        storageId: map['storage_id']! as int,
        supplierId: map['supplier_id']! as int,
        goodSpecialNumber: map['good_special_number']! as String,
        clientId: map['client_id']! as int,
        masterId: map['master_id']! as int,
        createDate: DateTime.parse(map['create_date']! as String),
        comment: map['comment']! as String,
        deleted: map['deleted']! as bool,
        unit:
            TransactionUnitModel.fromMap(map['unit']! as Map<String, Object?>),
        good: GoodModel.fromMap(map['good']! as Map<String, Object?>),
        saleUnit: map['sale_unit'] != null
            ? TransactionUnitModel.fromMap(
                map['sale_unit']! as Map<String, Object?>,
              )
            : null,
        serviceUnit: map['service_unit'] != null
            ? TransactionUnitModel.fromMap(
                map['service_unit']! as Map<String, Object?>,
              )
            : null,
        storage: TransactionStorageModel.fromMap(
          map['storage']! as Map<String, Object?>,
        ),
        supplier: map['supplier']! as Iterable,
        client: TransactionClientModel.fromMap(
          map['client']! as Map<String, Object?>,
        ),
        master: TransactionMasterModel.fromMap(
          map['master']! as Map<String, Object?>,
        ),
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory GoodTransactionModel.fromJson(final String source) =>
      GoodTransactionModel.fromMap(
        json.decode(source)! as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is GoodTransactionModel &&
          other.id == id &&
          other.documentId == documentId &&
          other.typeId == typeId &&
          other.type == type &&
          other.companyId == companyId &&
          other.goodId == goodId &&
          other.amount == amount &&
          other.serviceAmount == serviceAmount &&
          other.saleAmount == saleAmount &&
          other.costPerUnit == costPerUnit &&
          other.discount == discount &&
          other.cost == cost &&
          other.unitId == unitId &&
          other.serviceUnitId == serviceUnitId &&
          other.saleUnitId == saleUnitId &&
          other.operationUnitType == operationUnitType &&
          other.storageId == storageId &&
          other.supplierId == supplierId &&
          other.goodSpecialNumber == goodSpecialNumber &&
          other.clientId == clientId &&
          other.masterId == masterId &&
          other.createDate == createDate &&
          other.comment == comment &&
          other.deleted == deleted &&
          other.unit == unit &&
          other.good == good &&
          other.saleUnit == saleUnit &&
          other.serviceUnit == serviceUnit &&
          other.storage == storage &&
          other.supplier == supplier &&
          other.client == client &&
          other.master == master;

  @override
  int get hashCode =>
      id.hashCode ^
      documentId.hashCode ^
      typeId.hashCode ^
      type.hashCode ^
      companyId.hashCode ^
      goodId.hashCode ^
      amount.hashCode ^
      serviceAmount.hashCode ^
      saleAmount.hashCode ^
      costPerUnit.hashCode ^
      discount.hashCode ^
      cost.hashCode ^
      unitId.hashCode ^
      serviceUnitId.hashCode ^
      saleUnitId.hashCode ^
      operationUnitType.hashCode ^
      storageId.hashCode ^
      supplierId.hashCode ^
      goodSpecialNumber.hashCode ^
      clientId.hashCode ^
      masterId.hashCode ^
      createDate.hashCode ^
      comment.hashCode ^
      deleted.hashCode ^
      unit.hashCode ^
      good.hashCode ^
      saleUnit.hashCode ^
      serviceUnit.hashCode ^
      storage.hashCode ^
      supplier.hashCode ^
      client.hashCode ^
      master.hashCode;

  @override
  String toString() => 'GoodTransactionModel(id: $id, documentId: $documentId, '
      'typeId: $typeId, type: $type, companyId: $companyId, goodId: $goodId, '
      'amount: $amount, serviceAmount: $serviceAmount, '
      'saleAmount: $saleAmount, costPerUnit: $costPerUnit, '
      'discount: $discount, cost: $cost, unitId: $unitId, '
      'serviceUnitId: $serviceUnitId, saleUnitId: $saleUnitId, '
      'operationUnitType: $operationUnitType, storageId: $storageId, '
      'supplierId: $supplierId, goodSpecialNumber: $goodSpecialNumber, '
      'clientId: $clientId, masterId: $masterId, createDate: $createDate, '
      'comment: $comment, deleted: $deleted, unit: $unit, good: $good, '
      'saleUnit: $saleUnit, serviceUnit: $serviceUnit, storage: $storage, '
      'supplier: $supplier, client: $client, master: $master)';
}

/// The model of a client for [GoodTransactionModel].
@immutable
class TransactionClientModel {
  /// The model of a client for [GoodTransactionModel].
  const TransactionClientModel({
    required final this.id,
    required final this.name,
    required final this.phone,
    required final this.email,
  });

  /// The id of this client in the YClients API.
  final int id;

  /// The name of this client.
  final String name;

  /// The phone of this client.
  final String phone;

  /// The email of this client.
  final String email;

  /// Return the copy of this model.
  TransactionClientModel copyWith({
    final int? id,
    final String? name,
    final String? phone,
    final String? email,
  }) =>
      TransactionClientModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
      };

  /// Convert the map with string keys to this model.
  factory TransactionClientModel.fromMap(final Map<String, Object?> map) =>
      TransactionClientModel(
        id: map['id']! as int,
        name: map['name']! as String,
        phone: map['phone']! as String,
        email: map['email']! as String,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionClientModel.fromJson(final String source) =>
      TransactionClientModel.fromMap(
        json.decode(source)! as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is TransactionClientModel &&
          other.id == id &&
          other.name == name &&
          other.phone == phone &&
          other.email == email;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ phone.hashCode ^ email.hashCode;

  @override
  String toString() =>
      'TransactionClientModel(id: $id, name: $name, phone: $phone, '
      'email: $email)';
}

/// The model of a master for [GoodTransactionModel].
@immutable
class TransactionMasterModel {
  /// The model of a master for [GoodTransactionModel].
  const TransactionMasterModel({
    required final this.id,
    required final this.name,
  });

  /// The id of this master in the YClients API.
  final int id;

  /// The name of this master.
  final String name;

  /// Return the copy of this model.
  TransactionMasterModel copyWith({
    final int? id,
    final String? name,
  }) =>
      TransactionMasterModel(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{'id': id, 'name': name};

  /// Convert the map with string keys to this model.
  factory TransactionMasterModel.fromMap(final Map<String, Object?> map) =>
      TransactionMasterModel(
        id: map['id']! as int,
        name: map['name']! as String,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionMasterModel.fromJson(final String source) =>
      TransactionMasterModel.fromMap(
        json.decode(source)! as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is TransactionMasterModel && other.id == id && other.name == name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'TransactionMasterModel(id: $id, name: $name)';
}

/// The storage model for the [GoodTransactionModel].
@immutable
class TransactionStorageModel {
  /// The storage model for the [GoodTransactionModel].
  const TransactionStorageModel({
    required final this.id,
    required final this.title,
  });

  /// The id of this storage in the YClients API.
  final int id;

  /// The title of this storage.
  final String title;

  /// Return the copy of this model.
  TransactionStorageModel copyWith({
    final int? id,
    final String? title,
  }) =>
      TransactionStorageModel(
        id: id ?? this.id,
        title: title ?? this.title,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{'id': id, 'title': title};

  /// Convert the map with string keys to this model.
  factory TransactionStorageModel.fromMap(final Map<String, Object?> map) =>
      TransactionStorageModel(
        id: map['id']! as int,
        title: map['title']! as String,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionStorageModel.fromJson(final String source) =>
      TransactionStorageModel.fromMap(
        json.decode(source)! as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is TransactionStorageModel &&
          other.id == id &&
          other.title == title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() => 'TransactionStorageModel(id: $id, title: $title)';
}

/// The unit model for the [GoodTransactionModel].
@immutable
class TransactionUnitModel {
  /// The unit model for the [GoodTransactionModel].
  const TransactionUnitModel({
    required final this.id,
    required final this.title,
    required final this.shortTitle,
  });

  /// The id of this unit in the YClients API.
  final int id;

  /// The title of this unit.
  final String title;

  /// The short title of this unit.
  final String shortTitle;

  /// Return the copy of this model.
  TransactionUnitModel copyWith({
    final int? id,
    final String? title,
    final String? shortTitle,
  }) =>
      TransactionUnitModel(
        id: id ?? this.id,
        title: title ?? this.title,
        shortTitle: shortTitle ?? this.shortTitle,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'title': title,
        'short_title': shortTitle,
      };

  /// Convert the map with string keys to this model.
  factory TransactionUnitModel.fromMap(final Map<String, Object?> map) =>
      TransactionUnitModel(
        id: map['id']! as int,
        title: map['title']! as String,
        shortTitle: map['short_title']! as String,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory TransactionUnitModel.fromJson(final String source) =>
      TransactionUnitModel.fromMap(
        json.decode(source)! as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is TransactionUnitModel &&
          other.id == id &&
          other.title == title &&
          other.shortTitle == shortTitle;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ shortTitle.hashCode;

  @override
  String toString() => 'TransactionUnitModel(id: $id, title: $title, '
      'shortTitle: $shortTitle)';
}
