import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/data/models/reading_chapter_model.dart';

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
            'width': 800,
            'height': 1200,
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
            'width': '1024',
            'height': '768',
          },
        ],
        'comments': <Map<String, dynamic>>[],
      };

      final model = ReadingChapterModel.fromJson(json);

      expect(model.pages[0].width, 1024.0);
      expect(model.pages[0].height, 768.0);
    });
  });
}
