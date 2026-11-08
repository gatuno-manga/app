import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_typography.dart';

class AppColors {
  static const Color black = Color(0xFF000212);
  static const Color darkPurple = Color(0xFF20142A);
  static const Color darkGray = Color(0xFF191A1C);
  static const Color orange = Color(0xFFF18522);
  static const Color beige = Color(0xFFE9E1D1);
  static const Color white = Color(0xFFFDFDFD);
  static const Color lilac = Color(0xFFA972FF);
  static const Color darkLilac = Color(0xFF331E65);
  static const Color darkRed = Color(0xFFF12237);
  static const Color darkGreen = Color(0xFF157219);
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color(0xFF00FF00);

  // Gray Scale
  static const Color gray100 = Color(0xFFF8F9FA);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFCCCCCC);
  static const Color gray600 = Color(0xFF888888);
  static const Color gray700 = Color(0xFF666666);
  static const Color gray800 = Color(0xFF555555);
  static const Color gray900 = Color(0xFF333333);

  // Semantic Colors
  static const Color yellow = Color(0xFFFFC107);
  static const Color lightYellow = Color(0xFFFFF3CD);
  static const Color darkYellow = Color(0xFF856404);
  static const Color cyan = Color(0xFF17A2B8);
  static const Color success = Color(0xFF28A745);
  static const Color successHover = Color(0xFF218838);
  static const Color danger = Color(0xFFDC3545);
  static const Color lightRed = Color(0xFFFF4D4F);
  static const Color softRed = Color(0xFFFF6B6B);

  // Badge Colors
  static const Color badgeBlue = Color(0xFF2B7FFF);
  static const Color badgeBlueLight = Color(0xFFBEDBFF);
  static const Color badgeGreen = Color(0xFF2ECC71);
  static const Color badgeGreenLight = Color(0xFFA0EEBB);
  static const Color badgeOrange = Color(0xFFF18522);
  static const Color badgeOrangeLight = Color(0xFFFFCC99);
  static const Color badgeRed = Color(0xFFFF4343);
  static const Color badgeRedLight = Color(0xFFFFCCCC);
  static const Color badgePurple = Color(0xFF9B59B6);
  static const Color badgePurpleLight = Color(0xFFD2B4DE);
  static const Color badgeYellow = Color(0xFFF1C40F);
  static const Color badgeYellowLight = Color(0xFFF9E79F);
  static const Color badgeTurquoise = Color(0xFF1ABC9C);
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
    required this.scrapingStatusReady,
    required this.scrapingStatusProcessing,
    required this.scrapingStatusError,
    required this.contextMenuBackground,
    required this.overlayBackground,
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

  final Color? scrapingStatusReady;
  final Color? scrapingStatusProcessing;
  final Color? scrapingStatusError;
  final Color? contextMenuBackground;
  final Color? overlayBackground;
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

  @override
  GatunoColors copyWith({
    Color? scrapingStatusReady,
    Color? scrapingStatusProcessing,
    Color? scrapingStatusError,
    Color? contextMenuBackground,
    Color? overlayBackground,
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
      scrapingStatusReady: scrapingStatusReady ?? this.scrapingStatusReady,
      scrapingStatusProcessing:
          scrapingStatusProcessing ?? this.scrapingStatusProcessing,
      scrapingStatusError: scrapingStatusError ?? this.scrapingStatusError,
      contextMenuBackground:
          contextMenuBackground ?? this.contextMenuBackground,
      overlayBackground: overlayBackground ?? this.overlayBackground,
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
      scrapingStatusReady: Color.lerp(
        scrapingStatusReady,
        other.scrapingStatusReady,
        t,
      ),
      scrapingStatusProcessing: Color.lerp(
        scrapingStatusProcessing,
        other.scrapingStatusProcessing,
        t,
      ),
      scrapingStatusError: Color.lerp(
        scrapingStatusError,
        other.scrapingStatusError,
        t,
      ),
      contextMenuBackground: Color.lerp(
        contextMenuBackground,
        other.contextMenuBackground,
        t,
      ),
      overlayBackground: Color.lerp(
        overlayBackground,
        other.overlayBackground,
        t,
      ),
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
  static ThemeData get lightTheme =>
      _build(lightPalette, Brightness.light, _lightBadges);

  static ThemeData get darkTheme =>
      _build(darkPalette, Brightness.dark, _darkBadges);

  static ThemeData get trueDarkTheme =>
      _build(trueDarkPalette, Brightness.dark, _darkBadges);

  static ThemeData get draculaTheme =>
      _build(draculaPalette, Brightness.dark, _darkBadges);

  static ThemeData get slateTheme =>
      _build(slatePalette, Brightness.dark, _darkBadges);

  static ThemeData _build(
    AppPalette palette,
    Brightness brightness,
    _BadgeSet badges,
  ) {
    final isLight = brightness == Brightness.light;
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
        contentTextStyle: TextStyle(color: palette.onPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      extensions: [
        GatunoColors(
          scrapingStatusReady: palette.success,
          scrapingStatusProcessing: palette.warning,
          scrapingStatusError: palette.danger,
          contextMenuBackground: palette.contextMenuBackground,
          overlayBackground: palette.overlay,
          shadowColor: Color(isLight ? 0x26000000 : 0x33000000),
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

/// Badge colors have no Figma variable (gap `badge-colors-not-in-figma`), so
/// they stay per brightness rather than per theme.
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
