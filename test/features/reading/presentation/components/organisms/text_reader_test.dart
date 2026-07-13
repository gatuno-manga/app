import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/reading/domain/value_objects/chapter_content.dart';


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
  final ChapterId id = const ChapterId('chapter-1');
  @override
  final ChapterTitle? title;
  @override
  final ChapterContent? content;
  @override
  final ContentFormat? contentFormat;
  @override
  final BookTitle bookTitle = const BookTitle('Test Book');
  @override
  final List<ReadingPage> pages = [];
  @override
  final ChapterId? previous = null;
  @override
  final ChapterId? next = null;
  @override
  final ChapterIndex index = const ChapterIndex(1.0);

  _MockChapter({this.title, this.content, this.contentFormat});
}

void main() {
  late MockReadingViewModel mockViewModel;

    setUpAll(() {
    registerFallbackValue(ChapterId('dummy'));
  });

setUp(() {
    mockViewModel = MockReadingViewModel();
    when(() => mockViewModel.state).thenReturn(ReadingState.initial());
    when(() => mockViewModel.stateStream).thenAnswer((_) => Stream.value(ReadingState.initial()));
    when(() => mockViewModel.currentPageIndex).thenReturn(0);
  });

  group('TextReader', () {
    testWidgets('renders title and plain text content', (tester) async {
      final chapter = _MockChapter(
        title: const ChapterTitle('Chapter Title'),
        content: const ChapterContent('Hello world'),
        contentFormat: ContentFormat.plain,
      );

      await tester.pumpApp(
        Provider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(body: TextReader(chapter: chapter)),
        ),
      );

      expect(find.text('Chapter Title'), findsOneWidget);
      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('renders HTML content', (tester) async {
      final chapter = _MockChapter(
        title: const ChapterTitle('Chapter Title'),
        content: const ChapterContent('<h1>Hello</h1>'),
        contentFormat: ContentFormat.html,
      );

      await tester.pumpApp(
        Provider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(body: TextReader(chapter: chapter)),
        ),
      );

      expect(find.byType(Html), findsOneWidget);
    });

    testWidgets('renders Markdown content', (tester) async {
      final chapter = _MockChapter(
        title: const ChapterTitle('Chapter Title'),
        content: const ChapterContent('# Hello'),
        contentFormat: ContentFormat.markdown,
      );

      await tester.pumpApp(
        Provider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(body: TextReader(chapter: chapter)),
        ),
      );

      expect(find.byType(MarkdownBody), findsOneWidget);
    });
  });
}
