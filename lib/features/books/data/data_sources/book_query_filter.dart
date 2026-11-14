import 'package:drift/drift.dart';

import '../../../../core/database/offline_cache_database.dart';
import '../../domain/entities/book_page_options.dart';

/// Translates [BookPageOptions] into a query over the cached books, mirroring
/// the server's filters.
///
/// List responses carry no tags, authors or sensitive content, so a book whose
/// relations are unknown never passes a filter on them: hiding it is safer
/// than guessing.
class BookQueryFilter {
  final OfflineCacheDatabase _db;

  /// The `sensitiveContent` values the server reads as "no classification".
  static const Set<String> safeValues = {'safe', '0'};

  BookQueryFilter(this._db);

  OrderingTerm Function($CachedBooksTable) ordering(BookPageOptions options) {
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

  Expression<bool> where(BookPageOptions options) {
    final b = _db.cachedBooks;
    final conditions = <Expression<bool>>[];

    final search = options.search?.trim();
    if (search != null && search.isNotEmpty) {
      conditions.add(
        b.title.lower().like(
          '%${_escapeLike(search.toLowerCase())}%',
          escapeChar: r'\',
        ),
      );
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
        if (!safeValues.contains(v.toLowerCase())) v.toLowerCase(),
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

  /// `%` and `_` in a search are literal characters, not wildcards.
  static String _escapeLike(String value) =>
      value.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}');
}
