import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/models/smstretching/sm_abonement_model.dart';
import 'package:stretching/models/smstretching/sm_studio_options_model.dart';
import 'package:stretching/models/yclients/activity_model.dart';
import 'package:stretching/models/yclients/client_model.dart';
import 'package:stretching/models/yclients/company_model.dart';
import 'package:stretching/models/yclients/good_model.dart';
import 'package:stretching/models/yclients/good_transaction_model.dart';
import 'package:stretching/models/yclients/record_model.dart';
import 'package:stretching/models/yclients/storage_operation_model.dart';
import 'package:stretching/models/yclients/trainer_model.dart';
import 'package:stretching/models/yclients/transaction_model.dart';
import 'package:stretching/models/yclients/user_abonement_model.dart';
import 'package:stretching/models/yclients/user_model.dart';
import 'package:stretching/models/yclients/user_record_model.dart';
import 'package:stretching/models/yclients_response.dart';
import 'package:stretching/providers/content_provider.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/secrets.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/utils/logger.dart';
import 'package:stretching/widgets/error_screen.dart';

/// The url to the YClients Assets.
const String yClientsAssetsUrl = 'https://assets.yclients.com';

/// The url of the YClients API.
const String yClientsUrl = 'https://api.yclients.com/api/v1';

/// The base class for contacting with YClients API.
class YClientsAPI {
  /// The base class for contacting with YClients API.
  YClientsAPI._([final String? userToken]) {
    _dio = Dio(
      BaseOptions(
        responseType: ResponseType.plain,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/vnd.yclients.v2+json',
          HttpHeaders.authorizationHeader: 'Bearer $yClientsToken, '
              'User ${userToken ?? yClientsAdminToken}',
        },
        extra: const YClientsRequestExtra().toMap(),
        sendTimeout: 10000,
        connectTimeout: 30000,
        receiveTimeout: 30000,
      ),
    );
    _dio.interceptors
      ..add(ConnectionInterceptor())
      ..add(YClientsInterceptor());
  }

  late final Dio _dio;

  /// Send the phone confirmation sms code in the YClients API.
  Future<Response<YClientsResponse>> sendCode(
    final String phone,
    final int studioId,
  ) =>
      _dio.post<YClientsResponse>(
        '$yClientsUrl/book_code/$studioId',
        data: <String, Object?>{'phone': phone},
      );

  /// Verify the sent phone confirmation sms code in the YClients API.
  Future<Response<YClientsResponse>> verifyCode(
    final String phone,
    final String code,
  ) =>
      _dio.post<YClientsResponse>(
        '$yClientsUrl/user/auth',
        data: <String, Object?>{'phone': phone, 'code': code},
        options: Options(
          extra: YClientsRequestExtra<UserModel?>(
            onData: (final map) => map != null
                ? UserModel.fromMap(map as Map<String, Object?>)
                : null,
          ).toMap(),
        ),
      );

  /// Creates a record for the specified user and [activityId].
  Future<Tuple2<int, String>> bookActivity({
    required final String userName,
    required final String userPhone,
    required final String userEmail,
    required final int companyId,
    required final int activityId,
  }) async {
    final response = await _dio.post<YClientsResponse>(
      '$yClientsUrl/activity/$companyId/$activityId/book',
      data: <String, Object?>{
        'fullname': userName,
        'phone': userPhone,
        'email': userEmail,
        'type': 'mobile'
      },
    );
    final data = response.data!.data! as Map<String, Object?>;
    return Tuple2(data['id']! as int, data['hash']! as String);
  }

  /// Get a record for the specified [recordId] and [companyId].
  ///
  /// See: https://api.yclients.com/api/v1/record/{company_id}/{record_id}
  Future<RecordModel> getRecord({
    required final int companyId,
    required final int recordId,
  }) async {
    final response = await _dio.get<YClientsResponse>(
      '$yClientsUrl/record/$companyId/$recordId',
      options: Options(
        extra: const YClientsRequestExtra<Map<String, Object?>>(
          devToken: true,
        ).toMap(),
      ),
    );
    return RecordModel.fromMap(response.data!.data! as Map<String, Object?>);
  }

  /// Update the record for the specified [activityId].
  ///
  /// See: https://api.yclients.com/api/v1/record/{company_id}/{record_id}
  Future<RecordModel> updateRecord({
    required final int companyId,
    required final int recordId,
    required final int activityId,
    required final Map<String, Object?> data,
  }) async {
    final response = await _dio.put<YClientsResponse>(
      '$yClientsUrl/record/$companyId/$recordId',
      options: Options(
        extra: const YClientsRequestExtra<Map<String, Object?>>(
          devToken: true,
        ).toMap(),
      ),
      data: <String, Object?>{
        ...data,
        'activity_id': activityId,
      },
    );
    logger.i(response, response.data?.toJson());
    return RecordModel.fromMap(response.data!.data! as Map<String, Object?>);
  }

  /// Delete the record in the YClients API.
  ///
  /// [recordHash] is required if user is not authorized.
  ///
  /// See: https://api.yclients.com/api/v1/user/records/{record_id}/{record_hash}
  Future<bool> deleteRecord(
    final int recordId, [
    final String? recordHash,
  ]) async {
    final response = await _dio.delete<YClientsResponse>(
      '$yClientsUrl/user/records/$recordId/${recordHash ?? ''}',
      options: Options(
        extra: const YClientsRequestExtra(
          validate: false,
        ).toMap(),
      ),
    );
    return response.statusCode == 200;
  }

  /// Delete the [record] in the YClients API.
  ///
  /// See:
  ///   * https://api.yclients.com/api/v1/timetable/transactions/{company_id}
  ///   * https://api.yclients.com/api/v1/finance_transactions/{company_id}/{transaction_id}
  Future getTransactions(
    final UserRecordModel record,
  ) async {
    final response = await _dio.get<YClientsResponse>(
      '$yClientsUrl/timetable/transactions/${record.company.id}',
      queryParameters: <String, Object?>{'record_id': record.id},
      options: Options(
        extra: const YClientsRequestExtra<Iterable>(
          devToken: true,
        ).toMap(),
      ),
    );
    logger.v(response.data);
    // return TransactionModel.fromMap(
    //   response.data!.data! as Iterable,
    // );
  }

  /// See: https://api.yclients.com/api/v1/company/{company_id}/sale/{document_id}/payment
  Future<TransactionModel> _sale(
    final int companyId,
    final int documentId, {
    required final Map<String, Object?> data,
  }) async {
    final response = await _dio.post<YClientsResponse>(
      '$yClientsUrl/company/$companyId/sale/$documentId/payment',
      options: Options(
        extra: const YClientsRequestExtra<Map<String, Object?>>(
          devToken: true,
        ).toMap(),
      ),
      data: data,
    );
    logger.i(response, response.data?.toJson());
    return TransactionModel.fromMap(
      response.data!.data! as Map<String, Object?>,
    );
  }

  /// Sale by cash with price equal to [amount].
  ///
  /// - [documentId] is equal to [RecordDocumentModel.id] or
  /// [StorageOperationDocumentModel.id].
  /// - [accountId] is equal to [SMStudioOptionsModel.kassaId].
  ///
  /// See: https://api.yclients.com/api/v1/company/{company_id}/sale/{document_id}/payment
  Future<TransactionModel> saleByCash({
    required final int companyId,
    required final int documentId,
    required final int accountId,
    required final int amount,
  }) =>
      _sale(
        companyId,
        documentId,
        data: <String, Object?>{
          'payment': <String, Object?>{
            'method': <String, Object?>{
              'slug': 'account',
              'account_id': accountId,
            },
            'amount': amount,
          }
        },
      );

  /// Sale by abonement.
  ///
  /// - [abonementId] is equal to [SMAbonementModel.yId].
  /// - [abonementNumber] is equal to [UserAbonementModel.number].
  /// - [documentId] is equal to [RecordDocumentModel.id].
  ///
  /// See: https://api.yclients.com/api/v1/company/{company_id}/sale/{document_id}/payment
  Future<TransactionModel> saleByAbonement({
    required final int companyId,
    required final int documentId,
    required final int abonementId,
    required final String abonementNumber,
  }) =>
      _sale(
        companyId,
        documentId,
        data: <String, Object?>{
          'payment': <String, Object?>{
            'method': <String, Object?>{
              'slug': 'loyalty_abonement',
              'loyalty_abonement_id': abonementId,
            },
            'number': abonementNumber,
          }
        },
      );

  /// Changes the visit in the YClients API.
  ///
  /// - [recordId] equals [RecordModel.id].
  /// - [visitId] equals [RecordModel.visitId].
  /// - [serviceId] equals [RecordServiceModel.id].
  ///
  /// See: https://api.yclients.com/api/v1/visits/{visit_id}/{record_id}
  Future<bool> changeVisit({
    required final int recordId,
    required final int visitId,
    required final int serviceId,
    required final int regularCost,
    required final int ySaleCost,
    final int attendance = 0,
  }) async {
    final response = await _dio.put<YClientsResponse>(
      '$yClientsUrl/visits/$visitId/$recordId',
      options: Options(
        extra: const YClientsRequestExtra(devToken: true).toMap(),
      ),
      data: <String, Object?>{
        'attendance': attendance,
        'comment': 'mobile',
        'services': <Map<String, Object?>>[
          <String, Object?>{
            'id': serviceId,
            'cost': ySaleCost,
            'first_cost': regularCost,
            'record_id': recordId,
          }
        ],
      },
    );
    logger.i(response, response.data?.toJson());
    return response.data?.success ?? false;
  }

  /// Create a storage operation in the YClients API.
  ///
  /// - [companyId] equals [CompanyModel.id].
  /// - [clientId] equals [UserModel.id].
  /// - [storageId] equals [SMStudioOptionsModel.skladId].
  /// - [masterId] equals [SMStudioOptionsModel.kassirMobileId].
  /// - [goodId] equals [GoodModel.goodId].
  /// - [goodCost] equals [GoodModel.cost].
  ///
  /// See: https://api.yclients.com/api/v1/storage_operations/operation/{company_id}
  Future<StorageOperationModel> createStorageOperation({
    required final int companyId,
    required final int clientId,
    required final int storageId,
    required final int masterId,
    required final int goodId,
    required final int goodCost,
    required final DateTime serverTime,
    final String goodSpecialNumber = '',
  }) async {
    final response = await _dio.post<YClientsResponse>(
      '$yClientsUrl/storage_operations/operation/$companyId',
      options: Options(
        extra: const YClientsRequestExtra<Map<String, Object?>>(
          devToken: true,
        ).toMap(),
      ),
      data: <String, Object?>{
        'type_id': 1,
        'storage_id': storageId,
        'master_id': masterId,
        'client_id': clientId,
        'create_date': serverTime.toIso8601String(),
        'transactions': <Map<String, Object?>>[
          <String, Object?>{
            'amount': 1,
            'operation_unit_type': 1,
            'discount': 0,
            'good_id': goodId,
            'cost_per_unit': goodCost,
            'cost': goodCost,
            'master_id': masterId,
            'client_id': clientId,
            if (goodSpecialNumber.isNotEmpty)
              'good_special_number': goodSpecialNumber,
          }
        ],
      },
    );
    return StorageOperationModel.fromMap(
      response.data!.data! as Map<String, Object?>,
    );
  }

  /// Return the clients found in the company with the specified [userPhone].
  ///
  /// See: https://api.yclients.com/api/v1/company/{company_id}/clients/search
  Future<Iterable<ClientModel>> getClients({
    required final int companyId,
    required final String userPhone,
  }) async {
    final response = await _dio.post<YClientsResponse>(
      '$yClientsUrl/company/$companyId/clients/search',
      options: Options(
        extra: const YClientsRequestExtra<Map<String, Object?>>(
          devToken: true,
        ).toMap(),
      ),
      data: <String, Object?>{
        'fields': <String>[
          'id',
          'name',
          'phone',
          'email',
          'discount',
          'first_visit_date',
          'last_visit_date',
          'sold_amount',
          'visit_count'
        ],
        'filters': <Map<String, Object?>>[
          <String, Object?>{
            'type': 'quick_search',
            'state': <String, String>{'value': userPhone}
          }
        ]
      },
    );
    return (response.data!.data as Iterable? ?? const Iterable<Object>.empty())
        .cast<Map<String, Object?>>()
        .map(ClientModel.fromMap);
  }

  /// Create a client in the YClients API.
  ///
  /// See: https://api.yclients.com/api/v1/clients/{company_id}
  Future<FullClientModel> createClient({
    required final int companyId,
    required final String userPhone,
    final String name = '',
    final String email = '',
  }) async {
    final response = await _dio.post<YClientsResponse>(
      '$yClientsUrl/clients/$companyId',
      data: <String, Object?>{
        'phone': userPhone,
        'name': name.isNotEmpty ? name : userPhone,
        if (email.isNotEmpty) 'email': email,
      },
      options: Options(
        extra: const YClientsRequestExtra<Map<String, Object?>>(
          devToken: true,
        ).toMap(),
      ),
    );
    return FullClientModel.fromMap(
      response.data!.data! as Map<String, Object?>,
    );
  }

  /// Edit a client in the YClients API.
  ///
  /// See: https://api.yclients.com/api/v1/client/{company_id}/{id}
  Future<FullClientModel> editClient({
    required final int companyId,
    required final int clientId,
    required final String phone,
    required final String name,
    final String email = '',
  }) async {
    final response = await _dio.put<YClientsResponse>(
      '$yClientsUrl/client/$companyId/$clientId',
      data: <String, Object?>{
        'phone': '+$phone',
        'name': name,
        if (email.isNotEmpty) 'email': email,
      },
      options: Options(
        extra: const YClientsRequestExtra<Map<String, Object?>>(
          devToken: true,
        ).toMap(),
      ),
    );
    return FullClientModel.fromMap(
      response.data!.data! as Map<String, Object?>,
    );
  }

  /// Create a transaction in the YClients API.
  ///
  /// - [companyId] equals [CompanyModel.id].
  /// - [masterId] equals [SMStudioOptionsModel.kassirMobileId].
  /// - [clientId] equals [UserModel.id].
  /// - [goodId] equals [GoodModel.goodId].
  /// - [goodCost] equals [GoodModel.cost].
  /// - [documentId] equals [StorageOperationDocumentModel.id].
  ///
  /// See: https://api.yclients.com/api/v1/storage_operations/goods_transactions/{company_id}
  Future<GoodTransactionModel> createTransaction({
    required final int companyId,
    required final int masterId,
    required final int clientId,
    required final int goodId,
    required final int goodCost,
    required final String goodSpecialNumber,
    required final int documentId,
  }) async {
    final response = await _dio.post<YClientsResponse>(
      '$yClientsUrl/storage_operations/goods_transactions/$companyId',
      options: Options(
        extra: const YClientsRequestExtra<Map<String, Object?>>(
          devToken: true,
        ).toMap(),
      ),
      data: <String, Object?>{
        'amount': 1,
        'discount': 0,
        'operation_unit_type': 1,
        'document_id': documentId,
        'good_id': goodId,
        'cost_per_unit': goodCost,
        'cost': goodCost,
        'master_id': masterId,
        'client_id': clientId,
        'good_special_number': goodSpecialNumber,
      },
    );
    return GoodTransactionModel.fromMap(
      response.data!.data! as Map<String, Object?>,
    );
  }

  /// Returns the iterable data from YClients API.
  ///
  /// - [url] to get the data from.
  /// - [queryParameters] to pass with the url.
  /// - [options] to pass with the url.
  Stream<T> getIterableData<T extends Object>({
    required final JsonConverter<Iterable<T>, Iterable<Map<String, Object?>>>
        jsonConverter,
    required final String url,
    final Map<String, Object?>? queryParameters,
    final Options? options,
    final YClientsRequestExtra<Iterable<T>>? extra,
    final FutureOr<void> Function(DioError)? onError,
  }) async* {
    try {
      final _options = options ?? Options();
      final _extra = extra ?? YClientsRequestExtra<Iterable<T>>();
      final response = await _dio.get<YClientsResponse>(
        url,
        queryParameters: queryParameters,
        options: _options.copyWith(
          extra: _extra
              .copyWith(
                onData: (final data) => jsonConverter.fromJson(
                  (data! as Iterable).cast<Map<String, Object?>>(),
                ),
              )
              .toMap(),
        ),
      );
      for (final data in response.data!.data! as Iterable<Object?>) {
        yield data! as T;
      }
    } on DioError catch (e) {
      // debugger(message: e.toString());
      if (onError != null) {
        await onError(e);
      } else {
        rethrow;
      }
    }
  }

  /// Returns the iterable data from YClients API.
  ///
  /// Maps the data from [mapData] and aggregates results in the single result.
  ///
  /// - [url] to get the data from.
  /// - [queryParameters] to pass with the url.
  /// - [options] to pass with the url.
  Stream<T> mapData<T extends Object, S extends Object>({
    required final Iterable<S> mapData,
    required final JsonConverter<T, Map<String, Object?>> jsonConverter,
    required final String Function(S) url,
    final Map<String, Object?>? Function(S)? queryParameters,
    final Options? Function(S)? options,
    final YClientsRequestExtra? Function(S)? extra,
    final FutureOr<void> Function(DioError, S)? onError,
  }) async* {
    for (final data in mapData) {
      try {
        final _options = options?.call(data) ?? Options();
        final _extra = extra?.call(data) ?? YClientsRequestExtra<T>();
        final response = await _dio.get<YClientsResponse>(
          url(data),
          queryParameters: queryParameters?.call(data),
          options: _options.copyWith(
            extra: _extra
                .copyWith(
                  onData: (final data) => data! is List
                      ? ((data as List).cast<Map<String, Object?>>())
                          .map(jsonConverter.fromJson)
                          .single
                      : data is Iterable
                          ? ((data as Iterable<Object>)
                                  .cast<Map<String, Object?>>())
                              .map(jsonConverter.fromJson)
                              .single
                          : data is Map<String, Object?>
                              ? jsonConverter.fromJson(data)
                              : null,
                )
                .toMap(),
          ),
        );
        yield response.data!.data! as T;
      } on DioError catch (e) {
        // debugger(message: e.toString());
        if (onError != null) {
          await onError(e, data);
        } else {
          rethrow;
        }
      }
    }
  }
}

