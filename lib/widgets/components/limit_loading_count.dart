import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/hooks/on_disposed_hook.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The provider of the loading data on provided [NavigationScreen].
final StateProviderFamily<Iterable<String>, NavigationScreen> loadingData =
    StateProvider.family<Iterable<String>, NavigationScreen>(
  (final ref, final screen) => const Iterable<String>.empty(),
);

/// The provider of the loaded data on provided [NavigationScreen].
final StateProviderFamily<Iterable<String>, NavigationScreen> loadedData =
    StateProvider.family<Iterable<String>, NavigationScreen>(
  (final ref, final screen) => const Iterable<String>.empty(),
);

/// The widget for limiting the loading count on the selected [screen].
class LimitLoadingCount extends HookConsumerWidget {
  /// The widget for limiting the loading count on the selected [screen].
  const LimitLoadingCount(
    final this.url,
    final this.screen, {
    final this.child,
    final Key? key,
  }) : super(key: key);

  /// The url of this loading widget.
  final String url;

  /// The screen to limit the loading count on.
  final NavigationScreen screen;

  /// The child of this widget if any.
  ///
  /// Defaults to [Container].
  final Widget? child;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final widgetsBinding = useMemoized(() => ref.read(widgetsBindingProvider));
    final _loadedData = useMemoized(() => ref.read(loadedData(screen)));
    final _loadingData = useMemoized(() {
      final _loadingData = ref.read(loadingData(screen));
      widgetsBinding.addPostFrameCallback((final _) {
        if (!_loadedData.state.contains(url) &&
            !_loadingData.state.contains(url)) {
          _loadingData.state = <String>[..._loadingData.state, url];
        }
      });
      return _loadingData;
    });
    useOnDisposed(() {
      if (_loadingData.state.contains(url) &&
          !_loadedData.state.contains(url)) {
        widgetsBinding.addPostFrameCallback((final _) {
          _loadedData.state = <String>[..._loadedData.state, url];
          _loadingData.state = <String>[
            for (final data in _loadingData.state)
              if (data != url) data
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
        ..add(StringProperty('url', url))
        ..add(EnumProperty<NavigationScreen>('screen', screen))
        ..add(DiagnosticsProperty<Widget?>('child', child)),
    );
    ;
  }
}
