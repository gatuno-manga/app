import '../entities/books_view_preferences.dart';

/// Stored view preferences, read once at startup and kept in memory so the
/// view model can seed its state synchronously (like [SettingsService]).
abstract class BooksViewPreferencesRepository {
  /// Reads the stored preferences into [current]; defaults when absent.
  Future<void> init();

  BooksViewPreferences get current;

  /// Persists [preferences] and makes them [current].
  Future<void> save(BooksViewPreferences preferences);
}
