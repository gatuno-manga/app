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

  MarkdownStyleSheet _markdownStyle(ThemeData theme, TextStyle body) {
    final base = MarkdownStyleSheet.fromTheme(theme);
    TextStyle? tinted(TextStyle? heading) =>
        heading?.copyWith(color: palette.text);
    final align = preferences.alignment.wrapAlignment;
    return base.copyWith(
      p: body,
      h1: tinted(base.h1),
      h2: tinted(base.h2),
      h3: tinted(base.h3),
      h4: tinted(base.h4),
      h5: tinted(base.h5),
      h6: tinted(base.h6),
      listBullet: body,
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
