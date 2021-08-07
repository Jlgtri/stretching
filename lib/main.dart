import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/yclients_api.dart';

/// The premade initialisation of a Flutter's [WidgetsBinding].
/// Also is used for accessing the non null [WidgetsBinding] class.
final Provider<WidgetsBinding> widgetsBindingProvider =
    Provider<WidgetsBinding>((final ref) {
  return WidgetsFlutterBinding.ensureInitialized();
});

void main() {
  runApp(
    EasyLocalization(
      supportedLocales: supportedLocales,
      path: AssetsCG.translations,
      startLocale: defaultLocale,
      fallbackLocale: defaultLocale,
      child: Builder(
        builder: (final context) {
          final ez = EasyLocalization.of(context)!;
          return FutureBuilder(
            future: ez.delegate.load(ez.currentLocale!),
            builder: (final context, final snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox.shrink();
              }
              return ProviderScope(child: DumpJson(trainersProvider));
            },
          );
        },
      ),
    ),
  );
}

/// The widget that dumps data from a provider a user.
class DumpJson<T extends Object> extends ConsumerWidget {
  /// The widget to authorize a user.
  const DumpJson(final this.provider, {final Key? key}) : super(key: key);

  /// The provider which value to dump.
  final FutureProvider<T> provider;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return FutureBuilder<T>(
      future: ref.watch(provider.future),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        Permission.storage.request().then((final _) async {
          final snapshotData = snapshot.data;
          final data = snapshotData is Iterable
              ? snapshotData.map((final data) => data.toMap()).toList()
              : snapshotData.toString();
          final dirs = await getExternalStorageDirectories(
            type: StorageDirectory.downloads,
          );
          final file = File(
            join(dirs!.first.path, '${DateTime.now().toIso8601String()}.json'),
          )..writeAsStringSync(json.encode(data), flush: true);
          print('Dumped json at: ${file.path}');
        });
        return const Placeholder();
      },
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<FutureProvider>('provider', provider)),
    );
  }
}
