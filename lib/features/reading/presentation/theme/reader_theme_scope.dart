import 'package:flutter/material.dart';

import '../../domain/entities/reader_preferences.dart';
import 'reader_theme_palette.dart';

/// Applies [theme]'s [ReaderPalette] to the ambient [Theme] of [child], so
/// reader chrome and sheets built from `colorScheme` follow the reader theme.
class ReaderThemeScope extends StatelessWidget {
  final ReaderTheme theme;
  final Widget child;

  const ReaderThemeScope({super.key, required this.theme, required this.child});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final app = appPaletteOf(base);
    return Theme(data: theme.palette(app).themeData(base), child: child);
  }
}
