import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/books_view_preferences.dart';
import 'package:gatuno/features/books/presentation/components/molecules/books_view_mode_selector.dart';
import 'package:gatuno/shared/components/atoms/app_icon_segment.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  testWidgets('offers grid, list and cover with the current one selected', (
    tester,
  ) async {
    await tester.pumpApp(
      Scaffold(
        body: BooksViewModeSelector(
          value: BooksLayoutMode.list,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byTooltip('Grid'), findsOneWidget);
    expect(find.byTooltip('List'), findsOneWidget);
    expect(find.byTooltip('Covers'), findsOneWidget);
    final selected = tester
        .widgetList<AppIconSegment>(find.byType(AppIconSegment))
        .where((s) => s.selected)
        .map((s) => s.label);
    expect(selected, ['List']);
  });

  testWidgets('reports the tapped layout', (tester) async {
    BooksLayoutMode? changed;
    await tester.pumpApp(
      Scaffold(
        body: BooksViewModeSelector(
          value: BooksLayoutMode.grid,
          onChanged: (v) => changed = v,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Covers'));

    expect(changed, BooksLayoutMode.cover);
  });
}
