import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/books_view_preferences.dart';
import 'package:gatuno/features/books/presentation/components/molecules/books_columns_picker.dart';
import 'package:gatuno/features/books/presentation/components/organisms/books_view_options_sheet.dart';
import 'package:gatuno/features/books/presentation/view_models/books_view_model.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  late StreamController<BooksState> states;

  setUp(() {
    states = StreamController<BooksState>.broadcast();
  });

  tearDown(() => states.close());

  Future<void> pump(
    WidgetTester tester, {
    BooksViewPreferences prefs = const BooksViewPreferences(),
    ValueChanged<int>? onColumnsChanged,
    ValueChanged<BooksNavigationMode>? onNavigationChanged,
  }) {
    return tester.pumpApp(
      Scaffold(
        body: BooksViewOptionsSheet(
          stateStream: states.stream,
          initialState: BooksState.initial().copyWith(preferences: prefs),
          onColumnsChanged: onColumnsChanged ?? (_) {},
          onNavigationChanged: onNavigationChanged ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('shows the title and both pickers', (tester) async {
    await pump(tester);

    expect(find.text('View options'), findsOneWidget);
    expect(find.text('Columns'), findsOneWidget);
    expect(find.text('Navigation'), findsOneWidget);
    expect(find.text('Pages'), findsOneWidget);
    expect(find.text('Infinite scroll'), findsOneWidget);
  });

  testWidgets('tapping a column count reports it', (tester) async {
    int? columns;
    await pump(tester, onColumnsChanged: (v) => columns = v);

    await tester.tap(find.text('3'));

    expect(columns, 3);
  });

  testWidgets('tapping a navigation mode reports it', (tester) async {
    BooksNavigationMode? mode;
    await pump(tester, onNavigationChanged: (v) => mode = v);

    await tester.tap(find.text('Pages'));

    expect(mode, BooksNavigationMode.pages);
  });

  testWidgets('columns picker is disabled in list layout', (tester) async {
    await pump(
      tester,
      prefs: const BooksViewPreferences(layout: BooksLayoutMode.list),
    );

    final picker = tester.widget<BooksColumnsPicker>(
      find.byType(BooksColumnsPicker),
    );
    expect(picker.onChanged, isNull);
  });

  testWidgets('reflects a newer state from the stream', (tester) async {
    await pump(tester);

    states.add(
      BooksState.initial().copyWith(
        preferences: const BooksViewPreferences(columns: 4),
      ),
    );
    await tester.pump();

    final picker = tester.widget<BooksColumnsPicker>(
      find.byType(BooksColumnsPicker),
    );
    expect(picker.value, 4);
  });
}
