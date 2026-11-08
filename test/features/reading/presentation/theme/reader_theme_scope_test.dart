import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/reader_palette.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/presentation/theme/reader_theme_scope.dart';

void main() {
  Future<ThemeData> themeUnder(
    WidgetTester tester,
    ReaderTheme theme,
    ThemeData app,
  ) async {
    late ThemeData seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: app,
        home: ReaderThemeScope(
          theme: theme,
          child: Builder(
            builder: (context) {
              seen = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    return seen;
  }

  testWidgets('fixed theme overrides the ambient theme surfaces', (
    tester,
  ) async {
    final seen = await themeUnder(
      tester,
      ReaderTheme.sepia,
      AppTheme.darkTheme,
    );
    expect(seen.colorScheme.surface, ReaderPalette.sepia.background);
    expect(seen.extension<ReaderPalette>(), ReaderPalette.sepia);
  });

  testWidgets('standard theme follows the ambient GatunoColors palette', (
    tester,
  ) async {
    final seen = await themeUnder(
      tester,
      ReaderTheme.standard,
      AppTheme.draculaTheme,
    );
    expect(seen.colorScheme.surface, draculaPalette.appBackground);
    expect(
      seen.extension<ReaderPalette>(),
      ReaderPalette.fromAppPalette(draculaPalette),
    );
  });
}
