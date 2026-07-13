import 'package:dio/dio.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_description.dart';
import 'package:gatuno/features/books/domain/value_objects/book_cover.dart';
import 'package:gatuno/features/books/domain/value_objects/author_id.dart';
import 'package:gatuno/features/books/domain/value_objects/author_name.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/author.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart' as entity;
import 'package:gatuno/features/books/presentation/view_models/book_details_view_model.dart';
import 'package:gatuno/features/books/presentation/views/book_details_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_injection.dart';

class MockBookDetailsViewModel extends Mock implements BookDetailsViewModel {}

void main() {
  late MockBookDetailsViewModel mockViewModel;
  late StreamController<BookDetailsState> stateController;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() async {
    mockDioClient = MockDioClient();
    mockDio = mockDioClient.dio as MockDio;

    await initTestDI(dioClient: mockDioClient);

    mockViewModel = MockBookDetailsViewModel();

    final mockState = BookDetailsState.initial();
    stateController = StreamController<BookDetailsState>.broadcast();
    stateController.add(mockState);
    when(() => mockViewModel.state).thenReturn(mockState);
    when(() => mockViewModel.stateStream).thenAnswer((_) => stateController.stream);
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.isLoadingChapters).thenReturn(false);
    when(() => mockViewModel.hasReadingProgress).thenReturn(false);
    when(() => mockViewModel.error).thenReturn(null);
    when(() => mockViewModel.chaptersError).thenReturn(null);
    when(() => mockViewModel.book).thenReturn(null);
    when(() => mockViewModel.chapterList).thenReturn(null);
    when(() => mockViewModel.fetchBookDetails()).thenAnswer((_) async {});
    when(() => mockViewModel.fetchChapters()).thenAnswer((_) async {});

    // Handle listeners
    
    

    // Mock dio get for images
    registerFallbackValue(RequestOptions(path: ''));
    when(
      () => mockDio.get<List<int>>(any(), options: any(named: 'options')),
    ).thenAnswer(
      (_) async => Response(
        data: [],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return Provider<BookDetailsViewModel>.value(
      value: mockViewModel,
      child: const BookDetailsPage(),
    );
  }

  testWidgets('renders loading state', (tester) async {
    final mockState2 = BookDetailsState.initial().copyWith(isLoading: true);
    when(() => mockViewModel.state).thenReturn(mockState2);
    when(() => mockViewModel.stateStream).thenAnswer((_) => Stream.value(mockState2));
    stateController.add(mockState2);
    when(() => mockViewModel.isLoading).thenReturn(true);

    await tester.pumpApp(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders error state', (tester) async {
    final mockState3 = BookDetailsState.initial().copyWith(error: () => 'Failed to load book');
    when(() => mockViewModel.state).thenReturn(mockState3);
    when(() => mockViewModel.stateStream).thenAnswer((_) => Stream.value(mockState3));
    stateController.add(mockState3);
    when(() => mockViewModel.error).thenReturn('Failed to load book');

    await tester.pumpApp(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Failed to load book'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('renders book details and chapters', (tester) async {
    final book = Book(id: const BookId('1'),
      title: const BookTitle('Test Book'),
      authors: [Author(id: const AuthorId('1'), name: const AuthorName('Test Author'))],
      description: const BookDescription('Test Description'),
      cover: const BookCover('test_cover.jpg'),
      tags: [],
      totalChapters: const PositiveInt(1),
      publication: const PositiveInt(2023),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final chapterList = entity.ChapterList(
      data: [
        const entity.Chapter(id: ChapterId('1'),
          index: ChapterIndex(1),
          title: ChapterTitle('Chapter 1 Title'),
          read: false,
        ),
      ],
      nextCursor: null,
      hasNextPage: false,
    );

    final mockState4 = BookDetailsState.initial().copyWith(book: () => book, chapterList: () => chapterList);
    when(() => mockViewModel.state).thenReturn(mockState4);
    when(() => mockViewModel.stateStream).thenAnswer((_) => Stream.value(mockState4));
    stateController.add(mockState4);
    when(() => mockViewModel.book).thenReturn(book);
    when(() => mockViewModel.chapterList).thenReturn(chapterList);

    await tester.pumpApp(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Test Book'), findsOneWidget);
    expect(find.text('Test Author'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);

    // Check for chapters, possibly offstage due to SliverList in CustomScrollView
    expect(find.text('Chapter 1', skipOffstage: false), findsOneWidget);
    expect(find.text('Chapter 1 Title', skipOffstage: false), findsOneWidget);
  });
}
