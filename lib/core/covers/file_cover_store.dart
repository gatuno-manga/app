import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';

import '../database/offline_cache_database.dart';
import '../logging/logger.dart';
import '../offline/cache_epoch.dart';
import 'cover_store.dart';

/// Downloads a cover; `null` when it cannot be fetched.
typedef CoverDownloader = Future<Uint8List?> Function(String url);

/// [CoverStore] that keeps files under [directory] and indexes them in
/// [OfflineCacheDatabase].
class FileCoverStore implements CoverStore {
  /// Shared by every unpinned cover.
  static const int defaultBudgetBytes = 200 * 1024 * 1024;

  /// `lastUsedAt` is rewritten at most this often, so scrolling a grid does
  /// not write a row per tile; LRU over days does not need finer stamps.
  static const Duration touchInterval = Duration(hours: 1);

  final OfflineCacheDatabase _db;
  final Future<Directory> Function() _directory;
  final CoverDownloader _download;
  final int budgetBytes;
  final DateTime Function() _now;
  final bool Function() _isOffline;
  final CacheEpoch _epoch;

  static const String _logTag = 'FileCoverStore';

  final Map<String, Future<File?>> _inFlight = {};
  Future<void>? _budgetPass;

  FileCoverStore({
    required OfflineCacheDatabase db,
    required Future<Directory> Function() directory,
    required CoverDownloader download,
    this.budgetBytes = defaultBudgetBytes,
    DateTime Function()? now,
    bool Function()? isOffline,
    CacheEpoch? epoch,
  }) : _db = db,
       _directory = directory,
       _download = download,
       _now = now ?? DateTime.now,
       _isOffline = isOffline ?? _never,
       _epoch = epoch ?? CacheEpoch();

  static bool _never() => false;

  @override
  Future<File?> file(String bookId) async => _use(await _row(bookId));

  /// The file of [row] when it still exists on disk, marking it used.
  Future<File?> _use(CachedCover? row) async {
    if (row == null) return null;
    final file = File(row.filePath);
    if (!await file.exists()) {
      await _deleteRows([row.bookId]);
      return null;
    }
    if (_now().difference(row.lastUsedAt) >= touchInterval) {
      await _touch(row.bookId);
    }
    return file;
  }

  @override
  Future<File?> ensure(String bookId, String sourceUrl) {
    return _inFlight[bookId] ??=
        _ensure(
          bookId,
          sourceUrl,
          // A block body: `=> _inFlight.remove(...)` would return this very future
          // to whenComplete, which would then wait on itself forever.
        ).whenComplete(() {
          _inFlight.remove(bookId);
        });
  }

  Future<File?> _ensure(String bookId, String sourceUrl) async {
    final row = await _row(bookId);
    if (row != null && row.sourceUrl == sourceUrl) {
      final stored = await _use(row);
      if (stored != null) return stored;
    }

    // Offline, a download would only wait for the connect timeout while the
    // cover shows its skeleton: answer with what is stored at once.
    if (_isOffline()) return _use(row);

    final epoch = _epoch.value;
    final bytes = await _download(sourceUrl);
    if (bytes == null || bytes.isEmpty) {
      // Failed: an older cover is better than none.
      return _use(row);
    }
    // The cache was wiped while downloading (server changed): drop it.
    if (_epoch.value != epoch) return null;

    final target = await _write(bookId, sourceUrl, bytes);
    if (row != null && row.filePath != target.path) {
      await _deleteFile(row.filePath);
    }

    final now = _now();
    await _db
        .into(_db.cachedCovers)
        .insertOnConflictUpdate(
          CachedCoversCompanion.insert(
            bookId: bookId,
            sourceUrl: sourceUrl,
            filePath: target.path,
            bytes: bytes.length,
            fetchedAt: now,
            lastUsedAt: now,
          ),
        );
    unawaited(_scheduleBudgetPass());
    return target;
  }

