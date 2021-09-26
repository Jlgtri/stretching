import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:package_info/package_info.dart';
import 'package:riverpod/riverpod.dart';
import 'package:stretching/secrets.dart';

/// The provider of the [AppsflyerSdk].
final FutureProvider<AppsflyerSdk> appsflyerProvider =
    FutureProvider<AppsflyerSdk>((final ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final appsflyer = AppsflyerSdk(<String, Object?>{
    'afDevKey': appsflyerDevKey,
    'afAppId': packageInfo.packageName,
    'isDebug': false
  });
  await appsflyer.initSdk(
    registerConversionDataCallback: true,
    registerOnAppOpenAttributionCallback: true,
    registerOnDeepLinkingCallback: true,
  );
  return appsflyer;
});
