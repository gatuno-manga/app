import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/reading/domain/value_objects/original_url.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:gatuno/features/reading/domain/value_objects/reading_page_id.dart';
import 'package:gatuno/features/reading/domain/value_objects/reading_page_url.dart';

import 'package:gatuno/features/reading/data/models/reading_chapter_model.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/shared/domain/entities/image_metadata.dart';

void main() {
  group('ReadingChapter', () {
    test('initialization works correctly', () {
      final chapter = ReadingChapter(
        id: const ChapterId('1'),
        title: const ChapterTitle('Title'),
        originalUrl: const OriginalUrl('https://example.com/original.pdf'),
        index: const ChapterIndex(1.0),
        contentType: ContentType.image,
        retries: const PositiveInt(0),
        isFinal: true,
        bookId: const BookId('b1'),
        bookTitle: const BookTitle('Book'),
        totalChapters: const PositiveInt(10),
        pages: <ReadingPage>[],
        comments: <ChapterComment>[],
      );

      expect(chapter.id.value, '1');
      expect(chapter.contentType, ContentType.image);
    });
  });

  group('ReadingChapter navigation', () {
    ReadingChapter build({ChapterId? previous, ChapterId? next}) =>
        ReadingChapter(
          id: const ChapterId('1'),
          originalUrl: const OriginalUrl('https://example.com/original.pdf'),
          index: const ChapterIndex(1.0),
          contentType: ContentType.image,
          retries: const PositiveInt(0),
          isFinal: true,
          previous: previous,
          next: next,
          bookId: const BookId('b1'),
          bookTitle: const BookTitle('Book'),
          totalChapters: const PositiveInt(10),
          pages: const <ReadingPage>[],
          comments: const <ChapterComment>[],
        );

    test('null ids mean no previous/next', () {
      final c = build();
      expect(c.hasPrevious, isFalse);
      expect(c.hasNext, isFalse);
    });

    test('empty and whitespace ids mean no previous/next', () {
      final c = build(
        previous: const ChapterId(''),
        next: const ChapterId('   '),
      );
      expect(c.hasPrevious, isFalse);
      expect(c.hasNext, isFalse);
    });

    test('previous and next are evaluated independently', () {
      final onlyPrevious = build(previous: const ChapterId('p'));
      expect(onlyPrevious.hasPrevious, isTrue);
      expect(onlyPrevious.hasNext, isFalse);

      final onlyNext = build(next: const ChapterId('n'));
      expect(onlyNext.hasPrevious, isFalse);
      expect(onlyNext.hasNext, isTrue);
    });

    test('valid ids mean previous/next exist', () {
      final c = build(
        previous: const ChapterId('p'),
        next: const ChapterId('n'),
      );
      expect(c.hasPrevious, isTrue);
      expect(c.hasNext, isTrue);
    });
  });

  group('ReadingPage', () {
    test('initialization works correctly', () {
      final page = ReadingPage(
        id: const ReadingPageId('p1'),
        url: const ReadingPageUrl('url'),
        index: const PositiveInt(0),
        metadata: const ImageMetadata(width: 100, height: 200),
      );

      expect(page.id.value, 'p1');
      expect(page.width, 100);
      expect(page.height, 200);
    });
  });

  test('withNeighbours keeps every other field', () {
    final saved = ReadingChapterModel.fromJson({
      'id': 'c1',
      'title': 'One',
      'originalUrl': 'https://origin/c1',
      'index': 1,
      'contentType': 'document',
      'content': 'text',
      'contentFormat': 'plain',
      'documentPath': '/s3/c1.pdf',
      'documentFormat': 'pdf',
      'scrapingStatus': 'ready',
      'retries': 2,
      'isFinal': true,
      'deletedAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-02-01T00:00:00.000Z',
      'previous': 'c0',
      'next': 'c2',
      'bookId': 'b1',
      'bookTitle': 'Book',
      'totalChapters': 3,
      'pages': [
        {'id': 'p1', 'path': '/s3/1.jpg', 'index': 1},
      ],
      'comments': [
        {
          'id': 'k1',
          'content': 'Nice',
          'createdAt': '2026-01-02T00:00:00.000Z',
          'userId': 'u1',
          'userName': 'User',
        },
      ],
    });

    final refreshed = saved.withNeighbours(next: const ChapterId('c3'));

    expect(refreshed.previous, isNull);
    expect(refreshed.next, const ChapterId('c3'));
    expect(refreshed.id, saved.id);
    expect(refreshed.title, saved.title);
    expect(refreshed.originalUrl, saved.originalUrl);
    expect(refreshed.index, saved.index);
    expect(refreshed.contentType, saved.contentType);
    expect(refreshed.content, saved.content);
    expect(refreshed.contentFormat, saved.contentFormat);
    expect(refreshed.documentPath, saved.documentPath);
    expect(refreshed.documentFormat, saved.documentFormat);
    expect(refreshed.scrapingStatus, saved.scrapingStatus);
    expect(refreshed.retries, saved.retries);
    expect(refreshed.isFinal, saved.isFinal);
    expect(refreshed.deletedAt, saved.deletedAt);
    expect(refreshed.updatedAt, isNotNull);
    expect(refreshed.updatedAt, saved.updatedAt);
    expect(refreshed.bookId, saved.bookId);
    expect(refreshed.bookTitle, saved.bookTitle);
    expect(refreshed.totalChapters, saved.totalChapters);
    expect(refreshed.pages, same(saved.pages));
    expect(refreshed.comments, same(saved.comments));
  });
}
