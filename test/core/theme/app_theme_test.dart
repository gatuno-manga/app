import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/app_typography.dart';
import 'package:gatuno/core/theme/theme.dart';

/// Checks `AppTheme` against `.impeccable/design.json` (Figma export), so a
/// token drift in either side fails here.
String hex(Color c) {
  String b(double v) => (v * 255).round().toRadixString(16).padLeft(2, '0');
  final rgb = '${b(c.r)}${b(c.g)}${b(c.b)}';
  final a = b(c.a);
  return a == 'ff' ? '#$rgb' : '#$rgb$a';
}

void main() {
  final design =
      jsonDecode(File('.impeccable/design.json').readAsStringSync())
          as Map<String, dynamic>;
  final colors = design['colors'] as Map<String, dynamic>;
  final typography = design['typography'] as Map<String, dynamic>;

  final themes = <String, ThemeData Function()>{
    'Light': () => AppTheme.lightTheme,
    'Dark': () => AppTheme.darkTheme,
    'True-dark': () => AppTheme.trueDarkTheme,
    'Dracula': () => AppTheme.draculaTheme,
    'Slate': () => AppTheme.slateTheme,
  };

  Map<String, Color> tokens(ThemeData t) {
    final p = t.extension<GatunoColors>()!.palette;
    return {
      'app-background': p.appBackground,
      'text': p.text,
      'text-secondary': p.textSecondary,
      'text-muted': p.textMuted,
      'primary': p.primary,
      'secondary': p.secondary,
      'border': p.border,
      'hover': p.hover,
      'divider': p.divider,
      'context-menu-bg': p.contextMenuBackground,
      'overlay': p.overlay,
      'on-primary': p.onPrimary,
      'danger': p.danger,
      'warning': p.warning,
      'success': p.success,
      'lilac': p.lilac,
      'cyan': p.cyan,
      'primary-10': p.primary10,
      'primary-15': p.primary15,
      'primary-40': p.primary40,
      'lilac-15': p.lilac15,
      'lilac-40': p.lilac40,
      'success-15': p.success15,
      'success-40': p.success40,
      'danger-10': p.danger10,
      'danger-15': p.danger15,
      'danger-40': p.danger40,
      'warning-15': p.warning15,
      'warning-40': p.warning40,
      'cyan-15': p.cyan15,
      'cyan-40': p.cyan40,
      'secondary-45': p.secondary45,
      'secondary-60': p.secondary60,
      'text-10': p.text10,
      'text-40': p.text40,
      'app-background-2': p.appBackground2,
      'app-background-3': p.appBackground3,
      'app-background-40': p.appBackground40,
      'app-background-75': p.appBackground75,
    };
  }

  test('every design.json color token has a code counterpart', () {
    final code = tokens(AppTheme.lightTheme).keys.map((k) => 'color/$k');
    expect(colors.keys.toSet(), code.toSet());
  });

  for (final entry in themes.entries) {
    group('${entry.key} theme', () {
      final theme = entry.value();

      test('palette matches every Figma color token', () {
        final actual = tokens(theme);
        for (final key in colors.keys) {
          final expected =
              ((colors[key] as Map)['values'] as Map)[entry.key] as String;
          expect(
            hex(actual[key.substring('color/'.length)]!),
            expected,
            reason: '$key in ${entry.key}',
          );
        }
      });

      test('ThemeData roles use the Figma tokens', () {
        final p = theme.extension<GatunoColors>()!.palette;
        final s = theme.colorScheme;
        expect(s.primary, p.primary);
        expect(s.onPrimary, p.onPrimary);
        expect(s.surface, p.appBackground);
        expect(s.onSurface, p.text);
        expect(s.error, p.danger);
        expect(s.surfaceContainerHighest, p.secondary);
        expect(s.outline, p.border);
        expect(theme.scaffoldBackgroundColor, p.appBackground);
        expect(theme.dividerTheme.color, p.divider);
        final g = theme.extension<GatunoColors>()!;
        expect(g.contextMenuBackground, p.contextMenuBackground);
        expect(g.overlayBackground, p.overlay);
        expect(g.scrapingStatusReady, p.success);
        expect(g.scrapingStatusError, p.danger);
      });

      test('brightness follows the theme', () {
        expect(
          theme.brightness,
          entry.key == 'Light' ? Brightness.light : Brightness.dark,
        );
      });

      test('TextTheme matches the Figma text styles', () {
        final roles = <String, TextStyle?>{
          'textTheme.displayLarge': theme.textTheme.displayLarge,
          'textTheme.headlineMedium': theme.textTheme.headlineMedium,
          'textTheme.headlineSmall': theme.textTheme.headlineSmall,
          'textTheme.titleLarge': theme.textTheme.titleLarge,
          'textTheme.bodyLarge': theme.textTheme.bodyLarge,
          'textTheme.bodyMedium': theme.textTheme.bodyMedium,
          'textTheme.bodySmall': theme.textTheme.bodySmall,
          'textTheme.labelLarge': theme.textTheme.labelLarge,
          'textTheme.labelMedium': theme.textTheme.labelMedium,
          'textTheme.labelSmall': theme.textTheme.labelSmall,
        };
        var checked = 0;
        for (final tok in typography.values.cast<Map<String, dynamic>>()) {
          final target = (tok['flutter'] as Map)['target'] as String?;
          if (target == null || !target.startsWith('textTheme.')) continue;
          final style = roles[target]!;
          _expectStyle(style, tok, target);
          checked++;
        }
        expect(checked, roles.length);
        expect(theme.textTheme.bodyMedium!.color, theme.colorScheme.onSurface);
      });
    });
  }

  test('AppPalette.lerp returns its endpoints and blends between them', () {
    expect(
      AppPalette.lerp(lightPalette, darkPalette, 0).appBackground,
      lightPalette.appBackground,
    );
    expect(
      AppPalette.lerp(lightPalette, darkPalette, 1).primary,
      darkPalette.primary,
    );
    expect(
      AppPalette.lerp(lightPalette, darkPalette, 0.5).text,
      Color.lerp(lightPalette.text, darkPalette.text, 0.5),
    );
  });

  for (final entry in themes.entries) {
    test('${entry.key} snackbar text is readable on its background', () {
      final sb = entry.value().snackBarTheme;
      final ratio = _contrast(sb.backgroundColor!, sb.contentTextStyle!.color!);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });
  }

  test('styles without a Material role are exposed by AppTypography', () {
    final byName = <String, TextStyle>{
      'Interface/Sobrelinha': AppTypography.overline,
      'Leitura/Serifa': AppTypography.readingSerif,
      'Leitura/Dislexia': AppTypography.readingDyslexia,
    };
    for (final e in byName.entries) {
      _expectStyle(e.value, typography[e.key] as Map<String, dynamic>, e.key);
    }
  });

  test('every Figma font family is declared in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final families = typography.values
        .map((t) => (t as Map)['family'] as String)
        .toSet();
    for (final f in families) {
      expect(pubspec, contains('- family: $f\n'));
    }
    final assets = RegExp(
      r'asset: (assets/fonts/\S+\.ttf)',
    ).allMatches(pubspec).map((m) => m.group(1)!);
    expect(assets, isNotEmpty);
    for (final a in assets) {
      expect(File(a).existsSync(), isTrue, reason: a);
    }
    for (final t in typography.values.cast<Map<String, dynamic>>()) {
      final family = t['family'] as String;
      final weight = t['weight'] as int;
      final block = pubspec
          .split('- family: ')
          .firstWhere((b) => b.startsWith('$family\n'));
      expect(block, contains('weight: $weight'), reason: '$family $weight');
    }
  });
}

void _expectStyle(TextStyle style, Map<String, dynamic> tok, String name) {
  final size = (tok['size'] as num).toDouble();
  expect(style.fontFamily, tok['family'], reason: name);
  expect(style.fontSize, size, reason: name);
  expect(
    style.fontWeight,
    FontWeight.values[(tok['weight'] as int) ~/ 100 - 1], // w100 is index 0,
    reason: name,
  );
  expect(
    style.height,
    closeTo((tok['lineHeightPercent'] as num) / 100, 1e-9),
    reason: name,
  );
  expect(
    style.letterSpacing,
    closeTo(((tok['letterSpacingPercent'] ?? 0) as num) / 100 * size, 1e-9),
    reason: name,
  );
}

double _luminance(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
