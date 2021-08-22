// ignore_for_file: sort_constructors_first

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:stretching/utils/json_converters.dart';

/// The converter of the [CompanyModel].
const CompanyConverter companyConverter = CompanyConverter._();

/// The converter of the [CompanyModel].
class CompanyConverter
    implements JsonConverter<CompanyModel, Map<String, Object?>> {
  const CompanyConverter._();

  @override
  CompanyModel fromJson(final Map<String, Object?> data) =>
      CompanyModel.fromMap(data);

  @override
  Map<String, Object?> toJson(final CompanyModel data) => data.toMap();
}

/// The company model of the YClients API companies method.
///
/// See: https://yclientsru.docs.apiary.io/#reference/2/0/0
@immutable
class CompanyModel {
  /// The company model of the YClients API companies method.
  ///
  /// See: https://yclientsru.docs.apiary.io/#reference/2/0/0
  const CompanyModel({
    required final this.id,
    required final this.title,
    required final this.publicTitle,
    required final this.shortDescr,
    required final this.logo,
    required final this.countryId,
    required final this.country,
    required final this.cityId,
    required final this.city,
    required final this.active,
    required final this.phone,
    required final this.phones,
    required final this.email,
    required final this.timezone,
    required final this.timezoneName,
    required final this.schedule,
    required final this.address,
    required final this.coordinateLat,
    required final this.coordinateLon,
    required final this.appIos,
    required final this.appAndroid,
    required final this.phoneConfirmation,
    required final this.currencyShortTitle,
    required final this.nextSlot,
    required final this.remindsSmsDisabled,
    required final this.remindsSmsDefault,
    required final this.groupPriority,
    required final this.bookformGroupPriority,
    required final this.description,
    required final this.photos,
    required final this.seanceDelayStep,
    required final this.showAnyMaster,
    required final this.allowDeleteRecord,
    required final this.allowChangeRecord,
    required final this.allowChangeRecordDelayStep,
    required final this.allowDeleteRecordDelayStep,
    required final this.timetableOff,
    required final this.site,
    required final this.zip,
    required final this.businessGroupId,
    required final this.businessTypeId,
    required final this.isChargeActive,
    required final this.printBillOn,
    required final this.printBillType,
    required final this.recordTypeId,
    required final this.autoPayAccountId,
    required final this.autoPayBankAccountId,
    required final this.isAdminApp,
    required final this.pushNotificationPhoneConfirm,
    required final this.switchedToTariff,
    required final this.smsEnabled,
    required final this.activityRecordClientsCountMax,
    required final this.activityOnlineRecordClientsCountMax,
    required final this.isIndividual,
    required final this.isTipsEnabled,
    required final this.social,
    required final this.emailHoursDefault,
    required final this.isShowPrivacyPolicy,
    required final this.mainGroupId,
    required final this.mainGroup,
    required final this.bookingCommentInputName,
    required final this.bookingCommentRequired,
    required final this.bookingEmailRequired,
  });

  /// The id of this company in YClients API.
  final int id;

  /// The title of this company.
  final String title;

  /// The public title of this company.
  final String publicTitle;

  /// The description of this company.
  final String shortDescr;

  /// The link to logo of this company.
  final String logo;

  /// The id of the country of this company.
  final int countryId;

  /// The title of the country of this company.
  final String country;

  /// The id of the city of this company.
  final int cityId;

  /// The title of the city of this company.
  final String city;

  /// If this company is active for booking.
  final bool active;

  /// The phone number of this company.
  final String phone;

  /// All of the phone numbers of this company.
  final Iterable<String> phones;

  /// The email of this company.
  final String email;

  /// The time zone of this company.
  final int timezone;

  /// The time zone's name of this company.
  final String timezoneName;

  /// The working schedule of this company.
  final String schedule;

  /// The address of this company.
  final String address;

  /// The coordinate latitude of this company.
  final double coordinateLat;

