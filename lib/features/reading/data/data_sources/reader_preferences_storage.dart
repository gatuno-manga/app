import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/reader_preferences.dart';

/// Persists [ReaderPreferences] in `shared_preferences` (not sensitive).
/// One key per field, namespaced by reader section, so a future reader adds
/// its own keys without touching these.
class ReaderPreferencesStorage {
  static const String _themeKey = 'reader.theme';
  static const String _fontFamilyKey = 'reader.text.font_family';
  static const String _fontSizeKey = 'reader.text.font_size';
  static const String _lineHeightKey = 'reader.text.line_height';
  static const String _alignmentKey = 'reader.text.alignment';

  Future<ReaderPreferences> read() async {
    final prefs = await SharedPreferences.getInstance();
    // copyWith clamps the numbers and the enums fall back on unknown names.
    return ReaderPreferences.defaults.copyWith(
      theme: ReaderTheme.fromName(prefs.getString(_themeKey)),
      text: TextReaderPreferences.defaults.copyWith(
        fontFamily: ReaderFontFamily.fromName(prefs.getString(_fontFamilyKey)),
        fontSize: prefs.getDouble(_fontSizeKey),
        lineHeight: prefs.getDouble(_lineHeightKey),
        alignment: ReaderTextAlignment.fromName(prefs.getString(_alignmentKey)),
      ),
    );
  }

  Future<void> write(ReaderPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final text = preferences.text;
    await prefs.setString(_themeKey, preferences.theme.name);
    await prefs.setString(_fontFamilyKey, text.fontFamily.name);
    await prefs.setDouble(_fontSizeKey, text.fontSize);
    await prefs.setDouble(_lineHeightKey, text.lineHeight);
    await prefs.setString(_alignmentKey, text.alignment.name);
  }
}