// final StreamProvider<String> yClientsWebhookProvider =
//     StreamProvider<String>((final ref) {
//   return WebSocketChannel.connect(
//     Uri.parse('wss://echo.websocket.org'),
//   ).stream as Stream<String>;
// });

/// The provider of the [YClientsAPI].
final Provider<YClientsAPI> yClientsProvider = Provider<YClientsAPI>(
  (final ref) => YClientsAPI._(
    ref.watch(userProvider.select((final user) => user?.userToken)),
  ),
);

// /// The cities provider for YClients API.
// ///
// /// See: https://yclientsru.docs.apiary.io/#reference/40/0/0
// final ContentProvider<CityModel> citiesProvider =
//     ContentProvider<CityModel>((final ref) {
//   return ContentNotifier<CityModel>(
//     hive: ref.watch(hiveProvider),
//     saveName: 'cities',
//     converter: cityConverter,
//     refreshState: (final notifier) {},
//   );
// });

/// The studios provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/2/0/0
final StateNotifierProvider<ContentNotifier<StudioModel>, Iterable<StudioModel>>
    studiosProvider =
    StateNotifierProvider<ContentNotifier<StudioModel>, Iterable<StudioModel>>(
  (final ref) => ContentNotifier<StudioModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'studios',
    converter: companyConverter,
    refreshState: (final notifier) async {
      final studios = await (ref.read(yClientsProvider))
          .mapData<StudioModel, SMStudioOptionsModel>(
            mapData: ref.read(smStudiosOptionsProvider),
            jsonConverter: companyConverter,
            url: (final studio) => '$yClientsUrl/company/${studio.studioId}',
            onError: (final error, final studio) async {
              // debugger(message: error.message);
              logger.e(error.message, error, error.stackTrace);
            },
          )
          .toList();
      return studios.isEmpty ? null : studios;
    },
  ),
);

