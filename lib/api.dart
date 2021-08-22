import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:stretching/const.dart';
import 'package:stretching/models/abonement_model.dart';
import 'package:stretching/models/activity_model.dart';
import 'package:stretching/models/record_model.dart';
import 'package:stretching/models/trainer_model.dart';
import 'package:stretching/models/user_model.dart';
import 'package:stretching/models/yclients_response.dart';
import 'package:stretching/providers.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/secrets.dart';

/// The url of the YClients platfrom API.
const String yClientsUrl = 'https://api.yclients.com/api/v1';

/// The provider of the [YClientsAPI].
final Provider<YClientsAPI> yClientsProvider =
    Provider<YClientsAPI>((final ref) {
  final user = ref.watch(userProvider);
  return YClientsAPI(
    Dio(
      BaseOptions(
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/vnd.yclients.v2+json',
          HttpHeaders.authorizationHeader: user != null
              ? 'Bearer $yClientsToken, User ${user.userToken}'
              : 'Bearer $yClientsToken',
        },
      ),
    )..interceptors.add(YClientsInterceptor()),
  );
});

/// The initialisation of the main data from the YClients API.
final FutureProvider<void> mainYClientsProvider =
    FutureProvider<void>((final ref) async {
  final yClients = ref.read(yClientsProvider);
  final cities = ref.read(citiesProvider.notifier);
  if (ref.read(citiesProvider).isEmpty) {
    await yClients.getIterableData(
      notifier: cities,
      url: (final _) => '$yClientsUrl/cities',
      queryParameters: (final _) => <String, Object?>{'country_id': 1},
    );
  }

  int? cityId;
  for (final city in cities.state) {
    if (city.title == smstretchingCity) {
      cityId = city.id;
      break;
    }
  }
  if (cityId == null) {
    throw Exception('City id is not found in the fetched cities.');
  }

  if (ref.read(studiosProvider).isEmpty) {
    await yClients.getIterableData(
      notifier: ref.read(studiosProvider.notifier),
      url: (final _) => '$yClientsUrl/companies',
      queryParameters: (final _) => <String, Object?>{
        'city_id': cityId,
        'group_id': smstretchingGroupId.toString()
      },
    );
  }

  final studios = ref.read(studiosProvider);
  if (ref.read(trainersProvider).isEmpty) {
    await yClients.getIterableData<TrainerModel, StudioModel>(
      notifier: ref.read(trainersProvider.notifier),
      mapData: studios,
      url: (final studio) => '$yClientsUrl/book_staff/${studio.id}',
    );
  }

  if (ref.read(scheduleProvider).isEmpty) {
    await yClients.getIterableData<ActivityModel, StudioModel>(
      notifier: ref.read(scheduleProvider.notifier),
      mapData: studios,
      url: (final studio) => '$yClientsUrl/activity/${studio.id}/search',
      queryParameters: (final studio) => <String, Object?>{'count': 300},
    );
  }
});

/// The user specific data initialisation from the YClients API.
final FutureProvider<void> userYClientsProvider =
    FutureProvider<void>((final ref) async {
  final yClients = ref.read(yClientsProvider);
  final studios = ref.read(studiosProvider);
  await yClients.getIterableData<AbonementModel, StudioModel>(
    notifier: ref.read(userAbonementsProvider.notifier),
    mapData: studios,
    url: (final studio) => '$yClientsUrl/user/loyalty/abonements',
    queryParameters: (final studio) =>
        <String, Object?>{'company_id': studio.id},
  );

  await yClients.getIterableData<RecordModel, StudioModel>(
    notifier: ref.read(userRecordsProvider.notifier),
    mapData: studios,
    url: (final studio) => '$yClientsUrl/user/records',
  );
});

/// The base class for contacting with YClients API.
class YClientsAPI {
  /// The base class for contacting with YClients API.
  const YClientsAPI(this._dio);
  final Dio _dio;

