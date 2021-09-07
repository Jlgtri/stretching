import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The provider of the current hidden state of the appbar.
final StateProviderFamily<bool, NavigationScreen> hideAppBarProvider =
    StateProvider.family<bool, NavigationScreen>((final ref, final _) => false);

/// The provider of route observer for each [NavigationScreen].
final ProviderFamily<RouteObserver<Route<Object?>>, NavigationScreen>
    routeObserverProvider =
    Provider.family((final ref, final _) => RouteObserver<Route<Object?>>());

/// Mixin on the route Aware that hides the appbar on route switching.
mixin HideAppBarRouteAware<T extends ConsumerStatefulWidget> on ConsumerState<T>
    implements RouteAware {
  /// The current screen type of this route.
  NavigationScreen get screenType;
  late final RouteObserver<Route<Object?>> _observer;

  @override
  void initState() {
    super.initState();
    _observer = ref.read(routeObserverProvider(screenType));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    super.dispose();
    if (_observer.navigator?.mounted ?? false) {
      _observer.unsubscribe(this);
    }
  }

  @override
  void didPop() {
    ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
      ref.read(hideAppBarProvider(screenType)).state = false;
    });
  }

  @override
  void didPush() {
    ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
      ref.read(hideAppBarProvider(screenType)).state = true;
    });
  }

  @override
  void didPopNext() => didPush();

  @override
  void didPushNext() => didPush();
}
