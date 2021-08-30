// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [RecordModel].
const RecordConverter recordConverter = RecordConverter._();

/// The converter of the [RecordModel].
class RecordConverter
    implements JsonConverter<RecordModel, Map<String, Object?>> {
  const RecordConverter._();

  @override
  RecordModel fromJson(final Map<String, Object?> data) =>
      RecordModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final RecordModel data) => data.toMap();
}

/// The user record for YClients API.
///
/// The variation of the [ActivityModel] for the user.
///
/// See: https://developers.yclients.com/ru/#operation/Получить%20записи%20пользователя
@immutable
class RecordModel {
  /// The user record for YClients API.
  ///
  /// The variation of the [ActivityModel] for the user.
  ///
  /// See: https://developers.yclients.com/ru/#operation/Получить%20записи%20пользователя
  const RecordModel({
    required final this.id,
    required final this.services,
    required final this.company,
    required final this.staff,
    required final this.clientsCount,
    required final this.date,
    required final this.datetime,
    required final this.createDate,
    required final this.comment,
    required final this.deleted,
    required final this.attendance,
    required final this.length,
    required final this.notifyBySms,
    required final this.notifyByEmail,
    required final this.masterRequested,
    required final this.online,
    required final this.apiId,
    required final this.lastChangeDate,
    required final this.prepaid,
    required final this.prepaidConfirmed,
    required final this.activityId,
  });

  /// The id of this record in the YClients API.
  final int id;

  /// The services provided for this record.
  final Iterable<RecordServiceModel> services;

  /// The company organizer of this record.
  final RecordCompanyModel company;

  /// The staff member responsible for this record.
  final RecordStaffModel staff;

  /// The count of attendants for this record.
  final int clientsCount;

  /// The date and time of this record.
  final DateTime date;

  /// The date and time of this record (in iso format).
  final DateTime datetime;

  /// The date and time this record was created.
  final DateTime createDate;

  /// The comment to this record.
  final String comment;

  /// If this record is deleted.
  final bool deleted;

  /// The status of this record:
  ///
  /// * 2: client has confirmed the record.
  /// * 1: client arrived, the [services] are finished.
  /// * 0: waiting for client.
  /// * -1: client missed to the record.
  final int attendance;

  /// The duration of this event (in seconds).
  final int length;

  /// The number of hours to notify a user by sms before the [datetime].
  final int notifyBySms;

  /// The number of hours to notify a user by email before the [datetime].
  final int notifyByEmail;

  /// If a specific staff member was assigned to this record when booking.
  final bool masterRequested;

  /// If this record was made online or by administrator.
  final bool online;

  /// The outer id of this record.
  final String apiId;

  /// The date and time of the last time this record was changed.
  final DateTime lastChangeDate;

  /// If the online payment is available for this record.
  final bool prepaid;

  /// The status of the online payment for this record.
  final bool prepaidConfirmed;

  /// The id of the activity that correspondes to this record.
  final int activityId;

  /// Return the copy of this model.
  RecordModel copyWith({
    final int? id,
    final List<RecordServiceModel>? services,
    final RecordCompanyModel? company,
    final RecordStaffModel? staff,
    final int? clientsCount,
    final DateTime? date,
    final DateTime? datetime,
    final DateTime? createDate,
    final String? comment,
    final bool? deleted,
    final int? attendance,
    final int? length,
    final int? notifyBySms,
    final int? notifyByEmail,
    final bool? masterRequested,
    final bool? online,
    final String? apiId,
    final DateTime? lastChangeDate,
    final bool? prepaid,
    final bool? prepaidConfirmed,
    final int? activityId,
  }) {
    return RecordModel(
      id: id ?? this.id,
      services: services ?? this.services,
      company: company ?? this.company,
      staff: staff ?? this.staff,
      clientsCount: clientsCount ?? this.clientsCount,
      date: date ?? this.date,
      datetime: datetime ?? this.datetime,
      createDate: createDate ?? this.createDate,
      comment: comment ?? this.comment,
      deleted: deleted ?? this.deleted,
      attendance: attendance ?? this.attendance,
      length: length ?? this.length,
      notifyBySms: notifyBySms ?? this.notifyBySms,
      notifyByEmail: notifyByEmail ?? this.notifyByEmail,
      masterRequested: masterRequested ?? this.masterRequested,
      online: online ?? this.online,
      apiId: apiId ?? this.apiId,
      lastChangeDate: lastChangeDate ?? this.lastChangeDate,
      prepaid: prepaid ?? this.prepaid,
      prepaidConfirmed: prepaidConfirmed ?? this.prepaidConfirmed,
      activityId: activityId ?? this.activityId,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'services': services.map((final service) => service.toMap()).toList(),
      'company': company.toMap(),
      'staff': staff.toMap(),
      'clients_count': clientsCount,
      'date': date.toString(),
      'datetime': dateTimeConverter.toJson(datetime),
      'create_date': dateTimeConverter.toJson(createDate),
      'comment': comment,
      'deleted': deleted,
      'attendance': attendance,
      'length': length,
      'notify_by_sms': notifyBySms,
      'notify_by_email': notifyByEmail,
      'master_requested': masterRequested,
      'online': online,
      'api_id': apiId,
      'last_change_date': dateTimeConverter.toJson(lastChangeDate),
      'prepaid': prepaid,
      'prepaid_confirmed': prepaidConfirmed,
      'activity_id': activityId,
    };
  }

