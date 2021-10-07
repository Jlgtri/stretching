import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:stretching/utils/logger.dart';

/// A widget that extends [TextSpan] with custom emojis.
class EmojiTextSpan extends TextSpan {
  /// A widget that extends [TextSpan] with custom emojis.
  EmojiTextSpan({
    required final String text,
    final TextStyle? style,
    final double emojiFontMultiplier = 1,
    final String? emojiPath,
    final String? emojiPackage,
  }) : super(
          style: style,
          children: () {
            final spans = <InlineSpan>[];
            final emojiStyle = style?.copyWith(
              fontSize: style.fontSize != null
                  ? style.fontSize! * emojiFontMultiplier
                  : null,
            );

            text.splitMapJoin(
              emojiRegex,
              onMatch: (final m) {
                final emojiStr = m.input.substring(m.start, m.end);
                final unicode = emojiToUnicode(emojiStr);
                assert(
                  unicode?.isNotEmpty ?? false,
                  'Emoji could not be converted',
                );
                spans.add(
                  WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: emojiStyle?.letterSpacing ?? 0,
                        vertical: emojiStyle?.height ?? 0,
                      ),
                      child: Image.asset(
                        join(
                          emojiPath ?? join('assets', 'emoji'),
                          '$unicode.png',
                        ),
                        height: emojiStyle?.fontSize,
                        package: emojiPackage,
                        errorBuilder:
                            (final context, final error, final stackTrace) {
                          logger.w('Emoji $emojiStr, $unicode not found');
                          return Text(emojiStr, style: emojiStyle);
                        },
                      ),
                    ),
                  ),
                );
                return emojiStr;
              },
              onNonMatch: (final s) {
                spans.add(TextSpan(text: s, style: emojiStyle));
                return '';
              },
            );
            return spans;
          }(),
        );
}

/// A widget rendered with custom emojis.
class EmojiText extends StatelessWidget {
  /// A widget rendered with custom emojis.
  const EmojiText(
    final this.text, {
    final this.style,
    final this.emojiFontMultiplier = 1,
    final this.emojiPath,
    final this.emojiPackage,
    final this.textAlign,
    final this.textDirection,
    final this.softWrap,
    final this.overflow,
    final this.semanticsLabel,
    final this.textScaleFactor,
    final this.maxLines,
    final this.locale,
    final this.strutStyle,
    final this.textWidthBasis,
    final this.textHeightBehavior,
    final Key? key,
  }) : super(key: key);

  /// The text with emojis to convert in this widget.
  final String text;

  /// The style of this widget.
  final TextStyle? style;

  /// The size multiplier of the emojis compared to text.
  final double emojiFontMultiplier;

  /// The path to load emojis from.
  final String? emojiPath;

  /// The package to load emojis from.
  final String? emojiPackage;

  /// The align of the text in this widget.
  final TextAlign? textAlign;

  /// The direction of the text in this widget.
  final TextDirection? textDirection;

  /// Whether the text should break at soft line breaks.
  final bool? softWrap;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// An alternative semantics label for this text.
  final String? semanticsLabel;

  /// The number of font pixels for each logical pixel.
  final double? textScaleFactor;

  /// The maximum count of lines of this widget.
  final int? maxLines;

  /// The locale of this widget.
  final Locale? locale;

  /// The minimum vertical layout metrics.
  final StrutStyle? strutStyle;

  /// Defines how to measure the width of the rendered text
  final TextWidthBasis? textWidthBasis;

  /// Defines how the paragraph will apply [TextStyle.height] to the ascent of
  /// the first line and descent of the last line.
  final TextHeightBehavior? textHeightBehavior;

