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
    final OnBottomSheetButton<T>? onFirstPressed,
    final String secondText = '',
    final OnBottomSheetButton<T>? onSecondPressed,
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
                child: _BottomSheetButtons<T>(
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
typedef OnBottomSheetButton<T extends Object> = FutureOr<T> Function(
  BuildContext context,
);

class _BottomSheetButtons<T extends Object> extends StatelessWidget {
  const _BottomSheetButtons({
    final this.firstText = '',
    final this.onFirstPressed,
    final this.secondText = '',
    final this.onSecondPressed,
    final Key? key,
  }) : super(key: key);

  final String firstText;
  final OnBottomSheetButton<T>? onFirstPressed;
  final String secondText;
  final OnBottomSheetButton<T>? onSecondPressed;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (firstText.isNotEmpty)
          TextButton(
            onPressed:
                onFirstPressed != null ? () => onFirstPressed!(context) : null,
            style: TextButtonStyle.dark.fromTheme(theme),
            child: Text(
              firstText,
              style: TextStyle(color: theme.colorScheme.surface),
            ),
          ),
        if (secondText.isNotEmpty) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: onSecondPressed != null
                ? () => onSecondPressed!(context)
                : null,
            style: TextButtonStyle.light.fromTheme(theme),
            child: Text(
              secondText,
              style: TextStyle(color: theme.colorScheme.onSurface),
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
          ObjectFlagProperty<OnBottomSheetButton<T>?>.has(
            'onFirstPressed',
            onFirstPressed,
          ),
        )
        ..add(StringProperty('secondText', secondText))
        ..add(
          ObjectFlagProperty<OnBottomSheetButton<T>?>.has(
            'onSecondPressed',
            onSecondPressed,
          ),
        ),
    );
  }
}