  /// Convert the map with string keys to this model.
  factory RecordModel.fromMap(final Map<String, Object?> map) {
    return RecordModel(
      id: map['id']! as int,
      services: <RecordServiceModel>[
        for (final map in map['services']! as Iterable<Object?>)
          RecordServiceModel.fromMap(map! as Map<String, Object?>)
      ],
      company: RecordCompanyModel.fromMap(
        map['company']! as Map<String, Object?>,
      ),
      staff: RecordStaffModel.fromMap(map['staff']! as Map<String, Object?>),
      clientsCount: map['clients_count']! as int,
      date: dateTimeConverter.fromJson(map['date']! as String),
      datetime: dateTimeConverter.fromJson(map['datetime']! as String),
      createDate: dateTimeConverter.fromJson(map['create_date']! as String),
      comment: map['comment']! as String,
      deleted: map['deleted']! as bool,
      attendance: map['attendance']! as int,
      length: map['length']! as int,
      notifyBySms: map['notify_by_sms']! as int,
      notifyByEmail: map['notify_by_email']! as int,
      masterRequested: map['master_requested']! as bool,
      online: map['online']! as bool,
      apiId: map['api_id']! as String,
      lastChangeDate:
          dateTimeConverter.fromJson(map['last_change_date']! as String),
      prepaid: map['prepaid']! as bool,
      prepaidConfirmed: map['prepaid_confirmed']! as bool,
      activityId: map['activity_id']! as int,
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
            other.services == services &&
            other.company == company &&
            other.staff == staff &&
            other.clientsCount == clientsCount &&
            other.date == date &&
            other.datetime == datetime &&
            other.createDate == createDate &&
            other.comment == comment &&
            other.deleted == deleted &&
            other.attendance == attendance &&
            other.length == length &&
            other.notifyBySms == notifyBySms &&
            other.notifyByEmail == notifyByEmail &&
            other.masterRequested == masterRequested &&
            other.online == online &&
            other.apiId == apiId &&
            other.lastChangeDate == lastChangeDate &&
            other.prepaid == prepaid &&
            other.prepaidConfirmed == prepaidConfirmed &&
            other.activityId == activityId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        services.hashCode ^
        company.hashCode ^
        staff.hashCode ^
        clientsCount.hashCode ^
        date.hashCode ^
        datetime.hashCode ^
        createDate.hashCode ^
        comment.hashCode ^
        deleted.hashCode ^
        attendance.hashCode ^
        length.hashCode ^
        notifyBySms.hashCode ^
        notifyByEmail.hashCode ^
        masterRequested.hashCode ^
        online.hashCode ^
        apiId.hashCode ^
        lastChangeDate.hashCode ^
        prepaid.hashCode ^
        prepaidConfirmed.hashCode ^
        activityId.hashCode;
  }

  @override
  String toString() {
    return 'RecordModel(id: $id, services: $services, company: $company, '
        'staff: $staff, clientsCount: $clientsCount, date: $date, '
        'datetime: $datetime, createDate: $createDate, comment: $comment, '
        'deleted: $deleted, attendance: $attendance, length: $length, '
        'notifyBySms: $notifyBySms, notifyByEmail: $notifyByEmail, '
        'masterRequested: $masterRequested, online: $online, apiId: $apiId, '
        'lastChangeDate: $lastChangeDate, prepaid: $prepaid, '
        'prepaidConfirmed: $prepaidConfirmed, activityId: $activityId)';
  }
}

/// The company model for the [RecordModel].
@immutable
class RecordCompanyModel {
  /// The company model for the [RecordModel].
  const RecordCompanyModel({
    required final this.id,
    required final this.title,
    required final this.countryId,
    required final this.country,
    required final this.cityId,
    required final this.city,
    required final this.phone,
    required final this.phones,
    required final this.timezone,
    required final this.address,
    required final this.coordinateLat,
    required final this.coordinateLon,
    required final this.allowDeleteRecord,
    required final this.allowChangeRecord,
    required final this.site,
    required final this.currencyShortTitle,
    required final this.allowChangeRecordDelayStep,
    required final this.allowDeleteRecordDelayStep,
  });

