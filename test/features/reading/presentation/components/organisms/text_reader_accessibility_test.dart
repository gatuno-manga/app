import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/reading/data/data_sources/reader_preferences_storage.dart';
import 'package:gatuno/features/reading/domain/entities/reader_preferences.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/reading/domain/use_cases/reader_preferences_service.dart';
import 'package:gatuno/features/reading/domain/value_objects/chapter_content.dart';
import 'package:gatuno/features/reading/presentation/components/molecules/reading_ruler.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/text_reader.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../helpers/pump_app.dart';

class _MockReadingViewModel extends Mock implements ReadingViewModel {}

class _Chapter extends Fake implements ReadingChapter {
  @override
  final ChapterId id = const ChapterId('chapter-1');
  @override
  final ChapterTitle? title = const ChapterTitle('Title');
  @override
  final ChapterContent? content;
  @override
  final ContentFormat? contentFormat;
  @override
  final BookTitle bookTitle = const BookTitle('Book');
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

  _Chapter(String text, this.contentFormat) : content = ChapterContent(text);
}

void main() {
  late _MockReadingViewModel viewModel;
  late ReaderPreferencesService preferences;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    preferences = ReaderPreferencesService(ReaderPreferencesStorage());
    viewModel = _MockReadingViewModel();
    when(() => viewModel.state).thenReturn(ReadingState.initial());
    when(
      () => viewModel.stateStream,
    ).thenAnswer((_) => Stream.value(ReadingState.initial()));
    when(() => viewModel.currentPageIndex).thenReturn(0);
  });

  tearDown(() => preferences.dispose());

  Future<void> pumpReader(WidgetTester tester, _Chapter chapter) =>
      tester.pumpApp(
        MultiProvider(
          providers: [
            Provider<ReadingViewModel>.value(value: viewModel),
            Provider<ReaderPreferencesService>.value(value: preferences),
          ],
          child: Scaffold(body: TextReader(chapter: chapter)),
        ),
        theme: AppTheme.lightTheme,
      );

  Future<void> setText(
    TextReaderPreferences Function(TextReaderPreferences) change,
  ) => preferences.update((p) => p.copyWith(text: change(p.text)));

  group('letter and word spacing', () {
    testWidgets('scale with the font size on plain text and the title', (
      tester,
    ) async {
      await setText(
        (t) => t.copyWith(fontSize: 20, letterSpacing: 0.05, wordSpacing: 0.16),
      );
      await pumpReader(tester, _Chapter('Hello world', ContentFormat.plain));

      final body = tester.widget<Text>(find.text('Hello world')).style!;
      expect(body.letterSpacing, closeTo(1.0, 1e-9));
      expect(body.wordSpacing, closeTo(3.2, 1e-9));
      final title = tester.widget<Text>(find.text('Title')).style!;
      expect(title.letterSpacing, closeTo(1.0, 1e-9));
    });

    testWidgets('are untouched by default', (tester) async {
      await pumpReader(tester, _Chapter('Hello world', ContentFormat.plain));

      final body = tester.widget<Text>(find.text('Hello world')).style!;
      expect(body.letterSpacing, 0);
      expect(body.wordSpacing, 0);
      expect(body.fontStyle, isNull);
    });

    testWidgets('reach markdown headings and html body', (tester) async {
      await setText((t) => t.copyWith(letterSpacing: 0.05));
      await pumpReader(tester, _Chapter('# Head', ContentFormat.markdown));
      final heading = tester.widget<Text>(find.textContaining('Head').last);
      expect(heading.textSpan!.style!.letterSpacing, greaterThan(0));

      await pumpReader(tester, _Chapter('<p>Body</p>', ContentFormat.html));
      expect(find.byType(Html), findsOneWidget);
      final html = tester.widget<Html>(find.byType(Html));
      expect(html.style['body']!.letterSpacing!, greaterThan(0));
    });
  });

  group('italics suppression', () {
    testWidgets('plain text gets an explicit normal style', (tester) async {
      await setText((t) => t.copyWith(suppressItalics: true));
      await pumpReader(tester, _Chapter('Hello', ContentFormat.plain));

      expect(
        tester.widget<Text>(find.text('Hello')).style!.fontStyle,
        FontStyle.normal,
      );
    });

    testWidgets('markdown emphasis renders as normal', (tester) async {
      await setText((t) => t.copyWith(suppressItalics: true));
      await pumpReader(tester, _Chapter('*slanted*', ContentFormat.markdown));

      final body = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
      final sheet = body.styleSheet!;
      expect(sheet.em!.fontStyle, FontStyle.normal);
    });

    testWidgets('markdown keeps its italics when off', (tester) async {
      await pumpReader(tester, _Chapter('*slanted*', ContentFormat.markdown));

      final body = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
      expect(body.styleSheet!.em?.fontStyle, isNot(FontStyle.normal));
    });

    testWidgets('html italic elements render as normal', (tester) async {
      await setText((t) => t.copyWith(suppressItalics: true));
      await pumpReader(tester, _Chapter('<em>a</em>', ContentFormat.html));

      final html = tester.widget<Html>(find.byType(Html));
      for (final tag in ['em', 'i', 'cite', 'dfn', 'var']) {
        expect(html.style[tag]!.fontStyle, FontStyle.normal, reason: tag);
      }
    });
  });

  group('maximum line width', () {
    double contentWidth(WidgetTester tester) =>
        tester.getSize(find.text('Hello world')).width;

    testWidgets('caps the column at that many ch and centres it', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await setText((t) => t.copyWith(lineWidth: 40));
      await pumpReader(tester, _Chapter('Hello world', ContentFormat.plain));

      final style = tester.widget<Text>(find.text('Hello world')).style!;
      final painter = TextPainter(
        text: TextSpan(text: '0', style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      final expected = 40 * painter.width;
      painter.dispose();
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is ConstrainedBox &&
              (w.constraints.maxWidth - expected).abs() < 0.01,
        ),
        findsOneWidget,
      );
      expect(contentWidth(tester), lessThanOrEqualTo(expected));
    });

    testWidgets('without a limit keeps the default prose measure', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpReader(tester, _Chapter('Hello world', ContentFormat.plain));

      expect(
        find.byWidgetPredicate(
          (w) => w is ConstrainedBox && w.constraints.maxWidth == 680,
        ),
        findsOneWidget,
      );
    });

    testWidgets('never exceeds the screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await setText((t) => t.copyWith(lineWidth: 100));
      await pumpReader(tester, _Chapter('Hello world', ContentFormat.plain));

      expect(tester.takeException(), isNull);
      expect(contentWidth(tester), lessThanOrEqualTo(320));
    });
  });

  group('reading ruler', () {
    testWidgets('is absent by default and shown when enabled', (tester) async {
      await pumpReader(tester, _Chapter('Hello', ContentFormat.plain));
      expect(find.byType(ReadingRuler), findsNothing);

      await setText((t) => t.copyWith(readingRuler: true));
      await tester.pump();

      expect(find.byType(ReadingRuler), findsOneWidget);
    });

    testWidgets('is one line tall for the current font and line height', (
      tester,
    ) async {
      await setText((t) => t.copyWith(readingRuler: true, fontSize: 20));
      await pumpReader(tester, _Chapter('Hello', ContentFormat.plain));

      final ruler = tester.widget<ReadingRuler>(find.byType(ReadingRuler));
      expect(ruler.lineHeight, closeTo(20 * 1.8, 1e-9));
    });

    testWidgets('grows with the system text scale', (tester) async {
      await setText((t) => t.copyWith(readingRuler: true, fontSize: 20));
      await tester.pumpApp(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: MultiProvider(
            providers: [
              Provider<ReadingViewModel>.value(value: viewModel),
              Provider<ReaderPreferencesService>.value(value: preferences),
            ],
            child: Scaffold(
              body: TextReader(chapter: _Chapter('Hello', ContentFormat.plain)),
            ),
          ),
        ),
        theme: AppTheme.lightTheme,
      );

      final ruler = tester.widget<ReadingRuler>(find.byType(ReadingRuler));
      expect(ruler.lineHeight, closeTo(20 * 2 * 1.8, 1e-9));
    });
  });
}
