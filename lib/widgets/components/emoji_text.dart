import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

/// A widget that extends [TextSpan] with custom emojis.
class EmojiTextSpan extends TextSpan {
  /// A widget that extends [TextSpan] with custom emojis.
  EmojiTextSpan({
    required final String text,
    final TextStyle? style,
    final Iterable<InlineSpan>? children,
    final double emojiFontMultiplier = 1,
    final String? emojiPath,
  }) : super(
          style: style,
          children: _parse(style, text, emojiFontMultiplier, emojiPath)
            ..addAll(children ?? <InlineSpan>[]),
        );

  static List<InlineSpan> _parse(
    final TextStyle? _style,
    final String text,
    final double emojiFontMultiplier,
    final String? emojiPath,
  ) {
    final spans = <InlineSpan>[];
    final emojiStyle = (_style ?? const TextStyle()).copyWith(
      fontSize: (_style?.fontSize ?? 14) * emojiFontMultiplier,
    );
    text.splitMapJoin(
      _regex,
      onMatch: (final m) {
        final emojiStr = m.input.substring(m.start, m.end);
        final unicode = emojiToUnicode(emojiStr);
        assert(unicode?.isNotEmpty ?? false, 'Emoji could not be converted');
        spans.add(
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: emojiStyle.letterSpacing ?? 1,
                vertical: emojiStyle.height ?? 2,
              ),
              child: Image.asset(
                join('assets', 'emoji', '$unicode.png'),
                height: emojiStyle.fontSize,
                errorBuilder: (final context, final e, final st) {
                  return Text(emojiStr, style: _style);
                },
              ),
            ),
          ),
        );
        return '';
      },
      onNonMatch: (final s) {
        spans.add(TextSpan(text: s, style: _style));
        return '';
      },
    );
    return spans;
  }
}

/// A widget rendered with custom emojis.
class EmojiText extends RichText {
  /// A widget rendered with custom emojis.
  EmojiText(
    final String text, {
    final TextStyle? style,
    final double emojiFontMultiplier = 1,
    final String? emojiPath,
    final int? maxLines,
    final Key? key,
  }) : super(
          key: key,
          text: EmojiTextSpan(
            text: text,
            emojiFontMultiplier: emojiFontMultiplier,
            style: style,
            emojiPath: emojiPath,
          ),
          maxLines: maxLines,
        );
}

/// Converts emoji to unicode 😀 => "1F600"
String? emojiToUnicode(final String input) {
  if (input.length == 1) {
    return input.codeUnits.first.toString();
  } else if (input.length > 1) {
    final pairs = <int>[];
    for (var i = 0; i < input.length; i++) {
      if (
          // high surrogate
          input.codeUnits[i] >= 0xd800 && input.codeUnits[i] <= 0xdbff) {
        if (input.codeUnits[i + 1] >= 0xdc00 &&
            input.codeUnits[i + 1] <= 0xdfff) {
          // low surrogate
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
    return pairs.map((final e) => e.toRadixString(16)).toList().join('-');
  }
}

final RegExp _regex = RegExp(
  r'''(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff])[\ufe0e\ufe0f]?(?:[\u0300-\u036f\ufe20-\ufe23\u20d0-\u20f0]|\ud83c[\udffb-\udfff])?(?:\u200d(?:[^\ud800-\udfff]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff])[\ufe0e\ufe0f]?(?:[\u0300-\u036f\ufe20-\ufe23\u20d0-\u20f0]|\ud83c[\udffb-\udfff])?)*''',
);
