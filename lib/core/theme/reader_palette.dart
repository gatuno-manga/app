import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Color tokens of one reader theme (`.impeccable/design.json`,
/// `readerThemes`, Figma collection "Gatuno / Leitura (temas)").
///
/// Reader surfaces read it through `Theme.of(context).extension<ReaderPalette>()`
/// after [themeData] has been applied to their subtree.
class ReaderPalette extends ThemeExtension<ReaderPalette> {
  const ReaderPalette({
    required this.background,
    required this.surface,
    required this.text,
    required this.textSoft,
    required this.accent,
    required this.highlight,
    required this.border,
  });

  /// `leitura/fundo`
  final Color background;

  /// `leitura/superficie`
  final Color surface;

  /// `leitura/texto`
  final Color text;

  /// `leitura/texto-suave`
  final Color textSoft;

  /// `leitura/acento`
  final Color accent;

  /// `leitura/destaque`
  final Color highlight;

  /// `leitura/borda`
  final Color border;

  /// Figma mode `Sépia`.
  static const ReaderPalette sepia = ReaderPalette(
    background: Color(0xFFF4ECD8),
    surface: Color(0xFFEADFC6),
    text: Color(0xFF4A3A2C),
    textSoft: Color(0xFF6E5A48),
    accent: Color(0xFF9A4A00),
    highlight: Color(0x1F9A4A00),
    border: Color(0x2E4A3A2C),
  );

  /// Figma mode `Creme`.
  static const ReaderPalette cream = ReaderPalette(
    background: Color(0xFFFAF4E1),
    surface: Color(0xFFF0E8D0),
    text: Color(0xFF1F2430),
    textSoft: Color(0xFF4A5060),
    accent: Color(0xFF1B5FAD),
    highlight: Color(0x1F1B5FAD),
    border: Color(0x291F2430),
  );

  /// Figma mode `Alto contraste`.
  static const ReaderPalette highContrast = ReaderPalette(
    background: Color(0xFF000000),
    surface: Color(0xFF111111),
    text: Color(0xFFFFFFFF),
    textSoft: Color(0xFFE6E6E6),
    accent: Color(0xFFFFD600),
    highlight: Color(0x38FFD600),
    border: Color(0x99FFFFFF),
  );

  // Alpha of `leitura/destaque` in the Figma `Padrão` mode (#f185221f).
  static const int _highlightAlpha = 0x1F;

  /// Figma mode `Padrão`: the app theme's own tokens, so True-dark, Dracula
  /// or Light users keep their look inside the reader.
  static ReaderPalette fromAppPalette(AppPalette app) => ReaderPalette(
    background: app.appBackground,
    surface: app.secondary,
    text: app.text,
    textSoft: app.textSecondary,
    accent: app.primary,
    highlight: app.primary.withAlpha(_highlightAlpha),
    border: app.border,
  );

  /// [base] with the Material surface roles replaced by this palette, so the
  /// reader chrome and sheets built from `colorScheme` follow the reader
  /// theme without knowing about it.
  ThemeData themeData(ThemeData base) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return base.copyWith(
      brightness: brightness,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        surface: background,
        onSurface: text,
        primary: accent,
        outline: border,
        surfaceContainerHighest: surface,
      ),
      scaffoldBackgroundColor: background,
      extensions: [...base.extensions.values, this],
    );
  }

  @override
  ReaderPalette copyWith({
    Color? background,
    Color? surface,
    Color? text,
    Color? textSoft,
    Color? accent,
    Color? highlight,
    Color? border,
  }) {
    return ReaderPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      textSoft: textSoft ?? this.textSoft,
      accent: accent ?? this.accent,
      highlight: highlight ?? this.highlight,
      border: border ?? this.border,
    );
  }

  @override
  ReaderPalette lerp(ThemeExtension<ReaderPalette>? other, double t) {
    if (other is! ReaderPalette) return this;
    return ReaderPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSoft: Color.lerp(textSoft, other.textSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReaderPalette &&
      other.background == background &&
      other.surface == surface &&
      other.text == text &&
      other.textSoft == textSoft &&
      other.accent == accent &&
      other.highlight == highlight &&
      other.border == border;

  @override
  int get hashCode => Object.hash(
    background,
    surface,
    text,
    textSoft,
    accent,
    highlight,
    border,
  );
}
