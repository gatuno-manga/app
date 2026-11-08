import 'package:rxdart/rxdart.dart';

import '../../../../core/logging/logger.dart';
import '../../data/data_sources/reader_preferences_storage.dart';
import '../entities/reader_preferences.dart';

/// Holds the current [ReaderPreferences] for every reader and persists
/// changes. Seeded with the defaults until [init] loads the stored values.
class ReaderPreferencesService {
  static const String _logTag = 'ReaderPreferencesService';

  final ReaderPreferencesStorage _storage;
  final _subject = BehaviorSubject<ReaderPreferences>.seeded(
    ReaderPreferences.defaults,
  );
  bool _initialized = false;

  ReaderPreferencesService(this._storage);

  Stream<ReaderPreferences> get stream => _subject.stream;
  ReaderPreferences get current => _subject.value;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _subject.add(await _storage.read());
    } catch (e, stackTrace) {
      AppLogger.e('Error loading reader preferences', e, stackTrace, _logTag);
    }
  }

  /// Persists [preferences] and emits them. On a failed write the previous
  /// value stays current and `false` is returned.
  Future<bool> update(ReaderPreferences preferences) async {
    try {
      await _storage.write(preferences);
      _subject.add(preferences);
      return true;
    } catch (e, stackTrace) {
      AppLogger.e('Error saving reader preferences', e, stackTrace, _logTag);
      return false;
    }
  }

  void dispose() {
    _subject.close();
  }
}
