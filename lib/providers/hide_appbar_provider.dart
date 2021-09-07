import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The provider of the current hidden state of the appbar.
final StateProvider<bool> hideAppBarProvider =
    StateProvider<bool>((final ref) => false);

/// The provider of route observer for each [NavigationScreen].
final ProviderFamily<RouteObserver<Route<Object?>>, NavigationScreen>
    routeObserverProvider =
    Provider.family((final ref, final _) => RouteObserver<Route<Object?>>());

/// Mixin on the route Aware that hides the appbar on route switching.
mixin HideAppBarRouteAware<T extends ConsumerStatefulWidget> on ConsumerState<T>
    implements RouteAware {
  /// The current screen type of this route.
  NavigationScreen get screenType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    (ref.read(routeObserverProvider(screenType)))
        .subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    ref.read(routeObserverProvider(screenType)).unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
      ref.read(hideAppBarProvider).state = false;
    });
  }

  @override
  void didPush() {
    ref.read(widgetsBindingProvider).addPostFrameCallback((final _) {
      ref.read(hideAppBarProvider).state = true;
    });
  }

  @override
  void didPopNext() => didPush();

  @override
  void didPushNext() => didPush();
}
