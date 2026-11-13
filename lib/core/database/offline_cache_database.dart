import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'offline_cache_database.g.dart';

/// A book seen online, one typed column per field.
///
/// List responses carry no tags, authors or sensitive content, so those
/// relations are only trusted once [relationsKnown] is set by a detail fetch.
@TableIndex(name: 'idx_cached_books_cover', columns: {#cover})
@TableIndex(name: 'idx_cached_books_accessed', columns: {#lastAccessedAt})
class CachedBooks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get cover => text().nullable()();
  TextColumn get type => text().nullable()();
  IntColumn get publication => integer().nullable()();
  IntColumn get totalChapters => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  RealColumn get coverWidth => real().nullable()();
  RealColumn get coverHeight => real().nullable()();
  IntColumn get coverSizeBytes => integer().nullable()();
  TextColumn get coverMimeType => text().nullable()();
  TextColumn get coverBlurHash => text().nullable()();
  TextColumn get coverDominantColor => text().nullable()();
  TextColumn get coverPHash => text().nullable()();
  RealColumn get coverEntropy => real().nullable()();
  TextColumn get coverFormatOrigin => text().nullable()();

  /// Tags, authors and sensitive content come from a detail response.
  BoolColumn get relationsKnown =>
      boolean().withDefault(const Constant(false))();

  /// Returned by a list request that asked for safe books only. List items
  /// carry no sensitive content, so this is how a book never opened in
  /// detail can still pass the offline "safe" filter.
  BoolColumn get seenAsSafe => boolean().withDefault(const Constant(false))();

  DateTimeColumn get cachedAt => dateTime()();

  /// Last read or write; drives the 90-day eviction.
  DateTimeColumn get lastAccessedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedAuthors extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedTags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_cached_book_authors_author', columns: {#authorId})
class CachedBookAuthors extends Table {
  TextColumn get bookId => text()();
  TextColumn get authorId => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {bookId, authorId};
}

@TableIndex(name: 'idx_cached_book_tags_tag', columns: {#tagId})
class CachedBookTags extends Table {
  TextColumn get bookId => text()();
  TextColumn get tagId => text()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {bookId, tagId};
}

/// Sensitive-content names of a book, from its detail response.
class CachedBookSensitiveContents extends Table {
  TextColumn get bookId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {bookId, name};
}

/// A sensitive-content name a book is known to carry because a list request
/// filtered on that name alone returned it. Used only while the book's own
/// classification is unknown ([CachedBooks.relationsKnown] false).
class CachedBookSensitiveProvenance extends Table {
  TextColumn get bookId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {bookId, name};
}

@TableIndex(name: 'idx_cached_chapters_book', columns: {#bookId})
class CachedChapters extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  TextColumn get title => text().nullable()();
  RealColumn get chapterIndex => real()();
  TextColumn get scrapingStatus => text().nullable()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get lastPage => integer().withDefault(const Constant(0))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A cover file kept on disk for a book.
class CachedCovers extends Table {
  TextColumn get bookId => text()();
  TextColumn get sourceUrl => text()();
  TextColumn get filePath => text()();
  IntColumn get bytes => integer()();
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get lastUsedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {bookId};
}

/// Keeps a book's cover, and its cached row, from being evicted while any
/// owner (for example `download`) holds it.
class CoverPins extends Table {
  TextColumn get bookId => text()();
  TextColumn get owner => text()();

  @override
  Set<Column> get primaryKey => {bookId, owner};
}

/// Local copy of server data for offline use. Separate from the reading
/// database: everything here can be rebuilt from the server and is wiped when
/// the server changes.
@DriftDatabase(
  tables: [
    CachedBooks,
    CachedAuthors,
    CachedTags,
    CachedBookAuthors,
    CachedBookTags,
    CachedBookSensitiveContents,
    CachedBookSensitiveProvenance,
    CachedChapters,
    CachedCovers,
    CoverPins,
  ],
)
class OfflineCacheDatabase extends _$OfflineCacheDatabase {
  OfflineCacheDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'offline_cache'));

  @override
  int get schemaVersion => 1;

  /// Deletes books not read or written since [cutoff], with their chapters
  /// and relations, except books whose cover is pinned (downloads). Returns
  /// the evicted ids, so their cover files can be deleted too.
  Future<List<String>> evictBooksNotAccessedSince(DateTime cutoff) {
    // Select and delete in one transaction: a book refreshed between the two
    // (a screen loading at start) must not be deleted with a stale verdict.
    return transaction(() async {
      final pinned = selectOnly(coverPins)..addColumns([coverPins.bookId]);
      final stale =
          await (selectOnly(cachedBooks)
                ..addColumns([cachedBooks.id])
                ..where(
                  cachedBooks.lastAccessedAt.isSmallerThanValue(cutoff) &
                      cachedBooks.id.isNotInQuery(pinned),
                ))
              .map((r) => r.read(cachedBooks.id)!)
              .get();
      if (stale.isEmpty) return stale;

      await (delete(
        cachedBookAuthors,
      )..where((r) => r.bookId.isIn(stale))).go();
      await (delete(cachedBookTags)..where((r) => r.bookId.isIn(stale))).go();
      await (delete(
        cachedBookSensitiveContents,
      )..where((r) => r.bookId.isIn(stale))).go();
      await (delete(
        cachedBookSensitiveProvenance,
      )..where((r) => r.bookId.isIn(stale))).go();
      await (delete(cachedChapters)..where((r) => r.bookId.isIn(stale))).go();
      await (delete(cachedBooks)..where((r) => r.id.isIn(stale))).go();
      return stale;
    });
  }

  /// Deletes every cached row. Cover files are removed by the cover store.
  Future<void> clearAll() => transaction(() async {
    for (final table in allTables) {
      await delete(table).go();
    }
  });
}
