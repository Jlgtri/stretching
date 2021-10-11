import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:riverpod/riverpod.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/secrets.dart';

/// The provider of the [AppsflyerSdk].
final FutureProvider<AppsflyerSdk> appsflyerProvider =
    FutureProvider<AppsflyerSdk>((final ref) async {
  final appsflyer = AppsflyerSdk(
    AppsFlyerOptions(
      afDevKey: appsflyerDevKey,
      appId: Platform.isIOS
          ? appsflyerIOSAppId
          : ref.watch(packageInfoProvider).packageName,
    ),
  );
  await appsflyer.initSdk(
    registerConversionDataCallback: true,
    registerOnAppOpenAttributionCallback: true,
    registerOnDeepLinkingCallback: true,
  );
  return appsflyer;
});
