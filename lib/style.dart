import 'package:badges/badges.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/widgets/components/font_icon.dart';

/// The light theme in the app.
ThemeData get lightTheme {
  return _mainTheme.copyWith();
}

/// The dark theme in the app.
ThemeData get darkTheme {
  return _mainTheme.copyWith();
}

/// The same theme for light and dark theme in the app.
ThemeData get _mainTheme {
  return ThemeData.from(
    colorScheme: _colorScheme,
    textTheme: _textTheme,
  ).copyWith(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    hintColor: Colors.grey.withOpacity(3 / 4),
    appBarTheme: _appBarTheme,
    bottomSheetTheme: _bottomSheetTheme,
    buttonTheme: _buttonTheme,
    iconTheme: _iconTheme,
    floatingActionButtonTheme: _floatingActionButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    textSelectionTheme: _textSelectionTheme,
  );
}

FloatingActionButtonThemeData get _floatingActionButtonTheme {
  return FloatingActionButtonThemeData(
    enableFeedback: true,
    backgroundColor: _colorScheme.surface,
    foregroundColor: _colorScheme.onSurface,
    smallSizeConstraints: const BoxConstraints(minHeight: 32, minWidth: 32),
  );
}

ColorScheme get _colorScheme {
  return const ColorScheme.light(
    error: Color(0xFFF64A4A),
    primary: Color(0xFFB9506E),
    // primaryVariant: Color(0xFF303030),
    secondary: Color(0xFF5709FF),
    // secondaryVariant: Color(0xFF424242),
    // surface: ,
    background: Color(0xFFF5F5F5),
  );
}

BottomSheetThemeData get _bottomSheetTheme {
  return BottomSheetThemeData(
    elevation: 12,
    backgroundColor: _colorScheme.surface,
    modalBackgroundColor: _colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
  );
}

TextButtonThemeData get _textButtonTheme {
  return TextButtonThemeData(
    style: ButtonStyle(
      enableFeedback: true,
      minimumSize: MaterialStateProperty.all(Size.zero),
      maximumSize: MaterialStateProperty.all(Size.infinite),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      splashFactory: InkSplash.splashFactory,
      animationDuration: const Duration(milliseconds: 500),
      visualDensity: VisualDensity.comfortable,
      mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
      textStyle: MaterialStateProperty.all(_textTheme.button),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

IconThemeData get _iconTheme {
  return const IconThemeData(size: 20);
}

AppBarTheme get _appBarTheme {
  return AppBarTheme(
    backgroundColor: _colorScheme.onSurface,
    foregroundColor: _colorScheme.surface,
    shadowColor: Colors.transparent,
  );
}

TextTheme get _textTheme {
  return const TextTheme(
    headline1: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headline2: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    headline3: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    subtitle1: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.grey,
    ),
    subtitle2: TextStyle(fontSize: 16, color: Colors.grey),
    bodyText1: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
    bodyText2: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
    caption: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      decoration: TextDecoration.underline,
    ),
    button: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  ).apply(fontFamily: 'SF', displayColor: Colors.black);
}

InputDecorationTheme get _inputDecorationTheme {
  return InputDecorationTheme(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: _textTheme.subtitle1,
    floatingLabelStyle: _textTheme.subtitle2,
    hintStyle: _textTheme.bodyText2,
    helperStyle: _textTheme.bodyText1,
    errorStyle: _textTheme.bodyText2,
    border: const OutlineInputBorder(),
    enabledBorder: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(width: 2)),
    disabledBorder:
        const OutlineInputBorder(borderSide: BorderSide(width: 1 / 2)),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: _colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 2, color: _colorScheme.error),
    ),
  );
}

ButtonThemeData get _buttonTheme {
  return const ButtonThemeData(padding: EdgeInsets.zero, minWidth: 0);
}

TextSelectionThemeData get _textSelectionTheme {
  return TextSelectionThemeData(
    cursorColor: Colors.black,
    selectionColor: Colors.black.withOpacity(1 / 3),
    selectionHandleColor: Colors.black,
  );
}

/// The custom styles for the [TextButton].
enum TextButtonStyle {
  /// The light style for the [TextButton].
  light,

  /// The dark style for the [TextButton].
  dark
}

/// The extra data provided for [TextButtonStyle].
extension TextButtonStyleData on TextButtonStyle {
  /// Return this style from [theme].
  ButtonStyle fromTheme(final ThemeData theme) {
    switch (this) {
      case TextButtonStyle.light:
        return ButtonStyle(
          overlayColor: MaterialStateProperty.all(
            theme.colorScheme.onSurface.withOpacity(1 / 3),
          ),
          foregroundColor:
              MaterialStateProperty.all(theme.colorScheme.onSurface),
          backgroundColor: MaterialStateProperty.all(theme.colorScheme.surface),
          minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
          side: MaterialStateProperty.all(
            BorderSide(color: theme.colorScheme.onSurface),
          ),
        );
      case TextButtonStyle.dark:
        return ButtonStyle(
          overlayColor: MaterialStateProperty.all(
            theme.colorScheme.surface.withOpacity(1 / 3),
          ),
          foregroundColor: MaterialStateProperty.all(theme.colorScheme.surface),
          backgroundColor:
              MaterialStateProperty.all(theme.colorScheme.onSurface),
          minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
        );
    }
  }
}

/// The custom [InputDecoration] styles.
enum InputDecorationStyle {
  /// The style for the search field.
  search
}

/// The extra data provided for [InputDecorationStyle].
extension InputDecorationStyleData on InputDecorationStyle {
  /// Return this style's toolbar height.
  double get toolbarHeight {
    switch (this) {
      case InputDecorationStyle.search:
        return 40;
    }
  }

  /// Return this style from [theme].
  ///
  /// - [onSuffix] sets the callback on suffix.
  /// - If [suffixCount] is greater than 0, then badge is shown.
  InputDecoration fromTheme(
    final ThemeData theme, {
    final String? hintText,
    final void Function()? onSuffix,
    final int suffixCount = 0,
  }) {
    switch (this) {
      case InputDecorationStyle.search:
        return InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          prefixIcon: Align(
            child: FontIcon(
              FontIconData(IconsCG.search, color: theme.hintColor),
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 48, maxWidth: 48),
          suffix: suffixCount <= 0
              ? MaterialButton(
                  onPressed: onSuffix,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    TR.tooltipsCancel.tr(),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : null,
          suffixIcon: suffixCount > 0
              ? MaterialButton(
                  onPressed: onSuffix,
                  child: Badge(
                    badgeContent: Text(
                      suffixCount.toString(),
                      style: TextStyle(
                        height: 10,
                        color: theme.colorScheme.surface,
                      ),
                    ),
                    badgeColor: theme.colorScheme.onSurface,
                    animationType: BadgeAnimationType.scale,
                    child: FontIcon(
                      FontIconData(
                        IconsCG.filter,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                )
              : null,
          fillColor: theme.colorScheme.surface,
          hintText: hintText,
          border: InputBorder.none,
          disabledBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        );
    }
  }
}
