import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/data/models/reading_chapter_model.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';

void main() {
  group('ReadingChapterModel', () {
    test('should parse width and height for pages from JSON', () {
      final json = {
        'id': 'chapter-1',
        'title': 'Chapter 1',
        'originalUrl': 'http://example.com/c1',
        'index': 1.0,
        'contentType': 'image',
        'retries': 0,
        'isFinal': true,
        'bookId': 'book-1',
        'bookTitle': 'Book 1',
        'totalChapters': 10,
        'pages': [
          {
            'id': 'page-1',
            'url': 'http://example.com/p1.jpg',
            'index': 1,
            'metadata': {
              'width': 800,
              'height': 1200,
            },
          },
          {'id': 'page-2', 'url': 'http://example.com/p2.jpg', 'index': 2},
        ],
        'comments': <Map<String, dynamic>>[],
      };

      final model = ReadingChapterModel.fromJson(json);

      expect(model.pages[0].width, 800.0);
      expect(model.pages[0].height, 1200.0);
      expect(model.pages[1].width, isNull);
      expect(model.pages[1].height, isNull);
    });

    test('should handle string width and height', () {
      final json = {
        'id': 'chapter-1',
        'originalUrl': 'http://example.com/c1',
        'index': 1.0,
        'contentType': 'image',
        'retries': 0,
        'isFinal': true,
        'bookId': 'book-1',
        'bookTitle': 'Book 1',
        'totalChapters': 10,
        'pages': [
          {
            'id': 'page-1',
            'url': 'http://example.com/p1.jpg',
            'index': 1,
            'metadata': {
              'width': '1024',
              'height': '768',
            },
          },
        ],
        'comments': <Map<String, dynamic>>[],
      };

      final model = ReadingChapterModel.fromJson(json);

      expect(model.pages[0].width, 1024.0);
      expect(model.pages[0].height, 768.0);
    });

    test('fromJson handles different scraping statuses and formats', () {
      final json = {
        'id': '1',
        'originalUrl': 'url',
        'index': '1',
        'contentType': 'document',
        'retries': '0',
        'bookId': 'b1',
        'bookTitle': 'Book',
        'totalChapters': '1',
        'scrapingStatus': 'ready',
        'documentPath': '/path/to/doc',
        'documentFormat': 'pdf',
        'contentFormat': 'markdown',
        'deletedAt': '2023-01-01T10:00:00Z',
        'comments': [
          {
            'id': 'c1',
            'content': 'comment',
            'createdAt': '2023-01-01T10:00:00Z',
            'userId': 'u1',
            'userName': 'User',
          },
        ],
      };

      final model = ReadingChapterModel.fromJson(json);

      expect(model.scrapingStatus, ScrapingStatus.ready);
      expect(model.documentPath, '/path/to/doc');
      expect(model.documentFormat, DocumentFormat.pdf);
      expect(model.contentFormat, ContentFormat.markdown);
      expect(model.deletedAt, isA<DateTime>());
      expect(model.comments.length, 1);
      expect(model.comments[0].userName, 'User');
    });

    test('fromJson handles null scraping status', () {
      final json = {
        'id': '1',
        'originalUrl': 'url',
        'index': '1',
        'contentType': 'image',
        'retries': '0',
        'bookId': 'b1',
        'bookTitle': 'Book',
        'totalChapters': '1',
        'scrapingStatus': null,
      };

      final model = ReadingChapterModel.fromJson(json);
      expect(model.scrapingStatus, isNull);
    });
  });
}
