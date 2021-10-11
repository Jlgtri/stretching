import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:catcher/catcher.dart';
import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/const.dart';
import 'package:stretching/models/smstretching/sm_abonement_model.dart';
import 'package:stretching/models/smstretching/sm_activity_price_model.dart';
import 'package:stretching/models/smstretching/sm_advertisment_model.dart';
import 'package:stretching/models/smstretching/sm_classes_gallery_model.dart';
import 'package:stretching/models/smstretching/sm_payment_model.dart';
import 'package:stretching/models/smstretching/sm_record_model.dart';
import 'package:stretching/models/smstretching/sm_story_model.dart';
import 'package:stretching/models/smstretching/sm_studio_model.dart';
import 'package:stretching/models/smstretching/sm_studio_options_model.dart';
import 'package:stretching/models/smstretching/sm_trainer_model.dart';
import 'package:stretching/models/smstretching/sm_user_abonement_model.dart';
import 'package:stretching/models/smstretching/sm_wishlist_model.dart';
import 'package:stretching/models/yclients/activity_model.dart';
import 'package:stretching/models/yclients/storage_operation_model.dart';
import 'package:stretching/models/yclients/user_model.dart';
import 'package:stretching/models/yclients/user_record_model.dart';
import 'package:stretching/providers/content_provider.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/secrets.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/utils/logger.dart';
import 'package:stretching/widgets/error_screen.dart';
import 'package:stretching/widgets/navigation/modals/rating_picker.dart';
import 'package:tinkoff_acquiring/tinkoff_acquiring.dart';

/// The link to the SMStretching.
const String smStretchingUrl = 'https://smstretching.ru';

/// The link to the content in SMStretching API.
const String smStretchingContentUrl = '$smStretchingUrl/wp-json/jet-cct';

/// The link to the SMStretching API.
const String smStretchingApiUrl = '$smStretchingUrl/mobile';

/// The base class for working with SMStretching API.
final SMStretchingAPI smStretching = SMStretchingAPI._();

