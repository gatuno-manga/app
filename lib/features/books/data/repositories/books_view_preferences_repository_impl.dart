import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/logging/logger.dart';
import '../../domain/entities/books_view_preferences.dart';
import '../../domain/repositories/books_view_preferences_repository.dart';

/// Not sensitive, so it lives in shared_preferences, like the theme choice.
class BooksViewPreferencesRepositoryImpl
    implements BooksViewPreferencesRepository {
  static const String _layoutKey = 'books_view_layout';
  static const String _columnsKey = 'books_view_columns';
  static const String _navigationKey = 'books_view_navigation';
  static const String _logTag = 'BooksViewPreferencesRepository';

  BooksViewPreferences _current = const BooksViewPreferences();

  @override
  BooksViewPreferences get current => _current;

  @override
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const defaults = BooksViewPreferences();
      _current = BooksViewPreferences(
        layout:
            BooksLayoutMode.values.asNameMap()[prefs.getString(_layoutKey)] ??
            defaults.layout,
        columns: _columnsInRange(prefs.getInt(_columnsKey)) ?? defaults.columns,
        navigation:
            BooksNavigationMode.values.asNameMap()[prefs.getString(
              _navigationKey,
            )] ??
            defaults.navigation,
      );
      AppLogger.d('Loaded view preferences: $_current', _logTag);
    } catch (e, stackTrace) {
      // Unreadable storage must not block startup; defaults stay in place.
      AppLogger.e('Error loading view preferences', e, stackTrace, _logTag);
    }
  }

  @override
  Future<void> save(BooksViewPreferences preferences) async {
    _current = preferences;
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_layoutKey, preferences.layout.name),
      prefs.setInt(_columnsKey, preferences.columns),
      prefs.setString(_navigationKey, preferences.navigation.name),
    ]);
  }

  static int? _columnsInRange(int? columns) {
    if (columns == null ||
        columns < BooksViewPreferences.minColumns ||
        columns > BooksViewPreferences.maxColumns) {
      return null;
    }
    return columns;
  }
}
