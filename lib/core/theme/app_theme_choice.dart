import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'theme.dart';

/// What the user picks in Settings. [system] follows the OS (Light or Dark).
enum AppThemeChoice {
  system,
  light,
  dark,
  trueDark,
  dracula,
  slate;

  /// Parses a persisted [name]; null or unknown values fall back to [system].
  static AppThemeChoice fromName(String? name) {
    for (final choice in values) {
      if (choice.name == name) return choice;
    }
    return AppThemeChoice.system;
  }

  /// Palette previewed by the picker. [system] has none of its own.
  AppPalette? get palette => switch (this) {
    AppThemeChoice.system => null,
    AppThemeChoice.light => lightPalette,
    AppThemeChoice.dark => darkPalette,
    AppThemeChoice.trueDark => trueDarkPalette,
    AppThemeChoice.dracula => draculaPalette,
    AppThemeChoice.slate => slatePalette,
  };

  /// `MaterialApp.darkTheme` (`MaterialApp.theme` is always Light).
  ThemeData get darkTheme => switch (this) {
    AppThemeChoice.trueDark => AppTheme.trueDarkTheme,
    AppThemeChoice.dracula => AppTheme.draculaTheme,
    AppThemeChoice.slate => AppTheme.slateTheme,
    _ => AppTheme.darkTheme,
  };

  /// `MaterialApp.themeMode`.
  ThemeMode get themeMode => switch (this) {
    AppThemeChoice.system => ThemeMode.system,
    AppThemeChoice.light => ThemeMode.light,
    _ => ThemeMode.dark,
  };
}
