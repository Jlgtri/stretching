import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models_smstretching/sm_abonement_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/firebase_providers.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/utils/json_converters.dart';
import 'package:stretching/widgets/components/focus_wrapper.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/components/bottom_sheet.dart';
import 'package:stretching/widgets/navigation/screens/activities_screen.dart';
import 'package:validators/validators.dart';

/// The provider of the email on the payment page.
final StateNotifierProvider<SaveToHiveNotifier<String, String>, String>
    paymentEmailProvider =
    StateNotifierProvider<SaveToHiveNotifier<String, String>, String>(
        (final ref) {
  return SaveToHiveNotifier(
    hive: ref.watch(hiveProvider),
    saveName: 'paymentEmail',
    converter: DummyConverter(),
    defaultValue: '',
  );
});

/// The callback on payment. The payment is regular if [abonement] is null.
typedef OnPayment = FutureOr<void> Function(
  String email,
  SMAbonementModel? abonement,
  CombinedStudioModel? studio,
);

/// Shows a bottom sheet for picking a payment.
///
/// If [PaymentPickerScreen.payment] is null, it is considered an abonement.
Future<void> showPaymentPickerBottomSheet(
  final BuildContext context,
  final PaymentPickerScreen screen,
) async {
  await showMaterialModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    duration: const Duration(milliseconds: 500),
    animationCurve: Curves.easeInOut,
    closeProgressThreshold: 4 / 5,
    builder: (final context) {
      final theme = Theme.of(context);
      return BottomSheetBase(
        child: CustomScrollView(
          primary: false,
          shrinkWrap: true,
          controller: ModalScrollController.of(context),
          cacheExtent: double.infinity,
          slivers: <Widget>[
            SliverAppBar(
              primary: false,
              toolbarHeight: screen.payment == null ? 64 : 44,
              title: screen.payment == null
                  ? Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(TR.paymentPickerAbonementTitle.tr()),
                    )
                  : null,
              titleTextStyle: theme.textTheme.headline2?.copyWith(height: 2.5),
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leadingWidth: 0,
              leading: const SizedBox.shrink(),
              actions: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: screen.payment != null ? 14 : 8,
                    ),
                    child: IconButton(
                      onPressed: Navigator.of(context).maybePop,
                      padding: const EdgeInsets.only(bottom: 2),
                      splashRadius: 16,
                      iconSize: 16,
                      icon: FontIcon(
                        FontIconData(
                          IconsCG.close,
                          height: 20,
                          alignment: Alignment.topCenter,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(child: screen),
            ),
          ],
        ),
      );
    },
  );
}

/// The screen for picking abonement.
///
/// If [payment] is null, it is considered an abonement.
class PaymentPickerScreen extends HookConsumerWidget {
  /// The screen for picking abonement.
  ///
  /// If [payment] is null, it is considered an abonement.
  const PaymentPickerScreen({
    required final this.onPayment,
    final this.smAbonements = const Iterable<SMAbonementModel>.empty(),
    final this.allStudios = true,
    final this.payment,
    final Key? key,
  }) : super(key: key);

  /// The callback on payment.
  final OnPayment onPayment;

  /// The abonements for user to pick from.
  final Iterable<SMAbonementModel> smAbonements;

  /// If all studios should be picked by default.
  final bool allStudios;

  /// The payment amount to proceed on this screen.
  ///
  /// If it is null, this screen is considered for an abonement.
  final num? payment;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final smAbonementsStudios =
        smAbonements.map((final smAbonement) => smAbonement.service).toSet();
    final studios = ref.watch(
      combinedStudiosProvider.select((final studios) {
        return studios.where((final studio) {
          return smAbonementsStudios.contains(studio.item0.id);
        });
      }),
    );
    final countValues = (smAbonements.map((final abonement) => abonement.count))
        .toSet()
        .toList(growable: false)
      ..sort();

    final buttonKey = useMemoized(() => GlobalKey());
    final emailKey = useMemoized(() => GlobalKey());
    final emailError = useState<String>('');
    final emailController = useTextEditingController(
      text: ref.read(paymentEmailProvider),
    );
    final emailFocusNode = useFocusNode();
    final emailShowSuffix = useState<bool>(false);

    final isLoading = useState<bool>(false);
    final isMounted = useIsMounted();