/// The normalized trainers provider for YClients API.
final Provider<Iterable<TrainerModel>> normalizedTrainersProvider =
    Provider<Iterable<TrainerModel>>(
  (final ref) => ref.watch(
    trainersProvider.select(
      (final trainers) => trainers.toList()
        ..removeWhere(
          (final trainer) =>
              trainer.specialization == 'Не удалять' ||
              trainer.name.contains('Сотрудник'),
        )
        ..removeWhere(
          (final trainer) => <String>[
            'https://api.yclients.com/images/no-master.png',
            'https://api.yclients.com/images/no-master-sm.png'
          ].contains(trainer.avatarBig),
        )
        ..sort(
          (final trainerA, final trainerB) => trainerA.name
              .toLowerCase()
              .compareTo(trainerB.name.toLowerCase()),
        ),
    ),
  ),
);

/// The trainers provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/6/0//
final StateNotifierProvider<ContentNotifier<TrainerModel>,
        Iterable<TrainerModel>> trainersProvider =
    StateNotifierProvider<ContentNotifier<TrainerModel>,
        Iterable<TrainerModel>>(
  (final ref) => ContentNotifier<TrainerModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'trainers',
    converter: trainerConverter,
    refreshState: (final notifier) async {
      final getData = ref.read(yClientsProvider).getIterableData;
      final trainers = await StreamGroup.merge(<Stream<TrainerModel>>[
        for (final studio in ref.read(smStudiosOptionsProvider))
          getData(
            jsonConverter: const IterableConverter(trainerConverter),
            url: '$yClientsUrl/company/${studio.studioId}/staff',
            extra: const YClientsRequestExtra(devToken: true),
            onError: (final error) async {
              // debugger(message: error.message);
              logger.e(error.message, error, error.stackTrace);
            },
          )
      ]).toList();
      return trainers.isEmpty ? null : trainers;
    },
  ),
);

