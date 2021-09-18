import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:stretching/const.dart';
import 'package:stretching/generated/assets.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/widgets/appbars.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/screens/profile/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// The screen to contact support.
class ContactScreen extends StatelessWidget {
  /// The screen to contact support.
  const ContactScreen({required final this.onBackButton, final Key? key})
      : super(key: key);

  /// The function to be passed to appbar's back button.
  final FutureOr<void> Function() onBackButton;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    Widget messenger(
      final String title,
      final String iconUrl,
      final String url,
    ) {
      return MaterialButton(
        onPressed: () => launch(url),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                border: Border.all(color: theme.hintColor),
              ),
              alignment: Alignment.center,
              child: Image.asset(iconUrl, height: 32, width: 32),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.headline6,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        await onBackButton();
        return true;
      },
      child: Scaffold(
        appBar: cancelAppBar(
          theme,
          title: ProfileNavigationScreen.support.translation,
          leading: FontIconBackButton(
            color: theme.colorScheme.onSurface,
            onPressed: onBackButton,
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
                    padding: const EdgeInsets.symmetric(horizontal: 36)
                        .copyWith(top: 72),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        TR.supportTitle.tr(),
                        style: theme.textTheme.headline2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: messenger(
                            TR.supportMessengerVkontakte.tr(),
                            AssetsCG.messengersVk,
                            'Vk://vk.com/smstretching',
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
                            'tg://resolve?domain=SMSTRETCHINGSupportBot',
                          ),
                        ),
                        Expanded(
                          child: messenger(
                            TR.supportMessengerWhatsApp.tr(),
                            AssetsCG.messengersWhatsApp,
                            'whatsapp://send?phone=+79854880070',
                          ),
                        ),
                        // Expanded(child:messenger(
                        //   TR.supportMessengerViber.tr(),
                        //   AssetsCG.messengersViber,
                        // ),),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 270),
                      child: Text(
                        TR.supportInfo.tr(),
                        style: theme.textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                TR.miscVersion.tr(args: <String>[currentVersion]),
                style: theme.textTheme.headline6,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
