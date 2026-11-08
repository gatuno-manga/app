import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/reader_palette.dart';
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
  });
}
