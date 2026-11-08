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
