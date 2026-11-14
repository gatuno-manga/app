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

/// A file with a native task, for re-checking network rules.
class QueuedFile {
  final String chapterId;
  final BookType bookType;
  final bool queuedOnWifi;

  const QueuedFile({
    required this.chapterId,
    required this.bookType,
    required this.queuedOnWifi,
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

  /// Deletes the book when it has no chapter left; `true` if it did.
  Future<bool> deleteBookIfEmpty(String bookId) => _db.transaction(() async {
    final left =
        await (_db.select(_db.downloadChapters)
              ..where((c) => c.bookId.equals(bookId))
              ..limit(1))
            .get();
    if (left.isNotEmpty) return false;
    await (_db.delete(
      _db.downloadBooks,
    )..where((b) => b.bookId.equals(bookId))).go();
    return true;
  });

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
        query.where(
          (c) => c.chapterId.isIn([for (final id in chapterIds) id.value]),
        );
      case BookScope(:final bookId):
        query.where((c) => c.bookId.equals(bookId.value));
      case AllScope():
        break;
    }
    return (query..orderBy(_fifo)).get();
  }

  /// Planned chapters that still want files.
  Future<List<DownloadChapter>> activePlanned() =>
      (_db.select(_db.downloadChapters)
            ..where((c) => c.planned.equals(true) & c.state.isInValues(_active))
            ..orderBy(_fifo))
          .get();

  /// The oldest queued chapters without a manifest yet.
  Future<List<DownloadChapter>> unplanned(int limit) =>
      (_db.select(_db.downloadChapters)
            ..where(
              (c) =>
                  c.state.equalsValue(DownloadState.queued) &
                  c.planned.equals(false),
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
    final queued =
        await (_db.select(_db.downloadFiles)..where(
              (f) => f.chapterId.equals(chapterId) & f.nativeTaskId.isNotNull(),
            ))
            .get();
    await (_db.update(_db.downloadFiles)..where(
          (f) => f.chapterId.equals(chapterId) & f.nativeTaskId.isNotNull(),
        ))
        .write(const DownloadFilesCompanion(nativeTaskId: Value(null)));
    return [for (final f in queued) f.nativeTaskId!];
  });

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
        await (_db.delete(
          _db.downloadFiles,
        )..where((f) => f.chapterId.isIn(chapterIds))).go();
        await (_db.delete(
          _db.downloadChapters,
        )..where((c) => c.chapterId.isIn(chapterIds))).go();
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

  /// Sets or clears (`null`) the native task of several files at once,
  /// recording the network rule they were queued under.
  Future<void> assignTasks(
    Map<String, String?> taskIdsByFile, {
    bool queuedOnWifi = false,
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

  /// Files with a native task, with their book type and the rule they were
  /// queued under.
  Future<List<QueuedFile>> queuedFiles() async {
    final f = _db.downloadFiles;
    final c = _db.downloadChapters;
    final b = _db.downloadBooks;
    final query = _db.select(f).join([
      innerJoin(c, c.chapterId.equalsExp(f.chapterId)),
      leftOuterJoin(b, b.bookId.equalsExp(c.bookId)),
    ])..where(f.nativeTaskId.isNotNull());
    return [
      for (final row in await query.get())
        QueuedFile(
          chapterId: row.readTable(f).chapterId,
          bookType: row.readTableOrNull(b)?.bookType ?? BookType.other,
          queuedOnWifi: row.readTable(f).queuedOnWifi,
        ),
    ];
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

  /// Clears these native task ids from the files that hold them.
  Future<void> clearTaskIds(Set<String> taskIds) async {
    if (taskIds.isEmpty) return;
    await (_db.update(_db.downloadFiles)
          ..where((f) => f.nativeTaskId.isIn(taskIds)))
        .write(const DownloadFilesCompanion(nativeTaskId: Value(null)));
  }

  /// Pending files of several chapters, in chapter and page order.
  Future<List<DownloadFile>> pendingFilesOf(List<String> chapterIds) =>
      (_db.select(_db.downloadFiles)
            ..where((f) => f.chapterId.isIn(chapterIds) & f.done.equals(false))
            ..orderBy([
              (f) => OrderingTerm.asc(f.chapterId),
              (f) => OrderingTerm.asc(f.position),
            ]))
          .get();

  /// A chapter whose download is done.
  Future<DownloadChapter?> doneChapter(String chapterId) =>
      (_db.select(_db.downloadChapters)..where(
            (c) =>
                c.chapterId.equals(chapterId) &
                c.state.equalsValue(DownloadState.done),
          ))
          .getSingleOrNull();

  /// Every file of a chapter, in order.
  Future<List<DownloadFile>> files(String chapterId) =>
      (_db.select(_db.downloadFiles)
            ..where((f) => f.chapterId.equals(chapterId))
            ..orderBy([(f) => OrderingTerm.asc(f.position)]))
          .get();

  Future<void> setTask(String fileId, String? nativeTaskId) =>
      (_db.update(_db.downloadFiles)..where((f) => f.fileId.equals(fileId)))
          .write(DownloadFilesCompanion(nativeTaskId: Value(nativeTaskId)));

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
