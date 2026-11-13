import '../connectivity/connectivity_service.dart';
import '../logging/logger.dart';
import '../network/exceptions.dart';

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
class ReadThrough {
  final ConnectivityService _connectivity;

  static const String _logTag = 'ReadThrough';

  ReadThrough(this._connectivity);

  Future<T> call<T>({
    required Future<T> Function() fetch,
    required Future<void> Function(T value) save,
    required Future<T?> Function() load,
  }) async {
    if (_connectivity.isOffline) return _fromCache(load);

    final T value;
    try {
      value = await fetch();
    } on NetworkException {
      return _fromCache(load);
    }

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