  /// The coordinate longtitude of this company.
  final double coordinateLon;

  /// The link to the ios app of this company.
  final String appIos;

  /// The link to the android app of this company.
  final String appAndroid;

  /// If the user needs to confirm a phone number via sms on registration.
  final bool phoneConfirmation;

  /// The short title of the currency of this company.
  final String currencyShortTitle;

  /// Nearest available booking time.
  final DateTime? nextSlot;

  /// If company's sms service is turned off.
  final bool remindsSmsDisabled;

  /// If sms text of this company is default.
  final bool remindsSmsDefault;

  /// The more the priority, the higher the company is in the companies list.
  final int groupPriority;
  final int bookformGroupPriority;
  final String description;

  /// The links to the photos of this company.
  final Iterable<String> photos;
  final int seanceDelayStep;
  final bool showAnyMaster;

  /// If this company can be deleted.
  final bool allowDeleteRecord;

  /// If this company can be changed.
  final bool allowChangeRecord;

  /// Disable changing this company for a specified period (in seconds).
  final int allowChangeRecordDelayStep;

  /// Disable deleting this company for a specified period (in seconds).
  final int allowDeleteRecordDelayStep;

  final bool timetableOff;

  /// The link to the site of this company.
  final String site;

  /// The zip code of this company.
  final int zip;
  final int businessGroupId;
  final int businessTypeId;
  final bool isChargeActive;
  final int printBillOn;
  final String printBillType;
  final int recordTypeId;
  final int autoPayAccountId;
  final int autoPayBankAccountId;
  final int isAdminApp;
  final int pushNotificationPhoneConfirm;
  final bool switchedToTariff;
  final bool smsEnabled;
  final int activityRecordClientsCountMax;
  final int activityOnlineRecordClientsCountMax;
  final bool isIndividual;
  final bool isTipsEnabled;

  /// The links to social networks of this company.
  final CompanySocialModel social;

  /// The amount of working email hours of this company.
  final int emailHoursDefault;

  /// If the privacy policy is shown on registration of this company.
  final bool isShowPrivacyPolicy;

  /// The [mainGroup]'s id of this company.
  final int mainGroupId;

  /// The main group owner of this company.
  final CompanyMainGroupModel mainGroup;

  /// The optional comment field title.
  final String? bookingCommentInputName;

  /// If the comment is required when booking.
  final bool bookingCommentRequired;

  /// If the email is required when booking.
  final bool bookingEmailRequired;

