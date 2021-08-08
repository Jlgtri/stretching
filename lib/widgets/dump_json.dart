import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// The widget that dumps data from a provider a user.
class DumpJson<T extends Object> extends ConsumerWidget {
  /// The widget that dumps data from a provider a user.
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
          final dynamic snapshotData = snapshot.data;
          final data = snapshotData is Iterable
              ? snapshotData.map((final data) => data.toMap()).toList()
              : snapshotData.toMap();
          final dirs = await getExternalStorageDirectories(
            type: StorageDirectory.downloads,
          );
          final fileName = '${DateTime.now().toIso8601String()}.json';
          final file = File(join(dirs!.first.path, fileName));
          await file.writeAsString(json.encode(data), flush: true);
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