    // final isMounted = useIsMounted();
    // useMemoized(() {
    //   KeyboardVisibilityController().onChange.listen((final visible) {
    //     if (visible) {
    //       // if (isMounted()) {
    //       //   (ref.read(widgetsBindingProvider))
    //       //       .addPostFrameCallback((final _) async {
    //       //     // await Future<void>.delayed(const Duration(milliseconds: 250));
    //       //     if (isMounted()) {
    //       //       final context = emailKey.currentContext;
    //       //       if (context != null) {
    //       //         await Scrollable.ensureVisible(
    //       //           context,
    //       //           curve: Curves.easeInSine,
    //       //           duration: const Duration(milliseconds: 250),
    //       //         );
    //       //       }
    //       //     }
    //       //   });
    //       // }
    //       // final controller = ModalScrollController.of(context);
    //       // if (controller != null && controller.hasClients) {
    //       //   await Future<void>.delayed(const Duration(milliseconds: 250));
    //       //   controller.jumpTo(controller.position.maxScrollExtent);
    //       // }

    //     }
    //   });
    // });

    final pickedCount =
        useState<int?>(countValues.isNotEmpty ? countValues.first : null);
    final pickedTimeOfDay = useState<ActivityTime>(ActivityTime.all);
    final pickedAllStudios = useState<bool>(allStudios || studios.isEmpty);
    final pickedStudio = useState<CombinedStudioModel?>(
      studios.isNotEmpty ? studios.first : null,
    );

    final abonement = smAbonements.cast<SMAbonementModel?>().firstWhere(
      (final smAbonement) {
        return smAbonement!.count == pickedCount.value &&
            (!smAbonement.time && pickedTimeOfDay.value == ActivityTime.all ||
                smAbonement.time &&
                    pickedTimeOfDay.value == ActivityTime.before) &&
            ((pickedAllStudios.value && smAbonement.service == null) ||
                (!pickedAllStudios.value &&
                    (pickedStudio.value == null ||
                        smAbonement.service == pickedStudio.value!.item0.id)));
      },
      orElse: () => null,
    );

    useFuture(
      useMemoized(
        () async {
          if (abonement != null) {
            await analytics.logEvent(
              name: FAKeys.abonementSelect,
              parameters: <String, String>{
                'price': abonement.cost.toString(),
                'currency': 'RUB',
                'train_qnt': abonement.count.toString(),
                'class_start': abonement.time ? 'till_16.45' : 'any',
                'studio':
                    abonement.service != null && pickedStudio.value != null
                        ? translit(pickedStudio.value!.item1.studioName)
                        : 'all',
                'payment_method_type': 'credit_card',
              },
            );
          }
        },
        [abonement],
      ),
    );

