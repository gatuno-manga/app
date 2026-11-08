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
}
