import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/providers/other_providers.dart';

/// The builder of the scrollable for the [CustomDraggableBottomSheet].
typedef ScrollablePhysicsWidgetBuilder = Widget Function(
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
  final ScrollablePhysicsWidgetBuilder builder;

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
    final mediaQuery = MediaQuery.of(context);
    final animatedContainerKey = useMemoized(GlobalKey.new);
    final sheetKey = useMemoized(GlobalKey.new);

    final height = useState<double>(0);
    useMemoized(
      () => height.value = 0,
      [mediaQuery.orientation],
    );

    final screenSize = useMemoized(
      () => mediaQuery.size.height,
      [mediaQuery.orientation],
    );

    final maxScreenSize = useMemoized<double>(
      () => mainContext != null
          ? screenSize - MediaQuery.of(mainContext!).viewPadding.top
          : screenSize,
      [mediaQuery.orientation],
    );

    // for some reason initSize can't equal max size for very long widgets
    final childKey = useMemoized(GlobalKey.new);
    useMemoized(
      () => ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
        final size = childKey.currentContext?.size;
        if (size != null) {
          height.value = size.height;
        }
      }),
      [mediaQuery.orientation],
    );

    if (height.value <= 0) {
      return SizedBox(key: childKey, child: builder(null, null));
    }

    double toScreenSize(final double? value) => value != null
        ? (0 <= value && value < 1 ? value : value / maxScreenSize)
        : 1;

    final maxChildSize = useMemoized<double>(
      () {
        var maxChildSize = height.value / maxScreenSize;
        maxChildSize = maxChildSize.clamp(0, maxScreenSize / screenSize);
        maxChildSize = maxChildSize * toScreenSize(childHeight);
        maxChildSize += maxChildSize * 0.001;
        return maxChildSize.clamp(0, maxScreenSize).toDouble();
      },
      [mediaQuery.orientation],
    );

    final minChildSize = useMemoized<double>(
      () => toScreenSize(dismissHeight ?? 1 / 2).clamp(0, maxChildSize),
      [mediaQuery.orientation],
    );

    final initialChildSize = useMemoized<double>(
      () => toScreenSize(initialHeight).clamp(minChildSize, maxChildSize),
      [mediaQuery.orientation],
    );

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (final event) {
        final paintBounds = sheetKey.globalPaintBounds;
        if (paintBounds != null && !paintBounds.contains(event.position)) {
          Navigator.of(context).maybePop();
        }
      },
      child: DraggableScrollableSheet(
        key: sheetKey,
        expand: false,
        maxChildSize: maxChildSize,
        minChildSize: minChildSize,
        initialChildSize: initialChildSize,
        builder: (final context, final controller) {
          return AnimatedContainer(
            key: animatedContainerKey,
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
          ObjectFlagProperty<ScrollablePhysicsWidgetBuilder>.has(
            'builder',
            builder,
          ),
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
