import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/models_smstretching/sm_abonement_model.dart';
import 'package:stretching/models_smstretching/sm_activity_price_model.dart';
import 'package:stretching/models_smstretching/sm_gallery_model.dart';
import 'package:stretching/models_smstretching/sm_payment_model.dart';
import 'package:stretching/models_smstretching/sm_record_model.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_studio_options_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/models_smstretching/sm_user_abonement_model.dart';
import 'package:stretching/models_smstretching/sm_wishlist_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/storage_operation_model.dart';
import 'package:stretching/models_yclients/user_model.dart';
import 'package:stretching/providers/content_provider.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/secrets.dart';
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
class SMStretchingAPI extends DioForNative {
  /// The base class for working with SMStretching API.
  SMStretchingAPI._()
      : super(
          BaseOptions(
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.authorizationHeader:
                  'smstretchingstudio:$smStretchingHeaderToken'
            },
          ),
        );

  /// Adds a user in the SMStretching API.
  Future<bool> addUser(final UserModel user, final DateTime serverTime) async {
    final response = await post<String?>(
      '$smStretchingApiUrl/users/$smStretchingUrlToken/add_user',
      data: <String, Object?>{
        'phone': user.phone,
        'email': user.email,
        'date_add': serverTime.toString().split('.').first,
        // 'app_token': token,
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
  Future<DateTime?> getServerTime() async {
    final response = await post<String?>(
      '$smStretchingApiUrl/options/$smStretchingUrlToken/get_time',
    );
    final data = response.data;
    return data != null ? DateTime.tryParse(json.decode(data) as String) : null;
  }

  /// The actities price of the SMStretching API.
  Future<SMActivityPriceModel?> getActivityPrice() async {
    final response = await post<String?>(
      '$smStretchingApiUrl/options/$smStretchingUrlToken/get_price',
    );
    final data = response.data;
    return data != null ? SMActivityPriceModel.fromJson(data) : null;
  }

  /// Returns the current [userPhone]'s deposit.
  Future<int?> getUserDeposit(final String userPhone) async {
    final response = await post<String>(
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
  Future<bool> updateUserDeposit(
    final String userPhone,
    final int amount,
  ) async {
    final response = await post<String>(
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
    final response = await post<String>(
      '$smStretchingApiUrl/records/$smStretchingUrlToken/add',
      data: <String, Object?>{
        ...smRecord.toMap(post: true),
        'document_id': documentId,
      },
    );
    return response.statusCode == 200;
  }

  /// Updates this [smRecord] in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/records/{token}/edit/{record_id}
  Future<bool> editRecord(final SMRecordModel smRecord) async {
    final response = await post<String>(
      '$smStretchingApiUrl/records/$smStretchingUrlToken/edit/'
      '${smRecord.recordId}',
      data: smRecord.toMap(post: true, edit: true),
    );
    return response.statusCode == 200;
  }

  /// Get the record from [recordId] in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/records/{token}/get/{record_id}
  Future<Iterable<SMRecordModel>> getRecords({
    required final String userPhone,
    required final int recordId,
  }) async {
    final response = await post<String>(
      '$smStretchingApiUrl/records/$smStretchingUrlToken/get/$recordId',
      data: <String, Object?>{'user_phone': userPhone},
    );
    final dynamic data = json.decode(response.data!);
    if (data is! Iterable) {
      return const Iterable<SMRecordModel>.empty();
    }
    return (data.cast<Map<String, Object?>>())
        .map((final map) => SMRecordModel.fromMap(map));
  }

  /// Create a payment in SMStretching API.
  ///
  /// Returns created order's id.
  ///
  /// See: https://smstretching.ru/mobile/payment/{token}/add
  Future<int?> createPayment({
    required final int companyId,
    required final int? recordId,
    required final int? documentId,
    required final String userPhone,
  }) async {
    final response = await post<String>(
      '$smStretchingApiUrl/payment/$smStretchingUrlToken/add',
      data: <String, Object?>{
        'mobile': 1,
        'company_id': companyId,
        'user_phone': userPhone,
        if (recordId != null) 'record_id': recordId,
        if (documentId != null) 'document_id': documentId,
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
    final response = await post<String>(
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
    return (data.cast<Map<String, Object?>>())
        .map((final map) => SMPaymentModel.fromMap(map));
  }

  /// Edits a payment in SMStretching API after finishing Tinkoff [acquiring].
  ///
  /// See: https://smstretching.ru/mobile/payment/{token}/edit/{orderID}
  Future<bool> editPayment({
    required final Tuple2<InitRequest, InitResponse> acquiring,
    required final DateTime serverTime,
  }) async {
    final response = await post<String>(
      '$smStretchingApiUrl/payment/$smStretchingUrlToken/edit/'
      '${acquiring.item0.orderId}',
      data: <String, Object?>{
        'status': acquiring.item1.toJson()['Status'],
        'PaymentId': acquiring.item1.paymentId,
        'Amount': acquiring.item1.amount,
        'Email': acquiring.item0.data?['Email'],
        'Description': acquiring.item0.description,
        'Redirect': acquiring.item1.paymentURL,
        'Recurrent': 'N',
        'Token': acquiring.item0.signToken,
        'timestamp': serverTime.toString(),
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
    final response = await post<String>(
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
    required final DateTime? dateEnd,
  }) async {
    final response = await post<String>(
      '$smStretchingApiUrl/goods/$smStretchingUrlToken/add',
      data: <String, Object?>{
        'mobile': 1,
        'active': dateEnd != null ? 1 : 0,
        'abonement_id': abonementId,
        'document_id': documentId,
        'company_id': companyId,
        'date_start': createdAt.toString(),
        'phone': userPhone,
        'date_end': dateEnd.toString(),
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
    final response = await post<String>(
      '$smStretchingApiUrl/wishlist/$smStretchingUrlToken/get',
      data: <String, Object?>{'user_phone': userPhone},
    );
    final dynamic data = json.decode(response.data!);
    if (data is! Iterable) {
      return const Iterable<SMWishlistModel>.empty();
    }
    return (data.cast<Map<String, Object?>>())
        .map((final map) => SMWishlistModel.fromMap(map));
  }

  /// Create a wishlist item in the SMStretching API.
  ///
  /// See: https://smstretching.ru/mobile/wishlist/{token}/get
  Future<bool> createWishlist(final SMWishlistModel wishlist) async {
    final response = await post<String>(
      '$smStretchingApiUrl/wishlist/$smStretchingUrlToken/add',
      data: wishlist.toMap(post: true),
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
final FutureProvider<int> userDepositProvider =
    FutureProvider<int>((final ref) async {
  final userPhone = ref.watch(userProvider.select((final user) => user?.phone));
  return userPhone != null
      ? await smStretching.getUserDeposit(userPhone) ?? 0
      : 0;
});

/// The studios provider for SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/studii
final StateNotifierProvider<ContentNotifier<SMStudioModel>,
        Iterable<SMStudioModel>> smStudiosProvider =
    StateNotifierProvider<ContentNotifier<SMStudioModel>,
        Iterable<SMStudioModel>>((final ref) {
  return ContentNotifier<SMStudioModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smStudios',
    converter: smStudioConverter,
    refreshState: (final notifier) async {
      final response =
          await smStretching.get<Iterable>('$smStretchingContentUrl/studii');
      return (response.data!.cast<Map<String, Object?>>())
          .map((final map) => SMStudioModel.fromMap(map));
    },
  );
});

/// The studios options provider for SMStretching API.
///
/// See: https://smstretching.ru/mobile/options/{token}/get_all
final StateNotifierProvider<ContentNotifier<SMStudioOptionsModel>,
        Iterable<SMStudioOptionsModel>> smStudiosOptionsProvider =
    StateNotifierProvider<ContentNotifier<SMStudioOptionsModel>,
        Iterable<SMStudioOptionsModel>>((final ref) {
  return ContentNotifier<SMStudioOptionsModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smStudiosOptions',
    converter: smStudioOptionsConverter,
    refreshState: (final notifier) async {
      final response = await smStretching.post<String>(
        '$smStretchingApiUrl/options/$smStretchingUrlToken/get_all',
      );
      final data = json.decode(response.data!) as Map<String, Object?>;
      return data.entries.map((final entry) {
        return SMStudioOptionsModel.fromMap({entry.key: entry.value});
      });
    },
  );
});

/// The trainers provider for SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/shtab_v2
final StateNotifierProvider<ContentNotifier<SMTrainerModel>,
        Iterable<SMTrainerModel>> smTrainersProvider =
    StateNotifierProvider<ContentNotifier<SMTrainerModel>,
        Iterable<SMTrainerModel>>((final ref) {
  return ContentNotifier<SMTrainerModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smTrainers',
    converter: smTrainerConverter,
    refreshState: (final notifier) async {
      final response =
          await smStretching.get<String>('$smStretchingContentUrl/shtab_v2');
      return ((json.decode(response.data!) as Iterable)
              .cast<Map<String, Object?>>())
          .map((final map) => SMTrainerModel.fromMap(map));
    },
  );
});

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
      final user = ref.read(userProvider);
      if (user == null) {
        return const Iterable<SMUserAbonementModel>.empty();
      }
      final response = await smStretching.post<String>(
        '$smStretchingApiUrl/goods/$smStretchingUrlToken/get_all_user',
        data: <String, Object?>{'user_phone': user.phone},
      );
      final dynamic data = json.decode(response.data!);
      if (data is! Iterable) {
        return const Iterable<SMUserAbonementModel>.empty();
      }
      return ((json.decode(response.data!) as Iterable)
              .cast<Map<String, Object?>>())
          .map((final map) => SMUserAbonementModel.fromMap(map));
    },
  );
  ref.listen(
    userProvider.select((final user) => user?.phone),
    (final userPhone) async {
      if (userPhone == null) {
        await notifier.clear();
      } else {
        await notifier.refresh();
      }
    },
  );
  return notifier;
});

/// The abonements entities provider for SMStretching API.
///
/// See: https://smstretching.ru/mobile/goods/{token}/get_all
final StateNotifierProvider<ContentNotifier<SMAbonementModel>,
        Iterable<SMAbonementModel>> smAbonementsProvider =
    StateNotifierProvider<ContentNotifier<SMAbonementModel>,
        Iterable<SMAbonementModel>>((final ref) {
  return ContentNotifier<SMAbonementModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smAbonements',
    converter: smAbonementConverter,
    refreshInterval: const Duration(hours: 1),
    refreshState: (final notifier) async {
      final response = await smStretching.post<String>(
        '$smStretchingApiUrl/goods/$smStretchingUrlToken/get_all',
      );
      final data = json.decode(response.data!) as Map<String, Object?>;
      return data.entries.map((final entry) {
        return SMAbonementModel.fromMap({entry.key: entry.value});
      }).toList(growable: false)
        ..sort();
    },
  );
});

/// The classes gallery provider for SMStretching API.
///
/// See: https://smstretching.ru/wp-json/jet-cct/gallery_for_classes
final StateNotifierProvider<ContentNotifier<SMClassesGalleryModel>,
        Iterable<SMClassesGalleryModel>> smClassesGalleryProvider =
    StateNotifierProvider<ContentNotifier<SMClassesGalleryModel>,
        Iterable<SMClassesGalleryModel>>((final ref) {
  return ContentNotifier<SMClassesGalleryModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'smClassesGallery',
    converter: smClassesGalleryConverter,
    refreshState: (final notifier) async {
      final response = await smStretching
          .get<Iterable>('$smStretchingContentUrl/gallery_for_classes');
      return (response.data!.cast<Map<String, Object?>>())
          .map((final map) => SMClassesGalleryModel.fromMap(map));
    },
  );
});
