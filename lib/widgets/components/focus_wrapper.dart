import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Unfocus scope primary focus node on action.
class FocusWrapper extends StatelessWidget {
  /// Unfocus scope primary focus node on action.
  const FocusWrapper({
    required final this.child,
    final this.unfocus = true,
    final this.onlyWithoutKeyboard = false,
    final this.unfocussableKeys = const Iterable<GlobalKey>.empty(),
    final Key? key,
  }) : super(key: key);

  /// The child of this widget.
  final Widget child;

  /// If this widget should unfocus.
  final bool unfocus;

  /// If this widget should unfocus only without keyboard shown on the screen.
  final bool onlyWithoutKeyboard;

  /// The keys of the widgets that should not trigger unfocus operation.
  /// For example, fields themselves.
  final Iterable<GlobalKey> unfocussableKeys;

  @override
  Widget build(final BuildContext context) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: unfocus
            ? (final event) {
                for (final key in unfocussableKeys) {
                  if (key.globalPaintBounds?.contains(event.position) ??
                      false) {
                    return;
                  }
                }

                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus &&
                    currentFocus.focusedChild != null &&
                    (!onlyWithoutKeyboard ||
                        MediaQuery.of(context).viewInsets.bottom == 0)) {
                  currentFocus.focusedChild?.unfocus();
                }
              }
            : null,
        child: child,
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) =>
      super.debugFillProperties(
        properties
          ..add(DiagnosticsProperty<bool>('unfocus', unfocus))
          ..add(
            DiagnosticsProperty<bool>(
              'onlyWithoutKeyboard',
              onlyWithoutKeyboard,
            ),
          )
          ..add(
            IterableProperty<GlobalKey>(
              'unfocussableKeys',
              unfocussableKeys,
            ),
          ),
      );
}

extension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();

    if (translation != null && renderObject != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject.paintBounds.shift(offset);
    }
  }
}
