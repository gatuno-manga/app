import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_typography.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/presentation/theme/reader_text_style.dart';

void main() {
  group('ReaderFontFamily.family', () {
    test('maps every option to a bundled family name', () {
      expect(ReaderFontFamily.serif.family, AppTypography.literata);
      expect(ReaderFontFamily.sans.family, AppTypography.manrope);
      expect(ReaderFontFamily.lexend.family, AppTypography.lexend);
      expect(ReaderFontFamily.atkinson.family, AppTypography.atkinson);
      expect(ReaderFontFamily.openDyslexic.family, AppTypography.openDyslexic);
    });
  });

  group('TextReaderPreferences.textStyle', () {
    test('uses the chosen family, size and line height', () {
      const prefs = TextReaderPreferences(
        fontFamily: ReaderFontFamily.atkinson,
        fontSize: 22,
        lineHeight: 1.5,
        alignment: ReaderTextAlignment.center,
      );
      final style = prefs.textStyle(color: Colors.red);
      expect(style.fontFamily, 'Atkinson Hyperlegible');
      expect(style.fontSize, 22);
      expect(style.height, 1.5);
      expect(style.color, Colors.red);
    });
  });

  group('ReaderTextAlignment.textAlign', () {
    test('maps to Flutter alignments', () {
      expect(ReaderTextAlignment.left.textAlign, TextAlign.left);
      expect(ReaderTextAlignment.center.textAlign, TextAlign.center);
      expect(ReaderTextAlignment.justify.textAlign, TextAlign.justify);
    });
  });
}
