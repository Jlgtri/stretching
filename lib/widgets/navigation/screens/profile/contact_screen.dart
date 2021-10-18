import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/hooks/hook_consumer_stateful_widget.dart';
import 'package:stretching/providers/hide_appbar_provider.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';
import 'package:stretching/widgets/navigation/screens/profile/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// The screen to contact support.
class ContactScreen extends HookConsumerStatefulWidget {
  /// The screen to contact support.
  const ContactScreen({final this.onBackButton, final Key? key})
      : super(key: key);

  /// The function to be passed to appbar's back button.
  final FutureOr<void> Function()? onBackButton;

  @override
  ContactScreenState createState() => ContactScreenState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(
          ObjectFlagProperty<FutureOr<void> Function()>.has(
            'onBackButton',
            onBackButton,
          ),
        ),
    );
  }
}

/// The screen to contact support.
class ContactScreenState extends ConsumerState<ContactScreen>
    with HideAppBarRouteAware {
  @override
  NavigationScreen get screenType => NavigationScreen.profile;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final packageInfo = ref.watch(packageInfoProvider);

    Widget messenger(
      final String title,
      final String iconUrl,
      final String url,
    ) =>
        Align(
          child: MaterialButton(
            onPressed: () => launch(url),
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(4)) *
                  mediaQuery.textScaleFactor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 50 * mediaQuery.textScaleFactor,
                  width: 50 * mediaQuery.textScaleFactor,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(color: theme.hintColor),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    iconUrl,
                    height: 32 * mediaQuery.textScaleFactor,
                    width: 32 * mediaQuery.textScaleFactor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.headline6,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor: mediaQuery.textScaleFactor.clamp(0, 1.1),
                ),
              ],
            ),
          ),
        );

    final phoneFormatter = useMemoized(
      () => MaskTextInputFormatter(
        initialText: supportPhoneNumber.toString(),
        mask: '# ### ### ## ##',
        filter: {'#': RegExp(r'\d')},
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        await widget.onBackButton?.call();
        return widget.onBackButton == null;
      },
      child: Scaffold(
        appBar: cancelAppBar(
          theme,
          title: ProfileNavigationScreen.support.translation,
          leading: FontIconBackButton(
            color: theme.colorScheme.onSurface,
            onPressed: widget.onBackButton,
          ),
        ),
        body: NativeDeviceOrientationReader(
          builder: (final context) => Align(
            child: SingleChildScrollView(
              key: UniqueKey(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: GestureDetector(
                      onTap: () => launch('tel:$supportPhoneNumber'),
                      child: Text(
                        phoneFormatter.getMaskedText(),
                        style: theme.textTheme.headline2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor:
                            mediaQuery.textScaleFactor.clamp(0, 1.2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36)
                        .copyWith(top: 60),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: mediaQuery.textScaleFactor <= 1
                            ? 300
                            : double.infinity,
                      ),
                      child: Text(
                        TR.supportTitle.tr(),
                        style: theme.textTheme.headline3,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: messenger(
                            TR.supportMessengerVkontakte.tr(),
                            AssetsCG.messengersVk,
                            'https://vk.me/smstretching',
                          ),
                        ),
                        Expanded(
                          child: messenger(
                            TR.supportMessengerFacebook.tr(),
                            AssetsCG.messengersFacebook,
                            'https://m.me/smstretching',
                          ),
                        ),
                        Expanded(
                          child: messenger(
                            TR.supportMessengerTelegram.tr(),
                            AssetsCG.messengersTelegram,
                            'https://telegram.me/SMSTRETCHINGSupportBot',
                          ),
                        ),
                        Expanded(
                          child: messenger(
                            TR.supportMessengerWhatsApp.tr(),
                            AssetsCG.messengersWhatsApp,
                            'https://api.whatsapp.com/send?phone=79854880070',
                          ),
                        ),
                        // Expanded(child:messenger(
                        //   TR.supportMessengerViber.tr(),
                        //   AssetsCG.messengersViber,
                        // ),),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 270),
                      child: Text(
                        TR.supportInfo.tr(),
                        style: theme.textTheme.bodyText2,
                        textAlign: TextAlign.center,
                        textScaleFactor:
                            mediaQuery.textScaleFactor.clamp(0, 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom:
                NavigationRoot.navBarHeight + 18 * mediaQuery.textScaleFactor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                TR.miscVersion.tr(args: <String>[packageInfo.version]),
                style: theme.textTheme.headline6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
