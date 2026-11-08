import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/reader_palette.dart';
import 'package:gatuno/core/theme/theme.dart';

void main() {
  group('ReaderPalette fixed themes (Figma leitura/*)', () {
    test('sepia', () {
      const p = ReaderPalette.sepia;
      expect(p.background, const Color(0xFFF4ECD8));
      expect(p.surface, const Color(0xFFEADFC6));
      expect(p.text, const Color(0xFF4A3A2C));
      expect(p.textSoft, const Color(0xFF6E5A48));
      expect(p.accent, const Color(0xFF9A4A00));
      expect(p.highlight, const Color(0x1F9A4A00));
      expect(p.border, const Color(0x2E4A3A2C));
    });

    test('cream', () {
      const p = ReaderPalette.cream;
      expect(p.background, const Color(0xFFFAF4E1));
      expect(p.surface, const Color(0xFFF0E8D0));
      expect(p.text, const Color(0xFF1F2430));
      expect(p.textSoft, const Color(0xFF4A5060));
      expect(p.accent, const Color(0xFF1B5FAD));
      expect(p.highlight, const Color(0x1F1B5FAD));
      expect(p.border, const Color(0x291F2430));
    });

    test('high contrast', () {
      const p = ReaderPalette.highContrast;
      expect(p.background, const Color(0xFF000000));
      expect(p.surface, const Color(0xFF111111));
      expect(p.text, const Color(0xFFFFFFFF));
      expect(p.textSoft, const Color(0xFFE6E6E6));
      expect(p.accent, const Color(0xFFFFD600));
      expect(p.highlight, const Color(0x38FFD600));
      expect(p.border, const Color(0x99FFFFFF));
    });
  });

  group('ReaderPalette.themeData', () {
    test('overrides the surface roles and exposes the extension', () {
      final theme = ReaderPalette.sepia.themeData(AppTheme.darkTheme);
      expect(theme.colorScheme.surface, ReaderPalette.sepia.background);
      expect(theme.colorScheme.onSurface, ReaderPalette.sepia.text);
      expect(theme.colorScheme.primary, ReaderPalette.sepia.accent);
      expect(theme.colorScheme.outline, ReaderPalette.sepia.border);
      expect(
        theme.colorScheme.surfaceContainerHighest,
        ReaderPalette.sepia.surface,
      );
      expect(theme.scaffoldBackgroundColor, ReaderPalette.sepia.background);
      expect(theme.brightness, Brightness.light);
      expect(theme.extension<ReaderPalette>(), ReaderPalette.sepia);
      // Other extensions survive.
      expect(theme.extension<GatunoColors>(), isNotNull);
    });

    test('re-derives the baked text, icon and canvas colours', () {
      final theme = ReaderPalette.sepia.themeData(AppTheme.darkTheme);
      expect(theme.textTheme.bodyMedium?.color, ReaderPalette.sepia.text);
      expect(theme.textTheme.titleMedium?.color, ReaderPalette.sepia.text);
      expect(theme.textTheme.headlineSmall?.color, ReaderPalette.sepia.text);
      expect(
        theme.primaryTextTheme.bodyMedium?.color,
        ReaderPalette.sepia.text,
      );
      expect(theme.iconTheme.color, ReaderPalette.sepia.text);
      expect(theme.canvasColor, ReaderPalette.sepia.surface);
      expect(theme.dividerColor, ReaderPalette.sepia.border);
      expect(theme.hintColor, ReaderPalette.sepia.textSoft);
      expect(theme.colorScheme.onSurfaceVariant, ReaderPalette.sepia.textSoft);
      expect(theme.colorScheme.onPrimary, ReaderPalette.sepia.onAccent);

      final mirror = ReaderPalette.highContrast.themeData(AppTheme.lightTheme);
      expect(
        mirror.textTheme.bodyMedium?.color,
        ReaderPalette.highContrast.text,
      );
      expect(mirror.colorScheme.onPrimary, const Color(0xFF000000));
    });

    test('dark backgrounds produce a dark brightness', () {
      final theme = ReaderPalette.highContrast.themeData(AppTheme.lightTheme);
      expect(theme.brightness, Brightness.dark);
    });
  });

  test('lerp interpolates colors', () {
    final mid = ReaderPalette.highContrast.lerp(ReaderPalette.cream, 0.5);
    expect(
      mid.background,
      Color.lerp(
        ReaderPalette.highContrast.background,
        ReaderPalette.cream.background,
        0.5,
      ),
    );
    expect(
      mid.accent,
      Color.lerp(
        ReaderPalette.highContrast.accent,
        ReaderPalette.cream.accent,
        0.5,
      ),
    );
  });

  test('onAccent is readable on the accent', () {
    expect(ReaderPalette.sepia.onAccent, const Color(0xFFFDFDFD));
    expect(ReaderPalette.cream.onAccent, const Color(0xFFFDFDFD));
    expect(ReaderPalette.highContrast.onAccent, const Color(0xFF000000));
  });
}
