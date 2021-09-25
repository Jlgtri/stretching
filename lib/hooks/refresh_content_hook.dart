import 'dart:async';

import 'package:darq/darq.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stretching/providers/content_provider.dart';

/// The hook for refreshing a list of [notifiers] with [RefreshController].
///
/// Returns the created controller and a [SmartRefresher] refresh function.
Tuple2<RefreshController, Future<void> Function()> useRefreshController({
  final bool requestRefresh = true,
  final Iterable<ContentNotifier> notifiers =
      const Iterable<ContentNotifier>.empty(),
  final FutureOr<void> Function()? extraRefresh,
}) {
  return use(
    _RefreshControllerHook(
      requestRefresh: requestRefresh,
      notifiers: notifiers,
      extraRefresh: extraRefresh,
    ),
  );
}

class _RefreshControllerHook
    extends Hook<Tuple2<RefreshController, Future<void> Function()>> {
  const _RefreshControllerHook({
    final this.requestRefresh = true,
    final this.notifiers = const Iterable<ContentNotifier>.empty(),
    final this.extraRefresh,
  });

  /// If this hook should automatically [RefreshController.requestRefresh].
  final bool requestRefresh;

  /// The list of notifiers to update from this refresh controller.
  final Iterable<ContentNotifier> notifiers;

  /// The callback to call before running refresh on [notifiers].
  final FutureOr<void> Function()? extraRefresh;

  @override
  __RefreshControllerHookState createState() => __RefreshControllerHookState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<bool>('requestRefresh', requestRefresh))
        ..add(IterableProperty<ContentNotifier<Object>>('notifiers', notifiers))
        ..add(
          ObjectFlagProperty<FutureOr<void> Function()>.has(
            'extraRefresh',
            extraRefresh,
          ),
        ),
    );
  }
}

class __RefreshControllerHookState extends HookState<
    Tuple2<RefreshController, Future<void> Function()>,
    _RefreshControllerHook> {
  late final RefreshController _refreshController;
  late final Future<void> Function() _onRefresh;

  bool _mounted = true;
  bool _requestedRefresh = false;

  @override
  void initHook() {
    super.initHook();

    _refreshController = RefreshController();
    Future<void> onRefresh() async {
      if (_mounted && hook.requestRefresh && !_requestedRefresh) {
        await _refreshController.requestRefresh(
          needMove: false,
          curve: Curves.ease,
        );
      }
    }

    final notifiersLoaded = <String, bool>{};
    void onRefreshCompleted() {
      if (_mounted &&
          hook.requestRefresh &&
          !_requestedRefresh &&
          notifiersLoaded.values.all()) {
        _refreshController.refreshCompleted();
      }
    }

    for (final notifier in hook.notifiers) {
      Future<void> onNotifierRefresh() {
        notifiersLoaded[notifier.saveName] = false;
        return onRefresh();
      }

      void onNotifierRefreshCompleted({
        required final bool success,
      }) {
        notifiersLoaded[notifier.saveName] = true;
        return onRefreshCompleted();
      }

      notifier
        ..removeOnRefreshListener(onNotifierRefresh)
        ..removeOnRefreshCompletedListener(onNotifierRefreshCompleted)
        ..addOnRefreshListener(onNotifierRefresh)
        ..addOnRefreshCompletedListener(onNotifierRefreshCompleted);
    }

    _onRefresh = () async {
      _requestedRefresh = true;
      try {
        await hook.extraRefresh?.call();
        await Future.wait(<Future<void>>[
          for (final notifier in hook.notifiers) notifier.refresh(),
        ]);
      } finally {
        _requestedRefresh = false;
        if (_mounted) {
          _refreshController.refreshCompleted();
        }
      }
    };
  }

  @override
  void dispose() {
    try {
      _refreshController.dispose();
      super.dispose();
    } finally {
      _mounted = false;
    }
  }

  @override
  Tuple2<RefreshController, Future<void> Function()> build(
    final BuildContext context,
  ) =>
      Tuple2(_refreshController, _onRefresh);
}
