import 'dart:async';

import 'package:hive/hive.dart';
import 'package:stretching/providers/hive_provider.dart';
import 'package:stretching/utils/json_converters.dart';

/// The callback on refresh of the [ContentNotifier].
typedef OnContentNotifierRefresh = FutureOr<void> Function();

/// The callback on completed refresh of the [ContentNotifier].
typedef OnContentNotifierRefreshCompleted = FutureOr<void> Function({
  required bool success,
});

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
  Completer<bool> _isRefreshingCompleter = Completer<bool>()..complete(false);
  Iterable<OnContentNotifierRefresh> _onRefreshListeners =
      const Iterable<OnContentNotifierRefresh>.empty();
  Iterable<OnContentNotifierRefreshCompleted> _onRefreshCompletedListeners =
      const Iterable<OnContentNotifierRefreshCompleted>.empty();

  /// The timer for automatically refreshing a state of this notifier.
  late final Timer refreshTimer;

  /// The callback to refresh a state of this provider.
  final FutureOr<Iterable<T>?> Function(ContentNotifier<T>) refreshState;

  /// The interval for automatic refreshing of state of this notifier.
  final Duration refreshInterval;

  /// If this notifier is currently calling [refresh].
  bool get isRefreshing => !_isRefreshingCompleter.isCompleted;

  /// Wait until this notifier completes a refresh.
  Future<bool> waitUntilRefreshed() =>
      _isRefreshingCompleter.future.then((final success) => success);

  /// Refresh this state with a callback.
  Future<bool> refresh() async {
    if (!_isRefreshingCompleter.isCompleted) {
      return waitUntilRefreshed();
    }
    _isRefreshingCompleter = Completer<bool>();
    var success = false;
    try {
      final futures = <FutureOr<void>>[
        for (final listener in _onRefreshListeners) listener()
      ];
      await Future.wait<void>(futures.whereType<Future>());
    } finally {
      try {
        final state = await refreshState(this);
        if (state is Iterable<T>) {
          await setStateAsync(state);
          success = true;
        }
      } finally {
        try {
          final futures = <FutureOr<void>>[
            for (final listener in _onRefreshCompletedListeners)
              listener(success: success)
          ];
          await Future.wait<void>(futures.whereType<Future>());
        } finally {
          _isRefreshingCompleter.complete(success);
        }
      }
    }
    return success;
  }

  /// Add listener to the [refresh] function.
  void addOnRefreshListener(final OnContentNotifierRefresh listener) {
    _onRefreshListeners = <OnContentNotifierRefresh>[
      ..._onRefreshListeners,
      listener
    ];
  }

  /// Add listener to the [refresh] function.
  void removeOnRefreshListener(final OnContentNotifierRefresh listener) {
    _onRefreshListeners = <OnContentNotifierRefresh>[
      for (final _listener in _onRefreshListeners)
        if (_listener != listener) _listener
    ];
  }

  /// Add listener to the [refresh] function.
  void addOnRefreshCompletedListener(
    final OnContentNotifierRefreshCompleted listener,
  ) {
    _onRefreshCompletedListeners = <OnContentNotifierRefreshCompleted>[
      ..._onRefreshCompletedListeners,
      listener
    ];
  }

  /// Add listener to the completion of the [refresh] function.
  void removeOnRefreshCompletedListener(
    final OnContentNotifierRefreshCompleted listener,
  ) {
    _onRefreshCompletedListeners = <OnContentNotifierRefreshCompleted>[
      for (final _listener in _onRefreshCompletedListeners)
        if (_listener != listener) _listener
    ];
  }
}
