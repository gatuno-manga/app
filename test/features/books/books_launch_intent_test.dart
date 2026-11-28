import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/books_launch_intent.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';

void main() {
  group('BooksLaunchIntent.fromUri', () {
    test('reads focus, sort and nonce', () {
      final intent = BooksLaunchIntent.fromUri(
        Uri.parse('/books?focus=search&orderBy=updatedAt&order=desc&n=7'),
      )!;

      expect(intent.nonce, 7);
      expect(intent.focusSearch, isTrue);
      expect(intent.orderBy, 'updatedAt');
      expect(intent.order, SortOrder.desc);
      expect(intent.hasSort, isTrue);
    });

    test('a plain /books has no request', () {
      expect(BooksLaunchIntent.fromUri(Uri.parse('/books')), isNull);
      expect(
        BooksLaunchIntent.fromUri(Uri.parse('/books?focus=search')),
        isNull,
      );
    });

    test('a half-given sort is ignored', () {
      final intent = BooksLaunchIntent.fromUri(
        Uri.parse('/books?orderBy=title&n=1'),
      )!;

      expect(intent.hasSort, isFalse);
      expect(intent.focusSearch, isFalse);
    });

    test('an unknown order is ignored', () {
      final intent = BooksLaunchIntent.fromUri(
        Uri.parse('/books?orderBy=title&order=sideways&n=1'),
      )!;

      expect(intent.hasSort, isFalse);
      expect(intent.orderBy, isNull);
    });
  });
}
