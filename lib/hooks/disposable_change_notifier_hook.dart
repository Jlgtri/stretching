import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Creates a notifier that is automatically disposed.
///
/// The returned notifier is null until [initialValue] is finished.
V? useDisposableChangeNotifier<V extends ChangeNotifier>(
  final FutureOr<V> initialValue,
) {
  final createInitialValue = initialValue is Future<V>
      ? useFuture<V>(initialValue)
      : useFuture<V>(null, initialData: initialValue);
  return use(_DisposableChangeNotifierHook<V>(createInitialValue.data));
}

class _DisposableChangeNotifierHook<V extends ChangeNotifier> extends Hook<V?> {
  const _DisposableChangeNotifierHook(final this.initialValue);

  /// The callback for the creation of the notifier's initial value.
  final V? initialValue;

  @override
  __ChangeNotifierHookState<V> createState() => __ChangeNotifierHookState<V>();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties..add(ObjectFlagProperty<V>.has('initialValue', initialValue)),
    );
  }
}

class __ChangeNotifierHookState<V extends ChangeNotifier>
    extends HookState<V?, _DisposableChangeNotifierHook<V>> {
  @override
  V? build(final BuildContext context) => hook.initialValue;

  @override
  void dispose() {
    hook.initialValue?.dispose();
    super.dispose();
  }
}
