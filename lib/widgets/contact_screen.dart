import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The screen to contact support.
class ContactScreen extends StatelessWidget {
  /// The screen to contact support.
  const ContactScreen({final this.onBackButton, final Key? key})
      : super(key: key);

  /// The function to be passed to appbar's back button.
  final void Function()? onBackButton;

  @override
  Widget build(final BuildContext context) {
    return const Placeholder();
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(
          ObjectFlagProperty<void Function()>.has('onBackButton', onBackButton),
        ),
    );
  }
}
