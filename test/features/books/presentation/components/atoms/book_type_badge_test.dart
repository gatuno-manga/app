import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/book_type.dart';
import 'package:gatuno/features/books/presentation/components/atoms/book_type_badge.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  const labels = {
    TypeBook.manga: 'Manga',
    TypeBook.manhwa: 'Manhwa',
    TypeBook.manhua: 'Manhua',
    TypeBook.book: 'Book',
    TypeBook.other: 'Other',
  };

  for (final entry in labels.entries) {
    testWidgets('shows "${entry.value}" for ${entry.key}', (tester) async {
      await tester.pumpApp(BookTypeBadge(type: entry.key));
      expect(find.text(entry.value), findsOneWidget);
    });
  }

  testWidgets('shows "Unknown" when the type is null', (tester) async {
    await tester.pumpApp(const BookTypeBadge(type: null));
    expect(find.text('Unknown'), findsOneWidget);
  });

  testWidgets('fits a 70px cover at 2x text scale in Portuguese', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    tester.platformDispatcher.localesTestValue = const [Locale('pt')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    await tester.pumpApp(
      const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 70, child: BookTypeBadge(type: null)),
      ),
    );

    expect(find.text('Desconhecido'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(BookTypeBadge)).width,
      lessThanOrEqualTo(70),
    );
  });

  testWidgets('PositionedBookTypeBadge pins to the start corner in RTL', (
    tester,
  ) async {
    const stackKey = Key('stack');
    await tester.pumpApp(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(
          width: 200,
          height: 100,
          child: Stack(
            key: stackKey,
            children: [PositionedBookTypeBadge(type: TypeBook.manga, inset: 8)],
          ),
        ),
      ),
    );

    final right = tester.getTopRight(find.byType(BookTypeBadge)).dx;
    final boxRight = tester.getTopRight(find.byKey(stackKey)).dx;
    expect(boxRight - right, 8);
  });

  testWidgets('keeps the scrim at 0.7 alpha or above', (tester) async {
    await tester.pumpApp(const BookTypeBadge(type: TypeBook.manga));

    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(BookTypeBadge),
        matching: find.byType(DecoratedBox),
      ),
    );
    final color = (box.decoration as BoxDecoration).color!;
    expect(color.a, greaterThanOrEqualTo(0.7));
  });
}