/// The base class for working with SMStretching API.
class SMStretchingAPI {
  /// The base class for working with SMStretching API.
  SMStretchingAPI._() {
    _dio = Dio(
      BaseOptions(
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              'smstretchingstudio:$smStretchingHeaderToken'
        },
        sendTimeout: 10000,
        connectTimeout: 30000,
        receiveTimeout: 30000,
      ),
    );
    _dio.interceptors.add(ConnectionInterceptor());
  }
  late final Dio _dio;

  /// Adds a user in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/users/{token}/add_user
  Future<bool> addUser({
    required final String userPhone,
    required final String userEmail,
    required final DateTime serverTime,
    final String firebaseMessagingToken = '',
  }) async {
    final response = await _dio.post<String?>(
      '$smStretchingApiUrl/users/$smStretchingUrlToken/add_user',
      data: <String, Object?>{
        'phone': userPhone,
        'email': userEmail,
        'date_add': serverTime.toString().split('.').first,
        if (firebaseMessagingToken.isNotEmpty)
          'app_token': firebaseMessagingToken,
        'type_device': kIsWeb
            ? '0'
            : Platform.isAndroid
                ? '1'
                : '2'
      },
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      return true;
    }
    final jsonData = json.decode(data) as Map<String, Object?>;
    return jsonData.containsKey('true');
  }

  /// The server time of the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/options/{token}/get_time
  Future<DateTime?> getServerTime() async {
    final response = await _dio.post<String?>(
      '$smStretchingApiUrl/options/$smStretchingUrlToken/get_time',
    );
    final data = response.data;
    return data != null ? DateTime.tryParse(json.decode(data) as String) : null;
  }

  /// The actities price of the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/options/{token}/get_price
  Future<SMActivityPriceModel?> getActivityPrice() async {
    final response = await _dio.post<String?>(
      '$smStretchingApiUrl/options/$smStretchingUrlToken/get_price',
    );
    final data = response.data;
    return data != null ? SMActivityPriceModel.fromJson(data) : null;
  }

  /// Returns the current [userPhone]'s deposit.
  ///
  /// See: https://smstretching.ru/mobile/users/{token}/get_user_deposit
  Future<int?> getUserDeposit(final String userPhone) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/users/$smStretchingUrlToken/get_user_deposit',
      data: <String, Object?>{'phone': userPhone},
    );
    final data = response.data;
    if (data != null) {
      final decodedData = json.decode(data) as Object;
      if (decodedData is int) {
        return decodedData;
      } else if (decodedData is String) {
        return int.tryParse(decodedData);
      }
    }
  }

  /// Tries to update user deposit with the specified [amount].
  ///
  /// Returns true if operation was successful and false otherwise.
  ///
  /// See: https://smstretching.ru/mobile/users/{token}/edit_user_deposit
  Future<bool> updateUserDeposit(
    final String userPhone,
    final int amount,
  ) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/users/$smStretchingUrlToken/edit_user_deposit',
      data: <String, Object?>{'phone': userPhone, 'user_deposit': amount},
    );
    return response.data?.isNotEmpty ?? false;
  }

  /// Creates a record in the SMStretching API from [smRecord].
  ///
  /// See: https://smstretching.ru/mobile/records/{token}/add
  Future<bool> createRecord({
    required final int documentId,
    required final SMRecordModel smRecord,
  }) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/records/$smStretchingUrlToken/add',
      data: <String, Object?>{
        ...smRecord.toMap(post: true),
        'document_id': documentId,
      },
    );
    logger.i(response, response.data);
    return response.statusCode == 200;
  }

  /// Updates this [smRecord] in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/records/{token}/edit/{record_id}
  Future<bool> editRecord(final SMRecordModel smRecord) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/records/$smStretchingUrlToken/edit/'
      '${smRecord.recordId}',
      data: smRecord.toMap(post: true, edit: true),
    );
    logger.i(response, response.data);
    return response.statusCode == 200;
  }

  /// Get the record from [recordId] in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/records/{token}/get/{record_id}
  Future<Iterable<SMRecordModel>> getRecords({
    required final String userPhone,
    required final int recordId,
  }) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/records/$smStretchingUrlToken/get/$recordId',
      data: <String, Object?>{'user_phone': userPhone},
    );
    final dynamic data = json.decode(response.data!);
    if (data is! Iterable) {
      return const Iterable<SMRecordModel>.empty();
    }
    return (data.cast<Map<String, Object?>>()).map(SMRecordModel.fromMap);
  }

  /// Create a payment in SMStretching API.
  ///
  /// Returns created order's id.
  ///
  /// See: https://smstretching.ru/mobile/payment/{token}/add
  Future<int?> createPayment({
    required final int companyId,
    required final int? recordId,
    required final String userPhone,
  }) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/payment/$smStretchingUrlToken/add',
      data: <String, Object?>{
        'mobile': 1,
        'company_id': companyId,
        'user_phone': userPhone,
        if (recordId != null) 'record_id': recordId,
      },
    );
    final data = json.decode(response.data!) as Map<String, Object?>;
    return data['OrderID'] as int?;
  }

  /// Get the payment from SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/payment/{token}/get
  Future<Iterable<SMPaymentModel>> getPayments({
    required final int companyId,
    required final int recordId,
    required final String userPhone,
    final bool mobile = true,
  }) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/payment/$smStretchingUrlToken/get',
      data: <String, Object?>{
        'mobile': mobile ? 1 : 0,
        'company_id': companyId,
        'record_id': recordId,
        'user_phone': userPhone,
      },
    );
    final dynamic data = json.decode(response.data!);
    if (data is! Iterable) {
      return const Iterable<SMPaymentModel>.empty();
    }
    return (data.cast<Map<String, Object?>>()).map(SMPaymentModel.fromMap);
  }

  /// Edits a payment in SMStretching API after finishing Tinkoff [acquiring].
  ///
  /// See: https://smstretching.ru/mobile/payment/{token}/edit/{orderID}
  Future<bool> editPayment({
    required final Tuple2<InitRequest, InitResponse> acquiring,
    required final DateTime serverTime,
    required final int documentId,
    required final bool isAbonement,
  }) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/payment/$smStretchingUrlToken/edit/'
      '${acquiring.item0.orderId}',
      data: <String, Object?>{
        'document_id': documentId,
        'is_abonement': isAbonement ? 1 : 0,
        'status': acquiring.item1.toJson()['Status'],
        'PaymentId': acquiring.item1.paymentId,
        'Amount': acquiring.item1.amount,
        'Email': acquiring.item0.data?['Email'],
        'Description': acquiring.item0.description,
        'Redirect': acquiring.item1.paymentURL,
        'Recurrent': 'N',
        'Token': acquiring.item0.signToken,
        'timestamp': serverTime.toString().split('.').first,
      },
    );
    return response.statusCode == 200;
  }

  /// Edits a payment status in SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/payment/{token}/edit/{orderID}
  Future<bool> editPaymentStatus({
    required final String status,
    required final int orderId,
    required final int valueId,
    required final bool abonement,
  }) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/payment/$smStretchingUrlToken/edit/$orderId',
      data: <String, Object?>{
        'status': status,
        'is_abonement': abonement ? '1' : '0',
        // if (abonement) 'document_id': valueId else
        'record_id': valueId,
      },
    );
    return response.statusCode == 200;
  }

  /// Creates abonement in the SMStretching API.
  ///
  /// - [companyId] equals [SMStudioModel.studioYId].
  /// - [documentId] equals [StorageOperationDocumentModel.id].
  /// - [abonementId] equals [SMAbonementModel.yId].
  /// - [userPhone] equals [UserModel.phone].
  /// - [createdAt] equals current server time.
  /// - [dateEnd] equals [createdAt] plus [SMAbonementModel.ySrok].
  ///
  /// See: https://smstretching.ru/mobile/goods/{token}/add
  Future<bool> createAbonement({
    required final int companyId,
    required final int documentId,
    required final int abonementId,
    required final String userPhone,
    required final DateTime createdAt,
    final DateTime? dateEnd,
  }) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/goods/$smStretchingUrlToken/add',
      data: <String, Object?>{
        'mobile': 1,
        'active': dateEnd != null ? 1 : 0,
        'abonement_id': abonementId,
        'document_id': documentId,
        'company_id': companyId,
        'date_start': createdAt.toString().split('.').first,
        'phone': userPhone,
        if (dateEnd != null) 'date_end': dateEnd.toString().split('.').first,
      },
    );
    return response.statusCode == 200;
  }

  /// Activates abonement in the SMStretching API.
  ///
  /// - [documentId] equals [StorageOperationDocumentModel.id].
  /// - [dateEnd] equals the date of activation plus active period.
  /// - [active] - activate or deactivate.
  ///
  /// See: https://smstretching.ru/mobile/goods/{token}/activate/{document_id}
  Future<bool> activateAbonement({
    required final int documentId,
    required final DateTime dateEnd,
    final bool active = true,
  }) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/goods/$smStretchingUrlToken/activate/$documentId',
      data: <String, Object?>{
        'active': active ? 1 : 0,
        'document_id': documentId,
        'date_end': dateEnd.toString().split('.').first,
      },
    );
    return response.statusCode == 200;
  }

  /// Return the wishlist items for the [userPhone] in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/wishlist/{token}/get
  Future<Iterable<SMWishlistModel>> getWishlist(
    final String userPhone,
  ) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/wishlist/$smStretchingUrlToken/get',
      data: <String, Object?>{'user_phone': userPhone},
    );
    final dynamic data = json.decode(response.data!);
    if (data is! Iterable) {
      return const Iterable<SMWishlistModel>.empty();
    }
    return (data.cast<Map<String, Object?>>()).map(SMWishlistModel.fromMap);
  }

  /// Create a wishlist item in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/wishlist/{token}/get
  Future<bool> createWishlist(final SMWishlistModel wishlist) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/wishlist/$smStretchingUrlToken/add',
      data: wishlist.toMap(post: true),
    );
    return response.statusCode == 200;
  }

  /// Edit a rating of the record item in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/records/{token}/edit_rating/{record_id}
  Future<bool> editRating({
    required final int recordId,
    required final String userPhone,
    required final int rating,
    final String comment = '',
  }) async {
    final response = await _dio.post<String>(
      '$smStretchingApiUrl/records/$smStretchingUrlToken/edit_rating/$recordId',
      data: <String, Object?>{
        'user_phone': userPhone,
        'rating': rating,
        'comment': comment,
      },
    );
    return response.statusCode == 200;
  }
}

