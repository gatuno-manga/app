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

import 'package:optional/optional.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';

void main() {
  group('BookPageOptions', () {
    test('default values are correct', () {
      const options = BookPageOptions();

      expect(options.page?.value, 1);
      expect(options.limit?.value, 20);
      expect(options.orderBy, 'createdAt');
      expect(options.order, SortOrder.desc);
      expect(options.search, isNull);
      expect(options.publication, isNull);
      expect(options.publicationOperator, isNull);
      expect(options.tagsLogic, isNull);
      expect(options.excludeTagsLogic, isNull);
      expect(options.authorsLogic, isNull);
    });

    test('toJson should contain correct fields and uppercase order', () {
      const options = BookPageOptions(page: const PositiveInt(2),
        limit: const PositiveInt(10),
        orderBy: 'title',
        order: SortOrder.asc,
        search: 'one piece',
      );

      final json = options.toJson();

      expect(json['page'], const PositiveInt(2));
      expect(json['limit'], const PositiveInt(10));
      expect(json['orderBy'], 'title');
      expect(json['order'], 'ASC'); // Must be uppercase for backend
      expect(json['search'], 'one piece');
    });

    test('toJson should exclude null/empty filters by default', () {
      const options = BookPageOptions();
      final json = options.toJson();

      expect(json.containsKey('search'), false);
      expect(json.containsKey('publication'), false);
      expect(json.containsKey('publicationOperator'), false);
      expect(json.containsKey('type'), false);
      expect(json.containsKey('tags'), false);
      expect(json.containsKey('tagsLogic'), false);
      expect(json.containsKey('excludeTags'), false);
      expect(json.containsKey('excludeTagsLogic'), false);
      expect(json.containsKey('authors'), false);
      expect(json.containsKey('authorsLogic'), false);
    });

    test('copyWith should update fields correctly', () {
      const options = BookPageOptions();
      final updated = options.copyWith(
          page: const PositiveInt(5),
        search: Optional.ofNullable('test'),
        order: SortOrder.asc,
      );

      expect(updated.page?.value, 5);
      expect(updated.search, 'test');
      expect(updated.order, SortOrder.asc);
      expect(updated.limit, options.limit); // Unchanged
    });
  });
}