  /// Return the copy of this model.
  CompanyModel copyWith({
    final int? id,
    final String? title,
    final String? publicTitle,
    final String? shortDescr,
    final String? logo,
    final int? countryId,
    final String? country,
    final int? cityId,
    final String? city,
    final bool? active,
    final String? phone,
    final Iterable<String>? phones,
    final String? email,
    final int? timezone,
    final String? timezoneName,
    final String? schedule,
    final String? address,
    final double? coordinateLat,
    final double? coordinateLon,
    final String? appIos,
    final String? appAndroid,
    final bool? phoneConfirmation,
    final String? currencyShortTitle,
    final DateTime? nextSlot,
    final bool? remindsSmsDisabled,
    final bool? remindsSmsDefault,
    final int? groupPriority,
    final int? bookformGroupPriority,
    final String? description,
    final Iterable<String>? photos,
    final int? seanceDelayStep,
    final bool? showAnyMaster,
    final bool? allowDeleteRecord,
    final bool? allowChangeRecord,
    final int? allowChangeRecordDelayStep,
    final int? allowDeleteRecordDelayStep,
    final bool? timetableOff,
    final String? site,
    final int? zip,
    final int? businessGroupId,
    final int? businessTypeId,
    final bool? isChargeActive,
    final int? printBillOn,
    final String? printBillType,
    final int? recordTypeId,
    final int? autoPayAccountId,
    final int? autoPayBankAccountId,
    final int? isAdminApp,
    final int? pushNotificationPhoneConfirm,
    final bool? switchedToTariff,
    final bool? smsEnabled,
    final int? activityRecordClientsCountMax,
    final int? activityOnlineRecordClientsCountMax,
    final bool? isIndividual,
    final bool? isTipsEnabled,
    final CompanySocialModel? social,
    final int? emailHoursDefault,
    final bool? isShowPrivacyPolicy,
    final int? mainGroupId,
    final CompanyMainGroupModel? mainGroup,
    final String? bookingCommentInputName,
    final bool? bookingCommentRequired,
    final bool? bookingEmailRequired,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      publicTitle: publicTitle ?? this.publicTitle,
      shortDescr: shortDescr ?? this.shortDescr,
      logo: logo ?? this.logo,
      countryId: countryId ?? this.countryId,
      country: country ?? this.country,
      cityId: cityId ?? this.cityId,
      city: city ?? this.city,
      active: active ?? this.active,
      phone: phone ?? this.phone,
      phones: phones ?? this.phones,
      email: email ?? this.email,
      timezone: timezone ?? this.timezone,
      timezoneName: timezoneName ?? this.timezoneName,
      schedule: schedule ?? this.schedule,
      address: address ?? this.address,
      coordinateLat: coordinateLat ?? this.coordinateLat,
      coordinateLon: coordinateLon ?? this.coordinateLon,
      appIos: appIos ?? this.appIos,
      appAndroid: appAndroid ?? this.appAndroid,
      phoneConfirmation: phoneConfirmation ?? this.phoneConfirmation,
      currencyShortTitle: currencyShortTitle ?? this.currencyShortTitle,
      nextSlot: nextSlot ?? this.nextSlot,
      remindsSmsDisabled: remindsSmsDisabled ?? this.remindsSmsDisabled,
      remindsSmsDefault: remindsSmsDefault ?? this.remindsSmsDefault,
      groupPriority: groupPriority ?? this.groupPriority,
      bookformGroupPriority:
          bookformGroupPriority ?? this.bookformGroupPriority,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      seanceDelayStep: seanceDelayStep ?? this.seanceDelayStep,
      showAnyMaster: showAnyMaster ?? this.showAnyMaster,
      allowDeleteRecord: allowDeleteRecord ?? this.allowDeleteRecord,
      allowChangeRecord: allowChangeRecord ?? this.allowChangeRecord,
      allowChangeRecordDelayStep:
          allowChangeRecordDelayStep ?? this.allowChangeRecordDelayStep,
      allowDeleteRecordDelayStep:
          allowDeleteRecordDelayStep ?? this.allowDeleteRecordDelayStep,
      timetableOff: timetableOff ?? this.timetableOff,
      site: site ?? this.site,
      zip: zip ?? this.zip,
      businessGroupId: businessGroupId ?? this.businessGroupId,
      businessTypeId: businessTypeId ?? this.businessTypeId,
      isChargeActive: isChargeActive ?? this.isChargeActive,
      printBillOn: printBillOn ?? this.printBillOn,
      printBillType: printBillType ?? this.printBillType,
      recordTypeId: recordTypeId ?? this.recordTypeId,
      autoPayAccountId: autoPayAccountId ?? this.autoPayAccountId,
      autoPayBankAccountId: autoPayBankAccountId ?? this.autoPayBankAccountId,
      isAdminApp: isAdminApp ?? this.isAdminApp,
      pushNotificationPhoneConfirm:
          pushNotificationPhoneConfirm ?? this.pushNotificationPhoneConfirm,
      switchedToTariff: switchedToTariff ?? this.switchedToTariff,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      activityRecordClientsCountMax:
          activityRecordClientsCountMax ?? this.activityRecordClientsCountMax,
      activityOnlineRecordClientsCountMax:
          activityOnlineRecordClientsCountMax ??
              this.activityOnlineRecordClientsCountMax,
      isIndividual: isIndividual ?? this.isIndividual,
      isTipsEnabled: isTipsEnabled ?? this.isTipsEnabled,
      social: social ?? this.social,
      emailHoursDefault: emailHoursDefault ?? this.emailHoursDefault,
      isShowPrivacyPolicy: isShowPrivacyPolicy ?? this.isShowPrivacyPolicy,
      mainGroupId: mainGroupId ?? this.mainGroupId,
      mainGroup: mainGroup ?? this.mainGroup,
      bookingCommentInputName:
          bookingCommentInputName ?? this.bookingCommentInputName,
      bookingCommentRequired:
          bookingCommentRequired ?? this.bookingCommentRequired,
      bookingEmailRequired: bookingEmailRequired ?? this.bookingEmailRequired,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'public_title': publicTitle,
      'short_descr': shortDescr,
      'logo': logo,
      'country_id': countryId,
      'country': country,
      'city_id': cityId,
      'city': city,
      'active': boolToIntConverter.toJson(active),
      'phone': phone,
      'phones': phones.toList(),
      'email': email,
      'timezone': timezone,
      'timezone_name': timezoneName,
      'schedule': schedule,
      'address': address,
      'coordinate_lat': coordinateLat,
      'coordinate_lon': coordinateLon,
      'app_ios': appIos,
      'app_android': appAndroid,
      'phone_confirmation': phoneConfirmation,
      'currency_short_title': currencyShortTitle,
      'next_slot': optionalDateTimeConverter.toJson(nextSlot),
      'reminds_sms_disabled': remindsSmsDisabled,
      'reminds_sms_default': boolToIntConverter.toJson(remindsSmsDefault),
      'group_priority': groupPriority,
      'bookform_group_priority': bookformGroupPriority,
      'description': description,
      'photos': photos.toList(),
      'seance_delay_step': seanceDelayStep,
      'show_any_master': showAnyMaster,
      'allow_delete_record': allowDeleteRecord,
      'allow_change_record': allowChangeRecord,
      'allow_change_record_delay_step': allowChangeRecordDelayStep,
      'allow_delete_record_delay_step': allowDeleteRecordDelayStep,
      'timetable_off': timetableOff,
      'site': site,
      'zip': zip,
      'business_group_id': businessGroupId,
      'business_type_id': businessTypeId,
      'is_charge_active': isChargeActive,
      'print_bill_on': printBillOn,
      'print_bill_type': printBillType,
      'record_type_id': recordTypeId,
      'auto_pay_account_id': autoPayAccountId,
      'auto_pay_bank_account_id': autoPayBankAccountId,
      'is_admin_app': isAdminApp,
      'push_notification_phone_confirm': pushNotificationPhoneConfirm,
      'switched_to_tariff': switchedToTariff,
      'sms_enabled': smsEnabled,
      'activity_record_clients_count_max': activityRecordClientsCountMax,
      'activity_online_record_clients_count_max':
          activityOnlineRecordClientsCountMax,
      'is_individual': isIndividual,
      'is_tips_enabled': isTipsEnabled,
      'social': social.toMap(),
      'email_hours_default': emailHoursDefault,
      'is_show_privacy_policy': isShowPrivacyPolicy,
      'main_group_id': mainGroupId,
      'main_group': mainGroup.toMap(),
      'booking_comment_input_name': bookingCommentInputName,
      'booking_comment_required': bookingCommentRequired,
      'booking_email_required': bookingEmailRequired,
    };
  }