    return FocusWrapper(
      unfocus: false,
      unfocussableKeys: <GlobalKey>[emailKey, buttonKey],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (payment == null) ...[
            /// Day Count Picker
            AbonementCategoryPicker<int>(
              maxWidth: 50,
              category: TR.paymentPickerCountPerWeek.tr(),
              selected: <int?>[pickedCount.value].whereType<int>(),
              onSelected: (final count, final value) =>
                  pickedCount.value = count,
              builder: (final context, final count) =>
                  Text(count.toStringAsFixed(0)),
              values: countValues,
            ),

            /// Time of Day Picker
            AbonementCategoryPicker<ActivityTime>(
              category: TR.paymentPickerTimeOfDay.tr(),
              selected: <ActivityTime>[pickedTimeOfDay.value],
              onSelected: (final count, final value) =>
                  pickedTimeOfDay.value = count,
              builder: (final context, final time) => Text(
                time == ActivityTime.all
                    ? TR.paymentPickerTimeOfDayAll.tr()
                    : time.translate(),
              ),
              values: ActivityTime.values.reversed.toList()
                ..remove(ActivityTime.after),
            ),

            /// Studio Picker
            AbonementCategoryPicker<CombinedStudioModel>(
              dropdown: true,
              dropdownBuilder: (final context, final child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IntrinsicWidth(
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 16,
                        visualDensity: VisualDensity.compact,
                        leading: Container(
                          height: 24,
                          width: 24,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: Container(
                            height: 8,
                            width: 8,
                            color: pickedAllStudios.value
                                ? theme.colorScheme.onSurface
                                : Colors.transparent,
                          ),
                        ),
                        minLeadingWidth: 16,
                        onTap: () => pickedAllStudios.value = true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(right: 48),
                          child: Text(
                            TR.paymentPickerStudioAll.tr(),
                            style: theme.textTheme.bodyText1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    if (studios.isNotEmpty)
                      IntrinsicWidth(
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          horizontalTitleGap: 16,
                          visualDensity: VisualDensity.compact,
                          leading: Container(
                            height: 24,
                            width: 24,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 6),
                            child: Container(
                              height: 8,
                              width: 8,
                              color: !pickedAllStudios.value
                                  ? theme.colorScheme.onSurface
                                  : Colors.transparent,
                            ),
                          ),
                          minLeadingWidth: 16,
                          onTap: () => pickedAllStudios.value = false,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(right: 32),
                            child: Text.rich(
                              TextSpan(
                                text: TR.paymentPickerStudioPickText.tr(),
                                style: theme.textTheme.bodyText1?.copyWith(
                                  height:
                                      ((theme.textTheme.bodyText1!.fontSize! +
                                                  4) /
                                              theme.textTheme.bodyText1!
                                                  .fontSize!) *
                                          theme.textTheme.bodyText1!.height!,
                                ),
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: child,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                  ],
                );
              },
              category: TR.paymentPickerStudioPick.tr(),
              selected: <CombinedStudioModel?>[pickedStudio.value]
                  .whereType<CombinedStudioModel>(),
              onSelected: (final studio, final value) =>
                  pickedStudio.value = studio,
              builder: (final context, final studio) =>
                  Text(studio.item1.studioName),
              values: studios,
            ),

            /// Information
            if (abonement != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    TR.paymentPickerSubscriptionTermTitle.tr(),
                    style: theme.textTheme.subtitle1,
                  ),
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(
                      text: TR.paymentPickerSubscriptionTermWeeks.plural(
                        abonement.ySrok ~/ DateTime.daysPerWeek,
                      ),
                      children: <InlineSpan>[
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: TR.paymentPickerSubscriptionTermFreezes
                              .plural(abonement.yHold),
                        )
                      ],
                    ),
                    style: theme.textTheme.bodyText2,
                  )
                ],
              )
            else
              Text(
                TR.paymentPickerNotFound.tr(),
                style: theme.textTheme.subtitle1,
              ),
          ] else
            Text(
              TR.paymentPickerRegularTitle.tr(
                args: <String>[
                  TR.miscCurrency
                      .tr(args: <String>[payment!.toStringAsFixed(0)])
                ],
              ),
              style: theme.textTheme.headline3,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          /// Email Input Field
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  TR.paymentPickerEmailTitle.tr(),
                  style: theme.textTheme.overline,
                ),
                const SizedBox(height: 12),
                TextField(
                  key: emailKey,
                  controller: emailController,
                  focusNode: emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  style: theme.textTheme.bodyText1,
                  onChanged: (final value) {
                    emailShowSuffix.value = value.isNotEmpty;
                    emailError.value = value.isEmpty || isEmail(value)
                        ? ''
                        : TR.paymentPickerEmailError.tr();
                  },
                  onTap: emailKey.currentContext != null
                      ? () => Scrollable.ensureVisible(emailKey.currentContext!)
                      : null,
                  decoration: InputDecoration(
                    errorStyle:
                        theme.textTheme.headline6?.copyWith(color: Colors.red),
                    errorText:
                        emailError.value.isEmpty ? null : emailError.value,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    focusColor: Colors.white,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: const OutlineInputBorder(),
                    focusedErrorBorder: const OutlineInputBorder(),
                    suffix: emailShowSuffix.value
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
                              maxHeight: 18,
                              maxWidth: 18,
                            ),
                            tooltip: TR.tooltipsClear.tr(),
                            onPressed: () {
                              emailShowSuffix.value = false;
                              emailError.value = '';
                              emailController.clear();
                            },
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(
                      maxHeight: 36,
                      maxWidth: 48,
                    ),
                  ),
                ),
                if (emailError.value.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      TR.paymentPickerEmailApplication.tr(),
                      style: theme.textTheme.headline6?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// Footer
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              /// Application Button
              BottomButtons<dynamic>(
                key: buttonKey,
                firstText: payment != null || abonement == null
                    ? TR.paymentPickerPaymentRegular.tr()
                    : TR.paymentPickerPaymentAbonement.tr(
                        args: <String>[
                          TR.miscCurrency.tr(
                            args: <String>[abonement.cost.toStringAsFixed(0)],
                          )
                        ],
                      ),
                onFirstPressed: emailController.text.isNotEmpty &&
                        emailError.value.isEmpty &&
                        !isLoading.value
                    ? (final context) async {
                        isLoading.value = true;
                        try {
                          await (ref.read(paymentEmailProvider.notifier))
                              .setStateAsync(emailController.text);
                          await onPayment(
                            emailController.text,
                            payment == null ? abonement : null,
                            pickedStudio.value,
                          );
                        } finally {
                          if (isMounted()) {
                            isLoading.value = false;
                          }
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 12),

              /// Banks
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (final icon in [
                    IconsCG.applePay,
                    IconsCG.googlePay,
                    IconsCG.visa,
                    IconsCG.mastercard,
                    IconsCG.world
                  ]) ...[
                    Flexible(
                      child: FontIcon(
                        FontIconData(icon, color: theme.hintColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ]
                ],
              ),
              const SizedBox(height: 12),
            ],
          )
        ],
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(ObjectFlagProperty<OnPayment>.has('onPayment', onPayment))
        ..add(IterableProperty<SMAbonementModel>('smAbonements', smAbonements))
        ..add(DiagnosticsProperty<bool>('allStudios', allStudios))
        ..add(DiagnosticsProperty<num?>('payment', payment)),
    );
  }
}

