import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:stretching/models/studios_enum.dart';
import 'package:stretching/models/yclients_response.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_yclients/abonement_model.dart';
import 'package:stretching/models_yclients/activity_model.dart';
import 'package:stretching/models_yclients/record_model.dart';
import 'package:stretching/models_yclients/trainer_model.dart';
import 'package:stretching/models_yclients/user_model.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/providers/smstretching_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/providers/yclients_providers.dart';
import 'package:stretching/secrets.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/utils/logger.dart';

/// The url to the YClients Assets.
const String yClientsAssetsUrl = 'https://assets.yclients.com';

/// The url of the YClients API.
const String yClientsUrl = 'https://api.yclients.com/api/v1';

/// The provider of the [YClientsAPI].
final Provider<YClientsAPI> yClientsProvider =
    Provider<YClientsAPI>((final ref) {
  final user = ref.watch(userProvider);
  return YClientsAPI(
    Dio(
      BaseOptions(
        responseType: ResponseType.plain,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/vnd.yclients.v2+json',
          HttpHeaders.authorizationHeader: user != null
              ? 'Bearer $yClientsToken, User ${user.userToken}'
              : 'Bearer $yClientsToken, User $yClientsAdminToken',
        },
      ),
    )..interceptors.add(YClientsInterceptor()),
  );
});

/// The content provider for the YClients API.
final AutoDisposeFutureProvider<void> yClientsContentProvider =
    FutureProvider.autoDispose<void>((final ref) async {
  final studios = ref.watch(smStudiosProvider);
  if (studios.isEmpty) {
    return;
  }

  final yClients = ref.read(yClientsProvider);

  // final citiesNotifier = ref.read(citiesProvider.notifier);
  // if (citiesNotifier.state.isEmpty) {
  //   await yClients.getIterableData<CityModel>(
  //     notifier: citiesNotifier,
  //     jsonConverter: (citiesNotifier.converter
  //             as StringToIterableConverter<CityModel, Map<String, Object?>>)
  //         .converter,
  //     url: '$yClientsUrl/cities',
  //     queryParameters: <String, Object?>{'country_id': 1},
  //   );
  // }

  // int? cityId;
  // for (final city in citiesNotifier.state) {
  //   if (city.title == smstretchingCity) {
  //     cityId = city.id;
  //     break;
  //   }
  // }
  // if (cityId == null) {
  //   throw Exception('City id is not found in the fetched cities.');
  // }

  final studiosNotifier = ref.read(studiosProvider.notifier);
  try {
    if (studiosNotifier.state.isEmpty) {
      await yClients.mapData<StudioModel, SMStudioModel>(
        mapData: studios,
        notifier: studiosNotifier,
        jsonConverter: ((studiosNotifier.converter as StringToIterableConverter<
                        StudioModel, Map<String, Object?>>)
                    .converter
                as IterableConverter<StudioModel, Map<String, Object?>>)
            .converter,
        url: (final studio) => '$yClientsUrl/company/${studio.studioYId}',
      );
    }
  } on DioError catch (e) {
    studiosNotifier.state = const Iterable<StudioModel>.empty();
    logger.e(e.message, e, e.stackTrace);
  }

  final trainersNotifier = ref.read(trainersProvider.notifier);
  try {
    if (trainersNotifier.state.isEmpty) {
      await yClients.mapIterableData<TrainerModel, SMStudioModel>(
        mapData: studios,
        notifier: trainersNotifier,
        jsonConverter: (trainersNotifier.converter as StringToIterableConverter<
                TrainerModel, Map<String, Object?>>)
            .converter,
        url: (final studio) => '$yClientsUrl/company/${studio.studioYId}/staff',
      );
    }
  } on DioError catch (e) {
    trainersNotifier.state = const Iterable<TrainerModel>.empty();
    logger.e(e.message, e, e.stackTrace);
  }

  final scheduleNotifier = ref.read(scheduleProvider.notifier);
  try {
    if (scheduleNotifier.state.isEmpty) {
      await yClients.mapIterableData<ActivityModel, SMStudioModel>(
        mapData: studios,
        notifier: scheduleNotifier,
        jsonConverter: (scheduleNotifier.converter as StringToIterableConverter<
                ActivityModel, Map<String, Object?>>)
            .converter,
        url: (final studio) =>
            '$yClientsUrl/activity/${studio.studioYId}/search',
        queryParameters: (final studio) => <String, Object?>{'count': 300},
      );
    }
  } on DioError catch (e) {
    scheduleNotifier.state = const Iterable<ActivityModel>.empty();
    logger.e(e.message, e, e.stackTrace);
  }
});

/// The user-specific content provider for the YClients API.
final FutureProvider<void> yClientsUserContentProvider =
    FutureProvider<void>((final ref) async {
  final yClients = ref.read(yClientsProvider);
  final abonementsNotifier = ref.read(userAbonementsProvider.notifier);
  try {
    await yClients.mapIterableData<AbonementModel, SMStretchingStudios>(
      mapData: SMStretchingStudios.values,
      notifier: abonementsNotifier,
      jsonConverter: (abonementsNotifier.converter as StringToIterableConverter<
              AbonementModel, Map<String, Object?>>)
          .converter,
      url: (final studio) => '$yClientsUrl/user/loyalty/abonements',
      queryParameters: (final studio) =>
          <String, Object?>{'company_id': studio.id},
    );
  } on DioError catch (e) {
    abonementsNotifier.state = const Iterable<AbonementModel>.empty();
    logger.e(e.message, e, e.stackTrace);
  }

  final recordNotifier = ref.read(userRecordsProvider.notifier);
  try {
    await yClients.getIterableData<RecordModel>(
      notifier: recordNotifier,
      jsonConverter: (recordNotifier.converter
              as StringToIterableConverter<RecordModel, Map<String, Object?>>)
          .converter,
      url: '$yClientsUrl/user/records',
    );
  } on DioError catch (e) {
    recordNotifier.state = const Iterable<RecordModel>.empty();
    logger.e(e.message, e, e.stackTrace);
  }
});

