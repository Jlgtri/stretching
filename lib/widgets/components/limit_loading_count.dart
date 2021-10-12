import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/hooks/on_disposed_hook.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The provider of the loading data on provided [NavigationScreen].
final StateProviderFamily<Iterable<Object>, NavigationScreen>
    loadingDataProvider =
    StateProvider.family<Iterable<Object>, NavigationScreen>(
  (final ref, final screen) => const Iterable<Object>.empty(),
);

/// The provider of the loaded data on provided [NavigationScreen].
final StateProviderFamily<Iterable<Object>, NavigationScreen>
    loadedDataProvider =
    StateProvider.family<Iterable<Object>, NavigationScreen>(
  (final ref, final screen) => const Iterable<Object>.empty(),
);

/// The widget for limiting the loading count on the selected [screen].
class LimitLoadingCount<T extends Object> extends HookConsumerWidget {
  /// The widget for limiting the loading count on the selected [screen].
  const LimitLoadingCount(
    final this.data,
    final this.screen, {
    final this.child,
    final Key? key,
  }) : super(key: key);

  /// The data of this loading widget.
  final T data;

  /// The screen to limit the loading count on.
  final NavigationScreen screen;

  /// The child of this widget if any.
  ///
  /// Defaults to [Container].
  final Widget? child;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final widgetsBinding = useMemoized(() => ref.read(widgetsBindingProvider));
    final _loadedData = useMemoized(() => ref.read(loadedDataProvider(screen)));
    final _loadingData = useMemoized(() {
      final _loadingData = ref.read(loadingDataProvider(screen));
      widgetsBinding.addPostFrameCallback((final _) {
        if (!_loadedData.state.contains(data) &&
            !_loadingData.state.contains(data)) {
          _loadingData.state = <Object>[..._loadingData.state, data];
        }
      });
      return _loadingData;
    });
    useOnDisposed(() {
      if (_loadingData.state.contains(data) &&
          !_loadedData.state.contains(data)) {
        widgetsBinding.addPostFrameCallback((final _) {
          _loadedData.state = <Object>[..._loadedData.state, data];
          _loadingData.state = <Object>[
            for (final _data in _loadingData.state)
              if (_data != data) data
          ];
        });
      }
    });
    return child ?? Container();
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<T>('data', data))
        ..add(EnumProperty<NavigationScreen>('screen', screen))
        ..add(DiagnosticsProperty<Widget?>('child', child)),
    );
  }
}
