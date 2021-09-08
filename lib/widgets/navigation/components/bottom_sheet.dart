import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/components/custom_draggable_bottom_sheet.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The mixin that provides modal bottom sheets for regular usage.
mixin ModalBottomSheets {
  /// The reference to other providers.
  ProviderRefBase get ref;

  /// Show the custom modal bottom sheet and hide the navigation bar.
  Future<T?> showAlertBottomSheet<T extends Object?>({
    required final BuildContext context,
    required final ScrollablePhysicsWidgetBuilder builder,
    final String title = '',
    final Widget? trailing,
    final double borderRadius = 24,
  }) async {
    final result = await showCustomModalBottomSheet<T>(
      context: context,
      borderRadius: borderRadius,
      builder: (final _) {
        return CustomDraggableBottomSheet(
          mainContext: context,
          builder: (final controller, final physics) {
            return BottomSheetHeader(
              title: title,
              trailing: trailing,
              // child: builder(controller, physics),
            );
          },
        );
      },
    );
    return result;
  }

  /// Show the custom modal bottom sheet and hide the navigation bar.
  Future<T?> showCustomModalBottomSheet<T>({
    required final BuildContext context,
    required final WidgetBuilder builder,
    final double borderRadius = 24,
  }) async {
    final hideNavigation = ref.read(hideNavigationProvider)..state = true;
    try {
      return await showModalBottomSheet<T>(
        context: context,
        builder: builder,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
          ),
        ),
      );
    } finally {
      hideNavigation.state = false;
    }
  }
}

/// The header for the [showModalBottomSheet].
class BottomSheetHeader extends StatelessWidget {
  /// The header for the [showModalBottomSheet].
  const BottomSheetHeader({
    final this.title = '',
    final this.trailing,
    final Key? key,
  }) : super(key: key);

  /// The title of this bottom sheet.
  final String title;

  /// The trailing widget in the header of this bottom sheet base.
  final Widget? trailing;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: <Widget>[
        /// Title
        if (title.isNotEmpty)
          Padding(
            padding: trailing == null
                ? const EdgeInsets.only(left: 16, top: 56)
                : const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: trailing != null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
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

        /// Close button
        Align(
          alignment: trailing != null ? Alignment.topLeft : Alignment.topRight,
          child: Padding(
            padding: trailing != null
                ? const EdgeInsets.only(top: 12, left: 10)
                : const EdgeInsets.only(top: 24, right: 20),
            child: IconButton(
              iconSize: trailing != null ? 20 : 16,
              splashRadius: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxHeight: 28, maxWidth: 28),
              tooltip: TR.tooltipsClose.tr(),
              icon: FontIcon(
                FontIconData(
                  trailing != null ? IconsCG.closeSlim : IconsCG.close,
                ),
              ),
              onPressed: Navigator.maybeOf(context)?.pop,
            ),
          ),
        ),

        if (trailing != null)
          Align(
            alignment: Alignment.topRight,
            child: trailing,
          ),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<Widget?>('trailing', trailing))
        ..add(StringProperty('title', title)),
    );
  }
}

/// The callback to call when bottom sheet button was pressed.
typedef OnBottomButton<T> = FutureOr<T> Function(BuildContext);

/// The buttons that are persistent at the bottom of the screen.
class BottomButtons<T> extends StatelessWidget {
  /// The buttons that are persistent at the bottom of the screen.
  const BottomButtons({
    final this.firstText = '',
    final this.onFirstPressed,
    final this.secondText = '',
    final this.onSecondPressed,
    final this.direction = Axis.vertical,
    final this.inverse = false,
    final Key? key,
  }) : super(key: key);

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
    final defaultDarkStyle = TextButtonStyle.dark.fromTheme(theme);
    final darkStyle = defaultDarkStyle.copyWith(
      foregroundColor: MaterialStateProperty.all(theme.colorScheme.surface),
    );
    final defaultLightStyle = TextButtonStyle.light.fromTheme(theme);
    final lightStyle = defaultLightStyle.copyWith(
      foregroundColor: MaterialStateProperty.all(theme.colorScheme.onSurface),
    );
    return Flex(
      mainAxisSize: MainAxisSize.min,
      direction: direction,
      children: <Widget>[
        Flexible(
          child: TextButton(
            onPressed:
                onFirstPressed != null ? () => onFirstPressed!(context) : null,
            style: !inverse ? darkStyle : lightStyle,
            child: Text(firstText),
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
              style: !inverse ? lightStyle : darkStyle,
              child: Text(secondText),
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
