import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models/yclients/user_record_model.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/focus_wrapper.dart';
import 'package:stretching/widgets/components/font_icon.dart';

/// The screen for picking a rating after the record is finished.
class RatingPicker extends HookConsumerWidget {
  /// The screen for picking a rating after the record is finished.
  const RatingPicker(final this.userRecord, {final Key? key}) : super(key: key);

  /// The record to give rating to.
  final UserRecordModel userRecord;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    const emoji = <String>['😢', '😬', '😐', '🙂', '🤩'];

    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    final locale = ref.watch(localeProvider);
    final selectedRating = useState<int>(emoji.length);
    final commentsKey = useMemoized(GlobalKey.new);
    final commentController = useTextEditingController();
    final doneAnimated = useState<bool>(false);
    final doneTransitionAnimation = useAnimationController(
      lowerBound: 2 / 3,
      duration: const Duration(seconds: 1),
    );
    final doneOpacityAnimation = useAnimationController(
      duration: const Duration(seconds: 1),
    );

    Future<void> editRating() async {
      doneAnimated.value = true;
      try {
        await Future.wait(<Future<void>>[
          if (doneTransitionAnimation.value == 1)
            doneTransitionAnimation.reverse()
          else
            doneTransitionAnimation.forward(),
          if (doneOpacityAnimation.value == 1)
            doneOpacityAnimation.reverse()
          else
            doneOpacityAnimation.forward(),
          Future<void>.delayed(const Duration(seconds: 2)),
        ]);
        await smStretching.editRating(
          rating: selectedRating.value,
          comment: commentController.text,
          recordId: userRecord.id,
          userPhone: ref.read(userProvider)!.phone,
        );
      } finally {
        navigator.popUntil(Routes.root.withName);
      }
    }

