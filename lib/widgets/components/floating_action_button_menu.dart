import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// The floating action button menu widget.
class FloatingActionButtonMenu extends HookWidget {
  /// The floating action button menu widget.
  const FloatingActionButtonMenu({
    required final this.children,
    required final this.icon,
    final this.spacing = -5.0,
    final this.duration = const Duration(milliseconds: 500),
    final this.curve = Curves.easeOut,
    final this.colorStart,
    final this.colorEnd,
    final this.tooltip,
    final Key? key,
  }) : super(key: key);

  /// The children for this menu.
  final Iterable<Widget> children;

  /// The animated icon for this menu.
  final AnimatedIconData icon;

  /// The spacing between children of this menu.
  final double spacing;

  /// Th duration of the transition of this menu.
  final Duration duration;

  /// The curve of the transition of this menu.
  final Curve curve;

  /// This menu's transition start color.
  final Color? colorStart;

  /// This menu's transition end color.
  final Color? colorEnd;

  /// The tooltip to show on long press of this menu.
  final String? tooltip;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context).floatingActionButtonTheme;
    final isOpened = useState<bool>(false);
    final controller = useAnimationController(duration: duration);

    /// This Tween is to animate the icon of the main FAB.
    final animateIconAnimation =
        useMemoized(() => Tween<double>(begin: 0, end: 1).animate(controller));
    final animateIcon = useAnimation<double>(animateIconAnimation);

    /// This ColorTween is to animate the foreground Color of main FAB.
    final iconColor = useAnimation<Color?>(
      ColorTween(
        begin: colorEnd ?? theme.foregroundColor,
        end: colorStart ?? theme.backgroundColor,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear)),
    );

    /// This ColorTween is to animate the background Color of main FAB.
    final buttonColor = useAnimation<Color?>(
      ColorTween(
        begin: colorStart ?? theme.backgroundColor,
        end: colorEnd ?? theme.foregroundColor,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear)),
    );

    /// This Tween is to animate the position of the current fab
    /// according to its position in the list.
    final translateButton = useAnimation<double>(
      Tween<double>(begin: 56, end: spacing).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(0, 3 / 4, curve: curve),
        ),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (var i = 0; i < children.length; i++)
          Opacity(
            opacity: animateIcon,
            child: Transform(
              transform: Matrix4.translationValues(
                0,
                translateButton * (children.length - i),
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[children.elementAt(i)],
              ),
            ),
          ),
        FloatingActionButton.small(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: buttonColor,
          tooltip: tooltip,
          foregroundColor: iconColor,
          onPressed: () => (isOpened.value = !isOpened.value)
              ? controller.forward()
              : controller.reverse(),
          child: AnimatedIcon(icon: icon, progress: animateIconAnimation),
        )
      ],
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(IterableProperty<Widget>('children', children))
        ..add(DiagnosticsProperty<AnimatedIconData>('icon', icon))
        ..add(DiagnosticsProperty<Duration>('duration', duration))
        ..add(ColorProperty('colorEnd', colorEnd))
        ..add(DiagnosticsProperty<Curve>('curve', curve))
        ..add(StringProperty('tooltip', tooltip))
        ..add(ColorProperty('colorStart', colorStart))
        ..add(DoubleProperty('spacing', spacing)),
    );
  }
}
