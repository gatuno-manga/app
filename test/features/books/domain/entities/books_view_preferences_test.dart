import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/books_view_preferences.dart';

void main() {
  group('BooksViewPreferences', () {
    test('defaults are grid, 2 columns, infinite', () {
      const prefs = BooksViewPreferences();

      expect(prefs.layout, BooksLayoutMode.grid);
      expect(prefs.columns, 2);
      expect(prefs.navigation, BooksNavigationMode.infinite);
    });

    test('copyWith replaces only the given field', () {
      const prefs = BooksViewPreferences();

      final changed = prefs.copyWith(columns: 3);

      expect(changed.columns, 3);
      expect(changed.layout, prefs.layout);
      expect(changed.navigation, prefs.navigation);
    });

    test('equality is by value', () {
      expect(
        const BooksViewPreferences(layout: BooksLayoutMode.cover),
        const BooksViewPreferences(layout: BooksLayoutMode.cover),
      );
      expect(
        const BooksViewPreferences(columns: 1),
        isNot(const BooksViewPreferences(columns: 4)),
      );
    });
  });
}
