// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The model of the storage operation in the YClients API.
///
/// See: https://api.yclients.com/api/v1/storage_operations/operation/{company_id}
@immutable
class StorageOperationModel {
  /// The model of the storage operation in the YClients API.
  ///
  /// See: https://api.yclients.com/api/v1/storage_operations/operation/{company_id}
  const StorageOperationModel({
    required final this.userId,
    required final this.companyId,
    required final this.documentId,
    required final this.typeId,
    required final this.masterId,
    required final this.clientId,
    required final this.storageId,
    required final this.date,
    required final this.accountId,
    required final this.paid,
    required final this.document,
    required final this.client,
    required final this.goodsTransactions,
    required final this.paymentTransactions,
    required final this.kkmTransactions,
  });

  /// The id of the user that created this storage operation in the
  /// YClients API.
  final int userId;

  /// The id of the company of this storage operation in the YClients API.
  final int companyId;

  /// The id of the document of this storage operation in the YClients API.
  final int documentId;

  /// The id of the type of this storage operation in the YClients API.
  final int typeId;

  /// The id of the master (cachier) of this storage operation in the
  /// YClients API.
  final int? masterId;

  /// The id of the client of this storage operation in the YClients API.
  final int? clientId;

  /// The id of the storage of this storage operation in the YClients API.
  final int storageId;

  /// The date and time this storage operation was created.
  final DateTime date;

  /// The id of the account of this storage operation in the YClients API.
  final int accountId;

  /// If this storage operation is paid.
  final bool paid;

  /// The document of this storage operation.
  final StorageOperationDocumentModel document;

  /// The client of this storage operation.
  final dynamic client;

  /// The goods transactions of this storage operation.
  final Iterable<dynamic> goodsTransactions;

  /// The payment transactions of this storage operation.
  final dynamic paymentTransactions;

  /// The kkm transactions of this storage operation.
  final Iterable<dynamic> kkmTransactions;

  /// Return the copy of this model.
  StorageOperationModel copyWith({
    final int? userId,
    final int? companyId,
    final int? documentId,
    final int? typeId,
    final int? masterId,
    final int? clientId,
    final int? storageId,
    final DateTime? date,
    final int? accountId,
    final bool? paid,
    final StorageOperationDocumentModel? document,
    final dynamic client,
    final Iterable<dynamic>? goodsTransactions,
    final dynamic paymentTransactions,
    final Iterable<dynamic>? kkmTransactions,
  }) =>
      StorageOperationModel(
        userId: userId ?? this.userId,
        companyId: companyId ?? this.companyId,
        documentId: documentId ?? this.documentId,
        typeId: typeId ?? this.typeId,
        masterId: masterId ?? this.masterId,
        clientId: clientId ?? this.clientId,
        storageId: storageId ?? this.storageId,
        date: date ?? this.date,
        accountId: accountId ?? this.accountId,
        paid: paid ?? this.paid,
        document: document ?? this.document,
        client: client ?? this.client,
        goodsTransactions: goodsTransactions ?? this.goodsTransactions,
        paymentTransactions: paymentTransactions ?? this.paymentTransactions,
        kkmTransactions: kkmTransactions ?? this.kkmTransactions,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        'user_id': userId,
        'company_id': companyId,
        'document_id': documentId,
        'type_id': typeId,
        'master_id': masterId,
        'client_id': clientId,
        'storage_id': storageId,
        'date': date.toIso8601String(),
        'account_id': accountId,
        'paid': paid,
        'document': document.toMap(),
        'client': client,
        'goods_transactions': goodsTransactions.toList(growable: false),
        'payment_transactions': paymentTransactions,
        'kkm_transactions': kkmTransactions.toList(growable: false),
      };

