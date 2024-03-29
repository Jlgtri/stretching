import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [StatefulWidget] that can use [Hook] and read [Provider].
///
/// It's usage is very similar to [StatefulWidget], but it can use hooks inside
/// [State.build] and read providers with [ConsumerState.ref].
///
/// The difference is that it can use [Hook], which allows [HookWidget]
/// to store mutable data without implementing a [ConsumerState].
abstract class HookConsumerStatefulWidget extends ConsumerStatefulWidget {
  /// Initializes [key] for subclasses.
  const HookConsumerStatefulWidget({final Key? key}) : super(key: key);

  @override
  HookConsumerStatefulWidgetElement createElement() =>
      HookConsumerStatefulWidgetElement(this);
}

/// An [Element] that can use [Hook] and read [Provider].
///
/// It's usage is very similar to [StatefulWidget], but it can use hooks inside
/// [State.build] and read providers with [ConsumerState.ref].
///
/// The difference is that it can use [Hook], which allows [HookWidget]
/// to store mutable data without implementing a [ConsumerState].
class HookConsumerStatefulWidgetElement extends ConsumerStatefulElement
    with
        // ignore: invalid_use_of_visible_for_testing_member
        HookElement {
  /// Initializes [hooks] for subclasses.
  HookConsumerStatefulWidgetElement(final HookConsumerStatefulWidget hooks)
      : super(hooks);
}
