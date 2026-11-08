import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/semantic_colors.dart';
import 'package:gatuno/core/theme/theme.dart';

void main() {
  group('SemanticThemeColors', () {
    test('reads status colors from the Gatuno palette', () {
      final theme = AppTheme.darkTheme;
      final palette = theme.extension<GatunoColors>()!.palette;

      expect(theme.successColor, palette.success);
      expect(theme.warningColor, palette.warning);
      expect(theme.infoColor, palette.cyan);
      expect(theme.mutedColor, palette.textSecondary);
    });

    test('falls back to the light palette without GatunoColors', () {
      final theme = ThemeData();

      expect(theme.successColor, lightPalette.success);
      expect(theme.warningColor, lightPalette.warning);
    });

    test('legible moves a status color toward the text color', () {
      final theme = AppTheme.lightTheme;
      final amber = theme.warningColor;
      final legible = theme.legible(amber);

      expect(legible.computeLuminance(), lessThan(amber.computeLuminance()));
    });
  });
}
