import 'dart:ui';

/// The default [Locale] of this app.
const Locale defaultLocale = Locale('ru', 'RU');

/// The list of supported locales for this app.
const List<Locale> supportedLocales = <Locale>[defaultLocale];

/// The city of the smstretching.
///
/// See: https://yclientsru.docs.apiary.io/#reference/2/0/0
const String smstretchingCity = 'Москва';

/// The country code of the desired phone number.
const int phoneCountryCode = 38;

/// The length of the sms pin code for phone number authentication.
const int pinCodeLength = 4;
