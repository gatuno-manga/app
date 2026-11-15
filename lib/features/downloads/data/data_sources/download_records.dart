import 'package:drift/drift.dart';

import '../../../reading/domain/entities/reading_enums.dart';
import '../../domain/entities/download_scope.dart';
import '../../domain/entities/download_state.dart';
import '../../domain/entities/download_totals.dart';
import '../../domain/use_cases/chapter_file_plan.dart';
import '../database/downloads_database.dart';

/// One chapter download with its file counts, for the watch streams.
class ChapterDownloadRow {
  final String chapterId;
  final String bookId;
  final BookType bookType;
  final DownloadState state;
  final String? error;
  final int filesDone;
  final int filesTotal;
  final int bytes;

  const ChapterDownloadRow({
    required this.chapterId,
    required this.bookId,
    required this.bookType,
    required this.state,
    required this.error,
    required this.filesDone,
    required this.filesTotal,
    required this.bytes,
  });
}

/// A planned chapter and one of its done files, to spot lost downloads.
class PlannedChapterSample {
  final String chapterId;
  final String bookId;

  /// Relative path of the done file at the highest position, if any.
  final String? sample;

  const PlannedChapterSample({
    required this.chapterId,
    required this.bookId,
    required this.sample,
  });
}

/// Where a file of a done chapter lives.
class DoneFile {
  final String bookId;
  final String chapterId;

  /// Path relative to the chapter's directory.
  final String relativePath;

  const DoneFile({
    required this.bookId,
    required this.chapterId,
    required this.relativePath,
  });
}

/// Reads and writes of the downloads database. No decisions: the caller
/// applies the state machine and keeps writes serialized.
class DownloadRecords {
  final DownloadsDatabase _db;

  DownloadRecords(this._db);

  static const List<DownloadState> _active = [
    DownloadState.queued,
    DownloadState.running,
  ];

  /// Insertion order; `enqueuedAt` only has second precision.
  static const Expression<int> _rowId = CustomExpression<int>('rowid');

  /// Runs [action] in one transaction: one commit, one stream update.
  Future<T> transaction<T>(Future<T> Function() action) =>
      _db.transaction(action);

  // Books

  /// Records the book, or updates its type when [bookType] is known now.
  Future<void> upsertBook(
    String bookId,
    BookType? bookType,
    DateTime now,
  ) async {
    await _db
        .into(_db.downloadBooks)
        .insert(
          DownloadBooksCompanion.insert(
            bookId: bookId,
            bookType: bookType ?? BookType.other,
            enqueuedAt: now,
          ),
          onConflict: bookType == null
              ? DoNothing()
              : DoUpdate(
                  (_) => DownloadBooksCompanion(bookType: Value(bookType)),
                ),
        );
  }

  Future<BookType> bookType(String bookId) async {
    final row = await (_db.select(
      _db.downloadBooks,
    )..where((b) => b.bookId.equals(bookId))).getSingleOrNull();
    return row?.bookType ?? BookType.other;
  }

  /// `(bookId, chapterId)` of every chapter download.
  Future<Set<(String, String)>> chapterKeys() async => {
    for (final c in await _db.select(_db.downloadChapters).get())
      (c.bookId, c.chapterId),
  };

  Future<List<String>> bookIds() =>
      _db.select(_db.downloadBooks).map((b) => b.bookId).get();

  /// Whether [bookId] has no chapter left. Its row is then deleted, unless
  /// automatic download is on for it: that row stays, holding the setting.
  Future<bool> deleteBookIfEmpty(String bookId) => _db.transaction(() async {
    if (await _hasChapters(bookId)) return false;
    await (_db.delete(
          _db.downloadBooks,
        )..where((b) => b.bookId.equals(bookId) & b.autoDownloadSince.isNull()))
        .go();
    return true;
  });

  Future<bool> _hasChapters(String bookId) async {
    final left =
        await (_db.select(_db.downloadChapters)
              ..where((c) => c.bookId.equals(bookId))
              ..limit(1))
            .get();
    return left.isNotEmpty;
  }

