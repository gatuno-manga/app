import 'dart:ui' show Color;

// Opacity bytes of the `-N` suffixes in design.json (`_a40` = `-40`, ...).
// Figma stores the ramps as 8-bit alpha, so they are not exactly N percent.
const int _a2 = 0x05; // 5/255
const int _a3 = 0x08; // 8/255
const int _a10 = 0x1a; // 26/255
const int _a15 = 0x26; // 38/255
const int _a40 = 0x66; // 102/255
const int _a45 = 0x73; // 115/255
const int _a60 = 0x99; // 153/255
const int _a75 = 0xbf; // 191/255

/// Color tokens of one Figma theme (`.impeccable/design.json`, collection
/// "Gatuno"). Values are copied from the Figma variables; the alpha ramps
/// (`color/primary-10`, `color/text-40`, ...) derive from their base token.
class AppPalette {
  const AppPalette({
    required this.appBackground,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.border,
    required this.hover,
    required this.divider,
    required this.contextMenuBackground,
    required this.overlay,
    required this.danger,
    required this.warning,
    required this.success,
    required this.lilac,
    required this.cyan,
  });

  /// `color/app-background`
  final Color appBackground;

  /// `color/text`
  final Color text;

  /// `color/text-secondary`
  final Color textSecondary;

  /// `color/text-muted`
  final Color textMuted;

  /// Text on `color/lilac` (a fixed accent): the Dark `color/app-background`,
  /// 6.4:1. `color/on-primary` (#fdfdfd) is only 3.2:1 on lilac.
  static const Color onLilac = Color(0xFF000212);

  /// `color/primary`
  final Color primary;

  /// `color/on-primary`
  final Color onPrimary;

  /// `color/secondary`
  final Color secondary;

  /// `color/border`
  final Color border;

  /// `color/hover`
  final Color hover;

  /// `color/divider`
  final Color divider;

  /// `color/context-menu-bg`
  final Color contextMenuBackground;

  /// `color/overlay`
  final Color overlay;

  /// `color/danger`
  final Color danger;

  /// `color/warning`
  final Color warning;

  /// `color/success`
  final Color success;

  /// `color/lilac`
  final Color lilac;

  /// `color/cyan`
  final Color cyan;

  // Alpha ramps: `color/<base>-<N>` is the base token at the `_aN` opacity.
  /// `color/primary-10`
  Color get primary10 => primary.withAlpha(_a10);

  /// `color/primary-15`
  Color get primary15 => primary.withAlpha(_a15);

  /// `color/primary-40`
  Color get primary40 => primary.withAlpha(_a40);

  /// `color/lilac-15`
  Color get lilac15 => lilac.withAlpha(_a15);

  /// `color/lilac-40`
  Color get lilac40 => lilac.withAlpha(_a40);

  /// `color/success-15`
  Color get success15 => success.withAlpha(_a15);

  /// `color/success-40`
  Color get success40 => success.withAlpha(_a40);

  /// `color/danger-10`
  Color get danger10 => danger.withAlpha(_a10);

  /// `color/danger-15`
  Color get danger15 => danger.withAlpha(_a15);

  /// `color/danger-40`
  Color get danger40 => danger.withAlpha(_a40);

  /// `color/warning-15`
  Color get warning15 => warning.withAlpha(_a15);

  /// `color/warning-40`
  Color get warning40 => warning.withAlpha(_a40);

  /// `color/cyan-15`
  Color get cyan15 => cyan.withAlpha(_a15);

  /// `color/cyan-40`
  Color get cyan40 => cyan.withAlpha(_a40);

  /// `color/secondary-45`
  Color get secondary45 => secondary.withAlpha(_a45);

  /// `color/secondary-60`
  Color get secondary60 => secondary.withAlpha(_a60);

  /// `color/text-10`
  Color get text10 => text.withAlpha(_a10);

  /// `color/text-40`
  Color get text40 => text.withAlpha(_a40);

  /// `color/app-background-2`
  Color get appBackground2 => appBackground.withAlpha(_a2);

  /// `color/app-background-3`
  Color get appBackground3 => appBackground.withAlpha(_a3);

  /// `color/app-background-40`
  Color get appBackground40 => appBackground.withAlpha(_a40);

  /// `color/app-background-75`
  Color get appBackground75 => appBackground.withAlpha(_a75);

