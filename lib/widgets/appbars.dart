import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/widgets/components/font_icon.dart';

/// The app bar that can be used to pop the current screen.
AppBar cancelAppBar(
  final ThemeData theme, {
  final Widget? leading,
  final void Function()? onPressed,
  final String? title,
}) {
  return AppBar(
    toolbarHeight: 40,
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: theme.brightness,
      statusBarIconBrightness: theme.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    ),
    elevation: 0,
    centerTitle: true,
    title: title != null
        ? Text(
            title,
            style: theme.textTheme.headline3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : null,
    leadingWidth: leading == const SizedBox.shrink() ? 0 : null,
    automaticallyImplyLeading: false,
    leading: leading,
    actions: <Widget>[
      if (onPressed != null)
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(8),
            primary: theme.colorScheme.onSurface,
          ),
          child: Text(
            TR.tooltipsCancel.tr(),
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
        )
    ],
  );
}

/// The main app bar with the [IconsCG.logo].
AppBar mainAppBar(final ThemeData theme, {final Widget? leading}) {
  return AppBar(
    centerTitle: true,
    toolbarHeight: 60,
    leading: leading,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: theme.appBarTheme.backgroundColor,
      statusBarBrightness: theme.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
      statusBarIconBrightness: theme.brightness,
    ),
    title: FontIcon(
      FontIconData(
        IconsCG.logo,
        height: 16,
        color: theme.appBarTheme.foregroundColor,
      ),
    ),
  );
}
