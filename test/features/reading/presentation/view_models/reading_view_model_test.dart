import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/repositories/reading_repository.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockReadingRepository extends Mock implements ReadingRepository {}

class FakeReadingChapter extends Fake implements ReadingChapter {
  @override
  String get title => 'Test Chapter';
}

void main() {
  late ReadingViewModel viewModel;
  late MockReadingRepository mockRepository;

  setUp(() {
    mockRepository = MockReadingRepository();
    viewModel = ReadingViewModel(mockRepository);
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
        () => mockRepository.getChapter(chapterId),
      ).thenAnswer((_) async => mockChapter);

      final future = viewModel.loadChapter(chapterId);

      expect(viewModel.isLoading, isTrue);
      expect(viewModel.error, isNull);

      await future;

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.chapter, mockChapter);
      expect(viewModel.error, isNull);
      verify(() => mockRepository.getChapter(chapterId)).called(1);
    });

    test(
      'loadChapter success with initialPage updates currentPageIndex',
      () async {
        final mockChapter = FakeReadingChapter();
        when(
          () => mockRepository.getChapter(chapterId),
        ).thenAnswer((_) async => mockChapter);

        await viewModel.loadChapter(chapterId, initialPage: 5);

        expect(viewModel.currentPageIndex, 5);
      },
    );

    test('loadChapter failure updates error state', () async {
      when(
        () => mockRepository.getChapter(chapterId),
      ).thenThrow(Exception('Failed to load'));

      await viewModel.loadChapter(chapterId);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.chapter, isNull);
      expect(viewModel.error, contains('Failed to load'));
    });

    test('setCurrentPage updates currentPageIndex and notifies listeners', () {
      int listenerCount = 0;
      viewModel.addListener(() => listenerCount++);

      viewModel.setCurrentPage(3);

      expect(viewModel.currentPageIndex, 3);
      expect(listenerCount, 1);

      // Setting same page should not notify
      viewModel.setCurrentPage(3);
      expect(listenerCount, 1);
    });
  });
}
