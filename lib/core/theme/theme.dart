import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_typography.dart';

/// Badge text colors for dark themes. Badges have no Figma variable (gap
/// `badge-colors-not-in-figma`); every other color comes from [AppPalette].
abstract final class AppColors {
  static const Color badgeBlueLight = Color(0xFFBEDBFF);
  static const Color badgeGreenLight = Color(0xFFA0EEBB);
  static const Color badgeOrangeLight = Color(0xFFFFCC99);
  static const Color badgeRedLight = Color(0xFFFFCCCC);
  static const Color badgePurpleLight = Color(0xFFD2B4DE);
  static const Color badgeYellowLight = Color(0xFFF9E79F);
  static const Color badgeTurquoiseLight = Color(0xFFA3E4D7);
}

class BadgeColors {
  const BadgeColors({
    required this.bg,
    required this.border,
    required this.text,
  });

  final Color bg;
  final Color border;
  final Color text;

  static BadgeColors lerp(BadgeColors a, BadgeColors b, double t) {
    return BadgeColors(
      bg: Color.lerp(a.bg, b.bg, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      text: Color.lerp(a.text, b.text, t)!,
    );
  }
}

class GatunoColors extends ThemeExtension<GatunoColors> {
  const GatunoColors({
    required this.shadowColor,
    required this.degrader,
    required this.badgeDefault,
    required this.badgeSearch,
    required this.badgeType,
    required this.badgeExcluded,
    required this.badgeSensitive,
    required this.badgePublication,
    required this.badgeAuthor,
    required this.palette,
  });

  final Color? shadowColor;
  final LinearGradient? degrader;

  // Badge System
  final BadgeColors badgeDefault;
  final BadgeColors badgeSearch;
  final BadgeColors badgeType;
  final BadgeColors badgeExcluded;
  final BadgeColors badgeSensitive;
  final BadgeColors badgePublication;
  final BadgeColors badgeAuthor;

  /// Figma color tokens of the active theme, including the alpha ramps.
  final AppPalette palette;

  // Aliases of Figma tokens, kept so call sites need not know the palette.
  Color get scrapingStatusReady => palette.success;
  Color get scrapingStatusProcessing => palette.warning;
  Color get scrapingStatusError => palette.danger;
  Color get contextMenuBackground => palette.contextMenuBackground;
  Color get overlayBackground => palette.overlay;

  @override
  GatunoColors copyWith({
    Color? shadowColor,
    LinearGradient? degrader,
    BadgeColors? badgeDefault,
    BadgeColors? badgeSearch,
    BadgeColors? badgeType,
    BadgeColors? badgeExcluded,
    BadgeColors? badgeSensitive,
    BadgeColors? badgePublication,
    BadgeColors? badgeAuthor,
    AppPalette? palette,
  }) {
    return GatunoColors(
      shadowColor: shadowColor ?? this.shadowColor,
      degrader: degrader ?? this.degrader,
      badgeDefault: badgeDefault ?? this.badgeDefault,
      badgeSearch: badgeSearch ?? this.badgeSearch,
      badgeType: badgeType ?? this.badgeType,
      badgeExcluded: badgeExcluded ?? this.badgeExcluded,
      badgeSensitive: badgeSensitive ?? this.badgeSensitive,
      badgePublication: badgePublication ?? this.badgePublication,
      badgeAuthor: badgeAuthor ?? this.badgeAuthor,
      palette: palette ?? this.palette,
    );
  }

  @override
  GatunoColors lerp(ThemeExtension<GatunoColors>? other, double t) {
    if (other is! GatunoColors) {
      return this;
    }
    return GatunoColors(
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      degrader: LinearGradient.lerp(degrader, other.degrader, t),
      badgeDefault: BadgeColors.lerp(badgeDefault, other.badgeDefault, t),
      badgeSearch: BadgeColors.lerp(badgeSearch, other.badgeSearch, t),
      badgeType: BadgeColors.lerp(badgeType, other.badgeType, t),
      badgeExcluded: BadgeColors.lerp(badgeExcluded, other.badgeExcluded, t),
      badgeSensitive: BadgeColors.lerp(badgeSensitive, other.badgeSensitive, t),
      badgePublication: BadgeColors.lerp(
        badgePublication,
        other.badgePublication,
        t,
      ),
      badgeAuthor: BadgeColors.lerp(badgeAuthor, other.badgeAuthor, t),
      palette: AppPalette.lerp(palette, other.palette, t),
    );
  }
}

class AppTheme {
  static final ThemeData lightTheme = _build(lightPalette, _lightVariant);
  static final ThemeData darkTheme = _build(darkPalette, _darkVariant);
  static final ThemeData trueDarkTheme = _build(trueDarkPalette, _darkVariant);
  static final ThemeData draculaTheme = _build(draculaPalette, _darkVariant);
  static final ThemeData slateTheme = _build(slatePalette, _darkVariant);

