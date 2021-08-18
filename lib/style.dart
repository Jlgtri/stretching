import 'package:flutter/material.dart';

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
    iconTheme: _iconTheme,
    textButtonTheme: _textButtonTheme,
  );
}

ColorScheme get _colorScheme {
  return const ColorScheme.light(
    error: Color(0xFFF64A4A),
    primary: Color(0xFFF5F5F5),
    primaryVariant: Color(0xFF303030),
    secondary: Color(0xFF757575),
    secondaryVariant: Color(0xFF424242),
    surface: Color(0xFFF5F5F5),
  );
}

BottomSheetThemeData get _bottomSheetTheme {
  return const BottomSheetThemeData(
    elevation: 12,
    backgroundColor: Colors.white,
    modalBackgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
  );
}

TextButtonThemeData get _textButtonTheme {
  return TextButtonThemeData(
    style: TextButton.styleFrom(
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  );
}

IconThemeData get _iconTheme {
  return const IconThemeData(size: 20);
}

AppBarTheme get _appBarTheme {
  return const AppBarTheme(
    backgroundColor: Colors.black,
    shadowColor: Colors.transparent,
    foregroundColor: Colors.white,
  );
}

TextTheme get _textTheme {
  return const TextTheme(
    headline1: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headline2: TextStyle(fontSize: 28),
    headline3: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    subtitle1: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.grey,
    ),
    subtitle2: TextStyle(fontSize: 16, color: Colors.grey),
    bodyText1: TextStyle(fontSize: 18),
    bodyText2: TextStyle(fontSize: 16),
    caption: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      decoration: TextDecoration.underline,
    ),
    button: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  ).apply(
    fontFamily: 'SF',
    displayColor: Colors.black,
    bodyColor: const Color(0xFF03010D),
  );
}
