import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/main.dart';

/// The builder of the scrollable for the [CustomDraggableBottomSheet].
typedef ScrollableWidgetBuilder = Widget Function(
  ScrollController? controller,
  ScrollPhysics? physics,
);

/// The draggable bottom sheet that sizes itself to the child's height.
class CustomDraggableBottomSheet extends HookConsumerWidget {
  /// The draggable bottom sheet that sizes itself to the child's height.
  const CustomDraggableBottomSheet({
    required final this.builder,
    final this.childHeight,
    final this.initialHeight,
    final this.dismissHeight,
    final this.mainContext,
    final Key? key,
  })  : assert(
          childHeight == null || childHeight > 0,
          'Child height must be null or greater than zero.',
        ),
        assert(
          initialHeight == null || initialHeight > 0,
          'Initial height must be null or greater than zero.',
        ),
        assert(
          dismissHeight == null || dismissHeight > 0,
          'Dismiss height must be null or greater than zero.',
        ),
        super(key: key);

  /// The scrollable of this bottom sheet.
  final ScrollableWidgetBuilder builder;

  /// The height of the child widget.
  ///
  /// If this height is in 0-1 exclusive bounds, it is considered a factor.
  ///
  /// If height is null, it is set to maximum.
  final double? childHeight;

  /// The height at which the widget is created.
  ///
  /// If in 0-1 exclusive bounds, this height is considered a factor.
  final double? initialHeight;

  /// The minimum height at which the widget is dismissible.
  ///
  /// If in 0-1 exclusive bounds, this height is considered a factor.
  final double? dismissHeight;

  /// The context from the main application.
  final BuildContext? mainContext;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final sheetKey = useMemoized(() => GlobalKey());
    final height = useState<double>(0);

    final screenSize = useMemoized(() => MediaQuery.of(context).size.height);
    final maxScreenSize = useMemoized<double>(() {
      var maxSize = screenSize;
      final _mainContext = mainContext;
      if (_mainContext != null) {
        final topPadding = MediaQuery.of(_mainContext).viewPadding.top;
        maxSize -= topPadding;
      }
      return maxSize;
    });

    // calculate the proportion
    final maxChildSize = useMemoized<double>(
      () {
        return (height.value / maxScreenSize)
            .clamp(0, maxScreenSize / screenSize);
      },
      [height.value],
    );

    // for some reason initSize can't equal max size for very long widgets

    final childKey = useMemoized(() => GlobalKey());
    useMemoized(() {
      ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
        final size = childKey.currentContext?.size;
        if (size != null) {
          height.value = size.height;
        }
      });
    });

    if (height.value == 0) {
      return SizedBox(key: childKey, child: builder(null, null));
    }

    double toScreenSize(final double? value) {
      return value != null
          ? 0 <= value && value < 1
              ? value
              : value / maxScreenSize
          : 1;
    }

    var validMaxChildSize = maxChildSize * toScreenSize(childHeight);
    validMaxChildSize -= validMaxChildSize * 0.001;
    validMaxChildSize = validMaxChildSize.clamp(.0, maxScreenSize);
    final minChildSize =
        toScreenSize(dismissHeight).clamp(.0, validMaxChildSize);
    final initialChildSize =
        toScreenSize(initialHeight).clamp(minChildSize, validMaxChildSize);
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (final event) {
        final paintBounds = sheetKey.globalPaintBounds;
        if (paintBounds != null && !paintBounds.contains(event.position)) {
          Navigator.of(context).pop();
        }
      },
      child: DraggableScrollableSheet(
        key: sheetKey,
        expand: false,
        maxChildSize: validMaxChildSize,
        minChildSize: minChildSize,
        initialChildSize: initialChildSize,
        builder: (final context, final controller) {
          return AnimatedContainer(
            height: height.value,
            duration: const Duration(seconds: 1),
            child: SizedBox(
              key: childKey,
              child: builder(
                controller,
                maxChildSize < maxScreenSize / screenSize
                    ? const NeverScrollableScrollPhysics()
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(
          ObjectFlagProperty<ScrollableWidgetBuilder>.has('builder', builder),
        )
        ..add(DoubleProperty('childHeight', childHeight))
        ..add(DoubleProperty('initialHeight', initialHeight))
        ..add(DoubleProperty('dismissHeight', dismissHeight))
        ..add(DiagnosticsProperty<BuildContext?>('mainContext', mainContext)),
    );
  }
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

// /// The widget used to measure it's child size.
// class MeasuredWidget extends HookConsumerWidget {
//   /// The widget used to measure it's child size.
//   const MeasuredWidget({
//     required final this.onCalculateSize,
//     required final this.child,
//     final Key? key,
//   }) : super(key: key);

//   /// The callback to call when widget size was determined.
//   final void Function(Size size) onCalculateSize;

//   /// The child of this wrapper widget.
//   final Widget child;

//   @override
//   Widget build(final BuildContext context, final WidgetRef ref) {
//     final widgetKey = useMemoized(() => GlobalKey());
//     useMemoized(() {
//       ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
//         final size = widgetKey.currentContext?.size;
//         if (size != null) {
//           onCalculateSize(size);
//         }
//       });
//     });
//     return SizedBox(key: widgetKey, child: child);
//   }

//   @override
//   void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
//     super.debugFillProperties(
//       properties
//         ..add(
//           ObjectFlagProperty<Function(Size size)>.has(
//             'onCalculateSize',
//             onCalculateSize,
//           ),
//         ),
//     );
//   }
// }
