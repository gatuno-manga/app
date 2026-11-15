import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/theme.dart';

void main() {
  // Figma `Seletor segmentado` (#162).
  for (final (name, theme) in [
    ('light', AppTheme.lightTheme),
    ('dark', AppTheme.darkTheme),
    ('dracula', AppTheme.draculaTheme),
  ]) {
    test('$name: 48 dp, radius 8, primary-40 selected fill', () {
      final palette = theme.extension<GatunoColors>()!.palette;
      final style = theme.segmentedButtonTheme.style!;

      expect(style.minimumSize!.resolve({})!.height, 48);
      expect(
        style.shape!.resolve({}),
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
      expect(
        style.backgroundColor!.resolve({WidgetState.selected}),
        palette.primary40,
      );
      expect(style.backgroundColor!.resolve({}), isNull);
      expect(
        style.foregroundColor!.resolve({WidgetState.selected}),
        palette.text,
      );
      expect(
        style.foregroundColor!.resolve({WidgetState.disabled}),
        palette.text.withValues(alpha: 0.38),
      );
    });
  }

  test('the outline is color/border', () {
    final theme = AppTheme.darkTheme;
    expect(
      theme.colorScheme.outline,
      theme.extension<GatunoColors>()!.palette.border,
    );
  });
}
