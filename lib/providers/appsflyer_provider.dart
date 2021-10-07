import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:riverpod/riverpod.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/secrets.dart';

/// The provider of the [AppsflyerSdk].
final FutureProvider<AppsflyerSdk> appsflyerProvider =
    FutureProvider<AppsflyerSdk>((final ref) async {
  final packageInfo = ref.watch(packageInfoProvider);
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
