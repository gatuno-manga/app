import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';

import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';
import 'package:gatuno/features/books/domain/entities/chapter_page_options.dart';
import 'package:gatuno/features/books/domain/repositories/books_repository.dart';
import 'package:gatuno/features/books/presentation/view_models/book_details_view_model.dart';
import 'package:gatuno/features/reading/data/database/reading_database.dart';
import 'package:gatuno/features/reading/domain/use_cases/reading_progress_coordinator.dart';
import 'package:mocktail/mocktail.dart';

class MockBooksRepository extends Mock implements BooksRepository {}

class MockReadingProgressCoordinator extends Mock
    implements ReadingProgressCoordinator {}

void main() {
  late BookDetailsViewModel viewModel;
  late MockBooksRepository mockRepository;
  late MockReadingProgressCoordinator mockProgressCoordinator;
  const bookId = '1';

  setUpAll(() {
    registerFallbackValue(BookId('dummy'));
    registerFallbackValue(ChapterId('dummy'));

    registerFallbackValue(const ChapterPageOptions());
  });

  setUp(() {
    mockRepository = MockBooksRepository();
    mockProgressCoordinator = MockReadingProgressCoordinator();
    viewModel = BookDetailsViewModel(
      repository: mockRepository,
      progressCoordinator: mockProgressCoordinator,
      bookId: bookId,
    );

    // Default stubs
    when(
      () => mockProgressCoordinator.getLastReadChapter(any()),
    ).thenAnswer((_) async => null);
    when(
      () => mockProgressCoordinator.getAllProgressForBook(any()),
    ).thenAnswer((_) async => []);
  });

  group('BookDetailsViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      expect(viewModel.book, null);
      expect(viewModel.chapterList, null);
      expect(viewModel.options.order, ChapterSortOrder.asc);
      expect(viewModel.hasReadingProgress, false);
    });

    test('fetchBookDetails success updates state correctly', () async {
      const book = Book(id: BookId(bookId), title: const BookTitle('Test Book'));
      const chapterList = ChapterList(
        data: [Chapter(id: const ChapterId('1'), index: const ChapterIndex(1.0))],
        hasNextPage: false,
      );

      when(() => mockRepository.getBook(const BookId(bookId))).thenAnswer((_) async => book);
      when(
        () => mockRepository.getBookChapters(const BookId(bookId), any()),
      ).thenAnswer((_) async => chapterList);
      when(
        () => mockProgressCoordinator.getLastReadChapter(const BookId(bookId)),
      ).thenAnswer((_) async => null);
      when(
        () => mockProgressCoordinator.getAllProgressForBook(const BookId(bookId)),
      ).thenAnswer((_) async => []);

      await viewModel.fetchBookDetails();

      expect(viewModel.isLoading, false);
      expect(viewModel.error, null);
      expect(viewModel.book, book);
      expect(viewModel.chapterList?.data.length, chapterList.data.length);
      expect(viewModel.chapterList?.data[0].id, chapterList.data[0].id);
      expect(viewModel.hasReadingProgress, false);
    });

    test('getResumeChapterId returns first chapter when no progress', () async {
      const chapterList = ChapterList(
        data: [
          Chapter(id: const ChapterId('1'), index: const ChapterIndex(1.0)),
          Chapter(id: const ChapterId('2'), index: const ChapterIndex(2.0)),
        ],
        hasNextPage: false,
      );

      when(
        () => mockRepository.getBook(const BookId(bookId)),
      ).thenAnswer((_) async => const Book(id: BookId(bookId), title: const BookTitle('Test')));
      when(
        () => mockRepository.getBookChapters(const BookId(bookId), any()),
      ).thenAnswer((_) async => chapterList);
      when(
        () => mockProgressCoordinator.getLastReadChapter(const BookId(bookId)),
      ).thenAnswer((_) async => null);
      when(
        () => mockProgressCoordinator.getAllProgressForBook(const BookId(bookId)),
      ).thenAnswer((_) async => []);

      await viewModel.fetchBookDetails();

      expect(viewModel.getResumeChapterId(), '1');
    });

    test(
      'getResumeChapterId returns last read chapter when not completed',
      () async {
        const chapterList = ChapterList(
          data: [
            Chapter(id: const ChapterId('1'), index: const ChapterIndex(1.0)),
            Chapter(id: const ChapterId('2'), index: const ChapterIndex(2.0)),
          ],
          hasNextPage: false,
        );
        final progress = ReadingProgressData(
          userId: '1',
          chapterId: '1',
          bookId: bookId,
          pageIndex: 5,
          timestamp: DateTime.now(),
          version: 0,
          completed: false,
        );

        when(
          () => mockRepository.getBook(const BookId(bookId)),
        ).thenAnswer((_) async => const Book(id: BookId(bookId), title: const BookTitle('Test')));
        when(
          () => mockRepository.getBookChapters(const BookId(bookId), any()),
        ).thenAnswer((_) async => chapterList);
        when(
          () => mockProgressCoordinator.getLastReadChapter(const BookId(bookId)),
        ).thenAnswer((_) async => progress);
        when(
          () => mockProgressCoordinator.getAllProgressForBook(const BookId(bookId)),
        ).thenAnswer((_) async => []);

        await viewModel.fetchBookDetails();

        expect(viewModel.getResumeChapterId(), '1');
        expect(viewModel.hasReadingProgress, true);
      },
    );

    test(
      'getResumeChapterId returns next chapter when last read is completed',
      () async {
        const chapterList = ChapterList(
          data: [
            Chapter(id: const ChapterId('1'), index: const ChapterIndex(1.0)),
            Chapter(id: const ChapterId('2'), index: const ChapterIndex(2.0)),
          ],
          hasNextPage: false,
        );
        final progress = ReadingProgressData(
          userId: '1',
          chapterId: '1',
          bookId: bookId,
          pageIndex: 10,
          timestamp: DateTime.now(),
          version: 0,
          completed: true,
        );

        when(
          () => mockRepository.getBook(const BookId(bookId)),
        ).thenAnswer((_) async => const Book(id: BookId(bookId), title: const BookTitle('Test')));
        when(
          () => mockRepository.getBookChapters(const BookId(bookId), any()),
        ).thenAnswer((_) async => chapterList);
        when(
          () => mockProgressCoordinator.getLastReadChapter(const BookId(bookId)),
        ).thenAnswer((_) async => progress);
        when(
          () => mockProgressCoordinator.getAllProgressForBook(const BookId(bookId)),
        ).thenAnswer((_) async => []);

        await viewModel.fetchBookDetails();

        expect(viewModel.getResumeChapterId(), '2');
      },
    );

    test(
      'getResumeChapterId returns current chapter when last is completed but it is the last chapter',
      () async {
        const chapterList = ChapterList(
          data: [Chapter(id: const ChapterId('1'), index: const ChapterIndex(1.0))],
          hasNextPage: false,
        );
        final progress = ReadingProgressData(
          userId: '1',
          chapterId: '1',
          bookId: bookId,
          pageIndex: 10,
          timestamp: DateTime.now(),
          version: 0,
          completed: true,
        );

        when(
          () => mockRepository.getBook(const BookId(bookId)),
        ).thenAnswer((_) async => const Book(id: BookId(bookId), title: const BookTitle('Test')));
        when(
          () => mockRepository.getBookChapters(const BookId(bookId), any()),
        ).thenAnswer((_) async => chapterList);
        when(
          () => mockProgressCoordinator.getLastReadChapter(const BookId(bookId)),
        ).thenAnswer((_) async => progress);
        when(
          () => mockProgressCoordinator.getAllProgressForBook(const BookId(bookId)),
        ).thenAnswer((_) async => []);

        await viewModel.fetchBookDetails();

        expect(viewModel.getResumeChapterId(), '1');
      },
    );

    test('fetchBookDetails failure updates error state', () async {
      when(
        () => mockRepository.getBook(const BookId(bookId)),
      ).thenThrow(Exception('Failed to fetch book'));

      await viewModel.fetchBookDetails();

      expect(viewModel.isLoading, false);
      expect(viewModel.error, 'Exception: Failed to fetch book');
    });

    test('loadMoreChapters success appends chapters', () async {
      const book = Book(id: BookId(bookId), title: const BookTitle('Test Book'));
      const initialChapterList = ChapterList(
        data: [Chapter(id: const ChapterId('1'), index: const ChapterIndex(1.0))],
        nextCursor: 'cursor',
        hasNextPage: true,
      );
      const moreChapterList = ChapterList(
        data: [Chapter(id: const ChapterId('2'), index: const ChapterIndex(2.0))],
        hasNextPage: false,
      );

      when(() => mockRepository.getBook(const BookId(bookId))).thenAnswer((_) async => book);
      when(
        () => mockRepository.getBookChapters(const BookId(bookId), any()),
      ).thenAnswer((_) async => initialChapterList);
      when(
        () => mockProgressCoordinator.getAllProgressForBook(const BookId(bookId)),
      ).thenAnswer((_) async => []);

      await viewModel.fetchBookDetails();

      when(
        () => mockRepository.getBookChapters(const BookId(bookId), any()),
      ).thenAnswer((_) async => moreChapterList);
      when(
        () => mockProgressCoordinator.getAllProgressForBook(const BookId(bookId)),
      ).thenAnswer((_) async => []);

      await viewModel.loadMoreChapters();

      expect(viewModel.isLoading, false);
      expect(viewModel.chapterList?.data.length, 2);
      expect(viewModel.chapterList?.data[1].id.value, '2');
      expect(viewModel.chapterList?.hasNextPage, false);
    });

    test('setChapterOrder changes order and refetches', () async {
      const book = Book(id: BookId(bookId), title: const BookTitle('Test Book'));
      const chapterList = ChapterList(data: [], hasNextPage: false);

      when(() => mockRepository.getBook(const BookId(bookId))).thenAnswer((_) async => book);
      when(
        () => mockRepository.getBookChapters(const BookId(bookId), any()),
      ).thenAnswer((_) async => chapterList);
      when(
        () => mockProgressCoordinator.getAllProgressForBook(const BookId(bookId)),
      ).thenAnswer((_) async => []);

      viewModel.setChapterOrder(ChapterSortOrder.desc);

      expect(viewModel.options.order, ChapterSortOrder.desc);
      expect(
        viewModel.isLoadingChapters,
        true,
      ); // It starts fetching immediately

      await Future<void>.delayed(Duration.zero); // Allow fetch to complete

      verify(
        () => mockRepository.getBookChapters(
          const BookId(bookId),
          any(
            that: predicate<ChapterPageOptions>(
              (o) => o.order == ChapterSortOrder.desc,
            ),
          ),
        ),
      ).called(1);
    });

    test('clearError resets error', () {
      viewModel.clearError(); // Just to trigger it, we need to set error first

      // We can't set error directly, so we trigger a failure
      when(() => mockRepository.getBook(const BookId(bookId))).thenThrow(Exception('Error'));

      return viewModel.fetchBookDetails().then((_) {
        expect(viewModel.error, isNotNull);
        viewModel.clearError();
        expect(viewModel.error, null);
      });
    });

    test(
      'refreshReadStatus updates chapter completed and read state',
      () async {
        const book = Book(id: BookId(bookId), title: const BookTitle('Test Book'));
        const chapterList = ChapterList(
          data: [
            Chapter(id: const ChapterId('1'), index: const ChapterIndex(1.0), read: false, completed: false),
            Chapter(id: const ChapterId('2'), index: const ChapterIndex(2.0), read: false, completed: false),
          ],
          hasNextPage: false,
        );

        when(
          () => mockRepository.getBook(const BookId(bookId)),
        ).thenAnswer((_) async => book);
        when(
          () => mockRepository.getBookChapters(const BookId(bookId), any()),
        ).thenAnswer((_) async => chapterList);
        when(
          () => mockProgressCoordinator.getLastReadChapter(const BookId(bookId)),
        ).thenAnswer((_) async => null);
        when(
          () => mockProgressCoordinator.getAllProgressForBook(const BookId(bookId)),
        ).thenAnswer((_) async => []);

        await viewModel.fetchBookDetails();

        // Now mock progress updates
        final progress1 = ReadingProgressData(
          userId: '1',
          chapterId: '1',
          bookId: bookId,
          pageIndex: 10,
          timestamp: DateTime.now(),
          version: 0,
          completed: true,
        );
        final progress2 = ReadingProgressData(
          userId: '1',
          chapterId: '2',
          bookId: bookId,
          pageIndex: 5,
          timestamp: DateTime.now(),
          version: 0,
          completed: false,
        );

        when(
          () => mockProgressCoordinator.getLastReadChapter(const BookId(bookId)),
        ).thenAnswer((_) async => progress2);
        when(
          () => mockProgressCoordinator.getAllProgressForBook(const BookId(bookId)),
        ).thenAnswer((_) async => [progress1, progress2]);

        await viewModel.refreshReadStatus();

        expect(viewModel.chapterList?.data[0].completed, true);
        expect(viewModel.chapterList?.data[0].read, true);
        expect(viewModel.chapterList?.data[1].completed, false);
        expect(viewModel.chapterList?.data[1].read, true);
      },
    );
  });
}
