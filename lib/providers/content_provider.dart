import 'dart:async';

import 'package:hive/hive.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/utils/json_converters.dart';

/// The provider of content in the external API.
class ContentNotifier<T extends Object>
    extends SaveToHiveIterableNotifier<T, String> {
  /// The provider of content in the external API.
  ContentNotifier({
    required final Box<String> hive,
    required final JsonConverter<T, Map<String, Object?>> converter,
    required final String saveName,
    required final this.refreshState,
    final this.refreshInterval = Duration.zero,
  }) : super(
          hive: hive,
          saveName: saveName,
          converter: StringToIterableConverter(IterableConverter(converter)),
          defaultValue: Iterable<T>.empty(),
        ) {
    refreshTimer = Timer.periodic(refreshInterval, (final timer) => refresh());
    if (refreshInterval.inSeconds < 1) {
      refreshTimer.cancel();
    }
  }

  /// The timer for automatically refreshing a state of this notifier.
  late final Timer refreshTimer;

  /// The callback to refresh a state of this provider.
  final FutureOr<Iterable<T>> Function(ContentNotifier<T>) refreshState;

  /// The interval for automatic refreshing of state of this notifier.
  final Duration refreshInterval;

  /// Refresh this state with a callback.
  Future<Iterable<T>> refresh() async =>
      setStateAsync(await refreshState(this));
}
