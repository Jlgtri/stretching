import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stretching/generated/icons.g.dart';

// ignore_for_file: sort_constructors_first

/// The [IconData] extension with a data specific for rendering a widget.
class FontIconData extends IconData {
  /// The [IconData] extension with a data specific for rendering a widget.
  const FontIconData(
    final int codePoint, {
    final String? fontFamily,
    final String? fontPackage,
    final bool matchTextDirection = false,
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
        padding = padding ?? EdgeInsets.zero,
        super(
          codePoint,
          fontFamily: fontFamily,
          fontPackage: fontPackage,
          matchTextDirection: matchTextDirection,
        );

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

  /// Constructor of a [FontIconData] from [IconData].
  factory FontIconData.fromIconData(
    final IconData icon, {
    final double? width,
    final double? height,
    final Color? color,
    final AlignmentGeometry? alignment,
    final BoxFit? fit,
    final AlignmentGeometry? selfAlignment,
    final EdgeInsetsGeometry? padding,
  }) {
    return FontIconData(
      icon.codePoint,
      width: width,
      height: height,
      color: color,
      alignment: alignment,
      fit: fit,
      selfAlignment: selfAlignment,
      padding: padding,
      fontFamily: icon.fontFamily,
      fontPackage: icon.fontPackage,
      matchTextDirection: icon.matchTextDirection,
    );
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
                child: FontIcon(
                  icon,
                  width: icon.width,
                  color: icon.color,
                  fit: icon.fit,
                  alignment: icon.selfAlignment,
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
        ..add(IterableProperty<FontIconData>('icons', icons))
        ..add(DoubleProperty('width', width))
        ..add(DoubleProperty('height', height)),
    );
  }
}

/// The widget to display icon properly from [IconData].
class FontIcon extends Icon {
  /// The widget to display icon properly from [IconData].
  const FontIcon(
    final IconData icon, {
    final this.width,
    final double? height,
    final BoxFit? fit,
    final Color? color,
    final AlignmentGeometry? alignment,
    final Key? key,
  })  : fit = fit ?? BoxFit.scaleDown,
        alignment = alignment ?? Alignment.center,
        super(
          icon,
          color: color,
          size: height,
          textDirection: TextDirection.ltr,
          key: key,
        );

  /// The size of the icon.
  final double? width;

  /// The fit of this icon.
  final BoxFit fit;

  /// The alignment of this icon within its bounds.
  final AlignmentGeometry alignment;

  @override
  Widget build(final BuildContext context) {
    final iconTheme = Theme.of(context).iconTheme;
    final painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon!.codePoint),
        style: TextStyle(
          inherit: false,
          letterSpacing: 0,
          fontSize: size ?? iconTheme.size,
          color: color ?? iconTheme.color,
          fontFamily: icon!.fontFamily,
          package: icon!.fontPackage,
        ),
      )
      ..layout();

    return SizedBox(
      height: size,
      width: width ?? painter.width,
      child: FittedBox(
        fit: fit,
        alignment: alignment,
        child: Text.rich(painter.text!),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<IconData>('icon', icon))
        ..add(DoubleProperty('width', width))
        ..add(ColorProperty('color', color))
        ..add(EnumProperty<BoxFit>('fit', fit))
        ..add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment)),
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
        padding: EdgeInsets.zero,
        constraints: constraints ??
            (icon.size != null || icon.width != null
                ? BoxConstraints(
                      minHeight: icon.size ?? 0,
                      maxHeight: icon.size ?? double.infinity,
                      minWidth: icon.width ?? 0,
                      maxWidth: icon.width ?? double.infinity,
                    ) *
                    2
                : null),
        splashRadius: icon.size != null || icon.width != null
            ? max(icon.size ?? 0, icon.width ?? 0) * splashMultiplier
            : null,
        color: color,
        disabledColor: disabledColor,
        icon: icon,
        tooltip: tooltip,
        onPressed: onPressed,
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
    final this.color = Colors.white,
    final this.onPressed,
    final Key? key,
  }) : super(key: key);

  /// The color of this icon.
  final Color? color;

  /// The functionality of this button.
  final void Function()? onPressed;

  @override
  Widget build(final BuildContext context) {
    return FontIconButton(
      FontIcon(IconsCG.back, color: color, height: 24, width: 24),
      color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: onPressed ?? Navigator.of(context).maybePop,
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(ColorProperty('color', color))
        ..add(DiagnosticsProperty<void Function()>('onPressed', onPressed)),
    );
  }
}
