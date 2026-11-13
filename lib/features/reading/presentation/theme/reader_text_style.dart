import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/reader_preferences.dart';

/// Bundled font family of each [ReaderFontFamily] (see `pubspec.yaml`).
extension ReaderFontFamilyName on ReaderFontFamily {
  String get family => switch (this) {
    ReaderFontFamily.serif => AppTypography.literata,
    ReaderFontFamily.sans => AppTypography.manrope,
    ReaderFontFamily.lexend => AppTypography.lexend,
    ReaderFontFamily.atkinson => AppTypography.atkinson,
    ReaderFontFamily.openDyslexic => AppTypography.openDyslexic,
  };
}

extension ReaderTextAlignmentValue on ReaderTextAlignment {
  TextAlign get textAlign => switch (this) {
    ReaderTextAlignment.left => TextAlign.left,
    ReaderTextAlignment.center => TextAlign.center,
    ReaderTextAlignment.justify => TextAlign.justify,
  };

  /// `MarkdownStyleSheet` alignment; `spaceBetween` is what the markdown
  /// builder turns into [TextAlign.justify].
  WrapAlignment get wrapAlignment => switch (this) {
    ReaderTextAlignment.left => WrapAlignment.start,
    ReaderTextAlignment.center => WrapAlignment.center,
    ReaderTextAlignment.justify => WrapAlignment.spaceBetween,
  };
}

extension TextReaderPreferencesStyle on TextReaderPreferences {
  /// Body style of the text reader for these preferences.
  // The reader owns its typography: the family and size are the user's
  // choice, not the app theme's.
  // ignore: gatuno_lints/inline_text_style
  TextStyle textStyle({required Color color}) => TextStyle(
    fontFamily: fontFamily.family,
    fontSize: fontSize,
    height: lineHeight,
    color: color,
    letterSpacing: letterSpacing * fontSize,
    wordSpacing: wordSpacing * fontSize,
    fontStyle: suppressItalics ? FontStyle.normal : null,
  );

  /// Width of the line limit in dp, or null without one. `ch` is the width
  /// of the glyph `0` in [style], like the CSS unit.
  double? maxContentWidth(TextStyle style) {
    final chars = lineWidth;
    if (chars == null) return null;
    final painter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final zero = painter.width;
    painter.dispose();
    return chars * zero;
  }
}
