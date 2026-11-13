import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';

void main() {
  const text = TextReaderPreferences.defaults;

  group('accessibility fields', () {
    test('default to off', () {
      expect(text.letterSpacing, 0);
      expect(text.wordSpacing, 0);
      expect(text.lineWidth, isNull);
      expect(text.suppressItalics, isFalse);
      expect(text.readingRuler, isFalse);
    });

    test('copyWith clamps the spacings and the line width', () {
      expect(text.copyWith(letterSpacing: 1).letterSpacing, 0.10);
      expect(text.copyWith(letterSpacing: -1).letterSpacing, 0);
      expect(text.copyWith(wordSpacing: 1).wordSpacing, 0.32);
      expect(text.copyWith(lineWidth: 10).lineWidth, 40);
      expect(text.copyWith(lineWidth: 500).lineWidth, 100);
    });

    test('clearLineWidth removes the limit; copyWith keeps it otherwise', () {
      final limited = text.copyWith(lineWidth: 60);
      expect(limited.copyWith(fontSize: 20).lineWidth, 60);
      expect(limited.copyWith(clearLineWidth: true).lineWidth, isNull);
    });
  });

  group('stepping', () {
    test('letter spacing moves by 1% and stops at 0 and 10%', () {
      expect(text.stepLetterSpacing(1).letterSpacing, 0.01);
      expect(text.stepLetterSpacing(-1).letterSpacing, 0);
      expect(text.stepLetterSpacing(100).letterSpacing, 0.10);
      expect(text.canDecreaseLetterSpacing, isFalse);
      expect(text.stepLetterSpacing(100).canIncreaseLetterSpacing, isFalse);
    });

    test(
      'word spacing moves by 2% and reaches the preset value in 8 steps',
      () {
        expect(text.stepWordSpacing(1).wordSpacing, 0.02);
        expect(text.stepWordSpacing(8).wordSpacing, 0.16);
        expect(text.stepWordSpacing(100).wordSpacing, 0.32);
        expect(text.canDecreaseWordSpacing, isFalse);
      },
    );

    test('line width goes off -> 40 -> up by 5 -> back to off', () {
      expect(text.canDecreaseLineWidth, isFalse);
      final first = text.stepLineWidth(1);
      expect(first.lineWidth, 40);
      expect(first.stepLineWidth(1).lineWidth, 45);
      expect(first.stepLineWidth(-1).lineWidth, isNull);
      expect(first.stepLineWidth(100).lineWidth, 100);
      expect(first.stepLineWidth(100).canIncreaseLineWidth, isFalse);
      expect(text.stepLineWidth(-1).lineWidth, isNull);
    });
  });

  group('dyslexia mode', () {
    const user = ReaderPreferences(
      theme: ReaderTheme.sepia,
      text: TextReaderPreferences(
        fontFamily: ReaderFontFamily.sans,
        fontSize: 22,
        lineHeight: 1.4,
        alignment: ReaderTextAlignment.justify,
        letterSpacing: 0.02,
        wordSpacing: 0.04,
        lineWidth: 80,
        suppressItalics: false,
        readingRuler: false,
      ),
    );

    test('is off by default', () {
      expect(ReaderPreferences.defaults.dyslexiaMode, isFalse);
    });

    test('on writes the preset and keeps the font size', () {
      final on = user.withDyslexiaMode(true);
      expect(on.dyslexiaMode, isTrue);
      expect(on.theme, ReaderTheme.cream);
      expect(on.text.fontFamily, ReaderFontFamily.lexend);
      expect(on.text.alignment, ReaderTextAlignment.left);
      expect(on.text.lineHeight, 1.8);
      expect(on.text.letterSpacing, 0.05);
      expect(on.text.wordSpacing, 0.16);
      expect(on.text.lineWidth, 60);
      expect(on.text.suppressItalics, isTrue);
      expect(on.text.readingRuler, isTrue);
      expect(on.text.fontSize, 22);
    });

    test('off restores the values the user had', () {
      expect(user.withDyslexiaMode(true).withDyslexiaMode(false), user);
    });

    test('off from a default start restores the defaults', () {
      expect(
        ReaderPreferences.defaults
            .withDyslexiaMode(true)
            .withDyslexiaMode(false),
        ReaderPreferences.defaults,
      );
    });

    test('turning on or off twice changes nothing', () {
      final on = user.withDyslexiaMode(true);
      expect(on.withDyslexiaMode(true), on);
      expect(user.withDyslexiaMode(false), user);
    });

    test('an edit while on stays on and is discarded when turned off', () {
      final edited = user
          .withDyslexiaMode(true)
          .copyWith(
            text: user
                .withDyslexiaMode(true)
                .text
                .copyWith(
                  fontFamily: ReaderFontFamily.atkinson,
                  wordSpacing: 0.20,
                ),
          );
      expect(edited.dyslexiaMode, isTrue);
      expect(edited.text.fontFamily, ReaderFontFamily.atkinson);
      expect(edited.text.letterSpacing, 0.05);

      final off = edited.withDyslexiaMode(false);
      expect(off, user);
    });

    test('the font size changed while on survives turning off', () {
      final on = user.withDyslexiaMode(true);
      final resized = on.copyWith(text: on.text.stepFontSize(2));
      expect(resized.withDyslexiaMode(false).text.fontSize, 24);
      expect(
        resized.withDyslexiaMode(false).text.fontFamily,
        ReaderFontFamily.sans,
      );
    });

    test('a theme change while on is also restored by off', () {
      final changed = user
          .withDyslexiaMode(true)
          .copyWith(theme: ReaderTheme.highContrast);
      expect(changed.dyslexiaMode, isTrue);
      expect(changed.withDyslexiaMode(false).theme, ReaderTheme.sepia);
    });
  });
}
