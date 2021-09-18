// import 'dart:math';

// import 'package:draggable_scrollbar/draggable_scrollbar.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:stretching/providers/other_providers.dart';
// import 'package:stretching/widgets/appbars.dart';
// import 'package:stretching/widgets/navigation/navigation_root.dart';

// /// The widget builder with a scroll controller;
// typedef ScrollWidgetBuilder = Widget Function(
//   BuildContext context,
//   ScrollController scrollController,
//   void Function()? resetScrollbarPosition,
// );

// /// Provides a scrollable to it's [builder] that consumes a scroll controller.
// class CustomDraggableScrollBar extends HookConsumerWidget {
//   /// Provides a scrollable to it's [builder] that consumes a scroll controller.
//   const CustomDraggableScrollBar({
//     required final this.builder,
//     required final this.itemsCount,
//     final this.labelTextBuilder,
//     final this.visible = true,
//     final this.resetScrollbarPosition = false,
//     final this.leadingChildHeight = 0,
//     final this.trailingChildHeight = 0,
//     final Key? key,
//   }) : super(key: key);

//   /// The builder of the child of this scrollbar.
//   /// Should always use a scroll controller.
//   final ScrollWidgetBuilder builder;

//   /// The count of items of [builder]'s scrollable.
//   final int itemsCount;

//   /// The builder of the label for the scrollbar.
//   final Text Function(int index)? labelTextBuilder;

//   /// If the scrollbar is currently visible.
//   final bool visible;

//   /// If the scrollbar position should be immediately reset.
//   final bool resetScrollbarPosition;

//   /// The height of the widget on top of [builder]'s content.
//   final double leadingChildHeight;

//   /// The height of the widget on bottom of [builder]'s content.
//   final double trailingChildHeight;

//   @override
//   Widget build(final BuildContext context, final WidgetRef ref) {
//     final theme = Theme.of(context);
//     final mediaQuery = MediaQuery.of(context);
//     final scrollController = useScrollController();
//     final scrollNotificationExample = useRef<ScrollUpdateNotification?>(null);
//     final isHeightReset = useRef<bool>(false);
//     return DraggableScrollbar.semicircle(
//       controller: scrollController,
//       // Shows the scrollbar only if current trainers length is greater
//       // than 6 (3 rows).
//       heightScrollThumb: visible ? 40 : 0,
//       padding: EdgeInsets.zero,
//       backgroundColor: theme.colorScheme.onSurface,
//       labelTextBuilder: labelTextBuilder != null
//           ? (final offset) {
//               final sc = scrollController;
//               final maxScrollExtent = sc.position.maxScrollExtent -
//                   leadingChildHeight -
//                   trailingChildHeight;
//               final leadingExtent = sc.offset - leadingChildHeight;
//               final index = max(
//                     0,
//                     leadingExtent >= maxScrollExtent
//                         ? leadingExtent - trailingChildHeight
//                         : leadingExtent,
//                   ) *
//                   itemsCount /
//                   max(0, maxScrollExtent);
//               return labelTextBuilder!(
//                 sc.hasClients ? min(index.ceil(), itemsCount - 1) : 0,
//               );
//             }
//           : null,
//       child: ListView(
//         primary: false,
//         shrinkWrap: true,
//         padding: EdgeInsets.zero,
//         physics: const NeverScrollableScrollPhysics(),
//         itemExtent: mediaQuery.size.height -
//             mediaQuery.viewPadding.top -
//             mainAppBar(theme).preferredSize.height -
//             NavigationRoot.navBarHeight,
//         children: <Widget>[
//           /// Is used for moving the scrollbar to the initial position when
//           /// search is reset. Needs to access [DraggableScrollbar] context.
//           Builder(
//             builder: (final context) {
//               void Function()? resetPosition;
//               final notification = scrollNotificationExample.value;
//               if (notification != null) {
//                 resetPosition = () {
//                   (ref.read(widgetsBindingProvider))
//                       .addPostFrameCallback((final _) {
//                     ScrollUpdateNotification(
//                       context: notification.context ?? context,
//                       metrics: notification.metrics,
//                       depth: notification.depth,
//                       dragDetails: notification.dragDetails,
//                       scrollDelta: double.negativeInfinity,
//                     ).dispatch(notification.context ?? context);
//                   });
//                 };
//                 if (!isHeightReset.value && resetScrollbarPosition) {
//                   isHeightReset.value = true;
//                   resetPosition();
//                 }
//               }
//               return NotificationListener<ScrollUpdateNotification>(
//                 onNotification: (final notification) {
//                   scrollNotificationExample.value ??= notification;
//                   return false;
//                 },
//                 child: builder(context, scrollController, resetPosition),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
//     super.debugFillProperties(
//       properties
//         ..add(DiagnosticsProperty<bool>('visible', visible))
//         ..add(
//           ObjectFlagProperty<Text Function(int index)>.has(
//             'labelTextBuilder',
//             labelTextBuilder,
//           ),
//         )
//         ..add(
//           DiagnosticsProperty<bool>(
//             'resetScrollbarPosition',
//             resetScrollbarPosition,
//           ),
//         )
//         ..add(IntProperty('itemsCount', itemsCount))
//         ..add(ObjectFlagProperty<ScrollWidgetBuilder>.has('builder', builder))
//         ..add(DoubleProperty('leadingChildHeight', leadingChildHeight))
//         ..add(DoubleProperty('trailingChildHeight', trailingChildHeight)),
//     );
//   }
// }
