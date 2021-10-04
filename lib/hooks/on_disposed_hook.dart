import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// The callback for [useOnDisposed].
typedef OnDisposed<T extends Object?> = FutureOr<T> Function();

/// Creates a hook that calls [callback] when it is disposed.
void useOnDisposed<T extends Object?>(
  final OnDisposed<T> callback,
) =>
    use(_OnDisposedHook<T>(callback));

class _OnDisposedHook<T extends Object?> extends Hook<void> {
  const _OnDisposedHook(final this.callback);

  /// The callback to call on disposed.
  final OnDisposed<T> callback;

  @override
  __ChangeNotifierHookState<T> createState() => __ChangeNotifierHookState<T>();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(ObjectFlagProperty<OnDisposed<T>>.has('callback', callback)),
    );
  }
}

class __ChangeNotifierHookState<T extends Object?>
    extends HookState<void, _OnDisposedHook<T>> {
  @override
  void build(final BuildContext context) {}

  @override
  void dispose() {
    hook.callback();
    super.dispose();
  }
}
