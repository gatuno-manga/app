import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/presentation/components/molecules/book_card.dart';
import 'package:gatuno/features/home/presentation/components/organisms/horizontal_book_list.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  final books = [
    Book(
      id: const BookId('1'),
      title: const BookTitle('A very long book title that wraps'),
    ),
    Book(id: const BookId('2'), title: const BookTitle('B')),
  ];

  testWidgets('sizes the row to the grid card ratio without overflow', (
    tester,
  ) async {
    await tester.pumpApp(Scaffold(body: HorizontalBookList(books: books)));

    expect(tester.takeException(), isNull);
    expect(find.byType(BookCard), findsNWidgets(2));
    final card = tester.getSize(find.byType(BookCard).first);
    expect(card.width / card.height, closeTo(BookCard.aspectRatio, 0.01));
  });
}