  // Automatic download

  /// Turns automatic download of [bookId] on from [since], recording the book
  /// if it has no row yet.
  Future<void> enableAutoDownload(String bookId, DateTime since) => _db
      .into(_db.downloadBooks)
      .insert(
        DownloadBooksCompanion.insert(
          bookId: bookId,
          bookType: BookType.other,
          enqueuedAt: since,
          autoDownloadSince: Value(since),
        ),
        onConflict: DoUpdate(
          (_) => DownloadBooksCompanion(autoDownloadSince: Value(since)),
        ),
      );

  /// Turns automatic download of [bookId] off, forgetting the chapters the
  /// new-chapter check saw; a row left with no chapter goes.
  Future<void> disableAutoDownload(String bookId) => _db.transaction(() async {
    await (_db.update(
      _db.downloadBooks,
    )..where((b) => b.bookId.equals(bookId))).write(
      const DownloadBooksCompanion(
        autoDownloadSince: Value(null),
        autoDownloadBaselineFor: Value(null),
        autoDownloadCheckedAt: Value(null),
      ),
    );
    await (_db.delete(
      _db.autoDownloadSeen,
    )..where((s) => s.bookId.equals(bookId))).go();
    if (!await _hasChapters(bookId)) {
      await (_db.delete(
        _db.downloadBooks,
      )..where((b) => b.bookId.equals(bookId))).go();
    }
  });

  /// When automatic download of [bookId] was turned on, or `null` while it
  /// is off. Emits on listen, then on every change.
  Stream<DateTime?> watchAutoDownloadSince(String bookId) =>
      (_db.selectOnly(_db.downloadBooks)
            ..addColumns([_db.downloadBooks.autoDownloadSince])
            ..where(_db.downloadBooks.bookId.equals(bookId)))
          .map((row) => row.read(_db.downloadBooks.autoDownloadSince))
          .watchSingleOrNull()
          .distinct();

  /// Books with automatic download on, oldest setting first.
  Future<List<({String bookId, DateTime since})>> autoDownloadBooks() async {
    final b = _db.downloadBooks;
    final rows =
        await (_db.select(b)
              ..where((t) => t.autoDownloadSince.isNotNull())
              ..orderBy([(t) => OrderingTerm.asc(t.autoDownloadSince)]))
            .get();
    return [
      for (final row in rows)
        (bookId: row.bookId, since: row.autoDownloadSince!),
    ];
  }