/// The schedule provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/12/0/4
final StateNotifierProvider<ContentNotifier<ActivityModel>,
        Iterable<ActivityModel>> scheduleProvider =
    StateNotifierProvider<ContentNotifier<ActivityModel>,
        Iterable<ActivityModel>>(
  (final ref) => ContentNotifier<ActivityModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'activities',
    converter: activityConverter,
    refreshInterval: const Duration(minutes: 10),
    refreshState: (final notifier) async {
      final yClients = ref.read(yClientsProvider);
      Stream<ActivityModel> getSchedule(
        final SMStudioOptionsModel studio,
      ) async* {
        for (var index = 1;; index++) {
          var isDataPresent = false;
          await for (final activity in yClients.getIterableData(
            jsonConverter: const IterableConverter(activityConverter),
            url: '$yClientsUrl/activity/${studio.studioId}/search',
            queryParameters: <String, Object?>{'page': index, 'count': 300},
            onError: (final error) async {
              // debugger(message: error.message);
              logger.e(error.message, error, error.stackTrace);
            },
          )) {
            isDataPresent = true;
            yield activity;
          }

          if (!isDataPresent) {
            return;
          }
        }
      }

      final studios = ref.read(smStudiosOptionsProvider);
      final activities =
          await StreamGroup.merge(studios.map(getSchedule)).toList();
      return activities.isEmpty ? null : activities;
    },
  ),
);

