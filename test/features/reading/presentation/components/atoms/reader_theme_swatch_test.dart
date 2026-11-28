import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/reader_palette.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/reading/presentation/components/atoms/reader_theme_swatch.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ReaderThemeSwatch', () {
    testWidgets('shows the label, paints the palette and reports taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        Scaffold(
          body: ReaderThemeSwatch(
            palette: ReaderPalette.sepia,
            label: 'Sepia',
            isSelected: false,
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.text('Sepia'), findsOneWidget);
      expect(find.text('Aa'), findsOneWidget);
      final sample = tester.widget<Text>(find.text('Aa'));
      expect(sample.style?.color, ReaderPalette.sepia.text);
      expect(
        DefaultTextStyle.of(
          tester.element(find.text('Sepia')),
        ).style.fontWeight,
        isNot(FontWeight.w600),
      );
      final box = tester.widget<AnimatedContainer>(
        find.byKey(const ValueKey('reader-theme-swatch-sample')),
      );
      expect(
        (box.decoration as BoxDecoration).color,
        ReaderPalette.sepia.background,
      );

      await tester.tap(find.text('Sepia'));
      expect(taps, 1);
    });

    testWidgets('selected swatch is announced as selected', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        Scaffold(
          body: ReaderThemeSwatch(
            palette: ReaderPalette.cream,
            label: 'Cream',
            isSelected: true,
            onTap: () {},
          ),
        ),
      );

      expect(
        DefaultTextStyle.of(
          tester.element(find.text('Cream')),
        ).style.fontWeight,
        FontWeight.w600,
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Cream')),
        isSemantics(
          label: 'Cream',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          isInMutuallyExclusiveGroup: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('only the selected swatch fills its dot, same size', (
      tester,
    ) async {
      Future<(Color?, Size)> dot(bool selected) async {
        await tester.pumpApp(
          Scaffold(
            body: ReaderThemeSwatch(
              palette: ReaderPalette.cream,
              label: 'Cream',
              isSelected: selected,
              onTap: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        final finder = find.byKey(const ValueKey('reader-theme-swatch-dot'));
        final box = tester.widget<AnimatedContainer>(finder);
        return (
          (box.decoration as BoxDecoration).color,
          tester.getSize(finder),
        );
      }

      final off = await dot(false);
      final on = await dot(true);
      expect(off.$1, Colors.transparent);
      expect(on.$1, isNot(Colors.transparent));
      expect(on.$2, off.$2);
    });

    test('label colour reaches 4.5:1 on the sheet in every app theme', () {
      final themes = {
        'light': (AppTheme.lightTheme, lightPalette),
        'dark': (AppTheme.darkTheme, darkPalette),
        'true-dark': (AppTheme.trueDarkTheme, trueDarkPalette),
        'dracula': (AppTheme.draculaTheme, draculaPalette),
        'slate': (AppTheme.slateTheme, slatePalette),
      };
      for (final entry in themes.entries) {
        final (theme, palette) = entry.value;
        final text = theme.colorScheme.onSurface;
        for (final surface in [
          palette.appBackground,
          palette.secondary,
          theme.colorScheme.surfaceContainerLow,
        ]) {
          expect(
            _contrast(text, surface),
            greaterThanOrEqualTo(4.5),
            reason: '${entry.key} on $surface',
          );
          // The selected dot is non-text: 3:1.
          expect(
            _contrast(theme.colorScheme.primary, surface),
            greaterThanOrEqualTo(3),
            reason: '${entry.key} dot on $surface',
          );
        }
      }
    });
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
