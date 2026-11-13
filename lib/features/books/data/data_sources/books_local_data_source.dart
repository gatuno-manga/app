import 'package:drift/drift.dart';

import 'book_query_filter.dart';
import 'cached_book_mapper.dart';

import '../../../../core/database/offline_cache_database.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_page_options.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/chapter_page_options.dart';
import '../../domain/entities/tag.dart';
import '../../domain/value_objects/author_id.dart';
import '../../domain/value_objects/author_name.dart';
import '../../domain/value_objects/book_id.dart';
import '../../domain/value_objects/tag_id.dart';
import '../../domain/value_objects/tag_name.dart';
import '../models/author_model.dart';
import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../models/tag_model.dart';

/// Books, chapters, tags and authors cached in [OfflineCacheDatabase].
///
/// Offline, [queryBooks] answers any [BookPageOptions] over the books this
/// device has seen, mirroring the server's filters. List responses carry no
/// tags, authors or sensitive content, so a book whose relations are unknown
/// never passes a filter on them: hiding it is safer than guessing.
class BooksLocalDataSource {
  final OfflineCacheDatabase _db;
  final DateTime Function() _now;

  final CachedBookMapper _mapper;
  final BookQueryFilter _query;

  BooksLocalDataSource(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      _mapper = CachedBookMapper(_db),
      _query = BookQueryFilter(_db);

  // Books -------------------------------------------------------------------

  /// Upserts list items. Relations from an earlier detail fetch are kept (an
  /// empty list in a list item means "not sent"), and so is any field the
  /// list item leaves empty while the stored row has it.
  Future<void> saveBookList(
    List<Book> books, {
    required BookPageOptions options,
  }) async {
    final seenAsSafe = _isSafeOnly(options.sensitiveContent);
    final provenName = _singleName(options.sensitiveContent);
    final now = _now();
    await _db.batch((batch) {
      for (final book in books) {
        batch.insert(
          _db.cachedBooks,
          _bookCompanion(book, now).copyWith(seenAsSafe: Value(seenAsSafe)),
          onConflict: DoUpdate<$CachedBooksTable, CachedBook>.withExcluded(
            (old, excluded) => _mergeListItem(old, excluded, seenAsSafe),
            target: [_db.cachedBooks.id],
          ),
        );
        if (provenName != null) {
          batch.insert(
            _db.cachedBookSensitiveProvenance,
            CachedBookSensitiveProvenanceCompanion.insert(
              bookId: book.id.value,
              name: provenName,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
    });
  }

  /// The update half of a list upsert: new values win, a missing one keeps
  /// the stored value, and `seenAsSafe` only ever turns on.
  Insertable<CachedBook> _mergeListItem(
    $CachedBooksTable old,
    $CachedBooksTable excluded,
    bool seenAsSafe,
  ) {
    Expression<T> keep<T extends Object>(
      Expression<T> Function($CachedBooksTable) column,
    ) => coalesce([column(excluded), column(old)]);

    return CachedBooksCompanion.custom(
      title: excluded.title,
      description: keep((t) => t.description),
      cover: keep((t) => t.cover),
      type: keep((t) => t.type),
      publication: keep((t) => t.publication),
      totalChapters: keep((t) => t.totalChapters),
      createdAt: keep((t) => t.createdAt),
      updatedAt: keep((t) => t.updatedAt),
      coverWidth: keep((t) => t.coverWidth),
      coverHeight: keep((t) => t.coverHeight),
      coverSizeBytes: keep((t) => t.coverSizeBytes),
      coverMimeType: keep((t) => t.coverMimeType),
      coverBlurHash: keep((t) => t.coverBlurHash),
      coverDominantColor: keep((t) => t.coverDominantColor),
      coverPHash: keep((t) => t.coverPHash),
      coverEntropy: keep((t) => t.coverEntropy),
      coverFormatOrigin: keep((t) => t.coverFormatOrigin),
      seenAsSafe: seenAsSafe ? const Constant(true) : null,
      cachedAt: excluded.cachedAt,
      lastAccessedAt: excluded.lastAccessedAt,
    );
  }

  /// Upserts a book from a detail response, replacing its relations.
  Future<void> saveBook(Book book) async {
    final now = _now();
    final id = book.id.value;
    await _db.transaction(() async {
      final companion = _bookCompanion(
        book,
        now,
      ).copyWith(relationsKnown: const Value(true));
      await _db
          .into(_db.cachedBooks)
          .insert(
            companion,
            onConflict: DoUpdate(
              (_) => companion,
              target: [_db.cachedBooks.id],
            ),
          );

      await _upsertAuthors(book.authors);
      await _upsertTags(book.tags);

      await (_db.delete(
        _db.cachedBookAuthors,
      )..where((r) => r.bookId.equals(id))).go();
      await (_db.delete(
        _db.cachedBookTags,
      )..where((r) => r.bookId.equals(id))).go();
      await (_db.delete(
        _db.cachedBookSensitiveContents,
      )..where((r) => r.bookId.equals(id))).go();

      await _db.batch((batch) {
        batch.insertAll(_db.cachedBookAuthors, [
          for (final (i, author) in book.authors.indexed)
            CachedBookAuthorsCompanion.insert(
              bookId: id,
              authorId: author.id.value,
              position: i,
            ),
        ], mode: InsertMode.insertOrIgnore);
        batch.insertAll(_db.cachedBookTags, [
          for (final (i, tag) in book.tags.indexed)
            CachedBookTagsCompanion.insert(
              bookId: id,
              tagId: tag.id.value,
              position: i,
            ),
        ], mode: InsertMode.insertOrIgnore);
        batch.insertAll(_db.cachedBookSensitiveContents, [
          for (final name in book.sensitiveContent)
            CachedBookSensitiveContentsCompanion.insert(bookId: id, name: name),
        ], mode: InsertMode.insertOrIgnore);
      });
    });
  }

  /// The cached book, or `null` when it was never seen.
  Future<Book?> getBook(BookId bookId) async {
    final row = await (_db.select(
      _db.cachedBooks,
    )..where((b) => b.id.equals(bookId.value))).getSingleOrNull();
    if (row == null) return null;
    await _touch([row.id]);
    return (await _mapper.toBooks([row])).single;
  }

  /// Answers [options] from the cached books. `null` when nothing is cached
  /// at all, so the caller can tell "not saved" from "no match".
  Future<BookList?> queryBooks(BookPageOptions options) async {
    final anyBook =
        await (_db.selectOnly(_db.cachedBooks)
              ..addColumns([_db.cachedBooks.id])
              ..limit(1))
            .getSingleOrNull();
    if (anyBook == null) return null;

    final where = _query.where(options);
    final count = countAll();
    final countQuery = _db.selectOnly(_db.cachedBooks)
      ..addColumns([count])
      ..where(where);
    final total = (await countQuery.getSingle()).read(count) ?? 0;

    final limit = options.limit.value;
    final page = options.page.value < 1 ? 1 : options.page.value;
    final rows =
        await (_db.select(_db.cachedBooks)
              ..where((_) => where)
              ..orderBy([
                _query.ordering(options),
                (b) => OrderingTerm.asc(b.id),
              ])
              ..limit(limit, offset: (page - 1) * limit))
            .get();
    await _touch(rows.map((r) => r.id));

    return BookListModel(
      data: await _mapper.toBooks(rows),
      total: PositiveInt(total),
      page: PositiveInt(page),
      limit: PositiveInt(limit),
      totalPages: PositiveInt(limit == 0 ? 0 : (total / limit).ceil()),
    );
  }

  // Chapters ----------------------------------------------------------------

  /// Upserts [chapters]. With [complete] (the response held every chapter of
  /// the book), chapters the server no longer lists are dropped too.
  Future<void> saveChapters(
    BookId bookId,
    List<Chapter> chapters, {
    bool complete = false,
  }) async {
    final now = _now();
    await _db.batch((batch) {
      if (complete) {
        batch.deleteWhere(
          _db.cachedChapters,
          (c) =>
              c.bookId.equals(bookId.value) &
              c.id.isNotIn(chapters.map((ch) => ch.id.value)),
        );
      }
      batch.insertAllOnConflictUpdate(_db.cachedChapters, [
        for (final chapter in chapters)
          CachedChaptersCompanion.insert(
            id: chapter.id.value,
            bookId: bookId.value,
            title: Value(chapter.title?.value),
            chapterIndex: chapter.index.value,
            scrapingStatus: Value(chapter.scrapingStatus?.name),
            read: Value(chapter.read),
            completed: Value(chapter.completed),
            lastPage: Value(chapter.lastPage.value),
            cachedAt: now,
          ),
      ]);
    });
  }

  /// Every cached chapter of [bookId] in one page: the server pages with a
  /// cursor, so a later page ([ChapterPageOptions.cursor] set) is empty.
  /// `null` when no chapter of the book is cached.
  Future<ChapterList?> getChapters(
    BookId bookId,
    ChapterPageOptions options,
  ) async {
    final rows =
        await (_db.select(_db.cachedChapters)
              ..where((c) => c.bookId.equals(bookId.value))
              ..orderBy([
                (c) => OrderingTerm(
                  expression: c.chapterIndex,
                  mode: options.order == ChapterSortOrder.desc
                      ? OrderingMode.desc
                      : OrderingMode.asc,
                ),
              ]))
            .get();
    if (rows.isEmpty) return null;
    if (options.cursor != null) {
      return const ChapterListModel(data: [], hasNextPage: false);
    }
    return ChapterListModel(
      data: [for (final row in rows) _mapper.toChapter(row)],
      hasNextPage: false,
    );
  }

  // Tags and authors --------------------------------------------------------

  Future<void> saveTags(List<Tag> tags) => _upsertTags(tags);

  Future<void> saveAuthors(List<Author> authors) => _upsertAuthors(authors);

  /// `null` when no tag is cached.
  Future<List<Tag>?> getTags() async {
    final rows = await (_db.select(
      _db.cachedTags,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    if (rows.isEmpty) return null;
    return [
      for (final row in rows)
        TagModel(id: TagId(row.id), name: TagName(row.name)),
    ];
  }

  /// `null` when no author is cached.
  Future<List<Author>?> getAuthors() async {
    final rows = await (_db.select(
      _db.cachedAuthors,
    )..orderBy([(a) => OrderingTerm.asc(a.name)])).get();
    if (rows.isEmpty) return null;
    return [
      for (final row in rows)
        AuthorModel(id: AuthorId(row.id), name: AuthorName(row.name)),
    ];
  }

  // Internals ---------------------------------------------------------------

  Future<void> _upsertTags(List<Tag> tags) async {
    if (tags.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.cachedTags, [
        for (final tag in tags)
          CachedTagsCompanion.insert(id: tag.id.value, name: tag.name.value),
      ]);
    });
  }

  Future<void> _upsertAuthors(List<Author> authors) async {
    if (authors.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.cachedAuthors, [
        for (final author in authors)
          CachedAuthorsCompanion.insert(
            id: author.id.value,
            name: author.name.value,
          ),
      ]);
    });
  }

  Future<void> _touch(Iterable<String> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return;
    await (_db.update(_db.cachedBooks)..where((b) => b.id.isIn(list))).write(
      CachedBooksCompanion(lastAccessedAt: Value(_now())),
    );
  }

  CachedBooksCompanion _bookCompanion(Book book, DateTime now) {
    final metadata = book.metadata;
    return CachedBooksCompanion.insert(
      id: book.id.value,
      title: book.title.value,
      description: Value(book.description?.value),
      cover: Value(book.cover?.value),
      type: Value(book.type?.name),
      publication: Value(book.publication?.value),
      totalChapters: Value(book.totalChapters?.value),
      createdAt: Value(book.createdAt),
      updatedAt: Value(book.updatedAt),
      coverWidth: Value(metadata?.width),
      coverHeight: Value(metadata?.height),
      coverSizeBytes: Value(metadata?.sizeBytes),
      coverMimeType: Value(metadata?.mimeType),
      coverBlurHash: Value(metadata?.blurHash),
      coverDominantColor: Value(metadata?.dominantColor),
      coverPHash: Value(metadata?.pHash),
      coverEntropy: Value(metadata?.entropy),
      coverFormatOrigin: Value(metadata?.formatOrigin),
      cachedAt: now,
      lastAccessedAt: now,
    );
  }

  /// The name a request filtered on when it asked for exactly one
  /// classification and not "safe": every book it returned carries that name.
  /// With several names a book carries at least one of them, but not which,
  /// so nothing is recorded.
  static String? _singleName(List<String>? sensitiveContent) {
    if (sensitiveContent == null || sensitiveContent.length != 1) return null;
    final value = sensitiveContent.single;
    return BookQueryFilter.safeValues.contains(value.toLowerCase())
        ? null
        : value;
  }

  static bool _isSafeOnly(List<String>? sensitiveContent) =>
      sensitiveContent != null &&
      sensitiveContent.isNotEmpty &&
      sensitiveContent.every(
        (v) => BookQueryFilter.safeValues.contains(v.toLowerCase()),
      );
}