  /// Books with automatic download on, as the new-chapter check needs them:
  /// never checked first, then the least recently checked.
  Future<List<DownloadBook>> autoDownloadChecks() {
    final b = _db.downloadBooks;
    return (_db.select(b)
          ..where((t) => t.autoDownloadSince.isNotNull())
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.autoDownloadCheckedAt,
              nulls: NullsOrder.first,
            ),
            (t) => OrderingTerm.asc(t.autoDownloadSince),
          ]))
        .get();
  }

  /// Chapters the new-chapter check has seen for [bookId].
  Future<Set<String>> seenChapters(String bookId) async => {
    for (final row in await (_db.select(
      _db.autoDownloadSeen,
    )..where((s) => s.bookId.equals(bookId))).get())
      row.chapterId,
  };

  /// Records a check of [bookId]: [chapters] join its seen set (replace it
  /// when [baseline]) and the check time becomes [at]. Only while automatic
  /// download is still on from [since]: `false`, writing nothing, when it was
  /// turned off or on again meanwhile, or the downloads were wiped.
  Future<bool> recordAutoDownloadCheck(
    String bookId, {
    required DateTime since,
    required Set<String> chapters,
    required bool baseline,
    required DateTime at,
  }) => _db.transaction(() async {
    final updated =
        await (_db.update(_db.downloadBooks)..where(
              (b) =>
                  b.bookId.equals(bookId) & b.autoDownloadSince.equals(since),
            ))
            .write(
              DownloadBooksCompanion(
                autoDownloadCheckedAt: Value(at),
                autoDownloadBaselineFor: baseline
                    ? Value(since)
                    : const Value.absent(),
              ),
            );
    if (updated == 0) return false;
    if (baseline) {
      await (_db.delete(
        _db.autoDownloadSeen,
      )..where((s) => s.bookId.equals(bookId))).go();
    }
    await _db.batch((batch) {
      batch.insertAll(_db.autoDownloadSeen, [
        for (final chapterId in chapters)
          AutoDownloadSeenCompanion.insert(
            bookId: bookId,
            chapterId: chapterId,
          ),
      ], mode: InsertMode.insertOrIgnore);
    });
    return true;
  });

  /// When the new-chapter check last read any book, or `null` if never.
  Future<DateTime?> lastAutoDownloadCheck() {
    final checkedAt = _db.downloadBooks.autoDownloadCheckedAt.max();
    return (_db.selectOnly(
      _db.downloadBooks,
    )..addColumns([checkedAt])).map((row) => row.read(checkedAt)).getSingle();
  }

  // Chapters

  Future<DownloadChapter?> chapter(String chapterId) => (_db.select(
    _db.downloadChapters,
  )..where((c) => c.chapterId.equals(chapterId))).getSingleOrNull();

  Future<void> insertChapter(String chapterId, String bookId, DateTime now) =>
      _db
          .into(_db.downloadChapters)
          .insert(
            DownloadChaptersCompanion.insert(
              chapterId: chapterId,
              bookId: bookId,
              state: DownloadState.queued,
              enqueuedAt: now,
            ),
          );

  Future<List<DownloadChapter>> chaptersIn(DownloadScope scope) {
    final query = _db.select(_db.downloadChapters);
    switch (scope) {
      case ChaptersScope(:final chapterIds):
        return _chaptersWithIds([for (final id in chapterIds) id.value]);
      case BookScope(:final bookId):
        query.where((c) => c.bookId.equals(bookId.value));
      case AllScope():
        break;
    }
    return (query..orderBy(_fifo)).get();
  }

  Future<List<DownloadChapter>> _chaptersWithIds(List<String> ids) async {
    final query = _db.select(_db.downloadChapters)..orderBy(_fifo);
    if (ids.length <= _chunkSize) {
      return (query..where((c) => c.chapterId.isIn(ids))).get();
    }
    // Past one statement's variables: read in FIFO order, filter here.
    final wanted = ids.toSet();
    return [
      for (final row in await query.get())
        if (wanted.contains(row.chapterId)) row,
    ];
  }

  /// Planned chapters that still want files.
  Future<List<DownloadChapter>> activePlanned() =>
      (_db.select(_db.downloadChapters)
            ..where((c) => c.planned.equals(true) & c.state.isInValues(_active))
            ..orderBy(_fifo))
          .get();

  /// The oldest active chapters without a manifest yet.
  Future<List<DownloadChapter>> unplanned(int limit) =>
      (_db.select(_db.downloadChapters)
            ..where(
              (c) => c.state.isInValues(_active) & c.planned.equals(false),
            )
            ..orderBy(_fifo)
            ..limit(limit))
          .get();

  /// Sets the chapter's state. With [clearTasks], also clears its files'
  /// native task ids in the same transaction and returns them.
  Future<List<String>> setState(
    String chapterId,
    DownloadState state,
    String? error, {
    bool clearTasks = false,
  }) => _db.transaction(() async {
    await (_db.update(
      _db.downloadChapters,
    )..where((c) => c.chapterId.equals(chapterId))).write(
      DownloadChaptersCompanion(state: Value(state), error: Value(error)),
    );
    if (!clearTasks) return const <String>[];
    return _releaseTasksOf([chapterId]);
  });

  /// Unbinds the native tasks of the chapters' files and returns their ids,
  /// for the caller to cancel.
  Future<List<String>> releaseTasksOf(List<String> chapterIds) =>
      _db.transaction(() => _releaseTasksOf(chapterIds));

  Future<List<String>> _releaseTasksOf(List<String> chapterIds) async {
    final taskIds = <String>[];
    for (final chunk in _chunks(chapterIds)) {
      final bound =
          await (_db.select(_db.downloadFiles)..where(
                (f) => f.chapterId.isIn(chunk) & f.nativeTaskId.isNotNull(),
              ))
              .get();
      taskIds.addAll([for (final f in bound) f.nativeTaskId!]);
    }
    await releaseTaskIds(taskIds.toSet());
    return taskIds;
  }

  /// Stores a planned chapter's files; [files] URLs must be absolute.
  Future<void> recordPlan(
    String chapterId,
    int manifestBytes,
    List<PlannedFile> files,
  ) => _db.transaction(() async {
    for (final file in files) {
      await _db
          .into(_db.downloadFiles)
          .insert(
            DownloadFilesCompanion.insert(
              fileId: '$chapterId/${file.position}',
              chapterId: chapterId,
              position: file.position,
              url: file.url,
              relativePath: file.relativePath,
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
    await (_db.update(
      _db.downloadChapters,
    )..where((c) => c.chapterId.equals(chapterId))).write(
      DownloadChaptersCompanion(
        planned: const Value(true),
        manifestBytes: Value(manifestBytes),
      ),
    );
  });

  /// Forgets the chapter's plan so the manifest is fetched again.
  Future<void> resetPlan(String chapterId) => _db.transaction(() async {
    await (_db.delete(
      _db.downloadFiles,
    )..where((f) => f.chapterId.equals(chapterId))).go();
    await (_db.update(
      _db.downloadChapters,
    )..where((c) => c.chapterId.equals(chapterId))).write(
      const DownloadChaptersCompanion(
        planned: Value(false),
        manifestBytes: Value(0),
      ),
    );
  });

  Future<void> deleteChapters(List<String> chapterIds) =>
      _db.transaction(() async {
        for (final chunk in _chunks(chapterIds)) {
          await (_db.delete(
            _db.downloadFiles,
          )..where((f) => f.chapterId.isIn(chunk))).go();
          await (_db.delete(
            _db.downloadChapters,
          )..where((c) => c.chapterId.isIn(chunk))).go();
        }
      });

  // Files

  /// Files not on disk yet, in order.
  Future<List<DownloadFile>> pendingFiles(String chapterId) =>
      (_db.select(_db.downloadFiles)
            ..where((f) => f.chapterId.equals(chapterId) & f.done.equals(false))
            ..orderBy([(f) => OrderingTerm.asc(f.position)]))
          .get();

  Future<DownloadFile?> fileForTask(String nativeTaskId) => (_db.select(
    _db.downloadFiles,
  )..where((f) => f.nativeTaskId.equals(nativeTaskId))).getSingleOrNull();

  Future<void> markDone(String fileId, int bytes) =>
      (_db.update(
        _db.downloadFiles,
      )..where((f) => f.fileId.equals(fileId))).write(
        DownloadFilesCompanion(
          done: const Value(true),
          bytes: Value(bytes),
          nativeTaskId: const Value(null),
        ),
      );

  /// Binds files to their native tasks, recording the network rule they
  /// were queued under.
  Future<void> assignTasks(
    Map<String, String> taskIdsByFile, {
    required bool queuedOnWifi,
  }) => _db.transaction(() async {
    for (final entry in taskIdsByFile.entries) {
      await (_db.update(
        _db.downloadFiles,
      )..where((f) => f.fileId.equals(entry.key))).write(
        DownloadFilesCompanion(
          nativeTaskId: Value(entry.value),
          queuedOnWifi: Value(queuedOnWifi),
        ),
      );
    }
  });

  /// Chapters with a bound file whose stored rule differs from the current
  /// one: Wi-Fi only for [unmeteredTypes], any network otherwise.
  Future<List<String>> chaptersQueuedAgainstRules(
    Set<BookType> unmeteredTypes,
  ) async {
    final types = unmeteredTypes.map((t) => t.name).toList();
    final placeholders = List.filled(types.length, '?').join(', ');
    final wantsWifi = types.isEmpty
        ? '0'
        : "(COALESCE(b.book_type, 'other') IN ($placeholders))";
    final rows = await _db
        .customSelect(
          'SELECT DISTINCT f.chapter_id FROM download_files f '
          'JOIN download_chapters c ON c.chapter_id = f.chapter_id '
          'LEFT JOIN download_books b ON b.book_id = c.book_id '
          'WHERE f.native_task_id IS NOT NULL '
          'AND f.queued_on_wifi != $wantsWifi',
          variables: [for (final t in types) Variable<String>(t)],
          readsFrom: {
            _db.downloadFiles,
            _db.downloadChapters,
            _db.downloadBooks,
          },
        )
        .get();
    return [for (final r in rows) r.read<String>('chapter_id')];
  }

  /// Every native task id a file of a queued or running chapter points at.
  Future<Set<String>> recordedTaskIds() async {
    final f = _db.downloadFiles;
    final c = _db.downloadChapters;
    final query =
        _db.selectOnly(f).join([
            innerJoin(c, c.chapterId.equalsExp(f.chapterId)),
          ])
          ..addColumns([f.nativeTaskId])
          ..where(f.nativeTaskId.isNotNull() & c.state.isInValues(_active));
    return {for (final row in await query.get()) row.read(f.nativeTaskId)!};
  }

  /// Those of [taskIds] that a file is still bound to.
  Future<Set<String>> boundTaskIdsAmong(Set<String> taskIds) async {
    final bound = <String>{};
    for (final chunk in _chunks(taskIds)) {
      final query = _db.selectOnly(_db.downloadFiles)
        ..addColumns([_db.downloadFiles.nativeTaskId])
        ..where(_db.downloadFiles.nativeTaskId.isIn(chunk));
      for (final row in await query.get()) {
        bound.add(row.read(_db.downloadFiles.nativeTaskId)!);
      }
    }
    return bound;
  }

  /// Unbinds these native task ids from the files that hold them.
  Future<void> releaseTaskIds(Set<String> taskIds) async {
    if (taskIds.isEmpty) return;
    await _db.transaction(() async {
      for (final chunk in _chunks(taskIds)) {
        await (_db.update(_db.downloadFiles)
              ..where((f) => f.nativeTaskId.isIn(chunk)))
            .write(const DownloadFilesCompanion(nativeTaskId: Value(null)));
      }
    });
  }

  /// SQLite caps the variables of one statement (32766); a big queue can
  /// hold more ids than that.
  static const int _chunkSize = 500;

  static Iterable<List<String>> _chunks(Iterable<String> ids) sync* {
    final list = ids.toList();
    for (var i = 0; i < list.length; i += _chunkSize) {
      yield list.sublist(i, (i + _chunkSize).clamp(0, list.length));
    }
  }

  /// Every planned chapter with one sample of its files on disk: the done
  /// file at the highest position, or `null` when none is done yet.
  Future<List<PlannedChapterSample>> plannedChapterSamples() async {
    final rows = await _db
        .customSelect(
          'SELECT c.chapter_id, c.book_id, '
          '(SELECT f.relative_path FROM download_files f '
          'WHERE f.chapter_id = c.chapter_id AND f.done = 1 '
          'ORDER BY f.position DESC LIMIT 1) AS sample '
          'FROM download_chapters c WHERE c.planned = 1',
          readsFrom: {_db.downloadChapters, _db.downloadFiles},
        )
        .get();
    return [
      for (final r in rows)
        PlannedChapterSample(
          chapterId: r.read<String>('chapter_id'),
          bookId: r.read<String>('book_id'),
          sample: r.readNullable<String>('sample'),
        ),
    ];
  }

  /// A chapter whose download is done.
  Future<DownloadChapter?> doneChapter(String chapterId) =>
      (_db.select(_db.downloadChapters)..where(
            (c) =>
                c.chapterId.equals(chapterId) &
                c.state.equalsValue(DownloadState.done),
          ))
          .getSingleOrNull();

  /// The file stored from [url] in a chapter whose download is done.
  Future<DoneFile?> doneFileForUrl(String url) async {
    final query =
        _db.select(_db.downloadFiles).join([
            innerJoin(
              _db.downloadChapters,
              _db.downloadChapters.chapterId.equalsExp(
                _db.downloadFiles.chapterId,
              ),
            ),
          ])
          ..where(
            _db.downloadFiles.url.equals(url) &
                _db.downloadChapters.state.equalsValue(DownloadState.done),
          )
          ..limit(1);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final chapter = row.readTable(_db.downloadChapters);
    return DoneFile(
      bookId: chapter.bookId,
      chapterId: chapter.chapterId,
      relativePath: row.readTable(_db.downloadFiles).relativePath,
    );
  }

  /// Every file of a chapter, in order.
  Future<List<DownloadFile>> files(String chapterId) =>
      (_db.select(_db.downloadFiles)
            ..where((f) => f.chapterId.equals(chapterId))
            ..orderBy([(f) => OrderingTerm.asc(f.position)]))
          .get();

  Future<void> clear() => _db.clearAll();

  // Projections

  /// Every chapter with its file counts, books in first-enqueue order and
  /// chapters in enqueue order.
  Stream<List<ChapterDownloadRow>> watchRows() => _db
      .customSelect(
        'SELECT c.chapter_id, c.book_id, c.state, c.error, c.manifest_bytes, '
        'b.book_type, COUNT(f.file_id) AS files_total, '
        'COALESCE(SUM(f.done), 0) AS files_done, '
        'COALESCE(SUM(f.bytes), 0) AS file_bytes '
        'FROM download_chapters c '
        'LEFT JOIN download_books b ON b.book_id = c.book_id '
        'LEFT JOIN download_files f ON f.chapter_id = c.chapter_id '
        'GROUP BY c.chapter_id '
        'ORDER BY b.enqueued_at, b.rowid, c.enqueued_at, c.rowid',
        readsFrom: {_db.downloadChapters, _db.downloadBooks, _db.downloadFiles},
      )
      .watch()
      .map(
        (rows) => [
          for (final row in rows)
            ChapterDownloadRow(
              chapterId: row.read<String>('chapter_id'),
              bookId: row.read<String>('book_id'),
              bookType: _bookType(row.readNullable<String>('book_type')),
              state: $DownloadChaptersTable.$converterstate.fromSql(
                row.read<String>('state'),
              ),
              error: row.readNullable<String>('error'),
              filesDone: row.read<int>('files_done'),
              filesTotal: row.read<int>('files_total'),
              bytes:
                  row.read<int>('manifest_bytes') + row.read<int>('file_bytes'),
            ),
        ],
      );

  Future<DownloadTotals> totals() async {
    final row = await _db
        .customSelect(
          'SELECT (SELECT COUNT(*) FROM download_chapters) AS chapters, '
          '(SELECT COALESCE(SUM(manifest_bytes), 0) FROM download_chapters) + '
          '(SELECT COALESCE(SUM(bytes), 0) FROM download_files) AS bytes',
          readsFrom: {_db.downloadChapters, _db.downloadFiles},
        )
        .getSingle();
    return DownloadTotals(
      chapters: row.read<int>('chapters'),
      bytes: row.read<int>('bytes'),
    );
  }

  static BookType _bookType(String? sql) => sql == null
      ? BookType.other
      : $DownloadBooksTable.$converterbookType.fromSql(sql);

  static List<OrderClauseGenerator<$DownloadChaptersTable>> get _fifo => [
    (c) => OrderingTerm.asc(c.enqueuedAt),
    (_) => OrderingTerm.asc(_rowId),
  ];
}
