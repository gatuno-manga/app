import 'package:drift/drift.dart';

import '../../../../core/database/offline_cache_database.dart';
import '../../../../shared/data/models/image_metadata_model.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_type.dart';
import '../../domain/entities/chapter.dart';
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

/// Turns cached rows back into the models the repository returns.
class CachedBookMapper {
  final OfflineCacheDatabase _db;

  CachedBookMapper(this._db);

  Future<List<Book>> toBooks(List<CachedBook> rows) async {
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

  ChapterModel toChapter(CachedChapter row) {
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
}
