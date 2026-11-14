import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/home/presentation/components/molecules/carousel_indicator.dart';
import 'package:gatuno/features/home/presentation/components/organisms/featured_carousel.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  List<Book> booksOf(int count) => [
    for (var i = 0; i < count; i++)
      Book(id: BookId('$i'), title: BookTitle('Book $i')),
  ];

  const interval = Duration(seconds: 8);
  const settle = Duration(seconds: 1);

  int currentPage(WidgetTester tester) => tester
      .widget<CarouselIndicator>(find.byType(CarouselIndicator))
      .currentIndex;

  Future<void> pumpCarousel(
    WidgetTester tester,
    List<Book> books, {
    bool disableAnimations = false,
    bool accessibleNavigation = false,
  }) {
    return tester.pumpApp(
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
            accessibleNavigation: accessibleNavigation,
          ),
          child: Scaffold(body: FeaturedCarousel(books: books)),
        ),
      ),
    );
  }

  testWidgets('advances to the next book after the interval', (tester) async {
    await pumpCarousel(tester, booksOf(3));
    expect(currentPage(tester), 0);

    await tester.pump(interval);
    await tester.pump(settle);

    expect(currentPage(tester), 1);
  });

  testWidgets('stays put when the user asked for less motion', (tester) async {
    await pumpCarousel(tester, booksOf(3), disableAnimations: true);

    await tester.pump(interval * 2);
    await tester.pump(settle);

    expect(currentPage(tester), 0);
  });

  testWidgets('stays put for screen reader users', (tester) async {
    await pumpCarousel(tester, booksOf(3), accessibleNavigation: true);

    await tester.pump(interval * 2);
    await tester.pump(settle);

    expect(currentPage(tester), 0);
  });

  testWidgets('does not move the page during a swipe', (tester) async {
    await pumpCarousel(tester, booksOf(3));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
    );
    await gesture.moveBy(const Offset(-20, 0));
    await tester.pump(interval + settle);
    await gesture.moveBy(const Offset(20, 0));
    await gesture.up();
    await tester.pump(settle);

    expect(currentPage(tester), 0);
  });

  testWidgets('does not move the page while a finger rests on it', (
    tester,
  ) async {
    await pumpCarousel(tester, booksOf(3));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
    );
    await tester.pump(interval * 2);
    // Cancel, not up: lifting would be a tap that opens the book.
    await gesture.cancel();
    await tester.pump(settle);
    expect(currentPage(tester), 0);

    await tester.pump(interval);
    await tester.pump(settle);
    expect(currentPage(tester), 1);
  });

  testWidgets('stops while hidden and waits a full interval on return', (
    tester,
  ) async {
    var visible = true;
    late StateSetter setVisible;
    await tester.pumpApp(
      Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            setVisible = setState;
            return TickerMode(
              enabled: visible,
              child: FeaturedCarousel(books: booksOf(3)),
            );
          },
        ),
      ),
    );

    setVisible(() => visible = false);
    await tester.pump();
    await tester.pump(interval * 2);
    setVisible(() => visible = true);
    await tester.pump();
    await tester.pump(settle);
    expect(currentPage(tester), 0);

    await tester.pump(interval);
    await tester.pump(settle);
    expect(currentPage(tester), 1);
  });

  testWidgets('waits a full interval after a swipe', (tester) async {
    await pumpCarousel(tester, booksOf(3));

    await tester.pump(interval - const Duration(seconds: 2));
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(currentPage(tester), 1);

    // The old interval would have fired here.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(settle);
    expect(currentPage(tester), 1);

    await tester.pump(interval);
    await tester.pump(settle);
    expect(currentPage(tester), 2);
  });

  testWidgets('starts advancing when a refresh brings more books', (
    tester,
  ) async {
    var books = booksOf(1);
    late StateSetter setBooks;
    await tester.pumpApp(
      Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            setBooks = setState;
            return FeaturedCarousel(books: books);
          },
        ),
      ),
    );

    setBooks(() => books = booksOf(3));
    await tester.pump();
    await tester.pump(interval);
    await tester.pump(settle);

    expect(currentPage(tester), 1);
  });

  testWidgets('goes back to the first page when the list shrinks', (
    tester,
  ) async {
    var books = booksOf(3);
    late StateSetter setBooks;
    await tester.pumpApp(
      Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            setBooks = setState;
            return FeaturedCarousel(books: books);
          },
        ),
      ),
    );
    await tester.pump(interval);
    await tester.pump(settle);
    await tester.pump(interval);
    await tester.pump(settle);
    expect(currentPage(tester), 2);

    setBooks(() => books = booksOf(2));
    await tester.pump();
    await tester.pump(settle);

    expect(currentPage(tester), 0);
    expect(tester.takeException(), isNull);
  });
}
