import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reading_top_bar.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../../helpers/pump_app.dart';

class _MockChapter extends Fake implements ReadingChapter {
  @override
  final String? title;
  @override
  final double index;
  @override
  final String bookTitle;

  _MockChapter({this.title, required this.index, this.bookTitle = 'Test Book'});
}

void main() {
  group('ReadingTopBar', () {
    testWidgets('renders chapter and book information', (tester) async {
      final chapter = _MockChapter(title: 'Chapter 1', index: 1.0, bookTitle: 'My Book');
      await tester.pumpApp(
        Scaffold(
          body: ReadingTopBar(
            chapter: chapter,
            topPadding: 20.0,
          ),
        ),
      );

      expect(find.text('My Book'), findsOneWidget);
      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders default chapter title if title is null', (tester) async {
      final chapter = _MockChapter(title: null, index: 2.0);
      await tester.pumpApp(
        Scaffold(
          body: ReadingTopBar(
            chapter: chapter,
            topPadding: 20.0,
          ),
        ),
      );

      expect(find.text('Chapter 2.0'), findsOneWidget);
    });
  });
}