/// The schedule provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/12/0/4
final StateNotifierProvider<ContentNotifier<GoodModel>, Iterable<GoodModel>>
    goodsProvider =
    StateNotifierProvider<ContentNotifier<GoodModel>, Iterable<GoodModel>>(
  (final ref) => ContentNotifier<GoodModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'goods',
    converter: goodConverter,
    refreshState: (final notifier) async {
      final yClients = ref.read(yClientsProvider);
      Stream<GoodModel> getGoods(final SMStudioOptionsModel studio) async* {
        for (var index = 1;; index++) {
          var isDataPresent = false;
          await for (final good in yClients.getIterableData<GoodModel>(
            jsonConverter: const IterableConverter(goodConverter),
            url: '$yClientsUrl/goods/${studio.studioId}',
            queryParameters: <String, Object?>{
              'page': index,
              'count': 100,
              'category_id': studio.categoryAbId,
            },
            extra: const YClientsRequestExtra<Iterable<GoodModel>>(
              devToken: true,
            ),
            onError: (final error) async {
              // debugger(message: error.message);
              logger.e(error.message, error, error.stackTrace);
            },
          )) {
            isDataPresent = true;
            yield good;
          }

          if (!isDataPresent) {
            return;
          }
        }
      }

      final studios = ref.read(smStudiosOptionsProvider);
      final goods = await StreamGroup.merge(studios.map(getGoods)).toList();
      return goods.isEmpty ? null : goods;
    },
  ),
);

