import 'package:flutter/material.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart' as vo;
import 'package:gatuno/features/books/domain/value_objects/book_description.dart' as vo;
import 'package:gatuno/features/books/domain/value_objects/book_cover.dart';
import 'package:gatuno/features/books/domain/value_objects/author_id.dart';
import 'package:gatuno/features/books/domain/value_objects/author_name.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_id.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_name.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/presentation/components/molecules/book_info.dart';
import 'package:gatuno/features/books/presentation/components/atoms/book_title.dart';
import 'package:gatuno/features/books/presentation/components/atoms/book_description.dart';

void main() {
  testWidgets('BookInfo renders title and description', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookInfo(title: const vo.BookTitle('Test Title').value, description: const vo.BookDescription('Test Description').value),
        ),
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.byType(BookTitle), findsOneWidget);
    expect(find.byType(BookDescription), findsOneWidget);
  });

  testWidgets('BookInfo renders only title if description is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
          home: Scaffold(body: BookInfo(title: const vo.BookTitle('Test Title').value)),
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.byType(BookDescription), findsNothing);
  });
}
