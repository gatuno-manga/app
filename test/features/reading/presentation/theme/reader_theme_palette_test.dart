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
      // Figma Padrão `leitura/texto-suave` is the text at 62% (0x9E).
      expect(p.textSoft, draculaPalette.text.withAlpha(0x9E));
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
