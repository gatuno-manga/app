import 'package:rxdart/rxdart.dart';

import '../../../../core/logging/logger.dart';
import '../../data/data_sources/reader_preferences_storage.dart';
import '../entities/reader_preferences.dart';

/// Applies a change to the current [ReaderPreferences]. Callers never see a
/// stale value, so rapid changes compose instead of overwriting.
typedef ReaderPreferencesChange =
    ReaderPreferences Function(ReaderPreferences current);

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

  /// Loads the stored preferences once; a failed read is retried on the
  /// next call.
  Future<void> init() async {
    if (_initialized) return;
    try {
      _subject.add(await _storage.read());
      _initialized = true;
    } catch (e, stackTrace) {
      AppLogger.e('Error loading reader preferences', e, stackTrace, _logTag);
    }
  }

  /// Applies [change] to the current value, emits the result at once (so
  /// the reader repaints without waiting for disk) and then persists it.
  /// Deriving from [current] inside the service means rapid changes never
  /// overwrite each other. A failed write logs and restores the previous
  /// value.
  Future<void> update(ReaderPreferencesChange change) async {
    final previous = current;
    final next = change(previous);
    if (next == previous) return;
    _subject.add(next);
    try {
      await _storage.write(next);
    } catch (e, stackTrace) {
      AppLogger.e('Error saving reader preferences', e, stackTrace, _logTag);
      if (current == next) _subject.add(previous);
    }
  }

  void dispose() {
    _subject.close();
  }
}
