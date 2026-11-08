import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'theme.dart';

/// Fixed colors for content laid over arbitrary imagery (covers, banners).
///
/// Art has no theme, so the scrim is black and the content white in every
/// theme; theme tokens have no guaranteed contrast over images.
abstract final class OnImageColors {
  /// Black scrim base; apply alpha at the use site.
  static const Color scrim = Color(0xFF000000);

  /// Text and icons over a scrim.
  static const Color content = Color(0xFFFFFFFF);

  /// Secondary text over a scrim.
  static const Color contentMuted = Color(0xB3FFFFFF);
}

/// Status colors of the active theme, falling back to the light palette for
/// themes built without [GatunoColors] (plain `ThemeData` in tests). Error
/// and neutral colors need no alias: use `colorScheme.error`.
extension SemanticThemeColors on ThemeData {
  AppPalette get _palette => extension<GatunoColors>()?.palette ?? lightPalette;

  /// Positive state (ready, approved, completed).
  Color get successColor => _palette.success;

  /// Pending state.
  Color get warningColor => _palette.warning;

  /// In-progress state.
  Color get infoColor => _palette.cyan;

  /// De-emphasised icons and captions (`color/text-secondary`).
  Color get mutedColor => _palette.textSecondary;

  /// [status] mixed toward the text color so it stays legible as text or an
  /// icon: raw status fills (amber, dark green) fail contrast on surfaces.
  Color legible(Color status) =>
      Color.lerp(status, colorScheme.onSurface, 0.5)!;
}
