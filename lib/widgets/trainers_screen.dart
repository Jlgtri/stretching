import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:darq/darq.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/providers/yclients_providers.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The screen for the [NavigationScreen.trainers].
class TrainersScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.trainers].
  const TrainersScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final trainers = TrainersNotifier.normalizeTrainers(
      ref.watch(trainersProvider).distinct((final trainer) => trainer.name),
    );
    final scrollController = useScrollController();
    final searchKey = useMemoized(() => GlobalKey());
    return
        // FocusWrapper(
        //   unfocussableKeys: <GlobalKey>[searchKey],
        //   child:
        //   NestedScrollView(
        // // controller: scrollController,
        // headerSliverBuilder: (final context, final innerBoxIsScrolled) {
        //   return <Widget>[
        //     SliverAppBar(
        //       primary: false,
        //       pinned: true,
        //       floating: true,
        //       backgroundColor: theme.appBarTheme.foregroundColor,
        //       title: TextField(
        //         key: searchKey,
        //         cursorColor: theme.hintColor,
        //         decoration: InputDecoration(
        //           contentPadding:
        //               const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        //           prefixIcon: FontIcon(IconsCG.search, color: theme.hintColor),
        //           suffixText: TR.tooltipsCancel.tr(),
        //           suffixStyle: TextStyle(
        //             color: theme.colorScheme.onSurface,
        //             fontWeight: FontWeight.w500,
        //           ),
        //           hintText: TR.trainersSearch.tr(),
        //           border: InputBorder.none,
        //           disabledBorder: InputBorder.none,
        //           enabledBorder: InputBorder.none,
        //           focusedBorder: InputBorder.none,
        //         ),
        //       ),
        //     ),
        //   ];
        // },
        // body:
        DraggableScrollbar.semicircle(
      controller: scrollController,
      backgroundColor: theme.colorScheme.onSurface,
      labelTextBuilder: (final offset) {
        final sc = scrollController;
        final index = sc.offset / sc.position.maxScrollExtent * trainers.length;
        final trainer = trainers.elementAt(
          sc.hasClients ? min(index.ceil(), trainers.length - 1) : 0,
        );
        return Text(
          trainer.name.isNotEmpty ? trainer.name[0].toUpperCase() : '-',
          style: theme.textTheme.subtitle2
              ?.copyWith(color: theme.colorScheme.surface),
        );
      },
      heightScrollThumb: 40,
      child: GridView.builder(
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          mainAxisExtent: 210,
        ),
        itemCount: trainers.length,
        itemBuilder: (final context, final index) {
          final trainer = trainers.elementAt(index);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: trainer.avatarBig,
                imageBuilder: (final context, final imageProvider) {
                  return CircleAvatar(
                    radius: 80,
                    foregroundImage: imageProvider,
                  );
                },
                placeholder: (final context, final url) =>
                    const CircularProgressIndicator(),
                errorWidget: (final context, final url, final dynamic error) =>
                    const FontIcon(FontIconData(IconsCG.logo)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: AutoSizeText(
                    trainer.name,
                    style: theme.textTheme.headline3,
                    maxLines: 2,
                    stepGranularity: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
