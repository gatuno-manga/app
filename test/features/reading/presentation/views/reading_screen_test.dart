import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/reading/domain/value_objects/chapter_content.dart';


import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:gatuno/features/reading/presentation/views/reading_screen.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/image_reader.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/text_reader.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/document_reader.dart';
import 'package:gatuno/features/reading/presentation/components/templates/reading_template.dart';
import 'package:mocktail/mocktail.dart';


import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_injection.dart';

class MockReadingViewModel extends Mock implements ReadingViewModel {}

class _MockChapter extends Fake implements ReadingChapter {
  @override
  final ContentType contentType;
  @override
  final ChapterId id = const ChapterId('chapter-1');
  @override
  final List<ReadingPage> pages = [];
  @override
  final ChapterId? previous = null;
  @override
  final ChapterId? next = null;
  @override
  final ChapterTitle? title = const ChapterTitle('Chapter 1');
  @override
  final BookTitle bookTitle = const BookTitle('Test Book');
  @override
  final ChapterIndex index = const ChapterIndex(1.0);
  @override
  final ChapterContent? content = const ChapterContent('Content');
  @override
  final ContentFormat? contentFormat = ContentFormat.plain;
  @override
  final DocumentFormat? documentFormat = DocumentFormat.pdf;
  @override
  final ScrapingStatus? scrapingStatus = ScrapingStatus.ready;

  _MockChapter({required this.contentType});
}

void main() {
  late MockReadingViewModel mockViewModel;
  late StreamController<ReadingState> stateController;

  setUp(() async {
    mockViewModel = MockReadingViewModel();
    when(
      () => mockViewModel.loadChapter(
        any(),
        initialPage: any(named: 'initialPage'),
      ),
    ).thenAnswer((_) async {});
    final mockState = ReadingState.initial();
    stateController = StreamController<ReadingState>.broadcast();
    stateController.add(mockState);
    when(() => mockViewModel.state).thenReturn(mockState);
    when(() => mockViewModel.stateStream).thenAnswer((_) => stateController.stream);
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.error).thenReturn(null);
    when(() => mockViewModel.chapter).thenReturn(null);

    await initTestDI();
    sl.registerFactory<ReadingViewModel>(() => mockViewModel);
  });

    setUpAll(() {
    registerFallbackValue(ChapterId('dummy'));
  });

  tearDown(() {
    stateController.close();
  });

group('ReadingScreen', () {
    testWidgets('initializes viewModel and loads chapter', (tester) async {
      await tester.pumpApp(
        const ReadingScreen(chapterId: '123', initialPage: 0),
      );

      verify(() => mockViewModel.loadChapter('123', initialPage: 0)).called(1);
      expect(find.byType(ReadingTemplate), findsOneWidget);
    });

    testWidgets('renders loading state', (tester) async {
      final st = ReadingState.initial().copyWith(isLoading: true);
      stateController.add(st);
      when(() => mockViewModel.state).thenReturn(st);

      await tester.pumpApp(
        const ReadingScreen(chapterId: '123', initialPage: 0),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state and allows retry', (tester) async {
      final st = ReadingState.initial().copyWith(error: () => 'Error');
      stateController.add(st);
      when(() => mockViewModel.state).thenReturn(st);

      await tester.pumpApp(
        const ReadingScreen(chapterId: '123', initialPage: 0),
      );

      expect(find.text('Error'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      // 1st call in initState, 2nd call on retry
      verify(
        () => mockViewModel.loadChapter(
          '123',
          initialPage: any(named: 'initialPage'),
        ),
      ).called(2);
    });

    testWidgets('renders correct reader for image content', (tester) async {
      final chapter = _MockChapter(contentType: ContentType.image);
      final st = ReadingState.initial().copyWith(chapter: () => chapter);
      stateController.add(st);
      when(() => mockViewModel.state).thenReturn(st);

      await tester.pumpApp(
        const ReadingScreen(chapterId: '123', initialPage: 0),
      );

      expect(find.byType(ImageReader), findsOneWidget);
    });

    testWidgets('renders correct reader for text content', (tester) async {
      final chapter = _MockChapter(contentType: ContentType.text);
      final st = ReadingState.initial().copyWith(chapter: () => chapter);
      stateController.add(st);
      when(() => mockViewModel.state).thenReturn(st);

      await tester.pumpApp(
        const ReadingScreen(chapterId: '123', initialPage: 0),
      );

      expect(find.byType(TextReader), findsOneWidget);
    });

    testWidgets('renders correct reader for document content', (tester) async {
      final chapter = _MockChapter(contentType: ContentType.document);
      final st = ReadingState.initial().copyWith(chapter: () => chapter);
      stateController.add(st);
      when(() => mockViewModel.state).thenReturn(st);

      await tester.pumpApp(
        const ReadingScreen(chapterId: '123', initialPage: 0),
      );

      expect(find.byType(DocumentReader), findsOneWidget);
    });

    testWidgets('reloads when chapterId changes', (tester) async {
      await tester.pumpApp(
        const ReadingScreen(chapterId: '123', initialPage: 0),
      );
      verify(() => mockViewModel.loadChapter('123', initialPage: 0)).called(1);

      // Trigger didUpdateWidget by pumping with new chapterId
      await tester.pumpApp(
        const ReadingScreen(chapterId: '456', initialPage: 0),
      );
      verify(() => mockViewModel.loadChapter('456', initialPage: 0)).called(1);
    });
  });
}
