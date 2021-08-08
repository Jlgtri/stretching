import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stacked/stacked.dart';
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
class Authorization extends ConsumerWidget {
  /// The widget to authorize a user.
  const Authorization({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return ViewModelBuilder<AuthorizationViewModel>.reactive(
      builder: (final context, final viewModel, final child) {
        if (viewModel.isBusy) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: viewModel.phoneController,
                enabled: viewModel.currentStep == AuthorizationStep.phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  errorText: viewModel.phoneError,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: viewModel.codeController,
                enabled: viewModel.currentStep == AuthorizationStep.code,
                decoration: InputDecoration(
                  labelText: 'Code',
                  errorText: viewModel.codeError,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                if (viewModel.currentStep == AuthorizationStep.code ||
                    viewModel.currentStep == AuthorizationStep.done)
                  TextButton(
                    onPressed: () => viewModel.updateAuthStep(reset: true),
                    child: Text(
                      viewModel.currentStep == AuthorizationStep.code
                          ? 'Back'
                          : 'Finish',
                    ),
                  ),
                if (viewModel.currentStep != AuthorizationStep.done)
                  TextButton(
                    onPressed: viewModel.updateAuthStep,
                    child: const Text('Continue'),
                  )
              ],
            )
          ],
        );
      },
      disposeViewModel: false,
      fireOnModelReadyOnce: true,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (final viewModel) => viewModel.notifyListeners(),
      viewModelBuilder: () => AuthorizationViewModel(ref),
    );
  }
}

/// The view model for [Authorization].
class AuthorizationViewModel extends ReactiveViewModel {
  /// The view model for [Authorization].
  AuthorizationViewModel(final this.ref) {
    final user = ref.read(userProvider).state;
    if (user != null) {
      phoneController.text = user.phone;
      _stepService.currentStep = AuthorizationStep.done;
    }
  }

  AuthorizationStepService get _stepService =>
      ref.watch(authorizationStepServiceProvider);

  /// The reference to the [Consumer].
  final WidgetRef ref;

  /// The controller for entering a phone number.
  final TextEditingController phoneController = TextEditingController();

  /// The controller for entering a verification code for a phone number.
  final TextEditingController codeController = TextEditingController();

  /// The error for the phone input field.
  String? phoneError;

  /// The error for the code input field.
  String? codeError;

  /// The current step of this model.
  AuthorizationStep get currentStep => _stepService.currentStep;

  /// Processes the data for the current authorization step and proceed onto
  /// the next one.
  ///
  /// * If step is [AuthorizationStep.phone], send an authorization sms code.
  /// * If step is [AuthorizationStep.code], validate previously sent sms code
  /// and login the user.
  /// * If step is [AuthorizationStep.done], logout the user.
  Future<void> updateAuthStep({final bool reset = false}) async {
    phoneError = codeError = null;
    if (reset) {
      _stepService.currentStep = AuthorizationStep.done;
    }

    try {
      Response<YClientsResponse>? response;
      switch (_stepService.currentStep) {
        case AuthorizationStep.phone:
          response = await runBusyFuture(
            _sendCode(phoneController.text),
            throwException: true,
          );
          break;
        case AuthorizationStep.code:
          response = await runBusyFuture(
            _verifyCode(phoneController.text, int.parse(codeController.text)),
            throwException: true,
          );
          final user = ref.read(userProvider);
          user.state = response!.data!.data.single as UserModel;
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
      _stepService.nextStep();
    } on DioError catch (e) {
      final error = e.error;
      if (error is YClientsException) {
        logger.e(error, _stepService.currentStep);
        switch (_stepService.currentStep) {
          case AuthorizationStep.phone:
            phoneError = error.response.data?.meta?.message;
            break;
          case AuthorizationStep.code:
            codeError = error.response.data?.meta?.message;
            break;
          case AuthorizationStep.done:
            break;
        }
      } else {
        rethrow;
      }
    }
  }

  /// Send the phone confirmation sms code in the YClients API.
  Future<Response<YClientsResponse>> _sendCode(final String phone) async {
    final dio = ref.read(yclientsClientProvider);
    return dio.post<YClientsResponse>(
      '$yClientsUrl/book_code/$smstretchingGroupId',
      queryParameters: <String, Object?>{'phone': phone},
    );
  }

  /// Verify the sent phone confirmation sms code in the YClients API.
  Future<Response<YClientsResponse>> _verifyCode(
    final String phone,
    final int code,
  ) async {
    final dio = ref.read(yclientsClientProvider);
    return dio.post<YClientsResponse>(
      '$yClientsUrl/user/auth',
      queryParameters: <String, Object?>{'phone': phone, 'code': code},
      options: Options(
        extra: YClientsRequestExtra<UserModel>(
          onData: (final map) => UserModel.fromMap(map),
        ).toMap(),
      ),
    );
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      <ReactiveServiceMixin>[_stepService];
}

/// The provider of the [AuthorizationStepService].
final authorizationStepServiceProvider =
    Provider.autoDispose<AuthorizationStepService>((final ref) {
  return AuthorizationStepService();
});

/// The service for managing [AuthorizationViewModel.currentStep].
class AuthorizationStepService with ReactiveServiceMixin {
  /// The service for managing [AuthorizationViewModel.currentStep].
  AuthorizationStepService() {
    listenToReactiveValues([_currentStep]);
  }

  /// The current step of this model.
  AuthorizationStep get currentStep => _currentStep.value;
  set currentStep(final AuthorizationStep value) => _currentStep.value = value;

  final ReactiveValue<AuthorizationStep> _currentStep =
      ReactiveValue<AuthorizationStep>(AuthorizationStep.phone);

  /// Go to the next step of this model.
  void nextStep() {
    const values = AuthorizationStep.values;
    _currentStep.value = values.elementAt(
      currentStep.index + 1 < values.length ? currentStep.index + 1 : 0,
    );
  }
}
