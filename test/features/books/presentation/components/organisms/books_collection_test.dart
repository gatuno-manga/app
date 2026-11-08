import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/books_view_preferences.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/presentation/components/molecules/book_card.dart';
import 'package:gatuno/features/books/presentation/components/molecules/book_cover_card.dart';
import 'package:gatuno/features/books/presentation/components/molecules/book_list_item.dart';
import 'package:gatuno/features/books/presentation/components/organisms/books_collection.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  final books = List.generate(
    4,
    (i) => Book(id: BookId('$i'), title: BookTitle('Book $i')),
  );

  Future<void> pump(WidgetTester tester, BooksViewPreferences prefs) {
    return tester.pumpApp(
      Scaffold(
        body: BooksCollection(books: books, preferences: prefs),
      ),
    );
  }

  testWidgets('grid layout renders BookCard in the chosen columns', (
    tester,
  ) async {
    await pump(
      tester,
      const BooksViewPreferences(layout: BooksLayoutMode.grid, columns: 4),
    );

    expect(find.byType(BookCard), findsNWidgets(4));
    expect(find.byType(BookCoverCard), findsNothing);
    final padding = tester.widget<SliverPadding>(find.byType(SliverPadding));
    expect(padding.padding.horizontal, 32);
    final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
    final delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 4);
  });

  testWidgets('cover layout renders BookCoverCard', (tester) async {
    await pump(
      tester,
      const BooksViewPreferences(layout: BooksLayoutMode.cover, columns: 2),
    );

    expect(find.byType(BookCoverCard), findsNWidgets(4));
    expect(find.byType(BookCard), findsNothing);
  });

  testWidgets('list layout renders BookListItem', (tester) async {
    await pump(
      tester,
      const BooksViewPreferences(layout: BooksLayoutMode.list),
    );

    expect(find.byType(BookListItem), findsNWidgets(4));
    expect(find.byType(SliverGrid), findsNothing);
  });

  testWidgets('renders the footer after the items', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: BooksCollection(
          books: books.take(2).toList(),
          preferences: const BooksViewPreferences(columns: 4),
          footer: const Text('footer'),
        ),
      ),
    );

    expect(find.text('footer'), findsOneWidget);
    expect(
      tester.getRect(find.text('footer')).top,
      greaterThan(tester.getRect(find.byType(BookCard).first).bottom),
    );
  });
}
