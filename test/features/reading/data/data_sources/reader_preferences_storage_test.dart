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
  });
}
