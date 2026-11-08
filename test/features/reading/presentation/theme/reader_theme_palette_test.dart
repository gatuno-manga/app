import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/reader_palette.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/presentation/theme/reader_theme_palette.dart';

void main() {
  group('ReaderTheme.palette', () {
    test('standard follows the app palette', () {
      final p = ReaderTheme.standard.palette(draculaPalette);
      expect(p.background, draculaPalette.appBackground);
      expect(p.surface, draculaPalette.secondary);
      expect(p.text, draculaPalette.text);
      // Text at 70%: the lowest alpha that passes 4.5:1 on every app theme's
      // sheet surface (Figma's own Padrão value, 62%, fails on Light).
      expect(p.textSoft, draculaPalette.text.withAlpha(0xB3));
      expect(p.accent, draculaPalette.primary);
      expect(p.highlight, draculaPalette.primary.withAlpha(0x1F));
      expect(p.border, draculaPalette.border);
      expect(p.onAccent, draculaPalette.onPrimary);
    });

    test('fixed themes ignore the app palette', () {
      expect(ReaderTheme.sepia.palette(lightPalette), ReaderPalette.sepia);
      expect(ReaderTheme.cream.palette(darkPalette), ReaderPalette.cream);
      expect(
        ReaderTheme.highContrast.palette(slatePalette),
        ReaderPalette.highContrast,
      );
    });
  });
}
