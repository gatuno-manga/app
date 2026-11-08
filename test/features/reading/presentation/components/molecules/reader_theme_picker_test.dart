import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/presentation/components/atoms/reader_theme_swatch.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reader_theme_picker.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('ReaderThemePicker lists the four themes and reports a pick', (
    tester,
  ) async {
    ReaderTheme? picked;
    await tester.pumpApp(
      Scaffold(
        body: ReaderThemePicker(
          selected: ReaderTheme.standard,
          onSelected: (theme) => picked = theme,
        ),
      ),
      theme: AppTheme.darkTheme,
    );

    expect(find.byType(ReaderThemeSwatch), findsNWidgets(4));
    for (final label in ['Default', 'Sepia', 'Cream', 'High contrast']) {
      expect(find.text(label), findsOneWidget);
    }
    final selected = tester
        .widgetList<ReaderThemeSwatch>(find.byType(ReaderThemeSwatch))
        .where((s) => s.isSelected)
        .map((s) => s.label);
    expect(selected, ['Default']);

    await tester.tap(find.text('Cream'));
    expect(picked, ReaderTheme.cream);
  });

  testWidgets('ReaderThemePicker wraps to two rows when labels need it', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // The test font is 1 em per glyph, far wider than Plus Jakarta Sans, so
    // the widths below stand in for "fits" and "does not fit" rather than
    // for a real phone.
    Future<Set<double>> rowTops(double width, TextScaler scaler) async {
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpApp(
        MediaQuery(
          data: MediaQueryData(textScaler: scaler),
          child: Scaffold(
            body: ReaderThemePicker(
              selected: ReaderTheme.standard,
              onSelected: (_) {},
            ),
          ),
        ),
        theme: AppTheme.darkTheme,
        locale: const Locale('pt'),
      );
      return {
        for (final element in find.byType(ReaderThemeSwatch).evaluate())
          tester.getTopLeft(find.byWidget(element.widget)).dy,
      };
    }

    expect(await rowTops(1000, TextScaler.noScaling), hasLength(1));
    expect(await rowTops(1000, const TextScaler.linear(2.0)), hasLength(2));
  });

  testWidgets('ReaderThemePicker labels the group for screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      Scaffold(
        body: ReaderThemePicker(
          selected: ReaderTheme.standard,
          onSelected: (_) {},
        ),
      ),
      theme: AppTheme.darkTheme,
    );

    expect(find.bySemanticsLabel('Reading theme'), findsOneWidget);
    handle.dispose();
  });
}
