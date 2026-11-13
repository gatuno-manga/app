import 'package:drift/drift.dart';

import '../../../../core/database/offline_cache_database.dart';
import '../../../../shared/data/models/image_metadata_model.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_page_options.dart';
import '../../domain/entities/book_type.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/chapter_page_options.dart';
import '../../domain/entities/tag.dart';
import '../../domain/value_objects/author_id.dart';
import '../../domain/value_objects/author_name.dart';
import '../../domain/value_objects/book_cover.dart';
import '../../domain/value_objects/book_description.dart';
import '../../domain/value_objects/book_id.dart';
import '../../domain/value_objects/book_title.dart';
import '../../domain/value_objects/chapter_id.dart';
import '../../domain/value_objects/chapter_index.dart';
import '../../domain/value_objects/chapter_title.dart';
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

  /// The `sensitiveContent` values the server reads as "no classification".
  static const Set<String> _safeValues = {'safe', '0'};

  BooksLocalDataSource(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  // Books -------------------------------------------------------------------

  /// Upserts the scalar fields of list items. Relations from an earlier detail
  /// fetch are kept: an empty list in a list item means "not sent".
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
          _bookCompanion(book, now),
          onConflict: DoUpdate(
            (_) => _bookCompanion(book, now),
            target: [_db.cachedBooks.id],
          ),
        );
        if (seenAsSafe) {
          batch.update(
            _db.cachedBooks,
            const CachedBooksCompanion(seenAsSafe: Value(true)),
            where: (b) => b.id.equals(book.id.value),
          );
        }
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
    return (await _toBooks([row])).single;
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

    final where = _filters(options);
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
              ..orderBy([_ordering(options), (b) => OrderingTerm.asc(b.id)])
              ..limit(limit, offset: (page - 1) * limit))
            .get();
    await _touch(rows.map((r) => r.id));

    return BookListModel(
      data: await _toBooks(rows),
      total: PositiveInt(total),
      page: PositiveInt(page),
      limit: PositiveInt(limit),
      totalPages: PositiveInt(limit == 0 ? 0 : (total / limit).ceil()),
    );
  }

  // Chapters ----------------------------------------------------------------

  Future<void> saveChapters(BookId bookId, List<Chapter> chapters) async {
    final now = _now();
    await _db.batch((batch) {
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
      data: [for (final row in rows) _toChapter(row)],
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

  Future<List<Book>> _toBooks(List<CachedBook> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();

    final authorRows =
        await (_db.select(_db.cachedBookAuthors).join([
                innerJoin(
                  _db.cachedAuthors,
                  _db.cachedAuthors.id.equalsExp(
                    _db.cachedBookAuthors.authorId,
                  ),
                ),
              ])
              ..where(_db.cachedBookAuthors.bookId.isIn(ids))
              ..orderBy([OrderingTerm.asc(_db.cachedBookAuthors.position)]))
            .get();
    final tagRows =
        await (_db.select(_db.cachedBookTags).join([
                innerJoin(
                  _db.cachedTags,
                  _db.cachedTags.id.equalsExp(_db.cachedBookTags.tagId),
                ),
              ])
              ..where(_db.cachedBookTags.bookId.isIn(ids))
              ..orderBy([OrderingTerm.asc(_db.cachedBookTags.position)]))
            .get();
    final sensitiveRows = await (_db.select(
      _db.cachedBookSensitiveContents,
    )..where((r) => r.bookId.isIn(ids))).get();

    final authors = <String, List<Author>>{};
    for (final row in authorRows) {
      final author = row.readTable(_db.cachedAuthors);
      authors
          .putIfAbsent(row.readTable(_db.cachedBookAuthors).bookId, () => [])
          .add(
            AuthorModel(id: AuthorId(author.id), name: AuthorName(author.name)),
          );
    }
    final tags = <String, List<Tag>>{};
    for (final row in tagRows) {
      final tag = row.readTable(_db.cachedTags);
      tags
          .putIfAbsent(row.readTable(_db.cachedBookTags).bookId, () => [])
          .add(TagModel(id: TagId(tag.id), name: TagName(tag.name)));
    }
    final sensitive = <String, List<String>>{};
    for (final row in sensitiveRows) {
      sensitive.putIfAbsent(row.bookId, () => []).add(row.name);
    }

    return [
      for (final row in rows)
        _toBook(
          row,
          authors: authors[row.id] ?? const [],
          tags: tags[row.id] ?? const [],
          sensitiveContent: sensitive[row.id] ?? const [],
        ),
    ];
  }

  BookModel _toBook(
    CachedBook row, {
    required List<Author> authors,
    required List<Tag> tags,
    required List<String> sensitiveContent,
  }) {
    final width = row.coverWidth;
    final height = row.coverHeight;
    return BookModel(
      id: BookId(row.id),
      title: BookTitle(row.title),
      authors: authors,
      tags: tags,
      description: row.description == null
          ? null
          : BookDescription(row.description!),
      cover: row.cover == null ? null : BookCover(row.cover!),
      imageMetadata: width == null || height == null
          ? null
          : ImageMetadataModel(
              width: width,
              height: height,
              sizeBytes: row.coverSizeBytes,
              mimeType: row.coverMimeType,
              blurHash: row.coverBlurHash,
              dominantColor: row.coverDominantColor,
              pHash: row.coverPHash,
              entropy: row.coverEntropy,
              formatOrigin: row.coverFormatOrigin,
            ),
      type: _typeFromName(row.type),
      publication: row.publication == null
          ? null
          : PositiveInt(row.publication!),
      totalChapters: row.totalChapters == null
          ? null
          : PositiveInt(row.totalChapters!),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      sensitiveContent: sensitiveContent,
    );
  }

  ChapterModel _toChapter(CachedChapter row) {
    return ChapterModel(
      id: ChapterId(row.id),
      title: row.title == null ? null : ChapterTitle(row.title!),
      index: ChapterIndex(row.chapterIndex),
      scrapingStatus: _statusFromName(row.scrapingStatus),
      read: row.read,
      completed: row.completed,
      lastPage: PositiveInt(row.lastPage),
    );
  }

  static TypeBook? _typeFromName(String? name) {
    if (name == null) return null;
    for (final type in TypeBook.values) {
      if (type.name == name) return type;
    }
    return TypeBook.other;
  }

  static ScrapingStatus? _statusFromName(String? name) {
    if (name == null) return null;
    for (final status in ScrapingStatus.values) {
      if (status.name == name) return status;
    }
    return null;
  }

  /// The name a request filtered on when it asked for exactly one
  /// classification and not "safe": every book it returned carries that name.
  /// With several names a book carries at least one of them, but not which,
  /// so nothing is recorded.
  static String? _singleName(List<String>? sensitiveContent) {
    if (sensitiveContent == null || sensitiveContent.length != 1) return null;
    final value = sensitiveContent.single;
    return _safeValues.contains(value.toLowerCase()) ? null : value;
  }

  static bool _isSafeOnly(List<String>? sensitiveContent) =>
      sensitiveContent != null &&
      sensitiveContent.isNotEmpty &&
      sensitiveContent.every((v) => _safeValues.contains(v.toLowerCase()));

  // Query translation -------------------------------------------------------

  OrderingTerm Function($CachedBooksTable) _ordering(BookPageOptions options) {
    final mode = options.order == SortOrder.asc
        ? OrderingMode.asc
        : OrderingMode.desc;
    return (b) {
      final Expression<Object> column = switch (options.orderBy) {
        'updatedAt' => b.updatedAt,
        'title' => b.title.lower(),
        'publication' => b.publication,
        _ => b.createdAt,
      };
      return OrderingTerm(expression: column, mode: mode);
    };
  }

  Expression<bool> _filters(BookPageOptions options) {
    final b = _db.cachedBooks;
    final conditions = <Expression<bool>>[];

    final search = options.search?.trim();
    if (search != null && search.isNotEmpty) {
      conditions.add(b.title.lower().like('%${search.toLowerCase()}%'));
    }

    final types = options.type;
    if (types != null && types.isNotEmpty) {
      conditions.add(b.type.isIn(types.map((t) => t.name)));
    }

    final publication = options.publication?.value;
    if (publication != null) {
      conditions.add(switch (options.publicationOperator) {
        'gt' => b.publication.isBiggerThanValue(publication),
        'lt' => b.publication.isSmallerThanValue(publication),
        'gte' => b.publication.isBiggerOrEqualValue(publication),
        'lte' => b.publication.isSmallerOrEqualValue(publication),
        _ => b.publication.equals(publication),
      });
    }

    final tags = options.tags;
    if (tags != null && tags.isNotEmpty) {
      conditions.add(
        b.relationsKnown.equals(true) &
            _matchAll(
              tags.map(_hasTag),
              all: (options.tagsLogic ?? FilterLogic.and) == FilterLogic.and,
            ),
      );
    }

    final excludeTags = options.excludeTags;
    if (excludeTags != null && excludeTags.isNotEmpty) {
      conditions.add(
        b.relationsKnown.equals(true) &
            _matchAll(
              excludeTags.map(_hasTag),
              all:
                  (options.excludeTagsLogic ?? FilterLogic.or) ==
                  FilterLogic.and,
            ).not(),
      );
    }

    final authors = options.authors;
    if (authors != null && authors.isNotEmpty) {
      conditions.add(
        b.relationsKnown.equals(true) &
            _matchAll(
              authors.map(_hasAuthor),
              all: (options.authorsLogic ?? FilterLogic.and) == FilterLogic.and,
            ),
      );
    }

    final sensitive = options.sensitiveContent;
    if (sensitive != null && sensitive.isNotEmpty) {
      conditions.add(_sensitiveFilter(sensitive));
    }

    return conditions.isEmpty
        ? const Constant(true)
        : conditions.reduce((a, c) => a & c);
  }

  /// Mirrors the server: a book passes when it has any of the named
  /// classifications, or, when "safe" is asked, none at all. A book whose
  /// classification is unknown passes "safe" only if a safe-only list request
  /// returned it.
  Expression<bool> _sensitiveFilter(List<String> values) {
    final b = _db.cachedBooks;
    final names = [
      for (final v in values)
        if (!_safeValues.contains(v.toLowerCase())) v.toLowerCase(),
    ];
    final wantsSafe = names.length < values.length;
    final options = <Expression<bool>>[];

    if (names.isNotEmpty) {
      final s = _db.cachedBookSensitiveContents;
      final p = _db.cachedBookSensitiveProvenance;
      options.add(
        (b.relationsKnown.equals(true) &
                existsQuery(
                  _db.selectOnly(s)
                    ..addColumns([s.name])
                    ..where(
                      s.bookId.equalsExp(b.id) & s.name.lower().isIn(names),
                    ),
                )) |
            (b.relationsKnown.equals(false) &
                existsQuery(
                  _db.selectOnly(p)
                    ..addColumns([p.name])
                    ..where(
                      p.bookId.equalsExp(b.id) & p.name.lower().isIn(names),
                    ),
                )),
      );
    }
    if (wantsSafe) {
      final s = _db.cachedBookSensitiveContents;
      final hasNone = notExistsQuery(
        _db.selectOnly(s)
          ..addColumns([s.name])
          ..where(s.bookId.equalsExp(b.id)),
      );
      options.add(
        (b.relationsKnown.equals(true) & hasNone) |
            (b.relationsKnown.equals(false) & b.seenAsSafe.equals(true)),
      );
    }
    return options.reduce((a, c) => a | c);
  }

  Expression<bool> _matchAll(
    Iterable<Expression<bool>> each, {
    required bool all,
  }) => each.reduce((a, c) => all ? a & c : a | c);

  Expression<bool> _hasTag(String tagId) {
    final t = _db.cachedBookTags;
    return existsQuery(
      _db.selectOnly(t)
        ..addColumns([t.tagId])
        ..where(t.bookId.equalsExp(_db.cachedBooks.id) & t.tagId.equals(tagId)),
    );
  }

  Expression<bool> _hasAuthor(String authorId) {
    final a = _db.cachedBookAuthors;
    return existsQuery(
      _db.selectOnly(a)
        ..addColumns([a.authorId])
        ..where(
          a.bookId.equalsExp(_db.cachedBooks.id) & a.authorId.equals(authorId),
        ),
    );
  }
}
