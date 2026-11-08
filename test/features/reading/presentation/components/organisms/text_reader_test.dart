import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/reading/domain/value_objects/chapter_content.dart';

import 'package:gatuno/core/theme/reader_palette.dart';
import 'package:gatuno/features/reading/data/data_sources/reader_preferences_storage.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/reading/domain/use_cases/reader_preferences_service.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/text_reader.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool get hasPrevious => false;
  @override
  bool get hasNext => false;
  @override
  final ChapterIndex index = const ChapterIndex(1.0);

  _MockChapter({this.title, this.content, this.contentFormat});
}

const _customPrefs = ReaderPreferences(
  theme: ReaderTheme.cream,
  text: TextReaderPreferences(
    fontFamily: ReaderFontFamily.atkinson,
    fontSize: 22,
    lineHeight: 1.5,
    alignment: ReaderTextAlignment.center,
  ),
);

void main() {
  late MockReadingViewModel mockViewModel;
  late ReaderPreferencesService preferences;

  setUpAll(() {
    registerFallbackValue(ChapterId('dummy'));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    preferences = ReaderPreferencesService(ReaderPreferencesStorage());
    mockViewModel = MockReadingViewModel();
    when(() => mockViewModel.state).thenReturn(ReadingState.initial());
    when(
      () => mockViewModel.stateStream,
    ).thenAnswer((_) => Stream.value(ReadingState.initial()));
    when(() => mockViewModel.currentPageIndex).thenReturn(0);
  });

  tearDown(() => preferences.dispose());

  Future<void> pumpReader(WidgetTester tester, ReadingChapter chapter) =>
      tester.pumpApp(
        MultiProvider(
          providers: [
            Provider<ReadingViewModel>.value(value: mockViewModel),
            Provider<ReaderPreferencesService>.value(value: preferences),
          ],
          child: Scaffold(body: TextReader(chapter: chapter)),
        ),
      );

  group('TextReader', () {
    testWidgets('renders title and plain text content', (tester) async {
      final chapter = _MockChapter(
        title: const ChapterTitle('Chapter Title'),
        content: const ChapterContent('Hello world'),
        contentFormat: ContentFormat.plain,
      );

      await pumpReader(tester, chapter);

      expect(find.text('Chapter Title'), findsOneWidget);
      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('renders HTML content', (tester) async {
      final chapter = _MockChapter(
        title: const ChapterTitle('Chapter Title'),
        content: const ChapterContent('<h1>Hello</h1>'),
        contentFormat: ContentFormat.html,
      );

      await pumpReader(tester, chapter);

      expect(find.byType(Html), findsOneWidget);
    });

    testWidgets('renders Markdown content', (tester) async {
      final chapter = _MockChapter(
        title: const ChapterTitle('Chapter Title'),
        content: const ChapterContent('# Hello'),
        contentFormat: ContentFormat.markdown,
      );

      await pumpReader(tester, chapter);

      expect(find.byType(MarkdownBody), findsOneWidget);
    });
    testWidgets('applies the preferences to plain text and the surface', (
      tester,
    ) async {
      await preferences.update(_customPrefs);
      final chapter = _MockChapter(
        content: const ChapterContent('Hello world'),
        contentFormat: ContentFormat.plain,
      );

      await pumpReader(tester, chapter);

      final text = tester.widget<Text>(find.text('Hello world'));
      expect(text.style?.fontFamily, 'Atkinson Hyperlegible');
      expect(text.style?.fontSize, 22);
      expect(text.style?.height, 1.5);
      expect(text.style?.color, ReaderPalette.cream.text);
      expect(text.textAlign, TextAlign.center);
      final surface = tester.widget<ColoredBox>(
        find.byKey(const ValueKey('text-reader-surface')),
      );
      expect(surface.color, ReaderPalette.cream.background);
    });

    testWidgets('applies the preferences to markdown and HTML', (tester) async {
      await preferences.update(
        _customPrefs.copyWith(
          text: _customPrefs.text.copyWith(
            alignment: ReaderTextAlignment.justify,
          ),
        ),
      );

      await pumpReader(
        tester,
        _MockChapter(
          content: const ChapterContent('# Hello'),
          contentFormat: ContentFormat.markdown,
        ),
      );
      final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
      expect(markdown.styleSheet?.p?.fontFamily, 'Atkinson Hyperlegible');
      expect(markdown.styleSheet?.p?.fontSize, 22);
      expect(markdown.styleSheet?.p?.height, 1.5);
      expect(markdown.styleSheet?.textAlign, WrapAlignment.spaceBetween);

      await pumpReader(
        tester,
        _MockChapter(
          content: const ChapterContent('<p>Hello</p>'),
          contentFormat: ContentFormat.html,
        ),
      );
      final html = tester.widget<Html>(find.byType(Html));
      final body = html.style['body']!;
      expect(body.fontFamily, 'Atkinson Hyperlegible');
      expect(body.fontSize?.value, 22);
      expect(body.lineHeight?.size, 1.5);
      expect(body.textAlign, TextAlign.justify);
    });

    testWidgets('follows preference changes live', (tester) async {
      final chapter = _MockChapter(
        content: const ChapterContent('Hello world'),
        contentFormat: ContentFormat.plain,
      );
      await pumpReader(tester, chapter);
      expect(tester.widget<Text>(find.text('Hello world')).style?.fontSize, 19);

      await preferences.update(_customPrefs);
      await tester.pump();

      expect(tester.widget<Text>(find.text('Hello world')).style?.fontSize, 22);
    });

    testWidgets('settings action in the overlay opens the settings sheet', (
      tester,
    ) async {
      final chapter = _MockChapter(
        content: const ChapterContent('Hello world'),
        contentFormat: ContentFormat.plain,
      );
      await pumpReader(tester, chapter);

      await tester.tap(find.text('Hello world'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.settings_outlined), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.settings_outlined).first);
      await tester.pumpAndSettle();

      expect(find.text('Reading settings'), findsOneWidget);
      expect(find.text('Font size (19px)'), findsOneWidget);
    });
  });
}
