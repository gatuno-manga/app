import '../covers/cover_store.dart';
import '../database/offline_cache_database.dart';
import '../logging/logger.dart';
import 'cache_epoch.dart';

/// Lifecycle of the offline cache as a whole: eviction on start and the wipe
/// when the server changes (a different server is a different library).
class OfflineCacheMaintenance {
  final OfflineCacheDatabase _db;
  final CoverStore _covers;
  final CacheEpoch _epoch;
  final DateTime Function() _now;

  /// Books not read or written for this long are evicted on start.
  static const Duration bookRetention = Duration(days: 90);

  static const String _logTag = 'OfflineCacheMaintenance';

  OfflineCacheMaintenance(
    this._db,
    this._covers,
    this._epoch, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// Evicts stale books with their covers, then trims covers to the budget.
  /// Never throws: a failed eviction only leaves more data behind.
  Future<void> evictStale() async {
    try {
      final evicted = await _db.evictBooksNotAccessedSince(
        _now().subtract(bookRetention),
      );
      // A book fetched again right after its eviction is back in the cache,
      // possibly with a fresh cover: keep that one.
      final back = evicted.isEmpty
          ? const <String>[]
          : await (_db.selectOnly(_db.cachedBooks)
                  ..addColumns([_db.cachedBooks.id])
                  ..where(_db.cachedBooks.id.isIn(evicted)))
                .map((r) => r.read(_db.cachedBooks.id)!)
                .get();
      await _covers.remove(evicted.where((id) => !back.contains(id)));
      await _covers.enforceBudget();
      if (evicted.isNotEmpty) {
        AppLogger.i('Evicted ${evicted.length} stale books', _logTag);
      }
    } catch (e, stackTrace) {
      AppLogger.e('Offline cache eviction failed', e, stackTrace, _logTag);
    }
  }

  /// Deletes every cached row, cover file and pin. Bumps the epoch first, so
  /// writes from requests already in flight are dropped.
  Future<void> clearAll() async {
    _epoch.bump();
    await _db.clearAll();
    await _covers.clear();
    AppLogger.i('Offline cache cleared', _logTag);
  }
}
