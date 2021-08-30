import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_smstretching/sm_trainer_model.dart';
import 'package:stretching/providers/smstretching_providers.dart';
import 'package:stretching/secrets.dart';
import 'package:stretching/utils/logger.dart';

/// The url of the SMStretching API.
const String smStretchingUrl = 'https://smstretching.ru/wp-json/jet-cct';

/// The provider of the SMStreching API.
final Provider<Dio> smStretchingProvider = Provider<Dio>((final ref) {
  return Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            'smstretchingstudio:$smStretchingAuthToken'
      },
    ),
  );
});

/// The content provider for the SMStretching API.
final AutoDisposeFutureProvider<void> smStretchingContentProvider =
    FutureProvider.autoDispose<void>((final ref) async {
  final smstretching = ref.read(smStretchingProvider);
  final smStudiosNotifier = ref.read(smStudiosProvider.notifier);
  try {
    if (smStudiosNotifier.state.isEmpty) {
      final response =
          await smstretching.get<Iterable>('$smStretchingUrl/studii');
      smStudiosNotifier.state = response.data!
          .cast<Map<String, Object?>>()
          .map(SMStudioModel.fromMap);
    }
  } on DioError catch (e) {
    smStudiosNotifier.state = const Iterable<SMStudioModel>.empty();
    logger.e(e.message, e, e.stackTrace);
  }

  final smTrainersNotifier = ref.read(smTrainersProvider.notifier);
  try {
    if (smTrainersNotifier.state.isEmpty) {
      final response =
          await smstretching.get<Iterable>('$smStretchingUrl/shtab_v2');
      smTrainersNotifier.state = response.data!
          .cast<Map<String, Object?>>()
          .map(SMTrainerModel.fromMap);
    }
  } on DioError catch (e) {
    smTrainersNotifier.state = const Iterable<SMTrainerModel>.empty();
    logger.e(e.message, e, e.stackTrace);
  }
});
