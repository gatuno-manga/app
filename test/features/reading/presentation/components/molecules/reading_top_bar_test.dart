import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';


import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reading_top_bar.dart';
import '../../../../../helpers/pump_app.dart';

class _MockChapter extends Fake implements ReadingChapter {
  @override
  final ChapterTitle? title;
  @override
  final ChapterIndex index;
  @override
  final BookTitle bookTitle;

  _MockChapter({this.title, required this.index, this.bookTitle = const BookTitle('Test Book')});
}

void main() {
  group('ReadingTopBar', () {
    testWidgets('renders chapter and book information', (tester) async {
      final chapter = _MockChapter(
        title: const ChapterTitle('Chapter 1'),
        index: const ChapterIndex(1.0),
        bookTitle: const BookTitle('My Book'),
      );
      await tester.pumpApp(
        Scaffold(body: ReadingTopBar(chapter: chapter, topPadding: 20.0)),
      );

      expect(find.text('My Book'), findsOneWidget);
      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders default chapter title if title is null', (
      tester,
    ) async {
      final chapter = _MockChapter(title: null, index: const ChapterIndex(2.0));
      await tester.pumpApp(
        Scaffold(body: ReadingTopBar(chapter: chapter, topPadding: 20.0)),
      );

      expect(find.text('Chapter 2.0'), findsOneWidget);
    });
  });
}
