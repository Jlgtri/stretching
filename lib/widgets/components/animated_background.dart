import 'package:darq/darq.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// The widget of animated background to show on load.
class AnimatedBackground extends HookWidget {
  /// The widget of animated background to show on load.
  const AnimatedBackground({
    final this.colors = const <Color>[],
    final this.animateColors = true,
    final this.alignments = const <AlignmentGeometry>[],
    final this.animateAlignments = true,
    final this.duration = const Duration(milliseconds: 500),
    final this.curve = Curves.linear,
    final Key? key,
  })  : assert(
          colors.length == 0 || colors.length >= 2,
          'The count of colors should be equal or greater than 2.',
        ),
        assert(
          alignments.length == 0 || alignments.length >= 2,
          'The count of alignments should be equal or greater than 2.',
        ),
        super(key: key);

  /// The colors to switch in this background.
  final Iterable<Color> colors;

  /// If the colors should be switched.
  final bool animateColors;

  /// The alignments to switch in this background.
  final Iterable<AlignmentGeometry> alignments;

  /// If the alignments should be switched.
  final bool animateAlignments;

  /// The duration of the switch between [colors] and [alignments].
  final Duration duration;

  /// The curve of the switch between [colors] and [alignments].
  final Curve curve;

  @override
  Widget build(final BuildContext context) {
    final isMounted = useIsMounted();
    final index = useRef<int>(1);
    final state = useState(
      Tuple2(
        Tuple2(
          colors.isNotEmpty ? colors.first : null,
          colors.isNotEmpty ? colors.last : null,
        ),
        Tuple2(
          alignments.isNotEmpty ? alignments.first : null,
          alignments.isNotEmpty ? alignments.last : null,
        ),
      ),
    );

    void switchState() {
      if (isMounted()) {
        index.value++;
        state.value = Tuple2(
          Tuple2(
            colors.isNotEmpty && animateColors
                ? colors.elementAt(index.value % colors.length)
                : state.value.item0.item0,
            colors.isNotEmpty && animateColors
                ? colors.elementAt((index.value + 1) % colors.length)
                : state.value.item0.item1,
          ),
          Tuple2(
            alignments.isNotEmpty && animateAlignments
                ? alignments.elementAt(index.value % alignments.length)
                : state.value.item1.item0,
            alignments.isNotEmpty && animateAlignments
                ? alignments.elementAt((index.value + 1) % alignments.length)
                : state.value.item1.item1,
          ),
        );
      }
    }

    useMemoized(
      () => WidgetsBinding.instance?.addPostFrameCallback((final _) async {
        switchState();
        switchState();
      }),
    );
    final animKey = useMemoized(() => UniqueKey());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: AnimatedContainer(
        key: animKey,
        duration: duration,
        curve: curve,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: state.value.item1.item0 ?? Alignment.center,
            end: state.value.item1.item1 ?? Alignment.center,
            colors: <Color>[
              if (state.value.item0.item0 != null) state.value.item0.item0!,
              if (state.value.item0.item1 != null) state.value.item0.item1!
            ],
          ),
        ),
        onEnd: switchState,
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(IterableProperty<Color>('colors', colors))
        ..add(DiagnosticsProperty<bool>('animateColors', animateColors))
        ..add(IterableProperty<AlignmentGeometry>('alignments', alignments))
        ..add(DiagnosticsProperty<bool>('animateAlignments', animateAlignments))
        ..add(DiagnosticsProperty<Duration>('duration', duration))
        ..add(DiagnosticsProperty<Curve>('curve', curve)),
    );
  }
}