  @override
  Widget build(final BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    var effectiveTextStyle = style;
    if (effectiveTextStyle == null || effectiveTextStyle.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }
    if (MediaQuery.boldTextOverride(context)) {
      effectiveTextStyle = effectiveTextStyle
          .merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    final result = RichText(
      textAlign: textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap ?? defaultTextStyle.softWrap,
      overflow:
          overflow ?? effectiveTextStyle.overflow ?? defaultTextStyle.overflow,
      textScaleFactor: textScaleFactor ?? MediaQuery.textScaleFactorOf(context),
      maxLines: maxLines ?? defaultTextStyle.maxLines,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis ?? defaultTextStyle.textWidthBasis,
      textHeightBehavior: textHeightBehavior ??
          defaultTextStyle.textHeightBehavior ??
          DefaultTextHeightBehavior.of(context),
      text: EmojiTextSpan(
        style: effectiveTextStyle,
        text: text,
        emojiFontMultiplier: emojiFontMultiplier,
        emojiPackage: emojiPackage,
        emojiPath: emojiPath,
      ),
    );

    return semanticsLabel != null
        ? Semantics(
            textDirection: textDirection,
            label: semanticsLabel,
            child: ExcludeSemantics(child: result),
          )
        : result;
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(StringProperty('text', text))
        ..add(StringProperty('semanticsLabel', semanticsLabel))
        ..add(StringProperty('emojiPackage', emojiPackage))
        ..add(EnumProperty<TextDirection?>('textDirection', textDirection))
        ..add(DoubleProperty('emojiFontMultiplier', emojiFontMultiplier))
        ..add(
          DiagnosticsProperty<TextHeightBehavior?>(
            'textHeightBehavior',
            textHeightBehavior,
          ),
        )
        ..add(EnumProperty<TextOverflow>('overflow', overflow))
        ..add(IntProperty('maxLines', maxLines))
        ..add(DiagnosticsProperty<Locale?>('locale', locale))
        ..add(EnumProperty<TextAlign>('textAlign', textAlign))
        ..add(DiagnosticsProperty<StrutStyle?>('strutStyle', strutStyle))
        ..add(DiagnosticsProperty<TextStyle?>('style', style))
        ..add(StringProperty('emojiPath', emojiPath))
        ..add(EnumProperty<TextWidthBasis>('textWidthBasis', textWidthBasis))
        ..add(DoubleProperty('textScaleFactor', textScaleFactor))
        ..add(DiagnosticsProperty<bool>('softWrap', softWrap)),
    );
  }
}

/// Converts emoji to unicode 😀 => "1F600"
String? emojiToUnicode(final String input) {
  if (input.length == 1) {
    return input.codeUnits.first.toString();
  } else if (input.length > 1) {
    final pairs = <int>[];
    for (var i = 0; i < input.length; i++) {
      // high surrogate
      if (input.codeUnits[i] >= 0xd800 && input.codeUnits[i] <= 0xdbff) {
        // low surrogate
        if (input.codeUnits[i + 1] >= 0xdc00 &&
            input.codeUnits[i + 1] <= 0xdfff) {
          pairs.add(
            (input.codeUnits[i] - 0xd800) * 0x400 +
                (input.codeUnits[i + 1] - 0xdc00) +
                0x10000,
          );
        }
      } else if (input.codeUnits[i] < 0xd800 || input.codeUnits[i] > 0xdfff) {
        // modifiers and joiners
        pairs.add(input.codeUnitAt(i));
      }
    }
    return pairs
        .map((final e) => e.toRadixString(16))
        .toList(growable: false)
        .join('-');
  }
}

/// The regex to match emojis.
final RegExp emojiRegex = RegExp(
  r'''(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff])[\ufe0e\ufe0f]?(?:[\u0300-\u036f\ufe20-\ufe23\u20d0-\u20f0]|\ud83c[\udffb-\udfff])?(?:\u200d(?:[^\ud800-\udfff]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff])[\ufe0e\ufe0f]?(?:[\u0300-\u036f\ufe20-\ufe23\u20d0-\u20f0]|\ud83c[\udffb-\udfff])?)*''',
);
