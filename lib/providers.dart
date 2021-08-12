import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
import 'package:stretching/const.dart';
import 'package:stretching/models/abonement_model.dart';
import 'package:stretching/models/activity_model.dart';
import 'package:stretching/models/city_model.dart';
import 'package:stretching/models/company_model.dart';
import 'package:stretching/models/record_model.dart';
import 'package:stretching/models/trainer_model.dart';
import 'package:stretching/models/user_model.dart';
import 'package:stretching/models/yclients_response.dart';
import 'package:stretching/secrets.dart';
import 'package:stretching/utils/json_converters.dart';

/// The main hive String box provider.
final Provider<Box<String>> hiveProvider = Provider<Box<String>>((final ref) {
  throw Exception('Hive storage has not been initialized.');
});

/// The provider of a user.
final StateProvider<UserModel?> userProvider =
    StateProvider<UserModel?>((final ref) {
  final hive = ref.read(hiveProvider);
  final savedUser = hive.get('user');
  return savedUser != null ? UserModel.fromJson(savedUser) : null;
});

/// The client provider for YClients API.
final Provider<Dio> yclientsClientProvider = Provider<Dio>((final ref) {
  final user = ref.watch(userProvider).state;
  return Dio(
    BaseOptions(
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/vnd.yclients.v2+json',
        HttpHeaders.authorizationHeader: user != null
            ? 'Bearer $yClientsToken, User ${user.userToken}'
            : 'Bearer $yClientsToken',
      },
    ),
  )..interceptors.add(YClientsInterceptor());
});

/// The url of the YClients platfrom API.
const String yClientsUrl = 'https://api.yclients.com/api/v1';

/// The progress of initialising a [citiesProvider].
final StateProvider<num?> citiesProgressProvider =
    StateProvider<num?>((final ref) => null);

/// The cities provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/40/0/0
final FutureProvider<Iterable<CityModel>> citiesProvider =
    FutureProvider<Iterable<CityModel>>((final ref) async {
  return getIterableDataFromYClients(
    ref: ref,
    progressProvider: citiesProgressProvider,
    saveName: 'cities',
    url: (final _) => '$yClientsUrl/cities',
    queryParameters: (final _) => <String, Object?>{'country_id': 1},
    fromMap: (final map) => CityModel.fromMap(map! as Map<String, Object?>),
    toMap: (final data) => data.toMap(),
  );
});

/// The model of the smstretching studio.
typedef StudioModel = CompanyModel;

/// The progress of initialising a [studiosProvider].
final StateProvider<num?> studiosProgressProvider =
    StateProvider<num?>((final ref) => null);

/// The studios provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/2/0/0
final FutureProvider<Iterable<StudioModel>> studiosProvider =
    FutureProvider<Iterable<StudioModel>>((final ref) async {
  final cities = await ref.read(citiesProvider.future);
  int? cityId;
  for (final city in cities) {
    if (city.title == smstretchingCity) {
      cityId = city.id;
      break;
    }
  }
  if (cityId == null) {
    throw Exception('City id is not found in the fetched cities.');
  }
  return getIterableDataFromYClients(
    ref: ref,
    progressProvider: studiosProgressProvider,
    saveName: 'studios',
    url: (final _) => '$yClientsUrl/companies',
    queryParameters: (final _) => <String, Object?>{
      'city_id': cityId,
      'group_id': smstretchingGroupId.toString()
    },
    toMap: (final data) => data.toMap(),
    fromMap: (final data) => StudioModel.fromMap(data! as Map<String, Object?>),
  );
});

/// The progress of initialising a [trainersProvider].
final StateProvider<num?> trainersProgressProvider =
    StateProvider<num?>((final ref) => null);

/// The trainers provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/6/0//
final FutureProvider<Iterable<TrainerModel>> trainersProvider =
    FutureProvider<Iterable<TrainerModel>>((final ref) async {
  final studios = await ref.read(studiosProvider.future);
  return getIterableDataFromYClients<TrainerModel, StudioModel>(
    ref: ref,
    progressProvider: trainersProgressProvider,
    mapData: studios,
    saveName: 'trainers',
    url: (final studio) => '$yClientsUrl/book_staff/${studio.id}',
    toMap: (final data) => data.toMap(),
    fromMap: (final data) =>
        TrainerModel.fromMap(data! as Map<String, Object?>),
  );
});

/// The progress of initialising a [scheduleProvider].
final StateProvider<num?> scheduleProgressProvider =
    StateProvider<num?>((final ref) => null);