  /// The id of this company in the YClients API.
  final int id;

  /// The title of this company.
  final String title;

  /// The id of the country where this company is from.
  final int countryId;

  /// The name of the country where this company is from.
  final String country;

  /// The id of the city where this company is from.
  final int cityId;

  /// The name of the city where this company is from.
  final String city;

  /// The phone number of this company.
  final String phone;

  /// All of the phone number of this company.
  final Iterable<String> phones;

  /// The hour of the timezone of this company.
  final int timezone;

  /// The address of this company.
  final String address;

  /// The coordinates latitude of this company.
  final double coordinateLat;

  /// The coordinates longtitude of this company.
  final double coordinateLon;

  /// If this company can be deleted.
  final bool allowDeleteRecord;

  /// If this company can be changed.
  final bool allowChangeRecord;

  /// The link to the site of this company.
  final String site;

  /// The currency currency of this company.
  final String currencyShortTitle;

  /// Disable changing this company for a specified period (in seconds).
  final int allowChangeRecordDelayStep;

  /// Disable deleting this company for a specified period (in seconds).
  final int allowDeleteRecordDelayStep;

  /// Return the copy of this model.
  RecordCompanyModel copyWith({
    final int? id,
    final String? title,
    final int? countryId,
    final String? country,
    final int? cityId,
    final String? city,
    final String? phone,
    final List<String>? phones,
    final int? timezone,
    final String? address,
    final double? coordinateLat,
    final double? coordinateLon,
    final bool? allowDeleteRecord,
    final bool? allowChangeRecord,
    final String? site,
    final String? currencyShortTitle,
    final int? allowChangeRecordDelayStep,
    final int? allowDeleteRecordDelayStep,
  }) {
    return RecordCompanyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      countryId: countryId ?? this.countryId,
      country: country ?? this.country,
      cityId: cityId ?? this.cityId,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      phones: phones ?? this.phones,
      timezone: timezone ?? this.timezone,
      address: address ?? this.address,
      coordinateLat: coordinateLat ?? this.coordinateLat,
      coordinateLon: coordinateLon ?? this.coordinateLon,
      allowDeleteRecord: allowDeleteRecord ?? this.allowDeleteRecord,
      allowChangeRecord: allowChangeRecord ?? this.allowChangeRecord,
      site: site ?? this.site,
      currencyShortTitle: currencyShortTitle ?? this.currencyShortTitle,
      allowChangeRecordDelayStep:
          allowChangeRecordDelayStep ?? this.allowChangeRecordDelayStep,
      allowDeleteRecordDelayStep:
          allowDeleteRecordDelayStep ?? this.allowDeleteRecordDelayStep,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'country_id': countryId,
      'country': country,
      'city_id': cityId,
      'city': city,
      'phone': phone,
      'phones': phones.toList(),
      'timezone': timezone,
      'address': address,
      'coordinate_lat': coordinateLat,
      'coordinate_lon': coordinateLon,
      'allow_delete_record': allowDeleteRecord,
      'allow_change_record': allowChangeRecord,
      'site': site,
      'currency_short_title': currencyShortTitle,
      'allow_change_record_delay_step': allowChangeRecordDelayStep,
      'allow_delete_record_delay_step': allowDeleteRecordDelayStep,
    };
  }

