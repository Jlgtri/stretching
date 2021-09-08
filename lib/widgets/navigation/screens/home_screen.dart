import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/providers/user_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The screen for the [NavigationScreen.home].
class HomeScreen extends ConsumerWidget {
  /// The screen for the [NavigationScreen.home].
  const HomeScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        if (ref.watch(unauthorizedProvider))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true)
                  .pushNamed(Routes.auth.name),
              style: TextButtonStyle.light.fromTheme(theme),
              child: Text(
                TR.homeRegister.tr(),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
          )
      ],
    );
  }
}
