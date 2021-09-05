import 'package:catcher/catcher.dart';
import 'package:catcher/model/platform_type.dart';
import 'package:darq/darq.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/providers/connection_provider.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/components/emoji_text.dart';
import 'package:stretching/widgets/components/font_icon.dart';

/// The provider of the error inside the app.
final StateProvider<Tuple2<ReportMode, Report>?> errorProvider =
    StateProvider<Tuple2<ReportMode, Report>?>((final ref) => null);

/// The custom page report mode.
class ErrorPageReportMode extends ReportMode {
  /// The custom page report mode.
  ErrorPageReportMode();

  @override
  Future<void> requestAction(
    final Report report,
    final BuildContext? context,
  ) async {
    assert(context != null, 'Context is null.');
    final container = ProviderScope.containerOf(context!, listen: false);
    container.read(errorProvider).state = Tuple2(this, report);
  }

  @override
  bool isContextRequired() => true;

  @override
  List<PlatformType> getSupportedPlatforms() => PlatformType.values;
}

/// The screen to display an error in the app.
class ErrorScreen extends HookConsumerWidget {
  /// The screen to display an error in the app.
  const ErrorScreen(
    final this.reportMode,
    final this.report, {
    final Key? key,
  }) : super(key: key);

  /// The report mode specified for this handler.
  final ReportMode reportMode;

  /// The report created for this handler.
  final Report report;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Align(
        child: SingleChildScrollView(
          primary: true,
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              EmojiText('😣', style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 14),
              Text(TR.errorTitle.tr(), style: theme.textTheme.headline2),
              const SizedBox(height: 40),
              Text.rich(
                TextSpan(
                  text: TR.errorDescription.tr(),
                  children: <InlineSpan>[
                    TextSpan(
                      text: TR.errorDescriptionBold.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 200,
                child: TextButton(
                  style: TextButtonStyle.light.fromTheme(theme),
                  onPressed: () => reportMode.onActionConfirmed(report),
                  child: Text(TR.errorButton.tr()),
                ),
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
        ..add(DiagnosticsProperty<ReportMode>('reportMode', reportMode))
        ..add(DiagnosticsProperty<Report>('report', report)),
    );
  }
}

/// The screen to display an error in the app.
class ConnectionErrorScreen extends ConsumerWidget {
  /// The screen to display an error in the app.
  const ConnectionErrorScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    return Align(
      child: SingleChildScrollView(
        primary: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const FontIcon(FontIconData(IconsCG.globe, height: 40)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
              child: Text(
                TR.connectionErrorTitle.tr(),
                style: theme.textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            Consumer(
              child: Text(TR.connectionErrorRepeat.tr()),
              builder: (final context, final ref, final child) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 4,
                  ),
                  child: TextButton.icon(
                    label: child!,
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: FontIcon(
                        FontIconData(IconsCG.repeat, height: 16),
                      ),
                    ),
                    style: TextButtonStyle.light.fromTheme(theme),
                    onPressed: () => ref
                        .read(connectionProvider.notifier)
                        .updateConnection(),
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