/// The builder of the [AbonementCategoryPicker].
typedef AbonementCategoryPickerBuilder<T extends Object> = Widget Function(
  BuildContext context,
  T value,
);

/// The picker for the specified [category].
class AbonementCategoryPicker<T extends Object> extends StatelessWidget {
  /// The picker for the specified [category].
  const AbonementCategoryPicker({
    required final this.values,
    required final this.builder,
    final this.dropdownBuilder,
    final this.category = '',
    final this.selected = const Iterable.empty(),
    final this.onSelected,
    final this.maxWidth = 150,
    final this.dropdown = false,
    final Key? key,
  }) : super(key: key);

  /// The values to pick from in this category.
  final Iterable<T> values;

  /// The builder of the widget of each value.
  final AbonementCategoryPickerBuilder<T> builder;

  /// The builder of the dropdown. Passes dropdown as child.
  final Widget Function(BuildContext context, Widget child)? dropdownBuilder;

  /// The title of this category.
  final String category;

  /// The current selected value.
  final Iterable<T> selected;

  /// The callback on selected value.
  final void Function(T, bool value)? onSelected;

  /// The maximum width of the children of this picker.
  final double maxWidth;

  /// If this widget should be a dropdown.
  final bool dropdown;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final _dropdown = IgnorePointer(
      ignoring: values.length <= 1,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: DropdownButton<T>(
          isDense: true,
          icon: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: FontIcon(
              FontIconData(
                IconsCG.angleDown,
                height: values.length <= 1 ? 0 : 10,
              ),
            ),
          ),
          style: theme.textTheme.bodyText1,
          underline: Divider(
            height: 1,
            thickness: 1 / 2,
            color: theme.colorScheme.onSurface,
          ),
          value: selected.isNotEmpty ? selected.first : null,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          items: <DropdownMenuItem<T>>[
            for (final value in values)
              DropdownMenuItem<T>(value: value, child: builder(context, value))
          ],
          onChanged: (final value) {
            if (value != null) {
              onSelected?.call(value, !selected.contains(value));
            }
          },
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(category, style: theme.textTheme.subtitle1),
          const SizedBox(height: 12),
          if (values.isNotEmpty)
            if (dropdown)
              dropdownBuilder?.call(context, _dropdown) ?? _dropdown
            else
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: values.isNotEmpty
                        ? maxWidth * values.length
                        : double.infinity,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: Table(
                      border: TableBorder.all(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                      ),
                      children: <TableRow>[
                        TableRow(
                          children: <Widget>[
                            for (final value in values)
                              TableCell(
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                child: TextButton(
                                  style: (selected.contains(value)
                                          ? TextButtonStyle.dark
                                          : TextButtonStyle.light)
                                      .fromTheme(
                                    theme,
                                    ButtonStyle(
                                      textStyle: MaterialStateProperty.all(
                                        theme.textTheme.bodyText1,
                                      ),
                                      shape: MaterialStateProperty.all(
                                        const RoundedRectangleBorder(),
                                      ),
                                      side: MaterialStateProperty.all(
                                        BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  onPressed: onSelected != null
                                      ? () => onSelected!(
                                            value,
                                            !selected.contains(value),
                                          )
                                      : null,
                                  child: builder(context, value),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DoubleProperty('maxWidth', maxWidth))
        ..add(IterableProperty<T>('values', values))
        ..add(
          ObjectFlagProperty<AbonementCategoryPickerBuilder<T>>.has(
            'builder',
            builder,
          ),
        )
        ..add(
          ObjectFlagProperty<
              Widget Function(BuildContext context, Widget child)>.has(
            'dropdownBuilder',
            dropdownBuilder,
          ),
        )
        ..add(StringProperty('category', category))
        ..add(IterableProperty<T>('selected', selected))
        ..add(
          ObjectFlagProperty<void Function(T p1, bool value)>.has(
            'onSelected',
            onSelected,
          ),
        )
        ..add(DiagnosticsProperty<bool>('dropdown', dropdown)),
    );
  }
}