  /// Convert the map with string keys to this model.
  factory RecordCompanyModel.fromMap(final Map<String, Object?> map) {
    return RecordCompanyModel(
      id: map['id']! as int,
      title: map['title']! as String,
      countryId: map['country_id']! as int,
      country: map['country']! as String,
      cityId: map['city_id']! as int,
      city: map['city']! as String,
      phone: map['phone']! as String,
      phones: (map['phones']! as Iterable<Object?>).cast<String>(),
      timezone: map['timezone']! as int,
      address: map['address']! as String,
      coordinateLat: map['coordinate_lat']! as double,
      coordinateLon: map['coordinate_lon']! as double,
      allowDeleteRecord: map['allow_delete_record']! as bool,
      allowChangeRecord: map['allow_change_record']! as bool,
      site: map['site']! as String,
      currencyShortTitle: map['currency_short_title']! as String,
      allowChangeRecordDelayStep: map['allow_change_record_delay_step']! as int,
      allowDeleteRecordDelayStep: map['allow_delete_record_delay_step']! as int,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory RecordCompanyModel.fromJson(final String source) =>
      RecordCompanyModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is RecordCompanyModel &&
            other.id == id &&
            other.title == title &&
            other.countryId == countryId &&
            other.country == country &&
            other.cityId == cityId &&
            other.city == city &&
            other.phone == phone &&
            other.phones == phones &&
            other.timezone == timezone &&
            other.address == address &&
            other.coordinateLat == coordinateLat &&
            other.coordinateLon == coordinateLon &&
            other.allowDeleteRecord == allowDeleteRecord &&
            other.allowChangeRecord == allowChangeRecord &&
            other.site == site &&
            other.currencyShortTitle == currencyShortTitle &&
            other.allowChangeRecordDelayStep == allowChangeRecordDelayStep &&
            other.allowDeleteRecordDelayStep == allowDeleteRecordDelayStep;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        countryId.hashCode ^
        country.hashCode ^
        cityId.hashCode ^
        city.hashCode ^
        phone.hashCode ^
        phones.hashCode ^
        timezone.hashCode ^
        address.hashCode ^
        coordinateLat.hashCode ^
        coordinateLon.hashCode ^
        allowDeleteRecord.hashCode ^
        allowChangeRecord.hashCode ^
        site.hashCode ^
        currencyShortTitle.hashCode ^
        allowChangeRecordDelayStep.hashCode ^
        allowDeleteRecordDelayStep.hashCode;
  }

  @override
  String toString() {
    return 'RecordCompanyModel(id: $id, title: $title, '
        'countryId: $countryId, country: $country, cityId: $cityId, '
        'city: $city, phone: $phone, phones: $phones, timezone: $timezone, '
        'address: $address, coordinateLat: $coordinateLat, '
        'coordinateLon: $coordinateLon, allowDeleteRecord: $allowDeleteRecord, '
        'allowChangeRecord: $allowChangeRecord, site: $site, '
        'currencyShortTitle: $currencyShortTitle, '
        'allowChangeRecordDelayStep: $allowChangeRecordDelayStep, '
        'allowDeleteRecordDelayStep: $allowDeleteRecordDelayStep)';
  }
}

/// The service provided for the [RecordModel].
@immutable
class RecordServiceModel {
  /// The service provided for the [RecordModel].
  const RecordServiceModel({
    required final this.id,
    required final this.title,
    required final this.cost,
    required final this.priceMin,
    required final this.priceMax,
    required final this.discount,
    required final this.amount,
    required final this.seanceLength,
    required final this.apiId,
  });

  /// The id of this service.
  final int id;

  /// The title of this service.
  final String title;

  /// The cost of this service.
  final double cost;

  /// The minimum price of this service.
  final double priceMin;

  /// The maximum price of this service.
  final double priceMax;

  /// The discount for this service.
  final double discount;

  /// The amount of this service (in pieces).
  final int amount;

  /// The duration of this service (in seconds).
  final int seanceLength;

  /// The outer id of this service  .
  final String apiId;

  /// Return the copy of this model.
  RecordServiceModel copyWith({
    final int? id,
    final String? title,
    final double? cost,
    final double? priceMin,
    final double? priceMax,
    final double? discount,
    final int? amount,
    final int? seanceLength,
    final String? apiId,
  }) {
    return RecordServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      cost: cost ?? this.cost,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      discount: discount ?? this.discount,
      amount: amount ?? this.amount,
      seanceLength: seanceLength ?? this.seanceLength,
      apiId: apiId ?? this.apiId,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'cost': cost,
      'price_min': priceMin,
      'price_max': priceMax,
      'discount': discount,
      'amount': amount,
      'seance_length': seanceLength,
      'api_id': apiId,
    };
  }