  static ThemeData _build(AppPalette palette, _Variant variant) {
    final brightness = variant.brightness;
    final isLight = brightness == Brightness.light;
    final badges = variant.badges;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.inknut,
      textTheme: AppTypography.textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: brightness,
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        secondary: palette.secondary,
        onSecondary: palette.text,
        tertiary: palette.lilac,
        onTertiary: palette.onPrimary,
        error: palette.danger,
        onError: palette.onPrimary,
        surface: palette.appBackground,
        onSurface: palette.text,
        surfaceContainerHighest: palette.secondary,
        outline: palette.border,
      ),
      scaffoldBackgroundColor: palette.appBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.appBackground,
        foregroundColor: palette.text,
        elevation: 0,
        centerTitle: true,
      ),
      dividerTheme: DividerThemeData(color: palette.divider, thickness: 1),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(palette.primary),
        trackColor: WidgetStateProperty.all(palette.secondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.lilac,
        contentTextStyle: AppTypography.bodySmall.copyWith(
          color: AppPalette.onLilac,
        ),
        actionTextColor: AppPalette.onLilac,
        closeIconColor: AppPalette.onLilac,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      extensions: [
        GatunoColors(
          shadowColor: variant.shadowColor,
          degrader: LinearGradient(
            begin: const Alignment(1.0, -0.07),
            end: const Alignment(-1.0, 0.07),
            colors: isLight
                ? [
                    palette.appBackground,
                    palette.appBackground,
                    palette.secondary,
                  ]
                : [palette.appBackground, palette.secondary],
            stops: isLight ? const [0.0, 0.5, 1.0] : const [0.55, 1.94],
          ),
          badgeDefault: badges.badgeDefault,
          badgeSearch: badges.badgeSearch,
          badgeType: badges.badgeType,
          badgeExcluded: badges.badgeExcluded,
          badgeSensitive: badges.badgeSensitive,
          badgePublication: badges.badgePublication,
          badgeAuthor: badges.badgeAuthor,
          palette: palette,
        ),
      ],
    );
  }
}

class _Variant {
  const _Variant({
    required this.brightness,
    required this.badges,
    required this.shadowColor,
  });

  final Brightness brightness;
  final _BadgeSet badges;
  final Color shadowColor;
}

/// Badge colors have no Figma variable (gap `badge-colors-not-in-figma`), so
/// they stay per brightness rather than per theme.
/// What differs between light and dark builds beyond the palette.
class _BadgeSet {
  const _BadgeSet({
    required this.badgeDefault,
    required this.badgeSearch,
    required this.badgeType,
    required this.badgeExcluded,
    required this.badgeSensitive,
    required this.badgePublication,
    required this.badgeAuthor,
  });

  final BadgeColors badgeDefault;
  final BadgeColors badgeSearch;
  final BadgeColors badgeType;
  final BadgeColors badgeExcluded;
  final BadgeColors badgeSensitive;
  final BadgeColors badgePublication;
  final BadgeColors badgeAuthor;
}

const _BadgeSet _lightBadges = _BadgeSet(
  badgeDefault: BadgeColors(
    bg: Color(0x262B7FFF),
    border: Color(0x662B7FFF),
    text: Color(0xFF1A5ACF),
  ),
  badgeSearch: BadgeColors(
    bg: Color(0x262ECC71),
    border: Color(0x592ECC71),
    text: Color(0xFF1E8449),
  ),
  badgeType: BadgeColors(
    bg: Color(0x26F18522),
    border: Color(0x59F18522),
    text: Color(0xFFD68910),
  ),
  badgeExcluded: BadgeColors(
    bg: Color(0x26FF4343),
    border: Color(0x59FF4343),
    text: Color(0xFFC0392B),
  ),
  badgeSensitive: BadgeColors(
    bg: Color(0x269B59B6),
    border: Color(0x599B59B6),
    text: Color(0xFF7D3C98),
  ),
  badgePublication: BadgeColors(
    bg: Color(0x26F1C40F),
    border: Color(0x59F1C40F),
    text: Color(0xFF9A7D0A),
  ),
  badgeAuthor: BadgeColors(
    bg: Color(0x261ABC9C),
    border: Color(0x591ABC9C),
    text: Color(0xFF138D75),
  ),
);

const _BadgeSet _darkBadges = _BadgeSet(
  badgeDefault: BadgeColors(
    bg: Color(0x4D2B7FFF),
    border: Color(0x802B7FFF),
    text: AppColors.badgeBlueLight,
  ),
  badgeSearch: BadgeColors(
    bg: Color(0x332ECC71),
    border: Color(0x662ECC71),
    text: AppColors.badgeGreenLight,
  ),
  badgeType: BadgeColors(
    bg: Color(0x33F18522),
    border: Color(0x66F18522),
    text: AppColors.badgeOrangeLight,
  ),
  badgeExcluded: BadgeColors(
    bg: Color(0x33FF4343),
    border: Color(0x66FF4343),
    text: AppColors.badgeRedLight,
  ),
  badgeSensitive: BadgeColors(
    bg: Color(0x339B59B6),
    border: Color(0x669B59B6),
    text: AppColors.badgePurpleLight,
  ),
  badgePublication: BadgeColors(
    bg: Color(0x33F1C40F),
    border: Color(0x66F1C40F),
    text: AppColors.badgeYellowLight,
  ),
  badgeAuthor: BadgeColors(
    bg: Color(0x331ABC9C),
    border: Color(0x661ABC9C),
    text: AppColors.badgeTurquoiseLight,
  ),
);

const _lightVariant = _Variant(
  brightness: Brightness.light,
  badges: _lightBadges,
  shadowColor: Color(0x26000000),
);

const _darkVariant = _Variant(
  brightness: Brightness.dark,
  badges: _darkBadges,
  shadowColor: Color(0x33000000),
);
