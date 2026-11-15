import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../../../core/logging/logger.dart';
import '../../../reading/domain/entities/reading_enums.dart';
import '../../domain/entities/download_network.dart';
import '../../domain/repositories/download_network_rules.dart';
import '../data_sources/download_network_rules_storage.dart';

/// The rules the user saved, read once and kept in memory. Writes run one
/// at a time, so [changes] fires in the order the user made them.
class StoredDownloadNetworkRules implements DownloadNetworkRules {
  static const String _logTag = 'StoredDownloadNetworkRules';

  final DownloadNetworkRulesStorage _storage;
  final BehaviorSubject<Map<BookType, DownloadNetwork>> _rules =
      BehaviorSubject<Map<BookType, DownloadNetwork>>();
  final StreamController<void> _changes = StreamController<void>.broadcast();

  Future<void>? _loading;
  Future<void> _writes = Future<void>.value();

  StoredDownloadNetworkRules(this._storage);

  @override
  Future<DownloadNetwork> requirementFor(BookType type) async {
    await _load();
    return _rules.valueOrNull?[type] ?? DownloadNetworkRules.defaultRule;
  }

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Stream<Map<BookType, DownloadNetwork>> watch() {
    unawaited(_load());
    return _rules.stream;
  }

  @override
  Future<void> set(BookType type, DownloadNetwork network) {
    final write = _writes.then((_) => _set(type, network));
    // A failed write must not block the next one.
    _writes = write.then<void>((_) {}, onError: (Object _) {});
    return write;
  }

  Future<void> _set(BookType type, DownloadNetwork network) async {
    await _load();
    if (_rules.value[type] == network) return;
    await _storage.write(type, network);
    if (_rules.isClosed) return;
    _rules.add(Map.unmodifiable({..._rules.value, type: network}));
    _changes.add(null);
  }

  Future<void> _load() => _loading ??= _read();

  /// A rule that cannot be read falls back to the default, so the engine
  /// never spends mobile data because storage failed.
  Future<void> _read() async {
    final rules = <BookType, DownloadNetwork>{};
    for (final type in BookType.values) {
      try {
        rules[type] =
            await _storage.read(type) ?? DownloadNetworkRules.defaultRule;
      } catch (e, stackTrace) {
        AppLogger.e('Network rule unreadable', e, stackTrace, _logTag);
        rules[type] = DownloadNetworkRules.defaultRule;
      }
    }
    if (!_rules.isClosed) _rules.add(Map.unmodifiable(rules));
  }

  Future<void> dispose() async {
    await _rules.close();
    await _changes.close();
  }
}
