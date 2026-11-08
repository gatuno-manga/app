import 'package:flutter/material.dart';

/// Text styles of the Figma file (`.impeccable/design.json`, `typography`).
///
/// Sizes are dp, `height` is the Figma line height divided by the font size
/// (percent / 100) and `letterSpacing` is the Figma percentage times the size.
abstract final class AppTypography {
  static const String inknut = 'Inknut Antiqua';
  static const String manrope = 'Manrope';
  static const String plusJakartaSans = 'Plus Jakarta Sans';
  static const String literata = 'Literata';
  static const String lexend = 'Lexend';

  /// `Display/Hero`
  static const TextStyle displayHero = TextStyle(
    fontFamily: inknut,
    fontWeight: FontWeight.w700,
    fontSize: 48,
    height: 1.2,
    letterSpacing: 0,
  );

  /// `Título/1`
  static const TextStyle title1 = TextStyle(
    fontFamily: inknut,
    fontWeight: FontWeight.w600,
    fontSize: 32,
    height: 1.3,
    letterSpacing: 0,
  );

  /// `Título/2`
  static const TextStyle title2 = TextStyle(
    fontFamily: inknut,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.35,
    letterSpacing: 0,
  );

  /// `Título/3`
  static const TextStyle title3 = TextStyle(
    fontFamily: inknut,
    fontWeight: FontWeight.w500,
    fontSize: 20,
    height: 1.4,
    letterSpacing: 0,
  );

  /// `Corpo/Grande`
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: manrope,
    fontWeight: FontWeight.w400,
    fontSize: 18,
    height: 1.6,
    letterSpacing: 0,
  );

  /// `Corpo/Padrão`
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: manrope,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.6,
    letterSpacing: 0,
  );

  /// `Corpo/Pequeno`
  static const TextStyle bodySmall = TextStyle(
    fontFamily: manrope,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0,
  );

  /// `Interface/Botão`
  static const TextStyle button = TextStyle(
    fontFamily: plusJakartaSans,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.2,
    letterSpacing: 0,
  );

  /// `Interface/Rótulo`
  static const TextStyle label = TextStyle(
    fontFamily: plusJakartaSans,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.3,
    letterSpacing: 0,
  );

  /// `Interface/Legenda`
  static const TextStyle caption = TextStyle(
    fontFamily: plusJakartaSans,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.3,
    letterSpacing: 0,
  );

  /// `Interface/Sobrelinha`. Figma also upper-cases the text (`textCase:
  /// UPPER`); a [TextStyle] cannot, so callers apply `toUpperCase()`.
  static const TextStyle overline = TextStyle(
    fontFamily: plusJakartaSans,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    height: 1.3,
    letterSpacing: 1.32,
  );

  /// `Leitura/Serifa` (reader).
  static const TextStyle readingSerif = TextStyle(
    fontFamily: literata,
    fontWeight: FontWeight.w400,
    fontSize: 19,
    height: 1.8,
    letterSpacing: 0,
  );

  /// `Leitura/Dislexia` (reader).
  static const TextStyle readingDyslexia = TextStyle(
    fontFamily: lexend,
    fontWeight: FontWeight.w400,
    fontSize: 20,
    height: 1.8,
    letterSpacing: 1,
  );

  /// Maps the Figma styles onto the Material roles named in `DESIGN.md`.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayHero,
    headlineMedium: title1,
    headlineSmall: title2,
    titleLarge: title3,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: button,
    labelMedium: label,
    labelSmall: caption,
  );
}