  static AppPalette lerp(AppPalette a, AppPalette b, double t) {
    return AppPalette(
      appBackground: Color.lerp(a.appBackground, b.appBackground, t)!,
      text: Color.lerp(a.text, b.text, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      textMuted: Color.lerp(a.textMuted, b.textMuted, t)!,
      primary: Color.lerp(a.primary, b.primary, t)!,
      onPrimary: Color.lerp(a.onPrimary, b.onPrimary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      hover: Color.lerp(a.hover, b.hover, t)!,
      divider: Color.lerp(a.divider, b.divider, t)!,
      contextMenuBackground: Color.lerp(
        a.contextMenuBackground,
        b.contextMenuBackground,
        t,
      )!,
      overlay: Color.lerp(a.overlay, b.overlay, t)!,
      danger: Color.lerp(a.danger, b.danger, t)!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      success: Color.lerp(a.success, b.success, t)!,
      lilac: Color.lerp(a.lilac, b.lilac, t)!,
      cyan: Color.lerp(a.cyan, b.cyan, t)!,
    );
  }
}

/// Figma theme `Light`.
const AppPalette lightPalette = AppPalette(
  appBackground: Color(0xFFEEEEEE),
  text: Color(0xFF2B2D31),
  textSecondary: Color(0xA62B2D31),
  textMuted: Color(0x732B2D31),
  primary: Color(0xFFCC5E00),
  onPrimary: Color(0xFFFDFDFD),
  secondary: Color(0xFFE0E0E0),
  border: Color(0x1F2B2D31),
  hover: Color(0x0F2B2D31),
  divider: Color(0x1A2B2D31),
  contextMenuBackground: Color(0xE5FFFFFF),
  overlay: Color(0x4D000000),
  danger: Color(0xFFFF0000),
  warning: Color(0xFFFFC107),
  success: Color(0xFF28A745),
  lilac: Color(0xFFA972FF),
  cyan: Color(0xFF17A2B8),
);

/// Figma theme `Dark`.
const AppPalette darkPalette = AppPalette(
  appBackground: Color(0xFF000212),
  text: Color(0xFFE9E1D1),
  textSecondary: Color(0x8CE9E1D1),
  textMuted: Color(0x73FDFDFD),
  primary: Color(0xFFF18522),
  onPrimary: Color(0xFFFDFDFD),
  secondary: Color(0xFF181A1F),
  border: Color(0x26E9E1D1),
  hover: Color(0x14E9E1D1),
  divider: Color(0x1AE9E1D1),
  contextMenuBackground: Color(0xCC000212),
  overlay: Color(0xB2000000),
  danger: Color(0xFFF12237),
  warning: Color(0xFFFFC107),
  success: Color(0xFF157219),
  lilac: Color(0xFFA972FF),
  cyan: Color(0xFF17A2B8),
);

/// Figma theme `True-dark`.
const AppPalette trueDarkPalette = AppPalette(
  appBackground: Color(0xFF000000),
  text: Color(0xFFE9E1D1),
  textSecondary: Color(0x73E9E1D1),
  textMuted: Color(0x59FDFDFD),
  primary: Color(0xFFF18522),
  onPrimary: Color(0xFFFDFDFD),
  secondary: Color(0xFF181A1F),
  border: Color(0x1AE9E1D1),
  hover: Color(0x0FE9E1D1),
  divider: Color(0x12E9E1D1),
  contextMenuBackground: Color(0xE5000000),
  overlay: Color(0xD9000000),
  danger: Color(0xFFF12237),
  warning: Color(0xFFFFC107),
  success: Color(0xFF157219),
  lilac: Color(0xFFA972FF),
  cyan: Color(0xFF17A2B8),
);

/// Figma theme `Dracula`.
const AppPalette draculaPalette = AppPalette(
  appBackground: Color(0xFF282A36),
  text: Color(0xFFF8F8F2),
  textSecondary: Color(0xFF6272A4),
  textMuted: Color(0x73F8F8F2),
  primary: Color(0xFFBD93F9),
  onPrimary: Color(0xFFFDFDFD),
  secondary: Color(0xFF44475A),
  border: Color(0x26F8F8F2),
  hover: Color(0x14F8F8F2),
  divider: Color(0x1AF8F8F2),
  contextMenuBackground: Color(0xE5282A36),
  overlay: Color(0xBF000000),
  danger: Color(0xFFFF5555),
  warning: Color(0xFFFFB86C),
  success: Color(0xFF50FA7B),
  lilac: Color(0xFFA972FF),
  cyan: Color(0xFF17A2B8),
);

/// Figma theme `Slate`.
const AppPalette slatePalette = AppPalette(
  appBackground: Color(0xFF15161A),
  text: Color(0xFFF8FAFC),
  textSecondary: Color(0xFF94A3B8),
  textMuted: Color(0x73F8FAFC),
  primary: Color(0xFFF18522),
  onPrimary: Color(0xFFFDFDFD),
  secondary: Color(0xFF212329),
  border: Color(0x26F8FAFC),
  hover: Color(0x14F8FAFC),
  divider: Color(0x1AF8FAFC),
  contextMenuBackground: Color(0xE515161A),
  overlay: Color(0xB2000000),
  danger: Color(0xFFEF4444),
  warning: Color(0xFFF59E0B),
  success: Color(0xFF10B981),
  lilac: Color(0xFFA972FF),
  cyan: Color(0xFF17A2B8),
);
