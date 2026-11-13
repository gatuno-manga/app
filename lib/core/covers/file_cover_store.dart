import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';

import '../database/offline_cache_database.dart';
import '../logging/logger.dart';
import 'cover_store.dart';

/// Downloads a cover; `null` when it cannot be fetched.
typedef CoverDownloader = Future<Uint8List?> Function(String url);

/// [CoverStore] that keeps files under [directory] and indexes them in
/// [OfflineCacheDatabase].
class FileCoverStore implements CoverStore {
  /// Shared by every unpinned cover.
  static const int defaultBudgetBytes = 200 * 1024 * 1024;

  final OfflineCacheDatabase _db;
  final Future<Directory> Function() _directory;
  final CoverDownloader _download;
  final int budgetBytes;
  final DateTime Function() _now;

  static const String _logTag = 'FileCoverStore';

  final Map<String, Future<File?>> _inFlight = {};

  FileCoverStore({
    required OfflineCacheDatabase db,
    required Future<Directory> Function() directory,
    required CoverDownloader download,
    this.budgetBytes = defaultBudgetBytes,
    DateTime Function()? now,
  }) : _db = db,
       _directory = directory,
       _download = download,
       _now = now ?? DateTime.now;

  @override
  Future<File?> file(String bookId) async {
    final row = await _row(bookId);
    if (row == null) return null;
    final file = File(row.filePath);
    if (!await file.exists()) {
      await _deleteRows([bookId]);
      return null;
    }
    await _touch(bookId);
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
      final stored = await file(bookId);
      if (stored != null) return stored;
    }

    final bytes = await _download(sourceUrl);
    if (bytes == null || bytes.isEmpty) {
      // Offline or failed: an older cover is better than none.
      return row == null ? null : file(bookId);
    }

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
    unawaited(_enforceBudgetSafely());
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
    final pinned = _db.selectOnly(_db.coverPins)
      ..addColumns([_db.coverPins.bookId]);
    final unpinned =
        await (_db.select(_db.cachedCovers)
              ..where((c) => c.bookId.isNotInQuery(pinned))
              ..orderBy([(c) => OrderingTerm.asc(c.lastUsedAt)]))
            .get();

    var total = unpinned.fold<int>(0, (sum, c) => sum + c.bytes);
    final evicted = <String>[];
    for (final cover in unpinned) {
      if (total <= budgetBytes) break;
      await _deleteFile(cover.filePath);
      evicted.add(cover.bookId);
      total -= cover.bytes;
    }
    await _deleteRows(evicted);
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

  Future<void> _enforceBudgetSafely() async {
    try {
      await enforceBudget();
    } catch (e, stackTrace) {
      AppLogger.e('Cover eviction failed', e, stackTrace, _logTag);
    }
  }

  static String _extension(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot < path.lastIndexOf('/')) return 'img';
    final ext = path.substring(dot + 1).toLowerCase();
    return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(ext) ? ext : 'img';
  }
}
