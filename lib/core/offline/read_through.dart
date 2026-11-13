import '../connectivity/connectivity_service.dart';
import '../logging/logger.dart';
import '../network/exceptions.dart';
import 'cache_epoch.dart';

/// Network first, cache when offline.
///
/// - Known offline: skip the network (no connect timeout) and read the cache.
/// - Online: fetch, write the result to the cache, return it. A failed cache
///   write is logged and does not fail the call.
/// - The fetch cannot reach the server ([NetworkException]): fall back to the
///   cache. The connectivity interceptor has already flipped the status.
/// - A cache miss in either fallback throws [OfflineException].
///
/// Any other error, including server 4xx/5xx, propagates unchanged: the
/// server answered, so stale data would hide a real problem.
///
/// A response that arrives after the cache was wiped ([CacheEpoch] moved) is
/// returned but not saved: it belongs to the server the user just left.
class ReadThrough {
  final ConnectivityService _connectivity;
  final CacheEpoch _epoch;

  static const String _logTag = 'ReadThrough';

  ReadThrough(this._connectivity, this._epoch);

  Future<T> call<T>({
    required Future<T> Function() fetch,
    required Future<void> Function(T value) save,
    required Future<T?> Function() load,
  }) async {
    if (_connectivity.isOffline) return _fromCache(load);

    final epoch = _epoch.value;
    final T value;
    try {
      value = await fetch();
    } on NetworkException {
      return _fromCache(load);
    }

    if (_epoch.value != epoch) return value;
    try {
      await save(value);
    } catch (e, stackTrace) {
      AppLogger.e('Could not write the offline cache', e, stackTrace, _logTag);
    }
    return value;
  }

  Future<T> _fromCache<T>(Future<T?> Function() load) async {
    final cached = await load();
    if (cached == null) throw OfflineException();
    return cached;
  }
}
