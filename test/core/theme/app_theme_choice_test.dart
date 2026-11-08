import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_theme_choice.dart';
import 'package:gatuno/core/theme/theme.dart';

void main() {
  test('fromName falls back to system for null and unknown', () {
    expect(AppThemeChoice.fromName(null), AppThemeChoice.system);
    expect(AppThemeChoice.fromName('nope'), AppThemeChoice.system);
    expect(AppThemeChoice.fromName('trueDark'), AppThemeChoice.trueDark);
  });

  test('system follows the OS with light and dark themes', () {
    expect(AppThemeChoice.system.themeMode, ThemeMode.system);
    expect(AppThemeChoice.system.darkTheme, AppTheme.darkTheme);
    expect(AppThemeChoice.system.palette, isNull);
  });

  test('light forces light mode', () {
    expect(AppThemeChoice.light.themeMode, ThemeMode.light);
  });

  test('dark variants force dark mode with their own theme', () {
    expect(AppThemeChoice.dark.themeMode, ThemeMode.dark);
    expect(AppThemeChoice.dark.darkTheme, AppTheme.darkTheme);
    expect(AppThemeChoice.trueDark.darkTheme, AppTheme.trueDarkTheme);
    expect(AppThemeChoice.dracula.darkTheme, AppTheme.draculaTheme);
    expect(AppThemeChoice.slate.darkTheme, AppTheme.slateTheme);
    for (final c in AppThemeChoice.values.where((c) => c.index > 1)) {
      expect(c.themeMode, ThemeMode.dark);
    }
  });
}
