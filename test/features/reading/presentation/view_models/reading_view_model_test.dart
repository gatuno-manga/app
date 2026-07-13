import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';


import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/reading/domain/repositories/reading_repository.dart';
import 'package:gatuno/features/reading/domain/use_cases/reading_progress_coordinator.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:mocktail/mocktail.dart';



class MockReadingRepository extends Mock implements ReadingRepository {}

class MockReadingProgressCoordinator extends Mock
    implements ReadingProgressCoordinator {}

class FakeReadingChapter extends Fake implements ReadingChapter {
  @override
  ChapterId get id => ChapterId('chapter-1');
  @override
  BookId get bookId => BookId('book-1');
  @override
  ChapterTitle get title => ChapterTitle('Test Chapter');
  @override
  List<ReadingPage> get pages => [];
  @override
  ContentType get contentType => ContentType.image;
}

void main() {
  late ReadingViewModel viewModel;
  late MockReadingRepository mockRepository;
  late MockReadingProgressCoordinator mockCoordinator;

    setUpAll(() {
    registerFallbackValue(BookId('dummy'));
    registerFallbackValue(ChapterId('dummy'));
    registerFallbackValue(const PositiveInt(1));
  });

setUp(() {
    mockRepository = MockReadingRepository();
    mockCoordinator = MockReadingProgressCoordinator();
    viewModel = ReadingViewModel(mockRepository, mockCoordinator);

    registerFallbackValue(false);
  });

  group('ReadingViewModel', () {
    const chapterId = 'chapter-1';

    test('initial state is correct', () {
      expect(viewModel.chapter, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.currentPageIndex, 0);
    });

    test('loadChapter success updates state correctly', () async {
      final mockChapter = FakeReadingChapter();
      when(
        () => mockRepository.getChapter(const ChapterId(chapterId)),
      ).thenAnswer((_) async => mockChapter);

      final future = viewModel.loadChapter(chapterId);

      expect(viewModel.isLoading, isTrue);
      expect(viewModel.error, isNull);

      await future;

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.chapter, mockChapter);
      expect(viewModel.error, isNull);
      verify(() => mockRepository.getChapter(const ChapterId(chapterId))).called(1);
    });

    test(
      'loadChapter success with initialPage updates currentPageIndex',
      () async {
        final mockChapter = FakeReadingChapter();
        when(
          () => mockRepository.getChapter(const ChapterId(chapterId)),
        ).thenAnswer((_) async => mockChapter);

        await viewModel.loadChapter(chapterId, initialPage: 5);

        expect(viewModel.currentPageIndex, 5);
      },
    );

    test('loadChapter failure updates error state', () async {
      when(
        () => mockRepository.getChapter(const ChapterId(chapterId)),
      ).thenThrow(Exception('Failed to load'));

      await viewModel.loadChapter(chapterId);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.chapter, isNull);
      expect(viewModel.error, contains('Failed to load'));
    });

    test('setCurrentPage updates currentPageIndex and notifies listeners', () async {
      int listenerCount = 0;
      final sub = viewModel.stateStream.listen((_) => listenerCount++);

      viewModel.setCurrentPage(3, isAutoSave: false);

      expect(viewModel.currentPageIndex, 3);
      // Let stream emit
      await Future.delayed(Duration.zero);
      expect(listenerCount, 2); 

      // Setting same page should not notify
      viewModel.setCurrentPage(3, isAutoSave: false);
      await Future.delayed(Duration.zero);
      expect(listenerCount, 2);
      sub.cancel();
    });

    test('setCurrentPage calls saveProgress when isAutoSave is true', () async {
      final mockChapter = FakeReadingChapter();
      when(
        () => mockRepository.getChapter(const ChapterId(chapterId)),
      ).thenAnswer((_) async => mockChapter);

      when(
        () => mockCoordinator.saveProgress(
          chapterId: any(named: 'chapterId'),
          bookId: any(named: 'bookId'),
          pageIndex: any(named: 'pageIndex'),
          totalPages: any(named: 'totalPages'),
          completed: any(named: 'completed'),
        ),
      ).thenAnswer((_) async {});

      await viewModel.loadChapter(chapterId);
      viewModel.setCurrentPage(3);

      verify(
        () => mockCoordinator.saveProgress(
          chapterId: const ChapterId('chapter-1'),
          bookId: const BookId('book-1'),
          pageIndex: const PositiveInt(3),
          totalPages: const PositiveInt(0),
          completed: false,
        ),
      ).called(1);
    });
  });
}
