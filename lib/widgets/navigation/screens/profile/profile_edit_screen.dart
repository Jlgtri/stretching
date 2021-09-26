import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/business_logic.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/hook_consumer_stateful_widget.dart';
import 'package:stretching/providers/hide_appbar_provider.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/focus_wrapper.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/profile/profile_screen.dart';
import 'package:validators/validators.dart';

/// The screen that allows user to edit his personal data.
class ProfileEditScreen extends HookConsumerStatefulWidget {
  /// The screen that allows user to edit his personal data.
  const ProfileEditScreen({final Key? key}) : super(key: key);

  @override
  ProfileEditScreenState createState() => ProfileEditScreenState();
}

/// The screen that allows user to edit his personal data.
class ProfileEditScreenState extends ConsumerState<ProfileEditScreen>
    with HideAppBarRouteAware {
  @override
  NavigationScreen get screenType => NavigationScreen.profile;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    final user = ref.watch(userProvider)!;
    final userName = user.name.split(RegExp(r'\s+'));

    final firstNameKey = useMemoized(GlobalKey.new);
    final surnameKey = useMemoized(GlobalKey.new);
    final middleNameKey = useMemoized(GlobalKey.new);
    final phoneKey = useMemoized(GlobalKey.new);
    final emailKey = useMemoized(GlobalKey.new);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final firstName = useRef('');
    final surname = useRef('');
    final middleName = useRef('');
    final email = useRef('');
    return FocusWrapper(
      unfocussableKeys: <GlobalKey>[
        firstNameKey,
        surnameKey,
        middleNameKey,
        phoneKey,
        emailKey
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: NavigationRoot.navBarHeight),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: cancelAppBar(
            theme,
            title: ProfileNavigationScreen.profile.translation,
            leading: FontIconBackButton(
              color: theme.colorScheme.onSurface,
              onPressed: Navigator.of(context).maybePop,
            ),
          ),
          body: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              primary: false,
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                /// First Name
                ProfileEditField(
                  fieldKey: firstNameKey,
                  initialValue: userName.length == 1
                      ? userName.first
                      : userName.length > 1
                          ? userName.elementAt(1)
                          : '',
                  label: TR.profileEditFirstName.tr(),
                  keyboardType: TextInputType.name,
                  validator: (final value) {
                    return (value ?? '').isNotEmpty &&
                            RegExp(r'[^\p{L}]', unicode: true)
                                .hasMatch(value ?? '')
                        ? TR.profileEditFirstNameError.tr()
                        : null;
                  },
                  onSaved: (final value) => firstName.value = value,
                ),

                /// Surname
                ProfileEditField(
                  fieldKey: surnameKey,
                  initialValue: userName.length > 1 ? userName.first : '',
                  label: TR.profileEditSurname.tr(),
                  keyboardType: TextInputType.name,
                  validator: (final value) {
                    return RegExp(r'[^\p{L}]', unicode: true)
                            .hasMatch(value ?? '')
                        ? TR.profileEditSurnameError.tr()
                        : null;
                  },
                  onSaved: (final value) => surname.value = value,
                ),

                /// Middle Name
                ProfileEditField(
                  fieldKey: middleNameKey,
                  initialValue:
                      userName.length > 2 ? userName.elementAt(2) : '',
                  label: TR.profileEditMiddleName.tr(),
                  keyboardType: TextInputType.name,
                  validator: (final value) {
                    return RegExp(r'[^\p{L}]', unicode: true)
                            .hasMatch(value ?? '')
                        ? TR.profileEditMiddleNameError.tr()
                        : null;
                  },
                  onSaved: (final value) => middleName.value = value,
                ),

                /// Phone
                ProfileEditField(
                  disabled: true,
                  fieldKey: phoneKey,
                  initialValue: MaskTextInputFormatter(
                    initialText: user.phone,
                    mask: '+${'#' * phoneCountryCode.toString().length} '
                        '### ### ## ##',
                    filter: {'#': RegExp(r'\d')},
                  ).maskText(user.phone),
                  label: TR.profileEditPhone.tr(),
                  keyboardType: TextInputType.phone,
                  validator: (final value) => null,
                  onSaved: (final value) {},
                ),

                /// Email
                ProfileEditField(
                  fieldKey: emailKey,
                  initialValue: user.email,
                  label: TR.profileEditEmail.tr(),
                  keyboardType: TextInputType.emailAddress,
                  validator: (final value) =>
                      value != null && value.isNotEmpty && !isEmail(value)
                          ? TR.profileEditEmailError.tr()
                          : null,
                  onSaved: (final value) => email.value,
                ),

                /// Confirm
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: BottomButtons(
                    firstText: TR.profileEditConfirm.tr(),
                    onFirstPressed: (final context) async {
                      final form = formKey.currentState;
                      if (form != null && form.validate()) {
                        form.save();
                        final fullName = <String>[
                          if (surname.value.isNotEmpty) surname.value,
                          if (firstName.value.isNotEmpty) firstName.value,
                          if (middleName.value.isNotEmpty) middleName.value
                        ].join(' ');
                        final businessLogic = ref.read(businessLogicProvider);
                        await Future.wait(<Future<void>>[
                          /// Update client locally.
                          (ref.read(userProvider.notifier)).setStateAsync(
                            user.copyWith(
                              name: fullName.isEmpty ? null : fullName,
                              email: email.value.isEmpty ? null : email.value,
                            ),
                          ),

                          /// Update client in the SMStretching API.
                          smStretching.addUser(
                            userPhone: user.phone,
                            userEmail: email.value,
                            serverTime: ref.read(smServerTimeProvider),
                          ),

                          /// Update client in each studio in YClients API.
                          for (final company in ref.read(studiosProvider))
                            businessLogic.updateClient(
                              companyId: company.id,
                              userPhone: user.phone,
                              email: email.value,
                              name: <String>[
                                if (surname.value.isNotEmpty) surname.value,
                                if (firstName.value.isNotEmpty) firstName.value,
                                if (middleName.value.isNotEmpty)
                                  middleName.value
                              ].join(' '),
                            ),
                        ]);

                        await navigator.maybePop(true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The input field of the [ProfileEditScreen].
class ProfileEditField extends HookWidget {
  /// The input field of the [ProfileEditScreen].
  const ProfileEditField({
    required final this.fieldKey,
    required final this.label,
    required final this.initialValue,
    required final this.keyboardType,
    required final this.validator,
    required final this.onSaved,
    final this.capitalize = true,
    final this.disabled = false,
    final Key? key,
  }) : super(key: key);

  /// The key of this field.
  final GlobalKey fieldKey;

  /// The label of this field.
  final String label;

  /// The initial value of this field.
  final String initialValue;

  /// The keyboard type of this field.
  final TextInputType keyboardType;

  /// The validator of this field.
  final FormFieldValidator<String> validator;

  /// The callback to call when this field has been saved.
  final FutureOr<void> Function(String) onSaved;

  /// If this field should be capitalized on lost focus.
  final bool capitalize;

  /// If this field is disabled;
  final bool disabled;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    final focusNode = useFocusNode();
    final hasFocus = useState<bool>(focusNode.hasFocus);
    final controller = useTextEditingController(text: initialValue);
    final text = useState<String>(controller.text);
    useMemoized(() {
      focusNode.addListener(() {
        hasFocus.value = focusNode.hasPrimaryFocus;
        if (!hasFocus.value) {
          controller.text = text.value = text.value.splitMapJoin(
            RegExp(r'\s+'),
            onNonMatch: (final nonMatch) {
              return nonMatch.isNotEmpty
                  ? nonMatch.substring(0, 1).toUpperCase() +
                      nonMatch.substring(1).toLowerCase()
                  : '';
            },
            onMatch: (final m) => ' ',
          );
        }
      });
    });

    final state = fieldKey.currentState as FormFieldState<String>?;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.overline,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        TextFormField(
          key: fieldKey,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          validator: validator,
          style: theme.textTheme.bodyText2,
          enabled: !disabled,
          onChanged: (final value) => text.value = value,
          onSaved: (final value) async {
            focusNode.unfocus();
            await onSaved(text.value);
          },
          decoration: InputDecoration(
            alignLabelWithHint: false,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            filled: true,
            fillColor: disabled
                ? theme.hintColor.withOpacity(2 / 5)
                : Colors.transparent,
            border: const OutlineInputBorder(),
            disabledBorder:
                const OutlineInputBorder(borderSide: BorderSide.none),
            enabledBorder: const OutlineInputBorder(),
            focusedBorder:
                const OutlineInputBorder(borderSide: BorderSide(width: 2)),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.red),
            ),
            suffix: !hasFocus.value && state?.errorText == null
                ? FontIcon(
                    FontIconData(
                      IconsCG.confirmed,
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                : hasFocus.value && text.value.isNotEmpty
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 15.5,
                        icon: FontIcon(
                          FontIconData(
                            IconsCG.close,
                            height: 15.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          maxHeight: 24,
                          maxWidth: 18,
                        ),
                        tooltip: TR.tooltipsClear.tr(),
                        onPressed: () {
                          text.value = '';
                          state?.validate();
                          controller.clear();
                        },
                      )
                    : null,
            suffixIconConstraints:
                const BoxConstraints(maxWidth: 30, maxHeight: 30),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(
          DiagnosticsProperty<GlobalKey<State<StatefulWidget>>>(
            'fieldKey',
            fieldKey,
          ),
        )
        ..add(StringProperty('label', label))
        ..add(StringProperty('initialValue', initialValue))
        ..add(DiagnosticsProperty<TextInputType>('keyboardType', keyboardType))
        ..add(
          ObjectFlagProperty<FormFieldValidator<String>>.has(
            'validator',
            validator,
          ),
        )
        ..add(
          ObjectFlagProperty<void Function(String p1)>.has('onSaved', onSaved),
        )
        ..add(DiagnosticsProperty<bool>('capitalize', capitalize))
        ..add(DiagnosticsProperty<bool>('disabled', disabled)),
    );
  }
}
