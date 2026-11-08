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

  @override
  Future<BooksViewPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = BooksViewPreferences();
    final loaded = BooksViewPreferences(
      layout:
          _enumByName(BooksLayoutMode.values, prefs.getString(_layoutKey)) ??
          defaults.layout,
      columns: _columnsInRange(prefs.getInt(_columnsKey)) ?? defaults.columns,
      navigation:
          _enumByName(
            BooksNavigationMode.values,
            prefs.getString(_navigationKey),
          ) ??
          defaults.navigation,
    );
    AppLogger.d('Loaded view preferences: $loaded', _logTag);
    return loaded;
  }

  @override
  Future<void> save(BooksViewPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_layoutKey, preferences.layout.name),
      prefs.setInt(_columnsKey, preferences.columns),
      prefs.setString(_navigationKey, preferences.navigation.name),
    ]);
  }

  static T? _enumByName<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
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