/// The provider of the current server time.
///
/// See: https://smstretching.ru/mobile/options/{token}/get_time
final StateNotifierProvider<ServerTimeNotifier, DateTime> smServerTimeProvider =
    StateNotifierProvider<ServerTimeNotifier, DateTime>((final ref) {
  throw Exception('The provider was not initialized');
});

/// The provider of the [ActivityModel] price in the SMStretching API.
///
/// See: https://smstretching.ru/mobile/options/{token}/get_price
final Provider<SMActivityPriceModel> smActivityPriceProvider =
    Provider<SMActivityPriceModel>((final ref) {
  throw Exception('This provider was not initialised.');
});

/// The provider of the current user's deposit.
///
/// See: https://smstretching.ru/mobile/users/{token}/get_user_deposit
final FutureProvider<int> smUserDepositProvider =
    FutureProvider<int>((final ref) async {
  final userPhone = ref.watch(userProvider.select((final user) => user?.phone));
  return userPhone != null
      ? await smStretching.getUserDeposit(userPhone) ?? 0
      : 0;
});

/// The provider of the default studio id in the SMStretching API.
final FutureProvider<int> smDefaultStudioIdProvider =
    FutureProvider<int>((final ref) async {
  final response = await smStretching._dio.post<String>(
    '$smStretchingApiUrl/options/$smStretchingUrlToken/'
    'get_yclients_default_service_id',
  );
  final data = json.decode(response.data!) as Map<String, Object?>;
  return int.parse(
    (data['yclients_default_service_id']!
        as Map<String, Object?>)['option_value']! as String,
  );
});

