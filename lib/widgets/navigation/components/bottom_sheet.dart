import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/components/custom_draggable_bottom_sheet.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The mixin that provides modal bottom sheets for regular usage.
mixin ModalBottomSheets {
  /// The reference to other providers.
  ProviderRefBase get ref;

  /// Show the custom modal bottom sheet and hide the navigation bar.
  Future<T> showAlertBottomSheet<T extends Object>({
    required final BuildContext context,
    required final T defaultValue,
    final String title = '',
    final String firstText = '',
    final OnBottomButton<T>? onFirstPressed,
    final String secondText = '',
    final OnBottomButton<T>? onSecondPressed,
  }) async {
    final result = await showCustomModalBottomSheet<T>(
      context: context,
      builder: (final _) {
        return CustomDraggableBottomSheet(
          mainContext: context,
          builder: (final controller, final physics) {
            return _BottomSheetBase(
              title: title,
              controller: controller,
              physics: physics,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 36,
                ),
                child: BottomButtons<T>(
                  firstText: firstText,
                  onFirstPressed: onFirstPressed,
                  secondText: secondText,
                  onSecondPressed: onSecondPressed,
                ),
              ),
            );
          },
        );
      },
    );
    return result ?? defaultValue;
  }

  /// Show the custom modal bottom sheet and hide the navigation bar.
  Future<T?> showCustomModalBottomSheet<T>({
    required final BuildContext context,
    required final WidgetBuilder builder,
  }) async {
    final hideNavigation = ref.read(hideNavigationProvider)..state = true;
    try {
      return await showModalBottomSheet<T>(
        context: context,
        builder: builder,
        useRootNavigator: true,
        isScrollControlled: true,
      );
    } finally {
      hideNavigation.state = false;
    }
  }
}

class _BottomSheetBase extends StatelessWidget {
  const _BottomSheetBase({
    final this.child,
    final this.title = '',
    final this.controller,
    final this.physics,
    final Key? key,
  }) : super(key: key);

  final Widget? child;
  final String title;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      shrinkWrap: true,
      controller: controller,
      physics: physics,
      padding: EdgeInsets.zero,
      children: <Widget>[
        Stack(
          alignment: Alignment.topRight,
          children: <Widget>[
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 56, 0, 0),
                child: Row(
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.headline3?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 24, 20, 0),
              child: IconButton(
                iconSize: 16,
                splashRadius: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(maxHeight: 28, maxWidth: 28),
                tooltip: TR.tooltipsClose.tr(),
                icon: const Icon(IconsCG.close),
                onPressed: Navigator.maybeOf(context)?.pop,
              ),
            ),
          ],
        ),
        if (child != null) child!,
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(StringProperty('title', title))
        ..add(DiagnosticsProperty<ScrollController?>('controller', controller))
        ..add(DiagnosticsProperty<ScrollPhysics?>('physics', physics)),
    );
  }
}

/// The callback to call when bottom sheet button was pressed.
typedef OnBottomButton<T> = FutureOr<T> Function(BuildContext);

/// The buttons that are persistent at the bottom of the screen.
class BottomButtons<T> extends StatelessWidget {
  /// The buttons that are persistent at the bottom of the screen.
  const BottomButtons({
    required final this.firstText,
    final this.onFirstPressed,
    final this.secondText = '',
    final this.onSecondPressed,
    final this.direction = Axis.vertical,
    final this.inverse = false,
    final Key? key,
  })  : assert(firstText != '', 'There must be at least one button.'),
        super(key: key);

  /// The text of the first button.
  final String firstText;

  /// The callback of the first button.
  final OnBottomButton<T>? onFirstPressed;

  /// The text of the second button.
  final String secondText;

  /// The callback of the second button.
  final OnBottomButton<T>? onSecondPressed;

  /// The axis to put
  final Axis direction;

  /// If styles of the buttons should be switched.
  final bool inverse;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Flex(
      direction: direction,
      children: <Widget>[
        Flexible(
          child: TextButton(
            onPressed:
                onFirstPressed != null ? () => onFirstPressed!(context) : null,
            style: !inverse
                ? TextButtonStyle.dark.fromTheme(theme)
                : TextButtonStyle.light.fromTheme(theme),
            child: Text(
              firstText,
              style: TextStyle(
                color: !inverse
                    ? theme.colorScheme.surface
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        if (secondText.isNotEmpty) ...[
          if (direction == Axis.vertical)
            const SizedBox(height: 16)
          else
            const SizedBox(width: 8),
          Flexible(
            child: TextButton(
              onPressed: onSecondPressed != null
                  ? () => onSecondPressed!(context)
                  : null,
              style: !inverse
                  ? TextButtonStyle.light.fromTheme(theme)
                  : TextButtonStyle.dark.fromTheme(theme),
              child: Text(
                secondText,
                style: TextStyle(
                  color: !inverse
                      ? theme.colorScheme.surface
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(StringProperty('firstText', firstText))
        ..add(
          ObjectFlagProperty<OnBottomButton<T>?>.has(
            'onFirstPressed',
            onFirstPressed,
          ),
        )
        ..add(StringProperty('secondText', secondText))
        ..add(
          ObjectFlagProperty<OnBottomButton<T>?>.has(
            'onSecondPressed',
            onSecondPressed,
          ),
        )
        ..add(EnumProperty<Axis>('direction', direction))
        ..add(DiagnosticsProperty<bool>('inverse', inverse)),
    );
  }
}
