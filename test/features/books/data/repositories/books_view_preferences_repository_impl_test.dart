import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/data/repositories/books_view_preferences_repository_impl.dart';
import 'package:gatuno/features/books/domain/entities/books_view_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BooksViewPreferencesRepositoryImpl repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = BooksViewPreferencesRepositoryImpl();
  });

  group('BooksViewPreferencesRepositoryImpl', () {
    test('load returns defaults when nothing is stored', () async {
      final prefs = await repository.load();

      expect(prefs, const BooksViewPreferences());
    });

    test('save then load round-trips', () async {
      const saved = BooksViewPreferences(
        layout: BooksLayoutMode.cover,
        columns: 3,
        navigation: BooksNavigationMode.pages,
      );

      await repository.save(saved);
      final loaded = await repository.load();

      expect(loaded, saved);
    });

    test('load falls back to defaults for invalid stored values', () async {
      SharedPreferences.setMockInitialValues({
        'books_view_layout': 'carousel',
        'books_view_columns': 9,
        'books_view_navigation': 'teleport',
      });

      final prefs = await repository.load();

      expect(prefs, const BooksViewPreferences());
    });

    test('load keeps valid fields when only one is invalid', () async {
      SharedPreferences.setMockInitialValues({
        'books_view_layout': 'list',
        'books_view_columns': 0,
      });

      final prefs = await repository.load();

      expect(prefs.layout, BooksLayoutMode.list);
      expect(prefs.columns, 2);
      expect(prefs.navigation, BooksNavigationMode.infinite);
    });
  });
}