/// The studios provider for SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/studii
final StateNotifierProvider<ContentNotifier<SMStudioModel>,
        Iterable<SMStudioModel>> smStudiosProvider =
    StateNotifierProvider<ContentNotifier<SMStudioModel>,
        Iterable<SMStudioModel>>(
  (final ref) => ContentNotifier<SMStudioModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smStudios',
    converter: smStudioConverter,
    refreshState: (final notifier) async {
      final response = await smStretching._dio
          .get<Iterable>('$smStretchingContentUrl/studii');
      return (response.data!.cast<Map<String, Object?>>())
          .map(SMStudioModel.fromMap);
    },
  ),
);

/// The studios options provider for SMStretching API.
///
/// See: https://smstretching.ru/mobile/options/{token}/get_all
final StateNotifierProvider<ContentNotifier<SMStudioOptionsModel>,
        Iterable<SMStudioOptionsModel>> smStudiosOptionsProvider =
    StateNotifierProvider<ContentNotifier<SMStudioOptionsModel>,
        Iterable<SMStudioOptionsModel>>(
  (final ref) => ContentNotifier<SMStudioOptionsModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smStudiosOptions',
    converter: smStudioOptionsConverter,
    refreshState: (final notifier) async {
      final response = await smStretching._dio.post<String>(
        '$smStretchingApiUrl/options/$smStretchingUrlToken/get_all',
      );
      final data = json.decode(response.data!) as Map<String, Object?>;
      return data.entries.map(
        (final entry) => SMStudioOptionsModel.fromMap({entry.key: entry.value}),
      );
    },
  ),
);

