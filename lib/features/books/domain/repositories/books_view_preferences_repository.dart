import '../entities/books_view_preferences.dart';

abstract class BooksViewPreferencesRepository {
  Future<BooksViewPreferences> load();
  Future<void> save(BooksViewPreferences preferences);
}