  /// Convert the map with string keys to this model.
  factory CompanyModel.fromMap(final Map<String, Object?> map) {
    return CompanyModel(
      id: map['id']! as int,
      title: map['title']! as String,
      publicTitle: map['public_title']! as String,
      shortDescr: map['short_descr']! as String,
      logo: map['logo']! as String,
      countryId: map['country_id']! as int,
      country: map['country']! as String,
      cityId: map['city_id']! as int,
      city: map['city']! as String,
      active: boolToIntConverter.fromJson(map['active']! as int),
      phone: map['phone']! as String,
      phones: (map['phones']! as Iterable<Object?>).cast<String>(),
      email: map['email']! as String,
      timezone: map['timezone']! as int,
      timezoneName: map['timezone_name']! as String,
      schedule: map['schedule']! as String,
      address: map['address']! as String,
      coordinateLat: map['coordinate_lat']! as double,
      coordinateLon: map['coordinate_lon']! as double,
      appIos: map['app_ios']! as String,
      appAndroid: map['app_android']! as String,
      phoneConfirmation: map['phone_confirmation']! as bool,
      currencyShortTitle: map['currency_short_title']! as String,
      nextSlot: optionalDateTimeConverter.fromJson(map['next_slot'] as String?),
      remindsSmsDisabled: map['reminds_sms_disabled']! as bool,
      remindsSmsDefault:
          boolToIntConverter.fromJson(map['reminds_sms_default']! as int),
      groupPriority: map['group_priority']! as int,
      bookformGroupPriority: map['bookform_group_priority']! as int,
      description: map['description']! as String,
      photos: (map['photos']! as Iterable<Object?>).cast<String>(),
      seanceDelayStep: map['seance_delay_step']! as int,
      showAnyMaster: map['show_any_master']! as bool,
      allowDeleteRecord: map['allow_delete_record']! as bool,
      allowChangeRecord: map['allow_change_record']! as bool,
      allowChangeRecordDelayStep: map['allow_change_record_delay_step']! as int,
      allowDeleteRecordDelayStep: map['allow_delete_record_delay_step']! as int,
      timetableOff: map['timetable_off']! as bool,
      site: map['site']! as String,
      zip: map['zip']! as int,
      businessGroupId: map['business_group_id']! as int,
      businessTypeId: map['business_type_id']! as int,
      isChargeActive: map['is_charge_active']! as bool,
      printBillOn: map['print_bill_on']! as int,
      printBillType: map['print_bill_type']! as String,
      recordTypeId: map['record_type_id']! as int,
      autoPayAccountId: map['auto_pay_account_id']! as int,
      autoPayBankAccountId: map['auto_pay_bank_account_id']! as int,
      isAdminApp: map['is_admin_app']! as int,
      pushNotificationPhoneConfirm:
          map['push_notification_phone_confirm']! as int,
      switchedToTariff: map['switched_to_tariff']! as bool,
      smsEnabled: map['sms_enabled']! as bool,
      activityRecordClientsCountMax:
          map['activity_record_clients_count_max']! as int,
      activityOnlineRecordClientsCountMax:
          map['activity_online_record_clients_count_max']! as int,
      isIndividual: map['is_individual']! as bool,
      isTipsEnabled: map['is_tips_enabled']! as bool,
      social:
          CompanySocialModel.fromMap(map['social']! as Map<String, Object?>),
      emailHoursDefault: map['email_hours_default']! as int,
      isShowPrivacyPolicy: map['is_show_privacy_policy']! as bool,
      mainGroupId: map['main_group_id']! as int,
      mainGroup: CompanyMainGroupModel.fromMap(
        map['main_group']! as Map<String, Object?>,
      ),
      bookingCommentInputName: map['booking_comment_input_name'] as String?,
      bookingCommentRequired: map['booking_comment_required']! as bool,
      bookingEmailRequired: map['booking_email_required']! as bool,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory CompanyModel.fromJson(final String source) =>
      CompanyModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is CompanyModel &&
            other.id == id &&
            other.title == title &&
            other.publicTitle == publicTitle &&
            other.shortDescr == shortDescr &&
            other.logo == logo &&
            other.countryId == countryId &&
            other.country == country &&
            other.cityId == cityId &&
            other.city == city &&
            other.active == active &&
            other.phone == phone &&
            other.phones == phones &&
            other.email == email &&
            other.timezone == timezone &&
            other.timezoneName == timezoneName &&
            other.schedule == schedule &&
            other.address == address &&
            other.coordinateLat == coordinateLat &&
            other.coordinateLon == coordinateLon &&
            other.appIos == appIos &&
            other.appAndroid == appAndroid &&
            other.phoneConfirmation == phoneConfirmation &&
            other.currencyShortTitle == currencyShortTitle &&
            other.nextSlot == nextSlot &&
            other.remindsSmsDisabled == remindsSmsDisabled &&
            other.remindsSmsDefault == remindsSmsDefault &&
            other.groupPriority == groupPriority &&
            other.bookformGroupPriority == bookformGroupPriority &&
            other.description == description &&
            other.photos == photos &&
            other.seanceDelayStep == seanceDelayStep &&
            other.showAnyMaster == showAnyMaster &&
            other.allowDeleteRecord == allowDeleteRecord &&
            other.allowChangeRecord == allowChangeRecord &&
            other.allowChangeRecordDelayStep == allowChangeRecordDelayStep &&
            other.allowDeleteRecordDelayStep == allowDeleteRecordDelayStep &&
            other.timetableOff == timetableOff &&
            other.site == site &&
            other.zip == zip &&
            other.businessGroupId == businessGroupId &&
            other.businessTypeId == businessTypeId &&
            other.isChargeActive == isChargeActive &&
            other.printBillOn == printBillOn &&
            other.printBillType == printBillType &&
            other.recordTypeId == recordTypeId &&
            other.autoPayAccountId == autoPayAccountId &&
            other.autoPayBankAccountId == autoPayBankAccountId &&
            other.isAdminApp == isAdminApp &&
            other.pushNotificationPhoneConfirm ==
                pushNotificationPhoneConfirm &&
            other.switchedToTariff == switchedToTariff &&
            other.smsEnabled == smsEnabled &&
            other.activityRecordClientsCountMax ==
                activityRecordClientsCountMax &&
            other.activityOnlineRecordClientsCountMax ==
                activityOnlineRecordClientsCountMax &&
            other.isIndividual == isIndividual &&
            other.isTipsEnabled == isTipsEnabled &&
            other.social == social &&
            other.emailHoursDefault == emailHoursDefault &&
            other.isShowPrivacyPolicy == isShowPrivacyPolicy &&
            other.mainGroupId == mainGroupId &&
            other.mainGroup == mainGroup &&
            other.bookingCommentInputName == bookingCommentInputName &&
            other.bookingCommentRequired == bookingCommentRequired &&
            other.bookingEmailRequired == bookingEmailRequired;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        publicTitle.hashCode ^
        shortDescr.hashCode ^
        logo.hashCode ^
        countryId.hashCode ^
        country.hashCode ^
        cityId.hashCode ^
        city.hashCode ^
        active.hashCode ^
        phone.hashCode ^
        phones.hashCode ^
        email.hashCode ^
        timezone.hashCode ^
        timezoneName.hashCode ^
        schedule.hashCode ^
        address.hashCode ^
        coordinateLat.hashCode ^
        coordinateLon.hashCode ^
        appIos.hashCode ^
        appAndroid.hashCode ^
        phoneConfirmation.hashCode ^
        currencyShortTitle.hashCode ^
        nextSlot.hashCode ^
        remindsSmsDisabled.hashCode ^
        remindsSmsDefault.hashCode ^
        groupPriority.hashCode ^
        bookformGroupPriority.hashCode ^
        description.hashCode ^
        photos.hashCode ^
        seanceDelayStep.hashCode ^
        showAnyMaster.hashCode ^
        allowDeleteRecord.hashCode ^
        allowChangeRecord.hashCode ^
        allowChangeRecordDelayStep.hashCode ^
        allowDeleteRecordDelayStep.hashCode ^
        timetableOff.hashCode ^
        site.hashCode ^
        zip.hashCode ^
        businessGroupId.hashCode ^
        businessTypeId.hashCode ^
        isChargeActive.hashCode ^
        printBillOn.hashCode ^
        printBillType.hashCode ^
        recordTypeId.hashCode ^
        autoPayAccountId.hashCode ^
        autoPayBankAccountId.hashCode ^
        isAdminApp.hashCode ^
        pushNotificationPhoneConfirm.hashCode ^
        switchedToTariff.hashCode ^
        smsEnabled.hashCode ^
        activityRecordClientsCountMax.hashCode ^
        activityOnlineRecordClientsCountMax.hashCode ^
        isIndividual.hashCode ^
        isTipsEnabled.hashCode ^
        social.hashCode ^
        emailHoursDefault.hashCode ^
        isShowPrivacyPolicy.hashCode ^
        mainGroupId.hashCode ^
        mainGroup.hashCode ^
        bookingCommentInputName.hashCode ^
        bookingCommentRequired.hashCode ^
        bookingEmailRequired.hashCode;
  }

  @override
  String toString() {
    return 'CompanyModel(id: $id, title: $title, publicTitle: $publicTitle, '
        'shortDescr: $shortDescr, logo: $logo, countryId: $countryId, '
        'country: $country, cityId: $cityId, city: $city, active: $active, '
        'phone: $phone, phones: $phones, email: $email, timezone: $timezone, '
        'timezoneName: $timezoneName, schedule: $schedule, address: $address, '
        'coordinateLat: $coordinateLat, coordinateLon: $coordinateLon, '
        'appIos: $appIos, appAndroid: $appAndroid, '
        'phoneConfirmation: $phoneConfirmation, '
        'currencyShortTitle: $currencyShortTitle, nextSlot: $nextSlot, '
        'remindsSmsDisabled: $remindsSmsDisabled, '
        'remindsSmsDefault: $remindsSmsDefault, '
        'groupPriority: $groupPriority, '
        'bookformGroupPriority: $bookformGroupPriority, '
        'description: $description, photos: $photos, '
        'seanceDelayStep: $seanceDelayStep, showAnyMaster: $showAnyMaster, '
        'allowDeleteRecord: $allowDeleteRecord, '
        'allowChangeRecord: $allowChangeRecord, '
        'allowChangeRecordDelayStep: $allowChangeRecordDelayStep, '
        'allowDeleteRecordDelayStep: $allowDeleteRecordDelayStep, '
        'timetableOff: $timetableOff, site: $site, zip: $zip, '
        'businessGroupId: $businessGroupId, businessTypeId: $businessTypeId, '
        'isChargeActive: $isChargeActive, printBillOn: $printBillOn, '
        'printBillType: $printBillType, recordTypeId: $recordTypeId, '
        'autoPayAccountId: $autoPayAccountId, '
        'autoPayBankAccountId: $autoPayBankAccountId, isAdminApp: $isAdminApp, '
        'pushNotificationPhoneConfirm: $pushNotificationPhoneConfirm, '
        'switchedToTariff: $switchedToTariff, smsEnabled: $smsEnabled, '
        'activityRecordClientsCountMax: $activityRecordClientsCountMax, '
        // ignore: lines_longer_than_80_chars
        'activityOnlineRecordClientsCountMax: $activityOnlineRecordClientsCountMax, '
        'isIndividual: $isIndividual, isTipsEnabled: $isTipsEnabled, '
        'social: $social, emailHoursDefault: $emailHoursDefault, '
        'isShowPrivacyPolicy: $isShowPrivacyPolicy, mainGroupId: $mainGroupId, '
        'mainGroup: $mainGroup, '
        'bookingCommentInputName: $bookingCommentInputName, '
        'bookingCommentRequired: $bookingCommentRequired, '
        'bookingEmailRequired: $bookingEmailRequired)';
  }
}

/// The main group of the [CompanyModel].
@immutable
class CompanyMainGroupModel {
  /// The main group of the [CompanyModel].
  const CompanyMainGroupModel({
    required final this.id,
    required final this.title,
  });

