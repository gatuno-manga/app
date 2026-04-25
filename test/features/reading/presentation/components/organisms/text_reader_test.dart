import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/text_reader.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import '../../../../../helpers/pump_app.dart';

class MockReadingViewModel extends Mock implements ReadingViewModel {}

class _MockChapter extends Fake implements ReadingChapter {
  @override
  final String id = 'chapter-1';
  @override
  final String? title;
  @override
  final String? content;
  @override
  final ContentFormat? contentFormat;
  @override
  final String bookTitle = 'Test Book';
  @override
  final List<ReadingPage> pages = [];
  @override
  final String? previous = null;
  @override
  final String? next = null;
  @override
  final double index = 1.0;

  _MockChapter({this.title, this.content, this.contentFormat});
}

void main() {
  late MockReadingViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockReadingViewModel();
    when(() => mockViewModel.currentPageIndex).thenReturn(0);
  });

  group('TextReader', () {
    testWidgets('renders title and plain text content', (tester) async {
      final chapter = _MockChapter(
        title: 'Chapter Title',
        content: 'Hello world',
        contentFormat: ContentFormat.plain,
      );

      await tester.pumpApp(
        ChangeNotifierProvider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(
            body: TextReader(chapter: chapter),
          ),
        ),
      );

      expect(find.text('Chapter Title'), findsOneWidget);
      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('renders HTML content', (tester) async {
      final chapter = _MockChapter(
        title: 'Chapter Title',
        content: '<h1>Hello</h1>',
        contentFormat: ContentFormat.html,
      );

      await tester.pumpApp(
        ChangeNotifierProvider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(
            body: TextReader(chapter: chapter),
          ),
        ),
      );

      expect(find.byType(Html), findsOneWidget);
    });

    testWidgets('renders Markdown content', (tester) async {
      final chapter = _MockChapter(
        title: 'Chapter Title',
        content: '# Hello',
        contentFormat: ContentFormat.markdown,
      );

      await tester.pumpApp(
        ChangeNotifierProvider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(
            body: TextReader(chapter: chapter),
          ),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget);
    });
  });
}
