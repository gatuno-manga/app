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
}
