import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_description.dart';
import 'package:gatuno/features/books/domain/value_objects/book_cover.dart';
import 'package:gatuno/features/books/domain/value_objects/author_id.dart';
import 'package:gatuno/features/books/domain/value_objects/author_name.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_id.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_name.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';

import 'package:gatuno/features/books/data/models/chapter_model.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';

void main() {
  group('ChapterModel', () {
    test('fromJson should handle string index correctly', () {
      const json = {
        'id': '1',
        'title': 'Chapter 1',
        'index': '1.00000',
        'scrapingStatus': 'ready',
        'read': true,
      };

      final model = ChapterModel.fromJson(json);

      expect(model.id.value, '1');
      expect(model.title?.value, 'Chapter 1');
      expect(model.index.value, 1.0);
      expect(model.scrapingStatus, ScrapingStatus.ready);
      expect(model.read, true);
    });

    test('fromJson should handle numeric index correctly', () {
      const json = {'id': '1', 'index': 86.5};

      final model = ChapterModel.fromJson(json);

      expect(model.index.value, 86.5);
    });

    test('fromJson should handle invalid index as 0.0', () {
      const json = {'id': '1', 'index': 'invalid'};

      final model = ChapterModel.fromJson(json);

      expect(model.index.value, 0.0);
    });

    test('fromJson should parse scrapingStatus correctly', () {
      expect(
        ChapterModel.fromJson({
          'id': '1',
          'index': 1,
          'scrapingStatus': 'ready',
        }).scrapingStatus,
        ScrapingStatus.ready,
      );
      expect(
        ChapterModel.fromJson({
          'id': '1',
          'index': 1,
          'scrapingStatus': 'process',
        }).scrapingStatus,
        ScrapingStatus.process,
      );
      expect(
        ChapterModel.fromJson({
          'id': '1',
          'index': 1,
          'scrapingStatus': 'error',
        }).scrapingStatus,
        ScrapingStatus.error,
      );
    });

    test('fromJson should handle unknown scrapingStatus as process', () {
      const json = {'id': '1', 'index': 1, 'scrapingStatus': 'unknown_status'};

      final model = ChapterModel.fromJson(json);

      expect(model.scrapingStatus, ScrapingStatus.process);
    });

    test('fromJson should handle null scrapingStatus as null', () {
      const json = {'id': '1', 'index': 1, 'scrapingStatus': null};

      final model = ChapterModel.fromJson(json);

      expect(model.scrapingStatus, isNull);
    });
  });

  group('ChapterListModel', () {
    test('fromJson should return a valid list model', () {
      const json = {
        'data': [
          {'id': '1', 'index': 1},
          {'id': '2', 'index': 2},
        ],
        'nextCursor': 'next_id',
        'hasNextPage': true,
      };

      final model = ChapterListModel.fromJson(json);

      expect(model.data.length, 2);
      expect(model.data.first.index.value, 1.0);
      expect(model.nextCursor, 'next_id');
      expect(model.hasNextPage, true);
    });
  });
}
