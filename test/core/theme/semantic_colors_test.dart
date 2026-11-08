import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/semantic_colors.dart';
import 'package:gatuno/core/theme/theme.dart';

void main() {
  group('SemanticThemeColors', () {
    test('reads status colors from the Gatuno palette', () {
      final theme = AppTheme.darkTheme;
      final palette = theme.extension<GatunoColors>()!.palette;

      expect(theme.successColor, palette.success);
      expect(theme.warningColor, palette.warning);
      expect(theme.dangerColor, theme.colorScheme.error);
      expect(theme.mutedColor, theme.colorScheme.onSurfaceVariant);
    });

    test('falls back to the color scheme without GatunoColors', () {
      final theme = ThemeData();

      expect(theme.successColor, theme.colorScheme.tertiary);
      expect(theme.warningColor, theme.colorScheme.secondary);
    });
  });
}
