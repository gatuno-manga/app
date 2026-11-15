import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../../reading/domain/entities/reading_enums.dart';
import '../../domain/entities/download_state.dart';

part 'downloads_database.g.dart';

/// A book with at least one chapter download, or with automatic download of
/// new chapters turned on.
class DownloadBooks extends Table {
  TextColumn get bookId => text()();

  /// For the network rule; `other` until the book's details are known.
  TextColumn get bookType => textEnum<BookType>()();

  DateTimeColumn get enqueuedAt => dateTime()();

  /// When automatic download of new chapters was turned on; `null` while it
  /// is off. A row with it set outlives its last chapter.
  DateTimeColumn get autoDownloadSince => dateTime().nullable()();

  /// The [autoDownloadSince] whose chapters [AutoDownloadSeen] holds as the
  /// baseline; a different value (or `null`) means the next check records a
  /// new baseline instead of queueing.
  DateTimeColumn get autoDownloadBaselineFor => dateTime().nullable()();

  /// When the new-chapter check last read this book; the least recent go
  /// first.
  DateTimeColumn get autoDownloadCheckedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {bookId};
}

/// A chapter the new-chapter check has seen for a book with automatic
/// download on: one that existed when it was turned on, or one queued (or
/// found downloaded) since. Never queued again.
class AutoDownloadSeen extends Table {
  TextColumn get bookId => text()();
  TextColumn get chapterId => text()();

  @override
  Set<Column> get primaryKey => {bookId, chapterId};
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
// The readers look a page or document up by its URL.
@TableIndex(name: 'idx_download_files_url', columns: {#url})
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

  /// Whether the current task was queued for Wi-Fi only, so a rule change
  /// requeues exactly the files queued under another rule.
  BoolColumn get queuedOnWifi => boolean().withDefault(const Constant(false))();

  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get bytes => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {fileId};
}

/// Download records. User data with its own lifecycle, apart from the
/// rebuildable offline cache; wiped only when the server changes.
@DriftDatabase(
  tables: [DownloadBooks, DownloadChapters, DownloadFiles, AutoDownloadSeen],
)
class DownloadsDatabase extends _$DownloadsDatabase {
  DownloadsDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'downloads'));

  @override
  int get schemaVersion => 4;

  /// Each step stands alone, so steps added later stack on it.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createIndex(idxDownloadFilesUrl);
      if (from < 3) {
        await m.addColumn(downloadBooks, downloadBooks.autoDownloadSince);
      }
      if (from < 4) {
        await m.addColumn(downloadBooks, downloadBooks.autoDownloadBaselineFor);
        await m.addColumn(downloadBooks, downloadBooks.autoDownloadCheckedAt);
        await m.createTable(autoDownloadSeen);
      }
    },
  );

  Future<void> clearAll() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });
}