    return WillPopScope(
      onWillPop: () async => !doneAnimated.value,
      child: FocusWrapper(
        unfocussableKeys: <GlobalKey>[commentsKey],
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            /// Done Animation (children are reversed)
            IgnorePointer(
              ignoring: !doneAnimated.value,
              child: AbsorbPointer(
                absorbing: doneAnimated.value,
                child: Align(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      curve: Curves.easeOut,
                      parent: doneOpacityAnimation,
                    ),
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        curve: Curves.easeIn,
                        parent: doneTransitionAnimation,
                      ),
                      child: Container(
                        height: 200,
                        width: 240,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 25),
                            EmojiText(
                              '✌️',
                              style: const TextStyle(fontSize: 70),
                              textScaleFactor: mediaQuery.textScaleFactor,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              TR.ratingDone.tr(),
                              style: theme.textTheme.headline3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              TR.ratingDoneDescription.tr(),
                              style: theme.textTheme.bodyText2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// Main page
            Scaffold(
              appBar: AppBar(
                elevation: 0,
                toolbarHeight: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: theme.scaffoldBackgroundColor,
                  statusBarBrightness: theme.brightness,
                  statusBarIconBrightness: theme.brightness == Brightness.light
                      ? Brightness.dark
                      : Brightness.light,
                ),
              ),
              body: CustomScrollView(
                primary: false,
                slivers: <Widget>[
                  SliverAppBar(
                    toolbarHeight: 40,
                    backgroundColor: Colors.transparent,
                    actions: <Widget>[
                      TextButton(
                        onPressed: navigator.maybePop,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          primary: theme.colorScheme.onSurface,
                        ),
                        child: Text(
                          TR.tooltipsCancel.tr(),
                          style: theme.textTheme.button
                              ?.copyWith(color: theme.colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  /// Title
                  SliverPadding(
                    padding:
                        const EdgeInsets.all(50).copyWith(top: 20, bottom: 10),
                    sliver: SliverToBoxAdapter(
                      child: Align(
                        child: Text(
                          TR.ratingTitle.tr(),
                          style: theme.textTheme.headline3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),

                  /// Description
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    sliver: SliverToBoxAdapter(
                      child: Text.rich(
                        TextSpan(
                          text: TR.ratingDescription.tr(),
                          children: <InlineSpan>[
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: DateFormat.MMMMd(locale.toString())
                                  .format(userRecord.date),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(text: userRecord.services.first.title)
                          ],
                        ),
                        style: theme.textTheme.bodyText2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  /// Trainer
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(50, 20, 50, 10),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          /// Avatar
                          Flexible(
                            child: CachedNetworkImage(
                              imageUrl: userRecord.staff.avatar,
                              cacheKey: 'x90_${userRecord.staff.avatar}',
                              height: 90,
                              width: 90,
                              memCacheWidth: 90,
                              memCacheHeight: 90,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              imageBuilder:
                                  (final context, final imageProvider) =>
                                      CircleAvatar(
                                foregroundImage: imageProvider,
                                radius: 45,
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.transparent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          /// Name
                          Text(
                            userRecord.staff.name,
                            style: theme.textTheme.overline?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                  ),

                  /// Rating
                  SliverToBoxAdapter(
                    child: Align(
                      child: GestureDetector(
                        onTapDown: (final details) {
                          selectedRating.value = min(
                            emoji.length,
                            1 + details.localPosition.dx ~/ 60,
                          );
                        },
                        onHorizontalDragUpdate: (final details) {
                          selectedRating.value = min(
                            emoji.length,
                            1 + details.localPosition.dx ~/ 60,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            for (var index = 1;
                                index <= emoji.length;
                                index++) ...<Widget>[
                              FontIcon(
                                FontIconData(
                                  IconsCG.star,
                                  height: 60,
                                  width: 40,
                                  color: index <= selectedRating.value
                                      ? theme.colorScheme.onSurface
                                      : theme.hintColor,
                                ),
                              ),
                              const SizedBox(width: 20),
                            ]
                          ]..removeLast(),
                        ),
                      ),
                    ),
                  ),

                  /// Rating Emoji
                  SliverPadding(
                    padding: const EdgeInsets.all(50).copyWith(top: 20),
                    sliver: SliverToBoxAdapter(
                      child: Align(
                        child: SizedBox(
                          height: 60,
                          child: EmojiText(
                            selectedRating.value > 0
                                ? emoji.elementAt(selectedRating.value - 1)
                                : '',
                            style: const TextStyle(fontSize: 60),
                            textScaleFactor: mediaQuery.textScaleFactor,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Comments
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: TextField(
                        key: commentsKey,
                        controller: commentController,
                        maxLines: 7,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(1024),
                          // FilteringTextInputFormatter.allow(
                          //   RegExp(r'[\d\p{L}]', unicode: true),
                          // )
                        ],
                        keyboardType: TextInputType.multiline,
                        style: theme.textTheme.bodyText2,
                        onTap: () async {
                          await Future<void>.delayed(
                            const Duration(milliseconds: 200),
                          );
                          await Scrollable.ensureVisible(
                            commentsKey.currentContext!,
                          );
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          hintText: TR.ratingComment.tr(),
                          hintStyle: theme.textTheme.overline,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.hintColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.hintColor),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: theme.hintColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Button
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 50,
                    ).copyWith(bottom: 40),
                    sliver: SliverToBoxAdapter(
                      child: TextButton(
                        style:
                            (TextButtonStyle.light.fromTheme(theme)).copyWith(
                          backgroundColor: MaterialStateProperty.all(
                            selectedRating.value > 0
                                ? Colors.transparent
                                : theme.hintColor.withOpacity(1 / 3),
                          ),
                        ),
                        onPressed: selectedRating.value > 0 ? editRating : null,
                        child: Text(
                          TR.ratingConfirm.tr(),
                          style: theme.textTheme.button?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ].reversed.toList(growable: false),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<UserRecordModel>('userRecord', userRecord)),
    );
  }
}
