import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/entities/download_state.dart';

part 'downloads_database.g.dart';

/// A book with at least one chapter download.
class DownloadBooks extends Table {
  TextColumn get bookId => text()();

  /// `BookType.value`, for the network rule; `other` when unknown.
  TextColumn get bookType => text()();

  DateTimeColumn get enqueuedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {bookId};
}

/// The download of one chapter.
@TableIndex(name: 'idx_download_chapters_book', columns: {#bookId})
@TableIndex(name: 'idx_download_chapters_state', columns: {#state})
class DownloadChapters extends Table {
  TextColumn get chapterId => text()();
  TextColumn get bookId => text()();

  TextColumn get state => textEnum<DownloadState>()();

  /// A `DownloadErrors` code while failed.
  TextColumn get error => text().nullable()();

  /// The manifest is stored and every file has a row in [DownloadFiles].
  BoolColumn get planned => boolean().withDefault(const Constant(false))();

  /// Bytes of the stored manifest.
  IntColumn get manifestBytes => integer().withDefault(const Constant(0))();

  /// FIFO order of the queue.
  DateTimeColumn get enqueuedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {chapterId};
}

/// One file of a planned chapter: a page image or the document.
@TableIndex(name: 'idx_download_files_chapter', columns: {#chapterId})
@TableIndex(name: 'idx_download_files_task', columns: {#nativeTaskId})
class DownloadFiles extends Table {
  /// `<chapterId>/<position>`.
  TextColumn get fileId => text()();
  TextColumn get chapterId => text()();

  /// Page order; 0 for a document.
  IntColumn get position => integer()();

  /// Absolute URL on the server.
  TextColumn get url => text()();

  /// Path relative to the chapter's directory.
  TextColumn get relativePath => text()();

  /// The native task of the current attempt; `null` when none is queued.
  /// Events of any other task id are stale and ignored.
  TextColumn get nativeTaskId => text().nullable()();

  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get bytes => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {fileId};
}

/// Download records. User data with its own lifecycle, apart from the
/// rebuildable offline cache; wiped only when the server changes.
@DriftDatabase(tables: [DownloadBooks, DownloadChapters, DownloadFiles])
class DownloadsDatabase extends _$DownloadsDatabase {
  DownloadsDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'downloads'));

  @override
  int get schemaVersion => 1;

  Future<void> clearAll() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });
}