  /// Send the phone confirmation sms code in the YClients API.
  Future<Response<YClientsResponse>> sendCode(final String phone) async {
    return _dio.post<YClientsResponse>(
      '$yClientsUrl/book_code/$smstretchingGroupId',
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
  /// Maps the data from [mapData] and aggregates results in the single result.
  /// If the [mapData] is not specified, returns the data from the single call.
  ///
  /// - [url] to get the data from.
  /// - [queryParameters] to pass with the url.
  /// - [options] to pass with the url.
  Future<void> getIterableData<T extends Object, S extends Object>({
    required final SaveToHiveIterableNotifier<T, String> notifier,
    required final String Function(S) url,
    final Map<String, Object?>? Function(S)? queryParameters,
    final Options? Function(S)? options,
    Iterable<S>? mapData,
  }) async {
    mapData ??= Iterable<S>.generate(1);
    for (final data in mapData) {
      final response = await _dio.get<YClientsResponse>(
        url(data),
        queryParameters: queryParameters?.call(data),
        options: (options?.call(data) ?? Options()).copyWith(
          extra: YClientsRequestExtra<Iterable<T>>(
            onData: (final data) =>
                notifier.converter.fromJson(data!.toString()),
          ).toMap(),
        ),
      );
      await notifier
          .addAll((response.data!.data! as Iterable<Object?>).cast<T>());
    }
  }

  // /// Returns the iterable data from YClients API.
  // ///
  // /// Maps the data from [mapData] and aggregates results in the single result.
  // /// If the [mapData] is not specified, returns the data from the single call.
  // ///
  // /// - [ref] the reference to the Riverpod.
  // /// - [progressProvider] shows the progress of getting the data.
  // /// - [saveName] stands for how local cache data will be called.
  // /// - [toMap] / [fromMap] are the json serialization closures.
  // /// - [url] to get the data from.
  // /// - [queryParameters] to pass with the url.
  // /// - [options] to pass with the url.
  // Future<SaveToHiveIterableNotifier<T, S>>
  //     getIterableDataFromYClients<T extends Object, S extends Object>({
  //   required final ProviderRef ref,
  //   required final StateProvider<num?> progressProvider,
  //   required final String saveName,
  //   required final JsonConverter<T, Object> toMap,
  //   required final String Function(S) url,
  //   final Map<String, Object?>? Function(S)? queryParameters,
  //   final Options? Function(S)? options,
  //   Iterable<S>? mapData,
  // }) async {
  //   mapData ??= Iterable<S>.generate(1);
  //   final hive = ref.read(hiveProvider);
  //   final savedDataString = hive.get(saveName);
  //   final savedData = <T>[
  //     if (savedDataString != null)
  //       for (final map in json.decode(savedDataString) as Iterable<Object?>)
  //         fromMap(map)
  //   ];
  //   if (savedData.isEmpty) {
  //     final dio = ref.read(yclientsClientProvider);
  //     final progress = ref.read(progressProvider);
  //     num previousProgress = 0;
  //     for (final data in mapData) {
  //       final response = await dio.get<YClientsResponse>(
  //         url(data),
  //         queryParameters: queryParameters?.call(data),
  //         onReceiveProgress: (final count, final total) {
  //           if (total != -1) {
  //             progress.state =
  //                 previousProgress + (count / total) / mapData!.length;
  //           }
  //         },
  //         options: (options?.call(data) ?? Options()).copyWith(
  //           extra: YClientsRequestExtra<Iterable<T>>(
  //             onData: (final data) => <T>[
  //               for (final map
  //                   in data as Iterable<Object?>? ?? const <Object?>[])
  //                 fromMap(map)
  //             ],
  //           ).toMap(),
  //         ),
  //       );
  //       savedData.addAll((response.data!.data! as Iterable<Object?>).cast<T>());
  //       previousProgress += 1 / mapData.length;
  //     }
  //     await hive.put(
  //       saveName,
  //       json.encode([for (final data in savedData) toMap(data)]),
  //     );
  //   }
  //   return savedData;
  // }
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

/// The inteceptor for YClients API.
class YClientsInterceptor extends Interceptor {
  Response<YClientsResponse> _getCustomResponse(
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
