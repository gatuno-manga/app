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
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() async {
    mockDioClient = MockDioClient();
    mockDio = mockDioClient.dio as MockDio;

    await initTestDI(dioClient: mockDioClient);

    mockViewModel = MockBookDetailsViewModel();

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
    when(() => mockViewModel.addListener(any())).thenReturn(null);
    when(() => mockViewModel.removeListener(any())).thenReturn(null);

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

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<BookDetailsViewModel>.value(
      value: mockViewModel,
      child: const BookDetailsPage(),
    );
  }

  testWidgets('renders loading state', (tester) async {
    when(() => mockViewModel.isLoading).thenReturn(true);

    await tester.pumpApp(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders error state', (tester) async {
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
        const entity.Chapter(id: const ChapterId('1'),
          index: const ChapterIndex(1),
          title: const ChapterTitle('Chapter 1 Title'),
          read: false,
        ),
      ],
      nextCursor: null,
      hasNextPage: false,
    );

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
