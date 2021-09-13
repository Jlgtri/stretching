import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models/yclients_response.dart';
import 'package:stretching/models_yclients/user_model.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/logger.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/focus_wrapper.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The widget to authorize a user.
class AuthorizationScreen extends HookConsumerWidget {
  /// The widget to authorize a user.
  const AuthorizationScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    const phonePrefix = '+$phoneCountryCode ';

    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    final isLoading = useState<bool>(false);
    final isMounted = useIsMounted();

    final enteringPhone = useState<bool>(true);
    final phoneFormatter = useMemoized(() {
      return MaskTextInputFormatter(
        initialText: phonePrefix,
        mask: '$phonePrefix### ### ## ##',
        filter: {'#': RegExp(r'\d')},
      );
    });

    final currentPhone = useState<String?>(null);
    final currentCode = useState<String?>(null);

    // ignore: close_sinks
    final codeErrorController = useStreamController<ErrorAnimationType>();

    final phoneKey = useMemoized(() => GlobalKey());
    final codeKey = useMemoized(() => GlobalKey());

    final phoneError = useState<String?>(null);
    final codeError = useState<String?>(null);

    /// Processes the data for the current authorization step and proceed onto
    /// the next one.
    ///
    /// * If step is [AuthorizationScreenStep.phone], send an authorization
    /// sms code.
    /// * If step is [AuthorizationScreenStep.code], validate previously sent
    /// sms code and login the user.
    /// * If step is [AuthorizationScreenStep.done], logout the user.
    Future<void> updateAuthStep({final bool reset = false}) async {
      isLoading.value = true;
      phoneError.value = codeError.value = null;
      if (reset) {
        enteringPhone.value = false;
        ref.read(userProvider.notifier).state = null;
        phoneFormatter.clear();
      }

      Response<YClientsResponse>? response;
      try {
        final currentPhoneValue = currentPhone.value;
        if (currentPhoneValue != null) {
          final yClients = ref.read(yClientsProvider);
          if (enteringPhone.value) {
            response = await yClients.sendCode(
              currentPhoneValue,
              // TODO(feature): default studio
              // TODO(feature): add user to all other studios (post clients/$company)
              ref.read(studiosProvider).first.id,
            );
            if (isMounted()) {
              enteringPhone.value = false;
            }
          } else {
            final currentCodeValue = currentCode.value;
            if (currentCodeValue != null) {
              response = await yClients.verifyCode(
                currentPhoneValue,
                currentCodeValue,
              );
              final user = response.data?.data as UserModel?;
              if (user != null) {
                await smStretching.addUser(
                  user,
                  ref.read(smServerTimeProvider),
                );
                ref.read(userProvider.notifier).state = user;
                (ref.read(navigationProvider))
                    .jumpToTab(NavigationScreen.profile.index);
                await navigator.maybePop();
              }
            }
          }
        }
      } on DioError catch (e) {
        final dynamic error = e.error;
        if (error is YClientsException) {
          logger.e(error, 'Phone: ${enteringPhone.value}');
          if (enteringPhone.value) {
            phoneError.value = error.response.data?.meta?.message;
          } else {
            codeError.value = error.response.data?.meta?.message;
            codeErrorController.add(ErrorAnimationType.shake);
          }
        } else {
          rethrow;
        }
      } finally {
        if (isMounted()) {
          isLoading.value = false;
        }
        logger.i(
          response ?? 'Phone: ${enteringPhone.value}',
          response != null ? 'Phone: ${enteringPhone.value}' : response,
        );
      }
    }

    void onPhoneFieldChanged(final String value) {
      if (phoneFormatter.isFill()) {
        currentPhone.value =
            phoneCountryCode.toString() + phoneFormatter.getUnmaskedText();
      } else if (currentPhone.value != null) {
        currentPhone.value = null;
      }
    }