/// The trainers provider for SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/shtab_v2
final StateNotifierProvider<ContentNotifier<SMTrainerModel>,
        Iterable<SMTrainerModel>> smTrainersProvider =
    StateNotifierProvider<ContentNotifier<SMTrainerModel>,
        Iterable<SMTrainerModel>>(
  (final ref) => ContentNotifier<SMTrainerModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smTrainers',
    converter: smTrainerConverter,
    refreshState: (final notifier) async {
      final response = await smStretching._dio
          .get<String>('$smStretchingContentUrl/shtab_v2');
      return ((json.decode(response.data!) as Iterable)
              .cast<Map<String, Object?>>())
          .map(SMTrainerModel.fromMap);
    },
  ),
);

/// The user abonements provider for SMStretching API.
///
/// See: https://smstretching.ru/mobile/goods/{token}/get_all_user
final StateNotifierProvider<ContentNotifier<SMUserAbonementModel>,
        Iterable<SMUserAbonementModel>> smUserAbonementsProvider =
    StateNotifierProvider<ContentNotifier<SMUserAbonementModel>,
        Iterable<SMUserAbonementModel>>((final ref) {
  final notifier = ContentNotifier<SMUserAbonementModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smUserAbonements',
    converter: smUserAbonementConverter,
    refreshState: (final notifier) async {
      final userPhone = ref.read(userProvider)?.phone;
      if (userPhone == null) {
        return const Iterable<SMUserAbonementModel>.empty();
      }
      final response = await smStretching._dio.post<String>(
        '$smStretchingApiUrl/goods/$smStretchingUrlToken/get_all_user',
        data: <String, Object?>{'user_phone': userPhone},
      );
      final dynamic data = json.decode(response.data!);
      if (data is! Iterable) {
        return const Iterable<SMUserAbonementModel>.empty();
      }
      return ((json.decode(response.data!) as Iterable)
              .cast<Map<String, Object?>>())
          .map(SMUserAbonementModel.fromMap);
    },
  );
  ref.listen<bool>(
    userProvider.select((final user) => user == null),
    (final unauthorized) async =>
        unauthorized ? await notifier.clear() : await notifier.refresh(),
    fireImmediately: true,
  );
  return notifier;
});

/// The abonements entities provider for SMStretching API.
///
/// See: https://smstretching.ru/mobile/goods/{token}/get_all
final StateNotifierProvider<ContentNotifier<SMAbonementModel>,
        Iterable<SMAbonementModel>> smAbonementsProvider =
    StateNotifierProvider<ContentNotifier<SMAbonementModel>,
        Iterable<SMAbonementModel>>(
  (final ref) => ContentNotifier<SMAbonementModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smAbonements',
    converter: smAbonementConverter,
    refreshInterval: const Duration(hours: 1),
    refreshState: (final notifier) async {
      final response = await smStretching._dio.post<String>(
        '$smStretchingApiUrl/goods/$smStretchingUrlToken/get_all',
      );
      final data = json.decode(response.data!) as Map<String, Object?>;
      return data.entries
          .map(
            (final entry) => SMAbonementModel.fromMap({entry.key: entry.value}),
          )
          .toList(growable: false)
        ..sort();
    },
  ),
);

/// The classes gallery provider for SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/gallery_for_classes
final StateNotifierProvider<ContentNotifier<SMClassesGalleryModel>,
        Iterable<SMClassesGalleryModel>> smClassesGalleryProvider =
    StateNotifierProvider<ContentNotifier<SMClassesGalleryModel>,
        Iterable<SMClassesGalleryModel>>(
  (final ref) => ContentNotifier<SMClassesGalleryModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smClassesGallery',
    converter: smClassesGalleryConverter,
    refreshState: (final notifier) async {
      final response = await smStretching._dio.get<Iterable>(
        '$smStretchingContentUrl/gallery_for_classes',
      );
      return (response.data!.cast<Map<String, Object?>>())
          .map(SMClassesGalleryModel.fromMap);
    },
  ),
);

