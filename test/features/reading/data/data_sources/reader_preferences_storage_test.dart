import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/data/data_sources/reader_preferences_storage.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ReaderPreferencesStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = ReaderPreferencesStorage();
  });

  group('ReaderPreferencesStorage', () {
    test('read returns defaults when nothing is stored', () async {
      expect(await storage.read(), ReaderPreferences.defaults);
    });

    test('write then read round-trips every field', () async {
      const prefs = ReaderPreferences(
        theme: ReaderTheme.cream,
        text: TextReaderPreferences(
          fontFamily: ReaderFontFamily.openDyslexic,
          fontSize: 22,
          lineHeight: 2.0,
          alignment: ReaderTextAlignment.justify,
        ),
      );
      await storage.write(prefs);
      expect(await storage.read(), prefs);
    });

    test('unknown stored names fall back to defaults', () async {
      SharedPreferences.setMockInitialValues({
        'reader.theme': 'neon',
        'reader.text.font_family': 'comic',
        'reader.text.alignment': 'diagonal',
      });
      expect(await storage.read(), ReaderPreferences.defaults);
    });

    test('out-of-range stored numbers are clamped', () async {
      SharedPreferences.setMockInitialValues({
        'reader.text.font_size': 99.0,
        'reader.text.line_height': 0.1,
      });
      final prefs = await storage.read();
      expect(prefs.text.fontSize, TextReaderPreferences.maxFontSize);
      expect(prefs.text.lineHeight, TextReaderPreferences.minLineHeight);
    });

    group('accessibility fields', () {
      const accessible = ReaderPreferences(
        theme: ReaderTheme.cream,
        text: TextReaderPreferences(
          fontFamily: ReaderFontFamily.lexend,
          fontSize: 20,
          lineHeight: 1.8,
          alignment: ReaderTextAlignment.left,
          letterSpacing: 0.05,
          wordSpacing: 0.16,
          lineWidth: 60,
          suppressItalics: true,
          readingRuler: true,
        ),
      );

      test('round-trip, including the dyslexia snapshot', () async {
        final on = const ReaderPreferences(
          theme: ReaderTheme.sepia,
          text: TextReaderPreferences(
            fontFamily: ReaderFontFamily.sans,
            fontSize: 22,
            lineHeight: 1.4,
            alignment: ReaderTextAlignment.justify,
            letterSpacing: 0.02,
            wordSpacing: 0.04,
            lineWidth: 80,
          ),
        ).withDyslexiaMode(true);
        await storage.write(on);
        final read = await storage.read();
        expect(read, on);
        expect(read.dyslexiaMode, isTrue);
        expect(read.withDyslexiaMode(false).theme, ReaderTheme.sepia);
      });

      test('write then read round-trips the fields', () async {
        await storage.write(accessible);
        expect(await storage.read(), accessible);
      });

      test(
        'data stored before these fields existed reads as defaults',
        () async {
          SharedPreferences.setMockInitialValues({
            'reader.theme': 'sepia',
            'reader.text.font_family': 'lexend',
            'reader.text.font_size': 21.0,
            'reader.text.line_height': 1.6,
            'reader.text.alignment': 'center',
          });
          final prefs = await storage.read();
          expect(prefs.theme, ReaderTheme.sepia);
          expect(prefs.text.fontSize, 21);
          expect(prefs.text.letterSpacing, 0);
          expect(prefs.text.wordSpacing, 0);
          expect(prefs.text.lineWidth, isNull);
          expect(prefs.text.suppressItalics, isFalse);
          expect(prefs.text.readingRuler, isFalse);
          expect(prefs.dyslexiaMode, isFalse);
        },
      );

      test('a removed line width is not read back', () async {
        await storage.write(accessible);
        await storage.write(
          accessible.copyWith(
            text: accessible.text.copyWith(clearLineWidth: true),
          ),
        );
        expect((await storage.read()).text.lineWidth, isNull);
      });

      test('turning the preset off removes the snapshot', () async {
        await storage.write(accessible.withDyslexiaMode(false));
        final on = ReaderPreferences.defaults.withDyslexiaMode(true);
        await storage.write(on);
        expect((await storage.read()).dyslexiaMode, isTrue);
        await storage.write(on.withDyslexiaMode(false));
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.containsKey('reader.dyslexia_snapshot'), isFalse);
        expect((await storage.read()).dyslexiaMode, isFalse);
      });

      test('out-of-range numbers are clamped', () async {
        SharedPreferences.setMockInitialValues({
          'reader.text.letter_spacing': 5.0,
          'reader.text.word_spacing': -1.0,
          'reader.text.line_width': 5.0,
        });
        final text = (await storage.read()).text;
        expect(text.letterSpacing, 0.10);
        expect(text.wordSpacing, 0);
        expect(text.lineWidth, 40);
      });

      test('a corrupt snapshot means the preset is off', () async {
        for (final raw in ['not json', '[1,2]', '"x"']) {
          SharedPreferences.setMockInitialValues({
            'reader.dyslexia_snapshot': raw,
          });
          expect((await storage.read()).dyslexiaMode, isFalse, reason: raw);
        }
      });

      test('a partial snapshot fills the gaps with defaults', () async {
        SharedPreferences.setMockInitialValues({
          'reader.dyslexia_snapshot': '{"theme":"sepia","fontSize":23}',
        });
        final prefs = await storage.read();
        expect(prefs.dyslexiaMode, isTrue);
        final off = prefs.withDyslexiaMode(false);
        expect(off.theme, ReaderTheme.sepia);
        expect(off.text.fontFamily, TextReaderPreferences.defaults.fontFamily);
      });
    });
  });
}
