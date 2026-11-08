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
    test(
      'current is the defaults before init and when nothing is stored',
      () async {
        expect(repository.current, const BooksViewPreferences());

        await repository.init();

        expect(repository.current, const BooksViewPreferences());
      },
    );

    test('save updates current and survives a new instance', () async {
      const saved = BooksViewPreferences(
        layout: BooksLayoutMode.cover,
        columns: 3,
        navigation: BooksNavigationMode.pages,
      );

      await repository.save(saved);
      expect(repository.current, saved);

      final reopened = BooksViewPreferencesRepositoryImpl();
      await reopened.init();
      expect(reopened.current, saved);
    });

    test('init falls back to defaults for invalid stored values', () async {
      SharedPreferences.setMockInitialValues({
        'books_view_layout': 'carousel',
        'books_view_columns': 9,
        'books_view_navigation': 'teleport',
      });

      await repository.init();

      expect(repository.current, const BooksViewPreferences());
    });

    test('init keeps valid fields when only one is invalid', () async {
      SharedPreferences.setMockInitialValues({
        'books_view_layout': 'list',
        'books_view_columns': 0,
      });

      await repository.init();

      expect(repository.current.layout, BooksLayoutMode.list);
      expect(repository.current.columns, 2);
      expect(repository.current.navigation, BooksNavigationMode.infinite);
    });
  });
}