/// The user abonements provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/28/0
final StateNotifierProvider<ContentNotifier<UserAbonementModel>,
        Iterable<UserAbonementModel>> userAbonementsProvider =
    StateNotifierProvider<ContentNotifier<UserAbonementModel>,
        Iterable<UserAbonementModel>>((final ref) {
  final notifier = ContentNotifier<UserAbonementModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'userAbonements',
    converter: abonementConverter,
    refreshState: (final notifier) async => ref.read(userProvider) == null
        ? const Iterable<UserAbonementModel>.empty()
        : await (ref.read(yClientsProvider))
            .getIterableData(
              jsonConverter: const IterableConverter(abonementConverter),
              url: '$yClientsUrl/user/loyalty/abonements',
              onError: (final error) async {
                // debugger(message: error.message);
                logger.e(error.message, error, error.stackTrace);
              },
            )
            .toList(),
  );
  ref.listen<bool>(
    userProvider.select((final user) => user == null),
    (final unauthorized) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      unauthorized ? await notifier.clear() : await notifier.refresh();
    },
    fireImmediately: true,
  );
  return notifier;
});

/// The user recordrs provider for YClients API.
///
/// See: https://developers.yclients.com/ru/#operation/Получить%20записи%20пользователя
final StateNotifierProvider<ContentNotifier<UserRecordModel>,
        Iterable<UserRecordModel>> userRecordsProvider =
    StateNotifierProvider<ContentNotifier<UserRecordModel>,
        Iterable<UserRecordModel>>((final ref) {
  final notifier = ContentNotifier<UserRecordModel>(
    hive: ref.watch(hiveProvider),
    saveName: 'userRecords',
    converter: recordConverter,
    refreshState: (final notifier) async {
      if (ref.read(userProvider) == null) {
        return const Iterable<UserRecordModel>.empty();
      }
      final userRecords = await (ref.read(yClientsProvider))
          .getIterableData<UserRecordModel>(
            jsonConverter: const IterableConverter(recordConverter),
            url: '$yClientsUrl/user/records',
            onError: (final error) async {
              // debugger(message: error.message);
              logger.e(error.message, error, error.stackTrace);
            },
          )
          .toList();
      final studios = ref.read(studiosProvider);
      return userRecords.where(
        (final userRecord) =>
            studios.any((final studio) => studio.id == userRecord.company.id),
      );
    },
  );
  ref.listen<bool>(
    userProvider.select((final user) => user == null),
    (final unauthorized) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      unauthorized ? await notifier.clear() : await notifier.refresh();
    },
    fireImmediately: true,
  );
  return notifier;
});

