import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stretching/generated/icons.g.dart';

// ignore_for_file: sort_constructors_first

/// The [IconData] extension with a data specific for rendering a widget.
@immutable
class FontIconData {
  /// The [IconData] extension with a data specific for rendering a widget.
  const FontIconData(
    final this.icon, {
    final this.width,
    final this.height,
    final this.color,
    final AlignmentGeometry? alignment,
    final BoxFit? fit,
    final AlignmentGeometry? selfAlignment,
    final EdgeInsetsGeometry? padding,
  })  : alignment = alignment ?? Alignment.center,
        fit = fit ?? BoxFit.contain,
        selfAlignment = selfAlignment ?? Alignment.center,
        padding = padding ?? EdgeInsets.zero;

  /// The icon to pass to this font icon.
  final IconData icon;

  /// The width of this icon when positioned.
  final double? width;

  /// The height of this icon when positioned.
  final double? height;

  /// The color of this icon when positioned.
  final Color? color;

  /// The alignment of this icon when positioned.
  final AlignmentGeometry alignment;

  /// The fit of the icon when positioned within its bounds.
  final BoxFit fit;

  /// The alignment of this icon when positioned within its bounds.
  final AlignmentGeometry selfAlignment;

  /// The padding of this icon when positioned.
  final EdgeInsetsGeometry padding;

