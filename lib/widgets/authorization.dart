import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/const.dart';
import 'package:stretching/models/user_model.dart';
import 'package:stretching/models/yclients_response.dart';
import 'package:stretching/providers.dart';
import 'package:stretching/utils/logger.dart';

/// The step of the [Authorization] widget's lifecycle.
enum AuthorizationStep {
  /// Means entering a phone number.
  phone,

  /// Means entering a code received to authenticate the [phone].
  code,

  /// Means the [code] to authenticate the [phone] was successfully entered.
  done
}

/// The widget to authorize a user.
class Authorization extends HookConsumerWidget {
  /// The widget to authorize a user.
  const Authorization({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final currentStep = useState(AuthorizationStep.phone);
    final phoneError = useState<String?>(null);
    final codeError = useState<String?>(null);
    final isLoading = useState<bool>(false);
    final phoneController = useTextEditingController();
    final codeController = useTextEditingController();

    /// Processes the data for the current authorization step and proceed onto
    /// the next one.
    ///
    /// * If step is [AuthorizationStep.phone], send an authorization sms code.
    /// * If step is [AuthorizationStep.code], validate previously sent sms code
    /// and login the user.
    /// * If step is [AuthorizationStep.done], logout the user.
    Future<void> updateAuthStep({final bool reset = false}) async {
      /// Send the phone confirmation sms code in the YClients API.
      Future<Response<YClientsResponse>> sendCode(final String phone) async {
        final dio = ref.read(yclientsClientProvider);
        return dio.post<YClientsResponse>(
          '$yClientsUrl/book_code/$smstretchingGroupId',
          data: <String, Object?>{'phone': phone},
        );
      }

      /// Verify the sent phone confirmation sms code in the YClients API.
      Future<Response<YClientsResponse>> verifyCode(
        final String phone,
        final int code,
      ) async {
        final dio = ref.read(yclientsClientProvider);
        return dio.post<YClientsResponse>(
          '$yClientsUrl/user/auth',
          data: <String, Object?>{'phone': phone, 'code': code},
          options: Options(
            extra: YClientsRequestExtra<UserModel>(
              onData: (final map) =>
                  UserModel.fromMap(map! as Map<String, Object?>),
            ).toMap(),
          ),
        );
      }

      phoneError.value = codeError.value = null;
      if (reset) {
        currentStep.value = AuthorizationStep.done;
      }

      isLoading.value = true;
      try {
        Response<YClientsResponse>? response;
        switch (currentStep.value) {
          case AuthorizationStep.phone:
            response = await sendCode(phoneController.text);
            break;
          case AuthorizationStep.code:
            response = await verifyCode(
                phoneController.text, int.parse(codeController.text));
            final user = ref.read(userProvider);
            user.state = response.data!.data! as UserModel;
            final hive = ref.read(hiveProvider);
            await hive.put('user', json.encode(user.state!.toMap()));
            break;
          case AuthorizationStep.done:
            final user = ref.read(userProvider);
            if (user.state != null) {
              final hive = ref.read(hiveProvider);
              await hive.delete('user');
            }
            user.state = null;
            phoneController.clear();
            codeController.clear();
            break;
        }
        logger.i(
          response ?? currentStep,
          response != null ? currentStep : response,
        );
        currentStep.value = AuthorizationStep.values.elementAt(
          currentStep.value.index + 1 < AuthorizationStep.values.length
              ? currentStep.value.index + 1
              : 0,
        );
      } on DioError catch (e) {
        final error = e.error;
        if (error is YClientsException) {
          logger.e(error, currentStep.value);
          switch (currentStep.value) {
            case AuthorizationStep.phone:
              phoneError.value = error.response.data?.meta?.message;
              break;
            case AuthorizationStep.code:
              codeError.value = error.response.data?.meta?.message;
              break;
            case AuthorizationStep.done:
              break;
          }
        } else {
          rethrow;
        }
      } finally {
        isLoading.value = false;
      }
    }

    if (isLoading.value) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final user = ref.watch(userProvider).state;
    if (user != null && currentStep.value != AuthorizationStep.done) {
      phoneController.text = user.phone;
      currentStep.value = AuthorizationStep.done;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (user != null)
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              readOnly: true,
              controller: TextEditingController(text: user.userToken),
              decoration: const InputDecoration(labelText: 'User Token'),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextField(
            controller: phoneController,
            enabled: currentStep.value == AuthorizationStep.phone,
            decoration: InputDecoration(
              labelText: 'Phone',
              errorText: phoneError.value,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextField(
            controller: codeController,
            enabled: currentStep.value == AuthorizationStep.code,
            decoration: InputDecoration(
              labelText: 'Code',
              errorText: codeError.value,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            if (currentStep.value == AuthorizationStep.code ||
                currentStep.value == AuthorizationStep.done)
              TextButton(
                onPressed: () => updateAuthStep(reset: true),
                child: Text(
                  currentStep.value == AuthorizationStep.code
                      ? 'Back'
                      : 'Logout',
                ),
              ),
            if (currentStep.value != AuthorizationStep.done)
              TextButton(
                onPressed: updateAuthStep,
                child: const Text('Continue'),
              )
          ],
        )
      ],
    );
  }
}