  @override
  Future<String?> bookIdForUrl(String sourceUrl) async {
    final query = _db.selectOnly(_db.cachedBooks)
      ..addColumns([_db.cachedBooks.id])
      ..where(_db.cachedBooks.cover.equals(sourceUrl))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row?.read(_db.cachedBooks.id);
  }

  @override
  Future<void> pin(String bookId, String owner) async {
    await _db
        .into(_db.coverPins)
        .insert(
          CoverPinsCompanion.insert(bookId: bookId, owner: owner),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> unpin(String bookId, String owner) async {
    await (_db.delete(
      _db.coverPins,
    )..where((p) => p.bookId.equals(bookId) & p.owner.equals(owner))).go();
  }

  @override
  Future<void> remove(Iterable<String> bookIds) async {
    final ids = bookIds.toList();
    if (ids.isEmpty) return;
    final rows = await (_db.select(
      _db.cachedCovers,
    )..where((c) => c.bookId.isIn(ids))).get();
    for (final row in rows) {
      await _deleteFile(row.filePath);
    }
    await _deleteRows(ids);
  }

  @override
  Future<void> enforceBudget() async {
    // Rows are chosen and deleted in one transaction, so a cover written or
    // pinned meanwhile is not evicted on a stale reading. Files go after the
    // rows: an orphan file is harmless, a row without its file is not.
    final evicted = await _db.transaction(() async {
      final pinned = _db.selectOnly(_db.coverPins)
        ..addColumns([_db.coverPins.bookId]);
      final unpinned =
          await (_db.select(_db.cachedCovers)
                ..where((c) => c.bookId.isNotInQuery(pinned))
                ..orderBy([(c) => OrderingTerm.asc(c.lastUsedAt)]))
              .get();

      var total = unpinned.fold<int>(0, (sum, c) => sum + c.bytes);
      final victims = <CachedCover>[];
      for (final cover in unpinned) {
        if (total <= budgetBytes) break;
        victims.add(cover);
        total -= cover.bytes;
      }
      await _deleteRows([for (final v in victims) v.bookId]);
      return victims;
    });
    for (final cover in evicted) {
      await _deleteFile(cover.filePath);
    }
  }

  @override
  Future<void> clear() async {
    await _db.delete(_db.cachedCovers).go();
    await _db.delete(_db.coverPins).go();
    final dir = await _directory();
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  Future<CachedCover?> _row(String bookId) => (_db.select(
    _db.cachedCovers,
  )..where((c) => c.bookId.equals(bookId))).getSingleOrNull();

  Future<void> _touch(String bookId) async {
    await (_db.update(_db.cachedCovers)..where((c) => c.bookId.equals(bookId)))
        .write(CachedCoversCompanion(lastUsedAt: Value(_now())));
  }

  Future<File> _write(String bookId, String sourceUrl, Uint8List bytes) async {
    final dir = await _directory();
    await dir.create(recursive: true);
    final name = bookId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final target = File('${dir.path}/$name.${_extension(sourceUrl)}');
    // Write then rename, so a crash never leaves a half-written cover.
    final temp = File('${target.path}.part');
    await temp.writeAsBytes(bytes, flush: true);
    return temp.rename(target.path);
  }

  Future<void> _deleteRows(List<String> bookIds) async {
    if (bookIds.isEmpty) return;
    await (_db.delete(
      _db.cachedCovers,
    )..where((c) => c.bookId.isIn(bookIds))).go();
  }

  Future<void> _deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e, stackTrace) {
      AppLogger.e('Could not delete cover file', e, stackTrace, _logTag);
    }
  }

  /// One budget pass at a time: a grid of new covers schedules one pass, not
  /// one per cover.
  Future<void> _scheduleBudgetPass() {
    return _budgetPass ??= () async {
      try {
        await enforceBudget();
      } catch (e, stackTrace) {
        AppLogger.e('Cover eviction failed', e, stackTrace, _logTag);
      } finally {
        _budgetPass = null;
      }
    }();
  }

  static String _extension(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot < path.lastIndexOf('/')) return 'img';
    final ext = path.substring(dot + 1).toLowerCase();
    return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(ext) ? ext : 'img';
  }
}
