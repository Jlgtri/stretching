import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The screen for the [NavigationScreen.profile].
class ProfileScreen extends ConsumerWidget {
  /// The screen for the [NavigationScreen.profile].
  const ProfileScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!ref.watch(unauthorizedProvider))
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    ref.read(userProvider.notifier).state = null;
                    (ref.read(navigationProvider))
                        .jumpToTab(NavigationScreen.home.index);
                  },
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                      Colors.black.withOpacity(1 / 3),
                    ),
                  ),
                  child: Text(
                    TR.profileExit.tr(),
                    style: theme.textTheme.headline3
                        ?.copyWith(color: theme.hintColor),
                  ),
                )
              ],
            ),
          )
      ],
    );
  }
}
