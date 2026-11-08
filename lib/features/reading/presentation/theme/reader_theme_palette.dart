import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/reader_palette.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/reader_preferences.dart';

extension ReaderThemePalette on ReaderTheme {
  /// Palette of this theme. [ReaderTheme.standard] follows [app], the active
  /// app theme's tokens; the others are fixed.
  ReaderPalette palette(AppPalette app) => switch (this) {
    ReaderTheme.standard => ReaderPalette.fromAppPalette(app),
    ReaderTheme.sepia => ReaderPalette.sepia,
    ReaderTheme.cream => ReaderPalette.cream,
    ReaderTheme.highContrast => ReaderPalette.highContrast,
  };
}

/// The active app palette, or the Light/Dark one when [theme] was not built
/// by [AppTheme] (tests, previews).
AppPalette appPaletteOf(ThemeData theme) =>
    theme.extension<GatunoColors>()?.palette ??
    (theme.brightness == Brightness.dark ? darkPalette : lightPalette);
