import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/widgets/navigation/root.dart';

/// The mixin that provides modal bottom sheets for regular usage.
mixin ModalBottomSheets {
  /// The reference to other providers.
  ProviderRefBase get ref;

  Future<T?> showAlertBottomSheet<T extends Object>({
    required final BuildContext context,
    final String? firstText,
    final void Function()? onFirstPressed,
    final String? secondsText,
    final void Function()? onSecondPressed,
  }) {
    return showCustomModalBottomSheet<T>(
      context: context,
      builder: (final context) {
        return _BottomSheetBase();
      },
    );
  }

  /// Show the custom modal bottom sheet and hide the navigation bar.
  Future<T?> showCustomModalBottomSheet<T>({
    required final BuildContext context,
    required final WidgetBuilder builder,
  }) async {
    final hideNavigation = ref.read(hideNavigationProvider)..state = true;
    try {
      return await showModalBottomSheet<T>(context: context, builder: builder);
    } finally {
      hideNavigation.state = false;
    }
  }
}

class _BottomSheetBase extends StatelessWidget {
  const _BottomSheetBase({
    final this.child,
    final this.title,
    final Key? key,
  }) : super(key: key);

  final Widget? child;
  final String? title;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: <Widget>[
        const SizedBox(height: 150),
        if (child != null) child!,
        if (title != null)
          Positioned(
            top: 20,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(title!, style: theme.textTheme.headline2),
            ),
          ),
        Positioned(
          top: 12,
          right: 12,
          child: IconButton(
            splashRadius: 24,
            padding: EdgeInsets.zero,
            tooltip: TR.tooltipsClose.tr(),
            icon: const Icon(IconsCG.close),
            onPressed: Navigator.maybeOf(context)?.pop,
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties..add(StringProperty('title', title)));
  }
}
