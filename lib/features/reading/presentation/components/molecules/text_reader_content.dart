import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../../core/theme/reader_palette.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../../../domain/entities/reading_enums.dart';
import '../../theme/reader_text_style.dart';

/// The chapter body in its [format], styled by [preferences] and [palette].
class TextReaderContent extends StatelessWidget {
  final String content;
  final ContentFormat? format;
  final TextReaderPreferences preferences;
  final ReaderPalette palette;

  const TextReaderContent({
    super.key,
    required this.content,
    required this.format,
    required this.preferences,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final style = preferences.textStyle(color: palette.text);
    switch (format) {
      case ContentFormat.html:
        return Html(
          data: content,
          style: {
            'body': Style(
              margin: Margins.zero,
              fontFamily: style.fontFamily,
              fontSize: FontSize(preferences.fontSize),
              lineHeight: LineHeight(preferences.lineHeight),
              textAlign: preferences.alignment.textAlign,
              color: palette.text,
            ),
            'a': Style(color: palette.accent),
          },
        );
      case ContentFormat.markdown:
        return MarkdownBody(
          data: content,
          styleSheet: _markdownStyle(Theme.of(context), style),
        );
      case ContentFormat.plain:
      case null:
        return Text(
          content,
          style: style,
          textAlign: preferences.alignment.textAlign,
        );
    }
  }

  // Heading sizes relative to the body, so they scale with the font size
  // setting and never fall below the paragraphs.
  static const List<double> _headingScale = [1.6, 1.4, 1.2, 1.1, 1.0, 1.0];

  MarkdownStyleSheet _markdownStyle(ThemeData theme, TextStyle body) {
    final base = MarkdownStyleSheet.fromTheme(theme);
    final bodySize = body.fontSize!;
    TextStyle? heading(TextStyle? style, int level) => style?.copyWith(
      color: palette.text,
      fontSize: bodySize * _headingScale[level],
      height: body.height,
      fontWeight: level >= 4 ? FontWeight.w700 : null,
    );
    final align = preferences.alignment.wrapAlignment;
    return base.copyWith(
      p: body,
      h1: heading(base.h1, 0),
      h2: heading(base.h2, 1),
      h3: heading(base.h3, 2),
      h4: heading(base.h4, 3),
      h5: heading(base.h5, 4),
      h6: heading(base.h6, 5),
      listBullet: body,
      tableBody: body,
      checkbox: body,
      code: base.code?.copyWith(
        color: palette.text,
        backgroundColor: palette.surface,
        fontSize: bodySize * 0.9,
        height: body.height,
      ),
      codeblockDecoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      blockquote: body.copyWith(color: palette.textSoft),
      blockquoteDecoration: BoxDecoration(
        color: palette.highlight,
        border: Border(left: BorderSide(color: palette.accent, width: 3)),
      ),
      a: body.copyWith(color: palette.accent),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.border)),
      ),
      textAlign: align,
      blockquoteAlign: align,
      unorderedListAlign: align,
      orderedListAlign: align,
    );
  }
}
