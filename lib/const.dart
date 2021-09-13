import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stretching/widgets/navigation/screens/activities_screen.dart';

/// The default [Locale] of this app.
const Locale defaultLocale = Locale('ru', 'RU');

/// The list of supported locales for this app.
const List<Locale> supportedLocales = <Locale>[defaultLocale];

/// The city of the smstretching.
///
/// See: https://yclientsru.docs.apiary.io/#reference/2/0/0
const String smstretchingCity = 'Москва';

/// The country code of the desired phone number.
const int phoneCountryCode = 7;

/// The length of the sms pin code for phone number authentication.
const int pinCodeLength = 4;

/// The time filter to use for [ActivityTime].
const TimeOfDay filterTime = TimeOfDay(hour: 16, minute: 45);

/// The longest time that user can wait before booking
const Duration bookTimeout = Duration(minutes: 20);
