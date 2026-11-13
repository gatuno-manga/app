import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/reader_preferences.dart';

/// Persists [ReaderPreferences] in `shared_preferences` (not sensitive).
/// One key per field, namespaced by reader section, so a future reader adds
/// its own keys without touching these. Keys added after the first release
/// read as the defaults when missing, so stored data never needs migrating.
class ReaderPreferencesStorage {
  static const String _themeKey = 'reader.theme';
  static const String _fontFamilyKey = 'reader.text.font_family';
  static const String _fontSizeKey = 'reader.text.font_size';
  static const String _lineHeightKey = 'reader.text.line_height';
  static const String _alignmentKey = 'reader.text.alignment';
  static const String _letterSpacingKey = 'reader.text.letter_spacing';
  static const String _wordSpacingKey = 'reader.text.word_spacing';
  static const String _lineWidthKey = 'reader.text.line_width';
  static const String _suppressItalicsKey = 'reader.text.suppress_italics';
  static const String _readingRulerKey = 'reader.text.reading_ruler';

  /// JSON of the values the dyslexia preset replaced; present exactly while
  /// the preset is on.
  static const String _dyslexiaSnapshotKey = 'reader.dyslexia_snapshot';

  Future<ReaderPreferences> read() async {
    final prefs = await SharedPreferences.getInstance();
    // copyWith clamps the numbers and the enums fall back on unknown names.
    return ReaderPreferences(
      theme: ReaderTheme.fromName(prefs.getString(_themeKey)),
      text: TextReaderPreferences.defaults.copyWith(
        fontFamily: ReaderFontFamily.fromName(prefs.getString(_fontFamilyKey)),
        fontSize: prefs.getDouble(_fontSizeKey),
        lineHeight: prefs.getDouble(_lineHeightKey),
        alignment: ReaderTextAlignment.fromName(prefs.getString(_alignmentKey)),
        letterSpacing: prefs.getDouble(_letterSpacingKey),
        wordSpacing: prefs.getDouble(_wordSpacingKey),
        lineWidth: prefs.getDouble(_lineWidthKey),
        suppressItalics: prefs.getBool(_suppressItalicsKey),
        readingRuler: prefs.getBool(_readingRulerKey),
      ),
      dyslexiaSnapshot: _decodeSnapshot(prefs.getString(_dyslexiaSnapshotKey)),
    );
  }

  Future<void> write(ReaderPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final text = preferences.text;
    final snapshot = preferences.dyslexiaSnapshot;
    final lineWidth = text.lineWidth;
    await Future.wait([
      prefs.setString(_themeKey, preferences.theme.name),
      prefs.setString(_fontFamilyKey, text.fontFamily.name),
      prefs.setDouble(_fontSizeKey, text.fontSize),
      prefs.setDouble(_lineHeightKey, text.lineHeight),
      prefs.setString(_alignmentKey, text.alignment.name),
      prefs.setDouble(_letterSpacingKey, text.letterSpacing),
      prefs.setDouble(_wordSpacingKey, text.wordSpacing),
      if (lineWidth == null)
        prefs.remove(_lineWidthKey)
      else
        prefs.setDouble(_lineWidthKey, lineWidth),
      prefs.setBool(_suppressItalicsKey, text.suppressItalics),
      prefs.setBool(_readingRulerKey, text.readingRuler),
      if (snapshot == null)
        prefs.remove(_dyslexiaSnapshotKey)
      else
        prefs.setString(_dyslexiaSnapshotKey, _encodeSnapshot(snapshot)),
    ]);
  }

  static String _encodeSnapshot(DyslexiaSnapshot snapshot) {
    final text = snapshot.text;
    return jsonEncode({
      'theme': snapshot.theme.name,
      'fontFamily': text.fontFamily.name,
      'fontSize': text.fontSize,
      'lineHeight': text.lineHeight,
      'alignment': text.alignment.name,
      'letterSpacing': text.letterSpacing,
      'wordSpacing': text.wordSpacing,
      'lineWidth': text.lineWidth,
      'suppressItalics': text.suppressItalics,
      'readingRuler': text.readingRuler,
    });
  }

  /// A missing or unreadable snapshot means the preset is off; absent
  /// fields inside a readable one fall back to the defaults.
  static DyslexiaSnapshot? _decodeSnapshot(String? raw) {
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      num? number(String key) => json[key] is num ? json[key] as num : null;
      String? string(String key) =>
          json[key] is String ? json[key] as String : null;
      bool? flag(String key) => json[key] is bool ? json[key] as bool : null;
      return DyslexiaSnapshot(
        theme: ReaderTheme.fromName(string('theme')),
        text: TextReaderPreferences.defaults.copyWith(
          fontFamily: ReaderFontFamily.fromName(string('fontFamily')),
          fontSize: number('fontSize')?.toDouble(),
          lineHeight: number('lineHeight')?.toDouble(),
          alignment: ReaderTextAlignment.fromName(string('alignment')),
          letterSpacing: number('letterSpacing')?.toDouble(),
          wordSpacing: number('wordSpacing')?.toDouble(),
          lineWidth: number('lineWidth')?.toDouble(),
          suppressItalics: flag('suppressItalics'),
          readingRuler: flag('readingRuler'),
        ),
      );
    } on FormatException {
      return null;
    }
  }
}