  /// The id of this group.
  final int id;

  /// The title of this group.
  final String title;

  /// Return the copy of this model.
  CompanyMainGroupModel copyWith({final int? id, final String? title}) {
    return CompanyMainGroupModel(id: id ?? this.id, title: title ?? this.title);
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{'id': id, 'title': title};
  }

  /// Convert the map with string keys to this model.
  factory CompanyMainGroupModel.fromMap(final Map<String, Object?> map) {
    return CompanyMainGroupModel(
      id: map['id']! as int,
      title: map['title']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory CompanyMainGroupModel.fromJson(final String source) =>
      CompanyMainGroupModel.fromMap(
          json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is CompanyMainGroupModel &&
            other.id == id &&
            other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  String toString() => 'CompanyMainGroupModel(id: $id, title: $title)';
}

/// The links to social networks of the [CompanyModel].
@immutable
class CompanySocialModel {
  /// The links to social networks of the [CompanyModel].
  const CompanySocialModel({
    required final this.facebook,
    required final this.vk,
    required final this.instagram,
    required final this.telegram,
    required final this.whatsapp,
    required final this.viber,
  });

  /// The link to the facebook of this company.
  final String facebook;

  /// The link to the vk of this company.
  final String vk;

  /// The link to the instagram of this company.
  final String instagram;

  /// The link to the telegram of this company.
  final String telegram;

  /// The link to the whatsapp of this company.
  final String whatsapp;

  /// The link to the viber of this company.
  final String viber;

  /// Return the copy of this model.
  CompanySocialModel copyWith({
    final String? facebook,
    final String? vk,
    final String? instagram,
    final String? telegram,
    final String? whatsapp,
    final String? viber,
  }) {
    return CompanySocialModel(
      facebook: facebook ?? this.facebook,
      vk: vk ?? this.vk,
      instagram: instagram ?? this.instagram,
      telegram: telegram ?? this.telegram,
      whatsapp: whatsapp ?? this.whatsapp,
      viber: viber ?? this.viber,
    );
  }

  /// Convert this model to map with string keys.
  Map<String, Object?> toMap() {
    return <String, Object?>{
      'facebook': facebook,
      'vk': vk,
      'instagram': instagram,
      'telegram': telegram,
      'whatsapp': whatsapp,
      'viber': viber,
    };
  }

  /// Convert the map with string keys to this model.
  factory CompanySocialModel.fromMap(final Map<String, Object?> map) {
    return CompanySocialModel(
      facebook: map['facebook']! as String,
      vk: map['vk']! as String,
      instagram: map['instagram']! as String,
      telegram: map['telegram']! as String,
      whatsapp: map['whatsapp']! as String,
      viber: map['viber']! as String,
    );
  }

  /// Convert this model to a json string.
  String toJson() => json.encode(toMap());

  /// Convert the json string to this model.
  factory CompanySocialModel.fromJson(final String source) =>
      CompanySocialModel.fromMap(json.decode(source) as Map<String, Object?>);

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is CompanySocialModel &&
            other.facebook == facebook &&
            other.vk == vk &&
            other.instagram == instagram &&
            other.telegram == telegram &&
            other.whatsapp == whatsapp &&
            other.viber == viber;
  }

  @override
  int get hashCode {
    return facebook.hashCode ^
        vk.hashCode ^
        instagram.hashCode ^
        telegram.hashCode ^
        whatsapp.hashCode ^
        viber.hashCode;
  }

  @override
  String toString() {
    return 'CompanySocialModel(facebook: $facebook, vk: $vk, '
        'instagram: $instagram, telegram: $telegram, whatsapp: $whatsapp, '
        'viber: $viber)';
  }
}