/// The provider of the advertisments from the SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/adv_banner
final StateNotifierProvider<ContentNotifier<SMAdvertismentModel>,
        Iterable<SMAdvertismentModel>> smAdvertismentsProvider =
    StateNotifierProvider<ContentNotifier<SMAdvertismentModel>,
        Iterable<SMAdvertismentModel>>(
  (final ref) => ContentNotifier<SMAdvertismentModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smAdvertisments',
    converter: smAdvertismentConverter,
    refreshState: (final notifier) async {
      final response = await smStretching._dio
          .get<Iterable>('$smStretchingContentUrl/adv_banner');
      return (response.data!.cast<Map<String, Object?>>())
          .map(SMAdvertismentModel.fromMap);
    },
  ),
);

/// The provider of the stories from the SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/stories
final StateNotifierProvider<ContentNotifier<SMStoryModel>,
        Iterable<SMStoryModel>> smStoriesProvider =
    StateNotifierProvider<ContentNotifier<SMStoryModel>,
        Iterable<SMStoryModel>>(
  (final ref) => ContentNotifier<SMStoryModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smStories',
    converter: smStoryConverter,
    refreshState: (final notifier) async {
      final response = await smStretching._dio
          .get<Iterable>('$smStretchingContentUrl/stories');
      return (response.data!.cast<Map<String, Object?>>())
          .map(SMStoryModel.fromMap);
    },
  ),
);

/// The id converter of the [UserRecordModel].
final Provider<UserRecordIdConverter> userRecordIdConverterProvider =
    Provider<UserRecordIdConverter>(UserRecordIdConverter._);

/// The id converter of the [UserRecordModel].
class UserRecordIdConverter implements JsonConverter<UserRecordModel?, int> {
  const UserRecordIdConverter._(final this._ref);
  final ProviderRefBase _ref;

  @override
  UserRecordModel? fromJson(final int id) {
    for (final userRecord in _ref.read(userRecordsProvider)) {
      if (userRecord.id == id) {
        return userRecord;
      }
    }
  }

  @override
  int toJson(final UserRecordModel? data) => data!.id;
}

/// The provider of already pushed ids for [UserRecordModel].
final StateNotifierProvider<SaveToHiveIterableNotifier<UserRecordModel, String>,
        Iterable<UserRecordModel>> pushedRecordsProvider =
    StateNotifierProvider<SaveToHiveIterableNotifier<UserRecordModel, String>,
        Iterable<UserRecordModel>>(
  (final ref) => SaveToHiveIterableNotifier<UserRecordModel, String>(
    hive: ref.watch(hiveProvider),
    saveName: 'pushed_records',
    converter: StringToIterableConverter(
      OptionalIterableConverter(ref.watch(userRecordIdConverterProvider)),
    ),
    defaultValue: const Iterable<UserRecordModel>.empty(),
  ),
);

/// The event handler for push a review screen to user when a record finishes.
class ReviewRecordsEventHandler extends WidgetsBindingObserver {
  /// The event handler for push a review screen to user when a record finishes.
  ReviewRecordsEventHandler(final this._ref);
  final ProviderRefBase _ref;

  @override
  Future<void> didChangeAppLifecycleState(final AppLifecycleState state) async {
    final userPhone = _ref.read(userProvider)?.phone;
    final navigator = Catcher.navigatorKey?.currentState;
    if (state != AppLifecycleState.resumed ||
        userPhone == null ||
        navigator == null) {
      return;
    }
    final currentTime = _ref.read(smServerTimeProvider);
    final pushedRecordsNotifier = _ref.read(pushedRecordsProvider.notifier);
    for (final userRecord in _ref.read(userRecordsProvider)) {
      final recordTime = userRecord.date.add(userRecord.length);
      if (!userRecord.deleted &&
          currentTime.isAfter(recordTime) &&
          currentTime.difference(recordTime) < maxReviewTimeout &&
          !pushedRecordsNotifier.state
              .any((final record) => record.id == userRecord.id)) {
        await pushedRecordsNotifier.add(userRecord);
        final records = await smStretching.getRecords(
          userPhone: userPhone,
          recordId: userRecord.id,
        );
        if (records.any((final record) => record.rating == 0)) {
          await navigator.push(
            MaterialPageRoute<void>(
              builder: (final context) => RatingPicker(userRecord),
            ),
          );
        }
      }
    }
  }
}
