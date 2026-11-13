import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/database/offline_cache_database.dart';
import 'package:gatuno/features/books/data/data_sources/books_local_data_source.dart';
import 'package:gatuno/features/books/data/models/author_model.dart';
import 'package:gatuno/features/books/data/models/book_model.dart';
import 'package:gatuno/features/books/data/models/chapter_model.dart';
import 'package:gatuno/features/books/data/models/tag_model.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';
import 'package:gatuno/features/books/domain/entities/book_type.dart';
import 'package:gatuno/features/books/domain/entities/chapter_page_options.dart';
import 'package:gatuno/features/books/domain/value_objects/author_id.dart';
import 'package:gatuno/features/books/domain/value_objects/author_name.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_id.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_name.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';

BookModel book(
  String id, {
  String? title,
  TypeBook? type,
  int? publication,
  DateTime? createdAt,
  DateTime? updatedAt,
  List<String> tags = const [],
  List<String> authors = const [],
  List<String> sensitive = const [],
}) => BookModel(
  id: BookId(id),
  title: BookTitle(title ?? 'Book $id'),
  type: type,
  publication: publication == null ? null : PositiveInt(publication),
  createdAt: createdAt,
  updatedAt: updatedAt,
  tags: [for (final t in tags) TagModel(id: TagId(t), name: TagName(t))],
  authors: [
    for (final a in authors) AuthorModel(id: AuthorId(a), name: AuthorName(a)),
  ],
  sensitiveContent: sensitive,
);