  /// Return the painter for this icon.
  TextPainter getPainter([final IconThemeData? iconTheme]) {
    return TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          inherit: false,
          letterSpacing: 0,
          fontSize: height ?? iconTheme?.size,
          color: color ?? iconTheme?.color,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      )
      ..layout();
  }

  /// Return the copy of this model.
  FontIconData copyWith({
    final IconData? icon,
    final double? width,
    final double? height,
    final Color? color,
    final AlignmentGeometry? alignment,
    final BoxFit? fit,
    final AlignmentGeometry? selfAlignment,
    final EdgeInsetsGeometry? padding,
  }) {
    return FontIconData(
      icon ?? this.icon,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      alignment: alignment ?? this.alignment,
      fit: fit ?? this.fit,
      selfAlignment: selfAlignment ?? this.selfAlignment,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(final Object other) {
    return identical(this, other) ||
        other is FontIconData &&
            other.icon == icon &&
            other.width == width &&
            other.height == height &&
            other.color == color &&
            other.alignment == alignment &&
            other.fit == fit &&
            other.selfAlignment == selfAlignment &&
            other.padding == padding;
  }

  @override
  int get hashCode {
    return icon.hashCode ^
        width.hashCode ^
        height.hashCode ^
        color.hashCode ^
        alignment.hashCode ^
        fit.hashCode ^
        selfAlignment.hashCode ^
        padding.hashCode;
  }

  @override
  String toString() {
    return 'FontIconData(icon: $icon, width: $width, height: $height, '
        'color: $color, alignment: $alignment, fit: $fit, '
        'selfAlignment: $selfAlignment, padding: $padding)';
  }
}

/// The widget to stack icons on top of each other.
class MultiFontIcon extends StatelessWidget {
  /// The widget to stack icons on top of each other.
  const MultiFontIcon(
    final this.icons, {
    final this.width,
    final this.height,
    final Key? key,
  }) :
        // assert(
        //   _areAllItemsInside(icons, width, height),
        //   'One or more of the icons are bigger than maximum size',
        // ),
        super(key: key);

  /// The list of icons to display.
  final Iterable<FontIconData> icons;

  /// The width of the final widget.
  final double? width;

  /// The height of the final widget.
  final double? height;

  // static bool _areAllItemsInside(
  //   Iterable<FontIconData> icons,
  //   double? width,
  //   double? height,
  // ) {
  //   final Size size;
  //   if (height != null && width != null) {
  //     size = Size(width, height);
  //   } else if (width == null && height != null) {
  //     size = Size.fromHeight(height);
  //   } else if (height == null && width != null) {
  //     size = Size.fromWidth(width);
  //   } else {
  //     return true;
  //   }

  //   for (final icon in icons) {
  //     final iconWidth = icon.width + icon.padding.horizontal;
  //     final iconHeight = icon.height + icon.padding.vertical;

  //     final iconSize = Offset(iconWidth, iconHeight);
  //     if (!size.contains(iconSize)) {
  //       return false;
  //     }
  //   }

  //   return true;
  // }

  @override
  Widget build(final BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          for (final icon in icons)
            Align(
              alignment: icon.alignment,
              child: Padding(
                padding: icon.padding,
                child: FontIcon(icon),
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
        ..add(IterableProperty<FontIconData>('icons', icons))
        ..add(DoubleProperty('width', width))
        ..add(DoubleProperty('height', height)),
    );
  }
}

/// The widget to display icon properly from [IconData].
class FontIcon extends StatelessWidget {
  /// The widget to display icon properly from [IconData].
  const FontIcon(final this.data, {final Key? key}) : super(key: key);

  /// The data of this font icon.
  final FontIconData data;

  @override
  Widget build(final BuildContext context) {
    final painter = data.getPainter(Theme.of(context).iconTheme);
    return SizedBox(
      height: data.height,
      width: data.width ?? painter.width,
      child: FittedBox(
        fit: data.fit,
        alignment: data.alignment,
        child: Text.rich(painter.text!),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties..add(DiagnosticsProperty<FontIconData>('data', data)),
    );
  }
}

/// The icon button made from [FontIcon].
class FontIconButton extends StatelessWidget {
  /// The icon button made from [FontIcon].
  const FontIconButton(
    final this.icon, {
    final this.splashMultiplier = 4 / 5,
    final this.constraints,
    final this.color,
    final this.backgroudColor = Colors.transparent,
    final this.disabledColor,
    final this.tooltip,
    final this.onPressed,
    final Key? key,
  }) : super(key: key);

  /// The icon for this button.
  final FontIcon icon;

  /// The multiplier for the splash / icon propotion.
  final double splashMultiplier;

  /// The constraints for this button.
  final BoxConstraints? constraints;

  /// The color of this icon.
  final Color? color;

  /// The color of the background of this icon.
  final Color backgroudColor;

  /// The color of this icon when [onPressed] is null.
  final Color? disabledColor;

  /// The tooltip for this button.
  final String? tooltip;

  /// The function for this button.
  final void Function()? onPressed;

  @override
  Widget build(final BuildContext context) {
    return Material(
      color: backgroudColor,
      shape: const CircleBorder(),
      child: IconButton(
        icon: icon,
        color: color,
        disabledColor: disabledColor,
        tooltip: tooltip,
        onPressed: onPressed,
        padding: icon.data.padding,
        alignment: icon.data.alignment,
        constraints: constraints ??
            (icon.data.height != null || icon.data.width != null
                ? BoxConstraints(
                      minHeight: icon.data.height ?? 0,
                      maxHeight: icon.data.height ?? double.infinity,
                      minWidth: icon.data.width ?? 0,
                      maxWidth: icon.data.width ?? double.infinity,
                    ) *
                    2
                : null),
        splashRadius: icon.data.height != null || icon.data.width != null
            ? max(icon.data.height ?? 0, icon.data.height ?? 0) *
                splashMultiplier
            : null,
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<Widget>('icon', icon))
        ..add(DoubleProperty('splashMultiplier', splashMultiplier))
        ..add(DiagnosticsProperty<BoxConstraints>('constraints', constraints))
        ..add(ColorProperty('color', color))
        ..add(ColorProperty('backgroudColor', backgroudColor))
        ..add(ColorProperty('disabledColor', disabledColor))
        ..add(StringProperty('tooltip', tooltip))
        ..add(DiagnosticsProperty<void Function()>('onPressed', onPressed)),
    );
  }
}

/// The icon button to go back to previous screen.
class FontIconBackButton extends StatelessWidget {
  /// The icon button to go back to previous screen.
  const FontIconBackButton({
    final this.size = 28,
    final this.color = Colors.white,
    final this.onPressed,
    final Key? key,
  }) : super(key: key);

  /// The size of this icon.
  final double size;

  /// The color of this icon.
  final Color? color;

  /// The functionality of this button.
  final void Function()? onPressed;

  @override
  Widget build(final BuildContext context) {
    return FontIconButton(
      FontIcon(
        FontIconData(
          IconsCG.back,
          color: color,
          height: size,
          width: size,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 4),
        ),
      ),
      color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DoubleProperty('size', size))
        ..add(ColorProperty('color', color))
        ..add(DiagnosticsProperty<void Function()>('onPressed', onPressed)),
    );
  }
}