/// The schedule provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/12/0/4
final FutureProvider<Iterable<ActivityModel>> scheduleProvider =
    FutureProvider<Iterable<ActivityModel>>((final ref) async {
  final studios = await ref.read(studiosProvider.future);
  return getIterableDataFromYClients<ActivityModel, StudioModel>(
    ref: ref,
    progressProvider: scheduleProgressProvider,
    mapData: studios,
    saveName: 'activities',
    url: (final studio) => '$yClientsUrl/activity/${studio.id}/search',
    queryParameters: (final studio) => <String, Object?>{'count': 300},
    toMap: (final data) => data.toMap(),
    fromMap: (final data) =>
        ActivityModel.fromMap(data! as Map<String, Object?>),
  );
});

/// The progress of initialising a [userAbonementsProvider].
final StateProvider<num?> userAbonementsProgressProvider =
    StateProvider<num?>((final ref) => null);

/// The user abonements provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/28/0
final FutureProvider<Iterable<AbonementModel>?> userAbonementsProvider =
    FutureProvider<Iterable<AbonementModel>?>((final ref) async {
  final user = ref.watch(userProvider).state;
  if (user != null) {
    final studios = await ref.read(studiosProvider.future);
    return getIterableDataFromYClients<AbonementModel, StudioModel>(
      ref: ref,
      progressProvider: userAbonementsProgressProvider,
      mapData: studios,
      saveName: 'abonements',
      url: (final studio) => '$yClientsUrl/user/loyalty/abonements',
      queryParameters: (final studio) =>
          <String, Object?>{'company_id': studio.id},
      toMap: (final data) => data.toMap(),
      fromMap: (final data) =>
          AbonementModel.fromMap(data! as Map<String, Object?>),
    );
  } else {
    await ref.read(hiveProvider).delete('abonements');
  }
});

/// The progress of initialising a [userAbonementsProvider].
final StateProvider<num?> userRecordsProgressProvider =
    StateProvider<num?>((final ref) => null);

/// The user recordrs provider for YClients API.
///
/// See: https://developers.yclients.com/ru/#operation/Получить%20записи%20пользователя
final FutureProvider<Iterable<RecordModel>?> userRecordsProvider =
    FutureProvider<Iterable<RecordModel>?>((final ref) async {
  final user = ref.watch(userProvider).state;
  if (user != null) {
    final studios = await ref.read(studiosProvider.future);
    return getIterableDataFromYClients<RecordModel, StudioModel>(
      ref: ref,
      progressProvider: userRecordsProgressProvider,
      mapData: studios,
      saveName: 'records',
      url: (final studio) => '$yClientsUrl/user/records',
      toMap: (final data) => data.toMap(),
      fromMap: (final data) =>
          RecordModel.fromMap(data! as Map<String, Object?>),
    );
  } else {
    await ref.read(hiveProvider).delete('records');
  }
});

/// Returns the iterable data from YClients API.
///
/// Maps the data from [mapData] and aggregates results in the single result.
/// If the [mapData] is not specified, returns the data from the single call.
///
/// - [ref] the reference to the Riverpod.
/// - [progressProvider] shows the progress of getting the data.
/// - [saveName] stands for how local cache data will be called.
/// - [toMap] / [fromMap] are the json serialization closures.
/// - [url] to get the data from.
/// - [queryParameters] to pass with the url.
/// - [options] to pass with the url.
Future<Iterable<T>>
    getIterableDataFromYClients<T extends Object, S extends Object>({
  required final ProviderRef ref,
  required final StateProvider<num?> progressProvider,
  required final String saveName,
  required final ToJson<T> toMap,
  required final FromJson<T> fromMap,
  required final String Function(S) url,
  final Map<String, Object?>? Function(S)? queryParameters,
  final Options? Function(S)? options,
  Iterable<S>? mapData,
}) async {
  mapData ??= Iterable.generate(1);
  final hive = ref.read(hiveProvider);
  final savedDataString = hive.get(saveName);
  final savedData = <T>[
    if (savedDataString != null)
      for (final map in json.decode(savedDataString) as Iterable<Object?>)
        fromMap(map)
  ];
  if (savedData.isEmpty) {
    final dio = ref.read(yclientsClientProvider);
    final progress = ref.read(progressProvider);
    num previousProgress = 0;
    for (final data in mapData) {
      final response = await dio.get<YClientsResponse>(
        url(data),
        queryParameters: queryParameters?.call(data),
        onReceiveProgress: (final count, final total) {
          if (total != -1) {
            progress.state =
                previousProgress + (count / total) / mapData!.length;
          }
        },
        options: (options?.call(data) ?? Options()).copyWith(
          extra: YClientsRequestExtra<Iterable<T>>(
            onData: (final data) => <T>[
              for (final map in data as Iterable<Object?>? ?? const <Object?>[])
                fromMap(map)
            ],
          ).toMap(),
        ),
      );
      savedData.addAll((response.data!.data! as Iterable<Object?>).cast<T>());
      previousProgress += 1 / mapData.length;
    }
    await hive.put(
      saveName,
      json.encode([for (final data in savedData) toMap(data)]),
    );
  }
  return savedData;
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
      response.data,
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
