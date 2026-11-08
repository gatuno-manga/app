import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';

void main() {
  group('TextReaderPreferences', () {
    test('defaults match the Figma text reader (Serif 19, 1.8, left)', () {
      const prefs = TextReaderPreferences.defaults;
      expect(prefs.fontFamily, ReaderFontFamily.serif);
      expect(prefs.fontSize, 19);
      expect(prefs.lineHeight, 1.8);
      expect(prefs.alignment, ReaderTextAlignment.left);
    });

    test('copyWith clamps font size to 14..28', () {
      expect(TextReaderPreferences.defaults.copyWith(fontSize: 5).fontSize, 14);
      expect(
        TextReaderPreferences.defaults.copyWith(fontSize: 40).fontSize,
        28,
      );
      expect(
        TextReaderPreferences.defaults.copyWith(fontSize: 20).fontSize,
        20,
      );
    });

    test('copyWith clamps line height to 1.2..2.2', () {
      expect(
        TextReaderPreferences.defaults.copyWith(lineHeight: 0.5).lineHeight,
        1.2,
      );
      expect(
        TextReaderPreferences.defaults.copyWith(lineHeight: 3).lineHeight,
        2.2,
      );
    });

    test('copyWith keeps untouched fields and supports equality', () {
      final changed = TextReaderPreferences.defaults.copyWith(
        fontFamily: ReaderFontFamily.lexend,
      );
      expect(changed.fontSize, TextReaderPreferences.defaults.fontSize);
      expect(
        changed,
        const TextReaderPreferences(
          fontFamily: ReaderFontFamily.lexend,
          fontSize: 19,
          lineHeight: 1.8,
          alignment: ReaderTextAlignment.left,
        ),
      );
    });
  });

  group('ReaderPreferences', () {
    test('defaults to the standard theme and default text preferences', () {
      const prefs = ReaderPreferences.defaults;
      expect(prefs.theme, ReaderTheme.standard);
      expect(prefs.text, TextReaderPreferences.defaults);
    });

    test('copyWith replaces one section without touching the other', () {
      final prefs = ReaderPreferences.defaults.copyWith(
        theme: ReaderTheme.sepia,
      );
      expect(prefs.theme, ReaderTheme.sepia);
      expect(prefs.text, TextReaderPreferences.defaults);
    });
  });

  group('enum parsing', () {
    test('fromName returns the matching value', () {
      expect(ReaderFontFamily.fromName('lexend'), ReaderFontFamily.lexend);
      expect(ReaderTheme.fromName('cream'), ReaderTheme.cream);
      expect(
        ReaderTextAlignment.fromName('justify'),
        ReaderTextAlignment.justify,
      );
    });

    test('fromName falls back to the default for null or unknown', () {
      expect(ReaderFontFamily.fromName(null), ReaderFontFamily.serif);
      expect(ReaderFontFamily.fromName('comic'), ReaderFontFamily.serif);
      expect(ReaderTheme.fromName('neon'), ReaderTheme.standard);
      expect(ReaderTextAlignment.fromName(null), ReaderTextAlignment.left);
    });
  });
}