void main() {
  late OfflineCacheDatabase db;
  late BooksLocalDataSource local;
  late DateTime now;

  setUp(() {
    db = OfflineCacheDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 13);
    local = BooksLocalDataSource(db, now: () => now);
  });

  tearDown(() => db.close());

  Future<List<String>> ids(BookPageOptions options) async =>
      (await local.queryBooks(options))!.data.map((b) => b.id.value).toList();

  test('queryBooks is null when nothing is cached', () async {
    expect(await local.queryBooks(const BookPageOptions()), isNull);
  });

  test('a list upsert keeps relations from an earlier detail fetch', () async {
    await local.saveBook(book('1', tags: ['t1'], sensitive: ['Gore']));
    await local.saveBookList([
      book('1', title: 'Renamed'),
    ], options: const BookPageOptions());

    final cached = await local.getBook(const BookId('1'));
    expect(cached!.title.value, 'Renamed');
    expect(cached.tags.single.id.value, 't1');
    expect(cached.sensitiveContent, ['Gore']);
  });

  test('a detail fetch replaces relations', () async {
    await local.saveBook(book('1', tags: ['t1', 't2'], authors: ['a1']));
    await local.saveBook(book('1', tags: ['t2'], authors: []));

    final cached = await local.getBook(const BookId('1'));
    expect(cached!.tags.map((t) => t.id.value), ['t2']);
    expect(cached.authors, isEmpty);
  });

  group('queryBooks', () {
    setUp(() async {
      await local.saveBookList([
        book(
          '1',
          title: 'Alpha',
          type: TypeBook.manga,
          publication: 2000,
          createdAt: DateTime(2020),
          updatedAt: DateTime(2024),
        ),
        book(
          '2',
          title: 'beta',
          type: TypeBook.book,
          publication: 2010,
          createdAt: DateTime(2021),
          updatedAt: DateTime(2022),
        ),
        book(
          '3',
          title: 'Gamma',
          type: TypeBook.manga,
          publication: 2020,
          createdAt: DateTime(2022),
          updatedAt: DateTime(2023),
        ),
      ], options: const BookPageOptions());
    });

    test('orders by the requested field and direction', () async {
      expect(await ids(const BookPageOptions()), ['3', '2', '1']);
      expect(
        await ids(
          const BookPageOptions(orderBy: 'updatedAt', order: SortOrder.desc),
        ),
        ['1', '3', '2'],
      );
      expect(
        await ids(
          const BookPageOptions(orderBy: 'title', order: SortOrder.asc),
        ),
        ['1', '2', '3'],
      );
      expect(
        await ids(
          const BookPageOptions(orderBy: 'publication', order: SortOrder.asc),
        ),
        ['1', '2', '3'],
      );
    });

    test('pages with limit and page, reporting totals', () async {
      final page = await local.queryBooks(
        const BookPageOptions(limit: PositiveInt(2), page: PositiveInt(2)),
      );

      expect(page!.data.map((b) => b.id.value), ['1']);
      expect(page.total.value, 3);
      expect(page.totalPages.value, 2);
      expect(page.page.value, 2);
    });

    test('searches titles case-insensitively', () async {
      expect(await ids(const BookPageOptions(search: 'ET')), ['2']);
    });

    test('filters by type and publication', () async {
      expect(await ids(const BookPageOptions(type: [TypeBook.manga])), [
        '3',
        '1',
      ]);
      expect(
        await ids(
          const BookPageOptions(
            publication: PositiveInt(2010),
            publicationOperator: 'gte',
          ),
        ),
        ['3', '2'],
      );
      expect(await ids(const BookPageOptions(publication: PositiveInt(2010))), [
        '2',
      ]);
    });

    test('an empty match is an empty page, not a miss', () async {
      final page = await local.queryBooks(
        const BookPageOptions(search: 'nothing'),
      );
      expect(page!.data, isEmpty);
      expect(page.total.value, 0);
    });
  });

  group('tag and author filters', () {
    setUp(() async {
      await local.saveBook(book('1', tags: ['t1', 't2'], authors: ['a1']));
      await local.saveBook(book('2', tags: ['t2'], authors: ['a2']));
      // Seen only in a list: relations unknown.
      await local.saveBookList([book('3')], options: const BookPageOptions());
    });

    test('tags AND / OR', () async {
      expect(await ids(const BookPageOptions(tags: ['t1', 't2'])), ['1']);
      expect(
        await ids(
          const BookPageOptions(tags: ['t1', 't2'], tagsLogic: FilterLogic.or),
        ),
        unorderedEquals(['1', '2']),
      );
    });

    test('exclude tags OR / AND, hiding unknown books', () async {
      expect(await ids(const BookPageOptions(excludeTags: ['t1'])), ['2']);
      expect(
        await ids(
          const BookPageOptions(
            excludeTags: ['t1', 't2'],
            excludeTagsLogic: FilterLogic.and,
          ),
        ),
        ['2'],
      );
    });

    test('authors', () async {
      expect(await ids(const BookPageOptions(authors: ['a2'])), ['2']);
    });

    test(
      'books with unknown relations pass when no such filter is set',
      () async {
        expect(await ids(const BookPageOptions()), hasLength(3));
      },
    );
  });

  group('sensitive content', () {
    const safe = BookPageOptions(sensitiveContent: ['Safe']);

    test('known classification from details', () async {
      await local.saveBook(book('clean'));
      await local.saveBook(book('gore', sensitive: ['Gore']));

      expect(await ids(safe), ['clean']);
      expect(await ids(const BookPageOptions(sensitiveContent: ['gore'])), [
        'gore',
      ]);
      expect(
        await ids(const BookPageOptions(sensitiveContent: ['Safe', 'Gore'])),
        unorderedEquals(['clean', 'gore']),
      );
    });

    test('unknown classification is hidden under a sensitive filter', () async {
      await local.saveBookList([book('x')], options: const BookPageOptions());

      expect(await ids(safe), isEmpty);
      expect(
        await ids(const BookPageOptions(sensitiveContent: ['Gore'])),
        isEmpty,
      );
      expect(await ids(const BookPageOptions()), ['x']);
    });

    test('a safe-only list request flags its books safe', () async {
      await local.saveBookList([book('x')], options: safe);

      expect(await ids(safe), ['x']);
      expect(
        await ids(const BookPageOptions(sensitiveContent: ['Gore'])),
        isEmpty,
      );
    });

    test('a single-name list request links its books to that name', () async {
      await local.saveBookList([
        book('x'),
      ], options: const BookPageOptions(sensitiveContent: ['Gore']));
      await local.saveBookList([
        book('y'),
      ], options: const BookPageOptions(sensitiveContent: ['Gore', 'Nudity']));

      expect(await ids(const BookPageOptions(sensitiveContent: ['Gore'])), [
        'x',
      ]);
      expect(await ids(safe), isEmpty);
    });

    test('a detail fetch overrides list provenance', () async {
      await local.saveBookList([book('x')], options: safe);
      await local.saveBook(book('x', sensitive: ['Gore']));

      expect(await ids(safe), isEmpty);
    });
  });

  group('chapters', () {
    final chapters = [
      ChapterModel(id: const ChapterId('c2'), index: const ChapterIndex(2)),
      ChapterModel(id: const ChapterId('c1'), index: const ChapterIndex(1)),
    ];

    test('returns every cached chapter in the requested order', () async {
      await local.saveChapters(const BookId('1'), chapters);

      final asc = await local.getChapters(
        const BookId('1'),
        const ChapterPageOptions(),
      );
      final desc = await local.getChapters(
        const BookId('1'),
        const ChapterPageOptions(order: ChapterSortOrder.desc),
      );

      expect(asc!.data.map((c) => c.id.value), ['c1', 'c2']);
      expect(asc.hasNextPage, isFalse);
      expect(desc!.data.map((c) => c.id.value), ['c2', 'c1']);
    });

    test('a later cursor page is empty; an unknown book is a miss', () async {
      await local.saveChapters(const BookId('1'), chapters);

      final next = await local.getChapters(
        const BookId('1'),
        const ChapterPageOptions(cursor: 'abc'),
      );
      expect(next!.data, isEmpty);
      expect(
        await local.getChapters(const BookId('2'), const ChapterPageOptions()),
        isNull,
      );
    });
  });

  test('tags and authors: null until cached, then sorted by name', () async {
    expect(await local.getTags(), isNull);
    expect(await local.getAuthors(), isNull);

    await local.saveTags([
      TagModel(id: const TagId('2'), name: const TagName('Zeta')),
      TagModel(id: const TagId('1'), name: const TagName('Alpha')),
    ]);
    await local.saveAuthors([
      AuthorModel(id: const AuthorId('a'), name: const AuthorName('Oda')),
    ]);

    expect((await local.getTags())!.map((t) => t.name.value), [
      'Alpha',
      'Zeta',
    ]);
    expect((await local.getAuthors())!.single.name.value, 'Oda');
  });
}