/// The base class for contacting with YClients API.
class YClientsAPI {
  /// The base class for contacting with YClients API.
  const YClientsAPI(this._dio);
  final Dio _dio;

  /// Send the phone confirmation sms code in the YClients API.
  Future<Response<YClientsResponse>> sendCode(final String phone) async {
    return _dio.post<YClientsResponse>(
      '$yClientsUrl/book_code/${SMStretchingStudios.studiyaNaChistihPrudah.id}',
      data: <String, Object?>{'phone': phone},
    );
  }

  /// Verify the sent phone confirmation sms code in the YClients API.
  Future<Response<YClientsResponse>> verifyCode(
    final String phone,
    final String code,
  ) async {
    return _dio.post<YClientsResponse>(
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
  }

  /// Returns the iterable data from YClients API.
  ///
  /// - [url] to get the data from.
  /// - [queryParameters] to pass with the url.
  /// - [options] to pass with the url.
  Future<void> getIterableData<T extends Object>({
    required final SaveToHiveIterableNotifier<T, String> notifier,
    required final JsonConverter<Iterable<T>, Iterable<Map<String, Object?>>>
        jsonConverter,
    required final String url,
    final Map<String, Object?>? queryParameters,
    final Options? options,
  }) async {
    final response = await _dio.get<YClientsResponse>(
      url,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: YClientsRequestExtra<Iterable<T>>(
          onData: (final data) => jsonConverter.fromJson(
            (data! as List).cast<Map<String, Object?>>(),
          ),
        ).toMap(),
      ),
    );
    await notifier
        .addAll((response.data!.data! as Iterable<Object?>).cast<T>());
  }

  /// Returns the iterable data from YClients API.
  ///
  /// Maps the data from [mapData] and aggregates results in the single result.
  ///
  /// - [url] to get the data from.
  /// - [queryParameters] to pass with the url.
  /// - [options] to pass with the url.
  Future<void> mapIterableData<T extends Object, S extends Object>({
    required final Iterable<S> mapData,
    required final SaveToHiveIterableNotifier<T, String> notifier,
    required final JsonConverter<Iterable<T>, Iterable<Map<String, Object?>>>
        jsonConverter,
    required final String Function(S) url,
    final Map<String, Object?>? Function(S)? queryParameters,
    final Options? Function(S)? options,
  }) async {
    for (final data in mapData) {
      await getIterableData(
        notifier: notifier,
        jsonConverter: jsonConverter,
        url: url(data),
        options: options?.call(data),
        queryParameters: queryParameters?.call(data),
      );
    }
  }

  /// Returns the iterable data from YClients API.
  ///
  /// Maps the data from [mapData] and aggregates results in the single result.
  ///
  /// - [url] to get the data from.
  /// - [queryParameters] to pass with the url.
  /// - [options] to pass with the url.
  Future<void> mapData<T extends Object, S extends Object>({
    required final Iterable<S> mapData,
    required final SaveToHiveIterableNotifier<T, String> notifier,
    required final JsonConverter<T, Map<String, Object?>> jsonConverter,
    required final String Function(S) url,
    final Map<String, Object?>? Function(S)? queryParameters,
    final Options? Function(S)? options,
  }) async {
    for (final data in mapData) {
      final response = await _dio.get<YClientsResponse>(
        url(data),
        queryParameters: queryParameters?.call(data),
        options: (options?.call(data) ?? Options()).copyWith(
          extra: YClientsRequestExtra<T>(
            onData: (final data) => data! is List
                ? (data as List)
                    .cast<Map<String, Object?>>()
                    .map(jsonConverter.fromJson)
                    .single
                : data is Iterable
                    ? (data as Iterable<Object>)
                        .cast<Map<String, Object?>>()
                        .map(jsonConverter.fromJson)
                        .single
                    : data is Map<String, Object?>
                        ? jsonConverter.fromJson(data)
                        : null,
          ).toMap(),
        ),
      );
      await notifier.add(response.data!.data! as T);
    }
  }
}

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
  static Response<YClientsResponse> _getCustomResponse(
    final Response response, {
    final bool validate = true,
  }) {
    final requestExtra = response.requestOptions.extra.isNotEmpty
        ? YClientsRequestExtra.fromMap(response.requestOptions.extra)
        : const YClientsRequestExtra();
    final yClientsResponse = YClientsResponse.fromMap(
      response.data as Map<String, Object?>,
      onData: requestExtra.onData,
    );
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
    if (validate && requestExtra.validate && !yClientsResponse.success) {
      throw YClientsException(customResponse);
    }
    return customResponse;
  }

  @override
  void onResponse(
    final Response response,
    final ResponseInterceptorHandler handler,
  ) {
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
      handler.reject(
        DioError(
          response: customResponse,
          requestOptions: err.requestOptions,
          error: YClientsException(customResponse),
          type: err.type,
        ),
      );
    } else {
      handler.next(err);
    }
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
