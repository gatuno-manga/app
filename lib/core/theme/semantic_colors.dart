import 'package:flutter/material.dart';

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

/// Status colors of the active theme, with a [ColorScheme] fallback for
/// themes built without [GatunoColors] (plain `ThemeData` in tests).
extension SemanticThemeColors on ThemeData {
  /// Positive state (ready, approved, completed).
  Color get successColor =>
      extension<GatunoColors>()?.palette.success ?? colorScheme.tertiary;

  /// Pending or in-progress state.
  Color get warningColor =>
      extension<GatunoColors>()?.palette.warning ?? colorScheme.secondary;

  /// Failed or rejected state.
  Color get dangerColor => colorScheme.error;

  /// De-emphasised icons and captions.
  Color get mutedColor => colorScheme.onSurfaceVariant;
}
