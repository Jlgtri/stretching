import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
import 'package:stretching/const.dart';
import 'package:stretching/models/activity_model.dart';
import 'package:stretching/models/city_model.dart';
import 'package:stretching/models/company_model.dart';
import 'package:stretching/models/trainer_model.dart';
import 'package:stretching/models/user_model.dart';
import 'package:stretching/models/yclients_response.dart';
import 'package:stretching/secrets.dart';

/// The main hive String box provider.
final Provider<Box<String>> hiveProvider = Provider<Box<String>>((final ref) {
  throw Exception('Hive storage was not initialized.');
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
  final options = BaseOptions(
    headers: <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/vnd.yclients.v2+json',
      HttpHeaders.authorizationHeader: user != null
          ? 'Bearer $yClientsToken, User $user'
          : 'Bearer $yClientsToken',
    },
  );
  final dio = Dio(options);
  dio.interceptors.add(YClientsInterceptor());
  return dio;
});

/// The url of the yclients platfrom API.
const String yClientsUrl = 'https://api.yclients.com/api/v1';

/// The cities provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/40/0/0
final FutureProvider<Iterable<CityModel>> citiesProvider =
    FutureProvider<Iterable<CityModel>>((final ref) async {
  final dio = ref.read(yclientsClientProvider);
  final response = await dio.get<YClientsResponse>(
    '$yClientsUrl/cities',
    queryParameters: <String, Object?>{'country_id': 1},
    options: Options(
      extra: YClientsRequestExtra<CityModel>(
        onData: (final map) => CityModel.fromMap(map),
      ).toMap(),
    ),
  );
  return response.data!.data.cast<CityModel>();
});

/// The model of the smstretching studio.
typedef StudioModel = CompanyModel;

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

  final dio = ref.read(yclientsClientProvider);
  final response = await dio.get<YClientsResponse>(
    '$yClientsUrl/companies',
    queryParameters: <String, Object?>{
      'city_id': cityId,
      'group_id': smstretchingGroupId.toString()
    },
    options: Options(
      extra: YClientsRequestExtra<StudioModel>(
        onData: (final map) => StudioModel.fromMap(map),
      ).toMap(),
    ),
  );
  return response.data!.data.cast<StudioModel>();
});

/// The trainers provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/6/0//
final FutureProvider<Iterable<TrainerModel>> trainersProvider =
    FutureProvider<Iterable<TrainerModel>>((final ref) async {
  final dio = ref.read(yclientsClientProvider);
  final studios = await ref.read(studiosProvider.future);
  final trainers = List<TrainerModel>.empty(growable: true);
  for (final studio in studios) {
    final response = await dio.get<YClientsResponse>(
      '$yClientsUrl/book_staff/${studio.id}',
      options: Options(
        extra: YClientsRequestExtra<TrainerModel>(
          onData: (final map) => TrainerModel.fromMap(map),
        ).toMap(),
      ),
    );
    trainers.addAll(response.data!.data.cast<TrainerModel>());
  }
  return trainers;
});

/// The schedule provider for YClients API.
///
/// See: https://yclientsru.docs.apiary.io/#reference/12/0/4
final FutureProvider<Iterable<ActivityModel>> scheduleProvider =
    FutureProvider<Iterable<ActivityModel>>((final ref) async {
  final dio = ref.read(yclientsClientProvider);
  final studios = await ref.read(studiosProvider.future);
  final activities = List<ActivityModel>.empty(growable: true);
  for (final studio in studios) {
    final response = await dio.get<YClientsResponse>(
      '$yClientsUrl/activity/${studio.id}/search',
      queryParameters: <String, Object?>{'count': 300},
      options: Options(
        extra: YClientsRequestExtra<ActivityModel>(
          onData: (final map) => ActivityModel.fromMap(map),
        ).toMap(),
      ),
    );
    activities.addAll(response.data!.data.cast<ActivityModel>());
  }
  return activities;
});

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