  /// Convert the map with string keys to this model.
  factory RecordServiceModel.fromMap(final Map<String, Object?> map) {
    return RecordServiceModel(
      id: map['id']! as int,
      title: map['title']! as String,
      cost: (map['cost']! as num).toDouble(),
      priceMin: (map['price_min']! as num).toDouble(),
      priceMax: (map['price_max']! as num).toDouble(),
      discount: (map['discount']! as num).toDouble(),
      amount: map['amount']! as int,
      seanceLength: map['seance_length']! as int,
      apiId: map['api_id']! as String,
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
            other.priceMin == priceMin &&
            other.priceMax == priceMax &&
            other.discount == discount &&
            other.amount == amount &&
            other.seanceLength == seanceLength &&
            other.apiId == apiId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        cost.hashCode ^
        priceMin.hashCode ^
        priceMax.hashCode ^
        discount.hashCode ^
        amount.hashCode ^
        seanceLength.hashCode ^
        apiId.hashCode;
  }

  @override
  String toString() {
    return 'RecordServiceModel(id: $id, title: $title, cost: $cost, '
        'priceMin: $priceMin, priceMax: $priceMax, discount: $discount, '
        'amount: $amount, seanceLength: $seanceLength, apiId: $apiId)';
  }
}

/// The staff member responsible for the [RecordModel].
@immutable
class RecordStaffModel {
  /// The staff member responsible for the [RecordModel].
  const RecordStaffModel({
    required final this.id,
    required final this.name,
    required final this.specialization,
    required final this.position,
    required final this.showRating,
    required final this.rating,
    required final this.votesCount,
    required final this.avatar,
    required final this.commentsCount,
  });

  /// The id of this staff member in the YClients API.
  final int id;

  /// The name of this staff member.
  final String name;

  /// The specialization of this staff member.
  final String specialization;

  /// The position of this staff member.
  final Object? position;

  /// If this staff member's rating should be shown.
  final bool showRating;

  /// The 0-5 star rating of this staff member.
  final double rating;

  /// The count of votes fpr this staff member.
  final int votesCount;

  /// The link to the avatar of this staff member.
  final String avatar;

  /// The count of comments of this staff member.
  final int commentsCount;

  /// Return the copy of this model.
  RecordStaffModel copyWith({
    final int? id,
    final String? name,
    final String? specialization,
    final Object? position,
    final bool? showRating,
    final double? rating,
    final int? votesCount,
    final String? avatar,
    final int? commentsCount,
  }) {
    return RecordStaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      position: position ?? this.position,
      showRating: showRating ?? this.showRating,
      rating: rating ?? this.rating,
      votesCount: votesCount ?? this.votesCount,
      avatar: avatar ?? this.avatar,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'specialization': specialization,
      'position': position,
      'show_rating': boolToIntConverter.toJson(showRating),
      'rating': rating,
      'votes_count': votesCount,
      'avatar': avatar,
      'comments_count': commentsCount,
    };
  }

  /// Convert the map with string keys to this model.
  factory RecordStaffModel.fromMap(final Map<String, Object?> map) {
    return RecordStaffModel(
      id: map['id']! as int,
      name: map['name']! as String,
      specialization: map['specialization']! as String,
      position: map['position'],
      showRating: boolToIntConverter.fromJson(map['show_rating']! as int),
      rating: (map['rating']! as num).toDouble(),
      votesCount: map['votes_count']! as int,
      avatar: map['avatar']! as String,
      commentsCount: map['comments_count']! as int,
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
            other.name == name &&
            other.specialization == specialization &&
            other.position == position &&
            other.showRating == showRating &&
            other.rating == rating &&
            other.votesCount == votesCount &&
            other.avatar == avatar &&
            other.commentsCount == commentsCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        specialization.hashCode ^
        position.hashCode ^
        showRating.hashCode ^
        rating.hashCode ^
        votesCount.hashCode ^
        avatar.hashCode ^
        commentsCount.hashCode;
  }

  @override
  String toString() {
    return 'RecordStaffModel(id: $id, name: $name, '
        'specialization: $specialization, position: $position, '
        'showRating: $showRating, rating: $rating, votesCount: $votesCount, '
        'avatar: $avatar, commentsCount: $commentsCount)';
  }
}
