import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/shared/domain/entities/image_metadata.dart';

void main() {
  group('ReadingChapter', () {
    test('initialization works correctly', () {
      final chapter = ReadingChapter(
        id: '1',
        title: 'Title',
        originalUrl: 'url',
        index: 1.0,
        contentType: ContentType.image,
        retries: 0,
        isFinal: true,
        bookId: 'b1',
        bookTitle: 'Book',
        totalChapters: 10,
        pages: <ReadingPage>[],
        comments: <ChapterComment>[],
      );

      expect(chapter.id, '1');
      expect(chapter.contentType, ContentType.image);
    });
  });

  group('ReadingPage', () {
    test('initialization works correctly', () {
      final page = ReadingPage(
        id: 'p1',
        url: 'url',
        index: 0,
        metadata: const ImageMetadata(width: 100, height: 200),
      );

      expect(page.id, 'p1');
      expect(page.width, 100);
      expect(page.height, 200);
    });
  });
}