  /// Convert the map with string keys to this model.
  factory StorageOperationModel.fromMap(final Map<String, Object?> map) =>
      StorageOperationModel(
        userId: map['user_id']! as int,
        companyId: map['company_id']! as int,
        documentId: map['document_id']! as int,
        typeId: map['type_id']! as int,
        masterId: map['master_id'] as int?,
        clientId: map['client_id'] as int?,
        storageId: map['storage_id']! as int,
        date: DateTime.parse(map['date']! as String),
        accountId: map['account_id']! as int,
        paid: map['paid']! as bool,
        document: StorageOperationDocumentModel.fromMap(
          map['document']! as Map<String, Object?>,
        ),
        client: map['client'],
        goodsTransactions: map['goods_transactions']! as Iterable,
        paymentTransactions: map['payment_transactions'],
        kkmTransactions: map['kkm_transactions']! as Iterable,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory StorageOperationModel.fromJson(final String source) =>
      StorageOperationModel.fromMap(
        json.decode(source) as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is StorageOperationModel &&
          other.userId == userId &&
          other.companyId == companyId &&
          other.documentId == documentId &&
          other.typeId == typeId &&
          other.masterId == masterId &&
          other.clientId == clientId &&
          other.storageId == storageId &&
          other.date == date &&
          other.accountId == accountId &&
          other.paid == paid &&
          other.document == document &&
          other.client == client &&
          other.goodsTransactions == goodsTransactions &&
          other.paymentTransactions == paymentTransactions &&
          other.kkmTransactions == kkmTransactions;

  @override
  int get hashCode =>
      userId.hashCode ^
      companyId.hashCode ^
      documentId.hashCode ^
      typeId.hashCode ^
      masterId.hashCode ^
      clientId.hashCode ^
      storageId.hashCode ^
      date.hashCode ^
      accountId.hashCode ^
      paid.hashCode ^
      document.hashCode ^
      client.hashCode ^
      goodsTransactions.hashCode ^
      paymentTransactions.hashCode ^
      kkmTransactions.hashCode;

  @override
  String toString() =>
      'StorageOperationModel(userId: $userId, companyId: $companyId, '
      'documentId: $documentId, typeId: $typeId, masterId: $masterId, '
      'clientId: $clientId, storageId: $storageId, date: $date, '
      'accountId: $accountId, paid: $paid, document: $document, '
      'client: $client, goodsTransactions: $goodsTransactions, '
      'paymentTransactions: $paymentTransactions, '
      'kkmTransactions: $kkmTransactions)';
}

/// The model of the document for the [StorageOperationModel].
@immutable
class StorageOperationDocumentModel {
  /// The model of the document for the [StorageOperationModel].
  const StorageOperationDocumentModel({
    required final this.id,
    required final this.typeId,
    required final this.type,
    required final this.storageId,
    required final this.userId,
    required final this.companyId,
    required final this.number,
    required final this.comment,
    required final this.createDate,
    required final this.billPrintStatus,
    required final this.storage,
    required final this.company,
    required final this.user,
  });

  /// The id of this document in the YClients API.
  final int id;

  /// The id of the type of this document in the YClients API.
  final int typeId;

  /// The type of this document.
  final StorageOperationDocumentTypeModel type;

  /// The id of the storage of this document in the YClients API.
  final int storageId;

  /// The id of the user that created this document in the YClients API.
  final int userId;

  /// The id of the company of this document in the YClients API.
  final int companyId;

  /// The number of this document.
  final int number;

  /// The comment of this document.
  final String comment;

  /// The date and time this document was created in the YClients API.
  final DateTime createDate;

  /// If the bill for this document has already been printed.
  final bool billPrintStatus;

  /// The storage of this document.
  final StorageOperationDocumentStorageModel storage;

  /// The company of this document.
  final StorageOperationDocumentCompanyModel company;

  /// The user of this document.
  final StorageOperationDocumentUserModel user;

  /// Return the copy of this model.
  StorageOperationDocumentModel copyWith({
    final int? id,
    final int? typeId,
    final StorageOperationDocumentTypeModel? type,
    final int? storageId,
    final int? userId,
    final int? companyId,
    final int? number,
    final String? comment,
    final DateTime? createDate,
    final bool? billPrintStatus,
    final StorageOperationDocumentStorageModel? storage,
    final StorageOperationDocumentCompanyModel? company,
    final StorageOperationDocumentUserModel? user,
  }) =>
      StorageOperationDocumentModel(
        id: id ?? this.id,
        typeId: typeId ?? this.typeId,
        type: type ?? this.type,
        storageId: storageId ?? this.storageId,
        userId: userId ?? this.userId,
        companyId: companyId ?? this.companyId,
        number: number ?? this.number,
        comment: comment ?? this.comment,
        createDate: createDate ?? this.createDate,
        billPrintStatus: billPrintStatus ?? this.billPrintStatus,
        storage: storage ?? this.storage,
        company: company ?? this.company,
        user: user ?? this.user,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'type_id': typeId,
        'type': type.toMap(),
        'storage_id': storageId,
        'user_id': userId,
        'company_id': companyId,
        'number': number,
        'comment': comment,
        'create_date': createDate.toIso8601String(),
        'bill_print_status': boolToIntConverter.toJson(billPrintStatus),
        'storage': storage.toMap(),
        'company': company.toMap(),
        'user': user.toMap(),
      };

  /// Convert the map with string keys to this model.
  factory StorageOperationDocumentModel.fromMap(
    final Map<String, Object?> map,
  ) =>
      StorageOperationDocumentModel(
        id: map['id']! as int,
        typeId: map['type_id']! as int,
        type: StorageOperationDocumentTypeModel.fromMap(
          map['type']! as Map<String, Object?>,
        ),
        storageId: map['storage_id']! as int,
        userId: map['user_id']! as int,
        companyId: map['company_id']! as int,
        number: map['number']! as int,
        comment: map['comment']! as String,
        createDate: DateTime.parse(map['create_date']! as String),
        billPrintStatus:
            boolToIntConverter.fromJson(map['bill_print_status']! as int),
        storage: StorageOperationDocumentStorageModel.fromMap(
          map['storage']! as Map<String, Object?>,
        ),
        company: StorageOperationDocumentCompanyModel.fromMap(
          map['company']! as Map<String, Object?>,
        ),
        user: StorageOperationDocumentUserModel.fromMap(
          map['user']! as Map<String, Object?>,
        ),
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory StorageOperationDocumentModel.fromJson(final String source) =>
      StorageOperationDocumentModel.fromMap(
        json.decode(source) as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is StorageOperationDocumentModel &&
          other.id == id &&
          other.typeId == typeId &&
          other.type == type &&
          other.storageId == storageId &&
          other.userId == userId &&
          other.companyId == companyId &&
          other.number == number &&
          other.comment == comment &&
          other.createDate == createDate &&
          other.billPrintStatus == billPrintStatus &&
          other.storage == storage &&
          other.company == company &&
          other.user == user;

  @override
  int get hashCode =>
      id.hashCode ^
      typeId.hashCode ^
      type.hashCode ^
      storageId.hashCode ^
      userId.hashCode ^
      companyId.hashCode ^
      number.hashCode ^
      comment.hashCode ^
      createDate.hashCode ^
      billPrintStatus.hashCode ^
      storage.hashCode ^
      company.hashCode ^
      user.hashCode;

  @override
  String toString() =>
      'StorageOperationDocumentModel(id: $id, typeId: $typeId, '
      'type: $type, storageId: $storageId, userId: $userId, '
      'companyId: $companyId, number: $number, comment: $comment, '
      'createDate: $createDate, billPrintStatus: $billPrintStatus, '
      'storage: $storage, company: $company, user: $user)';
}

/// The model of the company for the [StorageOperationDocumentModel].
@immutable
class StorageOperationDocumentCompanyModel {
  /// The model of the company for the [StorageOperationDocumentModel].
  const StorageOperationDocumentCompanyModel({
    required final this.id,
    required final this.title,
    required final this.publicTitle,
    required final this.businessGroupId,
    required final this.businessTypeId,
    required final this.countryId,
    required final this.cityId,
    required final this.timezone,
    required final this.timezoneName,
    required final this.address,
    required final this.coordinateLat,
    required final this.coordinateLon,
    required final this.logo,
    required final this.zip,
    required final this.phone,
    required final this.phones,
    required final this.site,
    required final this.allowDeleteRecord,
    required final this.allowChangeRecord,
  });

  /// The id of this company in YClients API.
  final int id;

  /// The title of this company.
  final String title;

  /// The public title of this company.
  final String publicTitle;

  /// The link to logo of this company.
  final String logo;

  /// The id of the country of this company.
  final int countryId;

  /// The id of the city of this company.
  final int cityId;

  /// The phone number of this company.
  final String phone;

  /// All of the phone numbers of this company.
  final Iterable<String> phones;

  /// The time zone of this company.
  final int timezone;

  /// The time zone's name of this company.
  final String timezoneName;

  /// The address of this company.
  final String address;

  /// The coordinate latitude of this company.
  final double coordinateLat;

  /// The coordinate longtitude of this company.
  final double coordinateLon;

  /// If this company can be deleted.
  final bool allowDeleteRecord;

  /// If this company can be changed.
  final bool allowChangeRecord;

  /// The link to the site of this company.
  final String site;

  /// The zip code of this company.
  final int zip;

  final int businessGroupId;
  final int businessTypeId;

  /// Return the copy of this model.
  StorageOperationDocumentCompanyModel copyWith({
    final int? id,
    final String? title,
    final String? publicTitle,
    final String? logo,
    final int? countryId,
    final int? cityId,
    final String? phone,
    final Iterable<String>? phones,
    final int? timezone,
    final String? timezoneName,
    final String? address,
    final double? coordinateLat,
    final double? coordinateLon,
    final bool? allowDeleteRecord,
    final bool? allowChangeRecord,
    final String? site,
    final int? zip,
    final int? businessGroupId,
    final int? businessTypeId,
  }) =>
      StorageOperationDocumentCompanyModel(
        id: id ?? this.id,
        title: title ?? this.title,
        publicTitle: publicTitle ?? this.publicTitle,
        logo: logo ?? this.logo,
        countryId: countryId ?? this.countryId,
        cityId: cityId ?? this.cityId,
        phone: phone ?? this.phone,
        phones: phones ?? this.phones,
        timezone: timezone ?? this.timezone,
        timezoneName: timezoneName ?? this.timezoneName,
        address: address ?? this.address,
        coordinateLat: coordinateLat ?? this.coordinateLat,
        coordinateLon: coordinateLon ?? this.coordinateLon,
        allowDeleteRecord: allowDeleteRecord ?? this.allowDeleteRecord,
        allowChangeRecord: allowChangeRecord ?? this.allowChangeRecord,
        site: site ?? this.site,
        zip: zip ?? this.zip,
        businessGroupId: businessGroupId ?? this.businessGroupId,
        businessTypeId: businessTypeId ?? this.businessTypeId,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'title': title,
        'public_title': publicTitle,
        'business_group_id': businessGroupId,
        'business_type_id': businessTypeId,
        'country_id': countryId,
        'city_id': cityId,
        'timezone': timezone,
        'timezone_name': timezoneName,
        'address': address,
        'coordinate_lat': coordinateLat,
        'coordinate_lon': coordinateLon,
        'logo': logo,
        'zip': zip,
        'phone': phone,
        'phones': phones.toList(growable: false),
        'site': site,
        'allow_delete_record': allowDeleteRecord,
        'allow_change_record': allowChangeRecord,
      };

  /// Convert the map with string keys to this model.
  factory StorageOperationDocumentCompanyModel.fromMap(
    final Map<String, Object?> map,
  ) =>
      StorageOperationDocumentCompanyModel(
        id: map['id']! as int,
        title: map['title']! as String,
        publicTitle: map['public_title']! as String,
        businessGroupId: map['business_group_id']! as int,
        businessTypeId: map['business_type_id']! as int,
        countryId: map['country_id']! as int,
        cityId: map['city_id']! as int,
        timezone: map['timezone']! as int,
        timezoneName: map['timezone_name']! as String,
        address: map['address']! as String,
        coordinateLat: (map['coordinate_lat']! as num).toDouble(),
        coordinateLon: (map['coordinate_lon']! as num).toDouble(),
        logo: map['logo']! as String,
        zip: map['zip']! as int,
        phone: map['phone']! as String,
        phones: (map['phones']! as Iterable).cast<String>(),
        site: map['site']! as String,
        allowDeleteRecord: map['allow_delete_record']! as bool,
        allowChangeRecord: map['allow_change_record']! as bool,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory StorageOperationDocumentCompanyModel.fromJson(final String source) =>
      StorageOperationDocumentCompanyModel.fromMap(
        json.decode(source) as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is StorageOperationDocumentCompanyModel &&
          other.id == id &&
          other.title == title &&
          other.publicTitle == publicTitle &&
          other.logo == logo &&
          other.countryId == countryId &&
          other.cityId == cityId &&
          other.phone == phone &&
          other.phones == phones &&
          other.timezone == timezone &&
          other.timezoneName == timezoneName &&
          other.address == address &&
          other.coordinateLat == coordinateLat &&
          other.coordinateLon == coordinateLon &&
          other.allowDeleteRecord == allowDeleteRecord &&
          other.allowChangeRecord == allowChangeRecord &&
          other.site == site &&
          other.zip == zip &&
          other.businessGroupId == businessGroupId &&
          other.businessTypeId == businessTypeId;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      publicTitle.hashCode ^
      logo.hashCode ^
      countryId.hashCode ^
      cityId.hashCode ^
      phone.hashCode ^
      phones.hashCode ^
      timezone.hashCode ^
      timezoneName.hashCode ^
      address.hashCode ^
      coordinateLat.hashCode ^
      coordinateLon.hashCode ^
      allowDeleteRecord.hashCode ^
      allowChangeRecord.hashCode ^
      site.hashCode ^
      zip.hashCode ^
      businessGroupId.hashCode ^
      businessTypeId.hashCode;

  @override
  String toString() =>
      'StorageOperationDocumentCompanyModel(id: $id, title: $title, '
      'publicTitle: $publicTitle, logo: $logo, countryId: $countryId, '
      'cityId: $cityId, phone: $phone, phones: $phones, timezone: $timezone, '
      'timezoneName: $timezoneName, address: $address, '
      'coordinateLat: $coordinateLat, coordinateLon: $coordinateLon, '
      'allowDeleteRecord: $allowDeleteRecord, '
      'allowChangeRecord: $allowChangeRecord, site: $site, zip: $zip, '
      'businessGroupId: $businessGroupId, businessTypeId: $businessTypeId)';
}

/// The model of a storage for [StorageOperationDocumentModel].
@immutable
class StorageOperationDocumentStorageModel {
  /// The model of a storage for [StorageOperationDocumentModel].
  const StorageOperationDocumentStorageModel({
    required final this.id,
    required final this.title,
  });

  /// The id of this model in the YClients API.
  final int id;

  /// The title of this model in the YClientsAPI.
  final String title;

  /// Return the copy of this model.
  StorageOperationDocumentStorageModel copyWith({
    final int? id,
    final String? title,
  }) =>
      StorageOperationDocumentStorageModel(
        id: id ?? this.id,
        title: title ?? this.title,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{'id': id, 'title': title};

  /// Convert the map with string keys to this model.
  factory StorageOperationDocumentStorageModel.fromMap(
    final Map<String, Object?> map,
  ) =>
      StorageOperationDocumentStorageModel(
        id: map['id']! as int,
        title: map['title']! as String,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory StorageOperationDocumentStorageModel.fromJson(final String source) =>
      StorageOperationDocumentStorageModel.fromMap(
        json.decode(source) as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is StorageOperationDocumentStorageModel &&
          other.id == id &&
          other.title == title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() =>
      'StorageOperationDocumentStorageModel(id: $id, title: $title)';
}

/// The model of a type for [StorageOperationDocumentModel].
@immutable
class StorageOperationDocumentTypeModel {
  /// The model of a type for [StorageOperationDocumentModel].
  const StorageOperationDocumentTypeModel({
    required final this.id,
    required final this.title,
  });

  /// The id of this model in the YClients API.
  final int id;

  /// The title of this model in the YClientsAPI.
  final String title;

  /// Return the copy of this model.
  StorageOperationDocumentTypeModel copyWith({
    final int? id,
    final String? title,
  }) =>
      StorageOperationDocumentTypeModel(
        id: id ?? this.id,
        title: title ?? this.title,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() => <String, Object?>{'id': id, 'title': title};

  /// Convert the map with string keys to this model.
  factory StorageOperationDocumentTypeModel.fromMap(
    final Map<String, Object?> map,
  ) =>
      StorageOperationDocumentTypeModel(
        id: map['id']! as int,
        title: map['title']! as String,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory StorageOperationDocumentTypeModel.fromJson(final String source) =>
      StorageOperationDocumentTypeModel.fromMap(
        json.decode(source) as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is StorageOperationDocumentTypeModel &&
          other.id == id &&
          other.title == title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() =>
      'StorageOperationDocumentTypeModel(id: $id, title: $title)';
}

/// The model of a user for [StorageOperationDocumentModel].
@immutable
class StorageOperationDocumentUserModel {
  /// The model of a user for [StorageOperationDocumentModel].
  const StorageOperationDocumentUserModel({
    required final this.id,
    required final this.name,
    required final this.phone,
  });

  /// The id of this user in the YClients API.
  final int id;

  /// The name of this user.
  final String name;

  /// The phone number of this user.
  final String phone;

  /// Return the copy of this model.
  StorageOperationDocumentUserModel copyWith({
    final int? id,
    final String? name,
    final String? phone,
  }) =>
      StorageOperationDocumentUserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
      );

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() =>
      <String, Object?>{'id': id, 'name': name, 'phone': phone};

  /// Convert the map with string keys to this model.
  factory StorageOperationDocumentUserModel.fromMap(
    final Map<String, Object?> map,
  ) =>
      StorageOperationDocumentUserModel(
        id: map['id']! as int,
        name: map['name']! as String,
        phone: map['phone']! as String,
      );

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory StorageOperationDocumentUserModel.fromJson(final String source) =>
      StorageOperationDocumentUserModel.fromMap(
        json.decode(source) as Map<String, Object?>,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is StorageOperationDocumentUserModel &&
          other.id == id &&
          other.name == name &&
          other.phone == phone;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ phone.hashCode;

  @override
  String toString() =>
      'StorageOperationDocumentUserModel(id: $id, name: $name, '
      'phone: $phone)';
}