/// The provider of whether to provide a discount to a user.
final Provider<bool> discountProvider = Provider<bool>(
  (final ref) => ref.watch(
    userRecordsProvider.select(
      (final userRecords) =>
          !userRecords.any((final userRecord) => !userRecord.deleted),
    ),
  ),
);

/// The class to handle the exception in the YClients API.
@immutable
class YClientsException implements Exception {
  /// The class to handle the exception in the YClients API.
  const YClientsException(final this.response, [final this.customMessage]);

  /// The response that caused the exception.
  final Response<YClientsResponse> response;

  /// The message to print if cause of this exception is undetermined.
  final String? customMessage;

  @override
  String toString() {
    final messsage = StringBuffer(
      response.data?.meta?.message ??
          customMessage ??
          'There was an exception in YClients API.',
    )
      ..writeln()
      ..writeln('Response: ${response.statusMessage} (${response.statusCode})')
      ..writeln('Request Uri: ${response.realUri}')
      ..writeln('Request Data: ${response.requestOptions.queryParameters}');
    return messsage.toString();
  }
}

/// The interceptor for YClients API.
class YClientsInterceptor extends Interceptor {
  Response<YClientsResponse> _getCustomResponse(
    final Response response, {
    final bool validate = true,
  }) {
    final requestExtra = response.requestOptions.extra.isNotEmpty
        ? YClientsRequestExtra.fromMap(response.requestOptions.extra)
        : const YClientsRequestExtra();
    final dynamic data = response.data;
    final yClientsResponse = data != null &&
            (data is! String || data.trim().isNotEmpty)
        ? YClientsResponse.fromMap(
            (data is String ? json.decode(data) : data) as Map<String, Object?>,
            onData: requestExtra.onData,
          )
        : null;
    final customResponse = Response<YClientsResponse>(
      data: yClientsResponse,
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers,
      isRedirect: response.isRedirect,
      redirects: response.redirects,
      extra: response.extra,
    );
    if (validate &&
        requestExtra.validate &&
        !(yClientsResponse?.success ?? false)) {
      throw YClientsException(customResponse);
    }
    return customResponse;
  }

