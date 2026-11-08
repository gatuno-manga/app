import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/reader_preferences.dart';
import 'reader_theme_palette.dart';

/// Applies [theme]'s [ReaderPalette] to the ambient [Theme] of [child], so
/// reader chrome and sheets built from the theme follow the reader theme.
/// Theme changes cross-fade unless the platform disables animations.
class ReaderThemeScope extends StatelessWidget {
  final ReaderTheme theme;
  final Widget child;

  const ReaderThemeScope({super.key, required this.theme, required this.child});

  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final app = base.extension<GatunoColors>()!.palette;
    return AnimatedTheme(
      data: theme.palette(app).themeData(base),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : _duration,
      curve: Curves.easeOut,
      child: child,
    );
  }
}