    return FocusWrapper(
      unfocussableKeys: <GlobalKey>[phoneKey, codeKey],
      child: Scaffold(
        // ignore: use_build_context_synchronously
        appBar: cancelAppBar(
          theme,
          onPressed: navigator.maybePop,
          leading: !enteringPhone.value
              ? FontIconBackButton(
                  color: theme.colorScheme.onSurface,
                  onPressed: () => enteringPhone.value = true,
                )
              : const SizedBox.shrink(),
        ),
        body: SingleChildScrollView(
          primary: false,
          child: PageTransitionSwitcher(
            reverse: !enteringPhone.value,
            duration: const Duration(seconds: 1),
            layoutBuilder: (final entries) => Stack(children: entries),
            transitionBuilder: (
              final child,
              final animation,
              final secondaryAnimation,
            ) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
            child: Padding(
              key: ValueKey(enteringPhone.value),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 100),
                  Center(
                    child: Text(
                      enteringPhone.value
                          ? TR.authPhone.tr()
                          : <String>[
                              TR.authEnterCode.tr(),
                              phoneFormatter.getMaskedText(),
                            ].join('\n'),
                      style: theme.textTheme.headline2,
                      textAlign: !enteringPhone.value ? TextAlign.center : null,
                    ),
                  ),
                  if (enteringPhone.value) ...[
                    const SizedBox(height: 18),
                    _AuthorizationPhoneField(
                      fieldKey: phoneKey,
                      prefix: phonePrefix,
                      formatter: phoneFormatter,
                      enabled: !isLoading.value && enteringPhone.value,
                      style: theme.textTheme.headline3,
                      initialText: phoneFormatter.getMaskedText(),
                      errorText: phoneError.value,
                      onChanged: onPhoneFieldChanged,
                      onSubmitted: (final value) => updateAuthStep(),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed:
                          currentPhone.value != null ? updateAuthStep : null,
                      style: TextButtonStyle.dark.fromTheme(theme).copyWith(
                            backgroundColor: currentPhone.value == null
                                ? MaterialStateProperty.all(Colors.grey)
                                : null,
                            side: MaterialStateProperty.all(const BorderSide()),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                      child: Text(TR.authReceiveCode.tr()),
                    )
                  ] else ...[
                    const SizedBox(height: 50),
                    SizedBox(
                      width: 200,
                      child: PinCodeTextField(
                        key: codeKey,
                        appContext: context,
                        length: pinCodeLength,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          activeFillColor: theme.colorScheme.onSurface,
                          inactiveColor: theme.colorScheme.onSurface,
                          disabledColor: theme.colorScheme.onSurface,
                          activeColor: theme.colorScheme.onSurface,
                          selectedColor: theme.colorScheme.onSurface,
                          inactiveFillColor: theme.colorScheme.onSurface,
                          errorBorderColor: theme.colorScheme.error,
                          fieldOuterPadding: EdgeInsets.zero,
                          fieldWidth: 32,
                          fieldHeight: 40,
                        ),
                        hapticFeedbackTypes: HapticFeedbackTypes.medium,
                        // hintCharacter: '0',
                        keyboardType: TextInputType.number,
                        hintStyle: TextStyle(color: theme.hintColor),
                        errorAnimationController: codeErrorController,
                        onCompleted: (final value) async {
                          if (int.tryParse(value) != null) {
                            currentCode.value = value;
                            await updateAuthStep();
                          }
                        },
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (final value) {},
                        beforeTextPaste: (final text) {
                          return text != null &&
                              text.length == pinCodeLength &&
                              int.tryParse(text) != null;
                        },
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorizationPhoneField extends HookWidget {
  const _AuthorizationPhoneField({
    final this.fieldKey,
    final this.enabled,
    final this.prefix = '',
    final this.style,
    final this.formatter,
    final this.initialText = '',
    final this.errorText,
    final this.onChanged,
    final this.onSubmitted,
    final Key? key,
  }) : super(key: key);

  final Key? fieldKey;
  final bool? enabled;
  final String prefix;
  final TextStyle? style;
  final TextInputFormatter? formatter;
  final String initialText;
  final String? errorText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  @override
  Widget build(final BuildContext context) {
    final controller = useTextEditingController(text: initialText);
    final focusNode = useFocusNode();
    final showPrefix = useState<bool>(false);
    useMemoized(() {
      controller.addListener(() {
        if (controller.text.isEmpty) {
          if (!showPrefix.value) {
            showPrefix.value = true;
          }
        } else if (showPrefix.value) {
          showPrefix.value = false;
        }
      });
    });
    return TextField(
      key: fieldKey,
      controller: controller,
      focusNode: focusNode,
      style: style,
      enabled: enabled,
      onSubmitted: onSubmitted,
      enableSuggestions: false,
      keyboardType: TextInputType.phone,
      showCursor: focusNode.hasPrimaryFocus,
      decoration: InputDecoration(
        prefixText:
            focusNode.hasPrimaryFocus && showPrefix.value ? prefix : null,
        prefixStyle: style,
        hintText: focusNode.hasPrimaryFocus ? null : prefix,
        hintStyle: style,
        errorText: errorText,
        errorMaxLines: 2,
      ),
      inputFormatters: <TextInputFormatter>[if (formatter != null) formatter!],
      onChanged: onChanged?.call,
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<Key?>('fieldKey', fieldKey))
        ..add(DiagnosticsProperty<bool?>('enabled', enabled))
        ..add(StringProperty('prefix', prefix))
        ..add(DiagnosticsProperty<TextStyle?>('style', style))
        ..add(DiagnosticsProperty<TextInputFormatter?>('formatter', formatter))
        ..add(StringProperty('initialText', initialText))
        ..add(StringProperty('errorText', errorText))
        ..add(
          ObjectFlagProperty<void Function(String p1)>.has(
            'onChanged',
            onChanged,
          ),
        )
        ..add(
          ObjectFlagProperty<void Function(String p1)>.has(
            'onSubmitted',
            onSubmitted,
          ),
        ),
    );
  }
}