  @override
  void onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) {
    if (options.data != null) {
      logger.i(options.data, options.path);
    }
    final requestOptions = YClientsRequestExtra.fromMap(options.extra);
    handler.next(
      options.copyWith(
        headers: <String, Object?>{
          ...options.headers,
          if (requestOptions.devToken)
            HttpHeaders.authorizationHeader:
                'Bearer $yClientsToken, User $yClientsAdminToken',
        },
      ),
    );
  }

  @override
  void onResponse(
    final Response response,
    final ResponseInterceptorHandler handler,
  ) {
    // logger.i(response.data, response.realUri);
    handler.resolve(_getCustomResponse(response));
  }

  @override
  void onError(
    final DioError err,
    final ErrorInterceptorHandler handler,
  ) {
    final response = err.response;
    if (response != null) {
      final customResponse = _getCustomResponse(response, validate: false);
      if (err.error is! SocketException) {
        return handler.reject(
          DioError(
            response: customResponse,
            requestOptions: err.requestOptions,
            error: YClientsException(customResponse),
            type: err.type,
          ),
        );
      }
    }
    handler.next(err);
  }
}

// /// The interceptor for SMStretching API.
// class SMStretchingInterceptor extends Interceptor {
//   static Response<Iterable<Map<String, Object?>>> _getCustomResponse(
//     final Response response, {
//     final bool validate = true,
//   }) {
//     final requestExtra = response.requestOptions.extra.isNotEmpty
//         ? YClientsRequestExtra.fromMap(response.requestOptions.extra)
//         : const YClientsRequestExtra();
//     final yClientsResponse = YClientsResponse.fromMap(
//       response.data as Map<String, Object?>,
//       onData: requestExtra.onData,
//     );
//     final customResponse = Response<YClientsResponse>(
//       data: yClientsResponse,
//       requestOptions: response.requestOptions,
//       statusCode: response.statusCode,
//       statusMessage: response.statusMessage,
//       headers: response.headers,
//       isRedirect: response.isRedirect,
//       redirects: response.redirects,
//       extra: response.extra,
//     );
//     if (validate && requestExtra.validate && !yClientsResponse.success) {
//       throw YClientsException(customResponse);
//     }
//     return customResponse;
//   }

//   @override
//   void onResponse(
//     final Response response,
//     final ResponseInterceptorHandler handler,
//   ) {
//     handler.resolve(_getCustomResponse(response));
//   }

//   @override
//   void onError(
//     final DioError err,
//     final ErrorInterceptorHandler handler,
//   ) {
//     final response = err.response;
//     if (response != null) {
//       final customResponse = _getCustomResponse(response, validate: false);
//       handler.reject(
//         DioError(
//           response: customResponse,
//           requestOptions: err.requestOptions,
//           error: YClientsException(customResponse),
//           type: err.type,
//         ),
//       );
//     } else {
//       handler.next(err);
//     }
//   }
// }
