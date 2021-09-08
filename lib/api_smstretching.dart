import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/providers/connection_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/smstretching_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/secrets.dart';
import 'package:stretching/utils/logger.dart';

/// The link to the content in SMStretching API.
const String smStretchingContentUrl = 'https://smStretching.ru/wp-json/jet-cct';

/// The link to the SMStretching API.
const String smStretchingApiUrl = 'https://smStretching.ru/mobile';

/// The provider of the SMStreching API.
final Dio smStretching = Dio(
  BaseOptions(
    headers: <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader:
          'smstretchingstudio:$smStretchingHeaderToken'
    },
  ),
);

/// The content provider for the SMStretching API.
final AutoDisposeFutureProvider<void> smStretchingContentProvider =
    FutureProvider.autoDispose<void>((final ref) {
  final futures = List<Future<void>>.empty(growable: true);

  final smStudiosNotifier = ref.read(smStudiosProvider.notifier);
  try {
    if (smStudiosNotifier.state.isEmpty) {
      futures.add(
        (smStretching.get<Iterable>('$smStretchingContentUrl/studii'))
            .then((final response) {
          smStudiosNotifier.state = response.data!
              .cast<Map<String, Object?>>()
              .map((final map) => SMStudioModel.fromMap(map));
        }),
      );
    }
  } on DioError catch (e) {
    smStudiosNotifier.state = const Iterable<SMStudioModel>.empty();
    logger.e(e.message, e, e.stackTrace);
  }

  final smTrainersNotifier = ref.read(smTrainersProvider.notifier);
  try {
    if (smTrainersNotifier.state.isEmpty) {
      futures.add(
        (smStretching.get<Iterable>('$smStretchingContentUrl/shtab_v2')).then(
          (final response) {
            smTrainersNotifier.state = response.data!
                .cast<Map<String, Object?>>()
                .map((final map) => SMTrainerModel.fromMap(map));
          },
        ),
      );
    }
  } on DioError catch (e) {
    smTrainersNotifier.state = const Iterable<SMTrainerModel>.empty();
    logger.e(e.message, e, e.stackTrace);
  }

  return Future.wait<void>(futures);
});

/// The provider of a user in SMStretching API.
final FutureProvider<bool?> smUserProvider =
    FutureProvider<bool?>((final ref) async {
  final connection = ref.read(connectionProvider);
  if (connection == null || !connection) {
    return null;
  }
  final user = ref.watch(userProvider);
  if (user == null) {
    return null;
  }

  final response = await smStretching.post<String?>(
    '$smStretchingApiUrl/users/$smStretchingUrlToken/add_user',
    data: <String, Object?>{
      'phone': user.phone,
      'email': user.email,
      'date_add': ref.read(serverTimeProvider).toString().split('.').first,
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
});

/// The server time of the SMStretching API.
Future<DateTime?> smStretchingServerTime() async {
  final response = await smStretching.post<String?>(
    '$smStretchingApiUrl/options/$smStretchingUrlToken/get_time',
  );
  final data = response.data;
  return data != null ? DateTime.tryParse(json.decode(data) as String) : null;
}

/// The provider of current user's deposit.
final FutureProvider<int?> userDepositProvider =
    FutureProvider<int?>((final ref) async {
  final connection = ref.read(connectionProvider);
  if (connection == null || !connection) {
    return null;
  }
  final user = ref.watch(userProvider);
  if (user == null) {
    return null;
  }
  final response = await smStretching.post<String>(
    '$smStretchingApiUrl/users/$smStretchingUrlToken/get_user_deposit',
    data: <String, Object?>{'phone': user.phone},
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
});
