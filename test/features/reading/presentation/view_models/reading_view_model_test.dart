import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/reading/domain/entities/opened_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/reading/domain/repositories/reading_repository.dart';
import 'package:gatuno/features/reading/domain/use_cases/reading_progress_coordinator.dart';
import 'package:gatuno/features/reading/domain/value_objects/original_url.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_connectivity_service.dart';

class MockReadingRepository extends Mock implements ReadingRepository {}

class MockReadingProgressCoordinator extends Mock
    implements ReadingProgressCoordinator {}

ReadingChapter _chapter({
  String id = 'chapter-1',
  ChapterId? previous,
  ChapterId? next,
  ContentType contentType = ContentType.image,
}) => ReadingChapter(
  id: ChapterId(id),
  originalUrl: const OriginalUrl('https://origin/c'),
  index: const ChapterIndex(1),
  contentType: contentType,
  retries: const PositiveInt(0),
  isFinal: false,
  previous: previous,
  next: next,
  bookId: const BookId('book-1'),
  bookTitle: const BookTitle('Book'),
  totalChapters: const PositiveInt(3),
  pages: const [],
  comments: const [],
);

/// Lets the view model's unawaited follow-ups (neighbours, navigation) run.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late ReadingViewModel viewModel;
  late MockReadingRepository repository;
  late MockReadingProgressCoordinator coordinator;
  late FakeConnectivityService connectivity;

  const chapterId = 'chapter-1';
  const id = ChapterId(chapterId);

  setUpAll(() {
    registerFallbackValue(const BookId('dummy'));
    registerFallbackValue(const ChapterId('dummy'));
    registerFallbackValue(const PositiveInt(1));
    registerFallbackValue(_chapter());
  });

  void opens(ReadingChapter chapter, {bool downloaded = false}) {
    when(() => repository.openChapter(chapter.id)).thenAnswer(
      (_) async => OpenedChapter(chapter: chapter, isDownloaded: downloaded),
    );
  }

  ReadingViewModel build() =>
      ReadingViewModel(repository, coordinator, connectivity);

  setUp(() {
    repository = MockReadingRepository();
    coordinator = MockReadingProgressCoordinator();
    connectivity = FakeConnectivityService();
    when(
      () => coordinator.saveProgress(
        chapterId: any(named: 'chapterId'),
        bookId: any(named: 'bookId'),
        pageIndex: any(named: 'pageIndex'),
        totalPages: any(named: 'totalPages'),
        completed: any(named: 'completed'),
      ),
    ).thenAnswer((_) async {});
    when(() => repository.isDownloaded(any())).thenAnswer((_) async => false);
    viewModel = build();
  });

  tearDown(() async {
    viewModel.dispose();
    await connectivity.close();
  });

  group('loading', () {
    test('initial state is correct', () {
      expect(viewModel.chapter, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
      expect(viewModel.currentPageIndex, 0);
      expect(viewModel.state.isOffline, isFalse);
    });

    test('starts offline when the server is unreachable', () {
      connectivity = FakeConnectivityService(
        status: ConnectivityStatus.offline,
      );
      final offline = build();
      addTearDown(offline.dispose);

      expect(offline.state.isOffline, isTrue);
    });

    test('loadChapter success updates state', () async {
      final chapter = _chapter();
      opens(chapter);

      final future = viewModel.loadChapter(chapterId);
      expect(viewModel.isLoading, isTrue);
      await future;

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.chapter, chapter);
      expect(viewModel.state.isDownloaded, isFalse);
      expect(viewModel.error, isNull);
    });

    test('loadChapter with initialPage sets currentPageIndex', () async {
      opens(_chapter());

      await viewModel.loadChapter(chapterId, initialPage: 5);

      expect(viewModel.currentPageIndex, 5);
    });

    test('loadChapter failure updates error state', () async {
      when(
        () => repository.openChapter(id),
      ).thenThrow(Exception('Failed to load'));

      await viewModel.loadChapter(chapterId);

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.chapter, isNull);
      expect(viewModel.error, contains('Failed to load'));
      expect(viewModel.state.isOfflineMiss, isFalse);
    });
  });

  group('offline', () {
    test('a chapter that is not saved shows the offline view', () async {
      when(() => repository.openChapter(id)).thenThrow(OfflineException());

      await viewModel.loadChapter(chapterId);

      expect(viewModel.state.isOfflineMiss, isTrue);
      expect(viewModel.error, isNull);
      expect(viewModel.chapter, isNull);
    });

    test('reconnecting reopens a chapter the offline view stood for', () async {
      var calls = 0;
      when(() => repository.openChapter(id)).thenAnswer((_) async {
        if (calls++ == 0) throw OfflineException();
        return OpenedChapter(chapter: _chapter(), isDownloaded: false);
      });
      await viewModel.loadChapter(chapterId, initialPage: 2);

      connectivity.reconnect();
      await _settle();

      expect(viewModel.state.isOfflineMiss, isFalse);
      expect(viewModel.chapter, isNotNull);
      expect(viewModel.currentPageIndex, 2);
    });

    test('reconnecting leaves a chapter read from the server alone', () async {
      opens(_chapter());
      await viewModel.loadChapter(chapterId);

      connectivity.reconnect();
      await _settle();

      verify(() => repository.openChapter(id)).called(1);
      verifyNever(() => repository.refreshNavigation(any()));
    });

    test('retry probes the server, then opens the chapter again', () async {
      var calls = 0;
      when(() => repository.openChapter(id)).thenAnswer((_) async {
        if (calls++ == 0) throw OfflineException();
        return OpenedChapter(chapter: _chapter(), isDownloaded: false);
      });
      await viewModel.loadChapter(chapterId);
      connectivity.probeResult = ConnectivityStatus.online;

      await viewModel.retryOffline();

      expect(connectivity.checks, 1);
      expect(viewModel.state.isRetrying, isFalse);
      expect(viewModel.chapter, isNotNull);
    });

    test('follows the connectivity status', () async {
      connectivity.goOffline();
      await _settle();
      expect(viewModel.state.isOffline, isTrue);

      connectivity.reconnect();
      await _settle();
      expect(viewModel.state.isOffline, isFalse);
    });
  });

  group('neighbours', () {
    test('records which neighbours are downloaded', () async {
      opens(
        _chapter(
          previous: const ChapterId('prev'),
          next: const ChapterId('next'),
        ),
      );
      when(
        () => repository.isDownloaded(const ChapterId('next')),
      ).thenAnswer((_) async => true);

      await viewModel.loadChapter(chapterId);
      await _settle();

      expect(viewModel.state.previousDownloaded, isFalse);
      expect(viewModel.state.nextDownloaded, isTrue);
    });

    test('offline, only downloaded neighbours are available', () async {
      opens(
        _chapter(
          previous: const ChapterId('prev'),
          next: const ChapterId('next'),
        ),
      );
      when(
        () => repository.isDownloaded(const ChapterId('next')),
      ).thenAnswer((_) async => true);
      await viewModel.loadChapter(chapterId);
      await _settle();

      expect(viewModel.state.previousUnavailable, isFalse);

      connectivity.goOffline();
      await _settle();
      expect(viewModel.state.previousUnavailable, isTrue);
      expect(viewModel.state.nextUnavailable, isFalse);

      connectivity.reconnect();
      await _settle();
      expect(viewModel.state.previousUnavailable, isFalse);
    });
  });

  group('downloaded chapters', () {
    test('online, the navigation is refreshed from the server', () async {
      final saved = _chapter(previous: const ChapterId('prev'));
      final refreshed = saved.withNeighbours(
        previous: const ChapterId('prev'),
        next: const ChapterId('new-next'),
      );
      opens(saved, downloaded: true);
      when(
        () => repository.refreshNavigation(saved),
      ).thenAnswer((_) async => refreshed);

      await viewModel.loadChapter(chapterId);
      await _settle();

      expect(viewModel.state.isDownloaded, isTrue);
      expect(viewModel.chapter!.next, const ChapterId('new-next'));
      verify(() => repository.isDownloaded(const ChapterId('new-next')));
    });

    test('offline, the saved navigation is kept', () async {
      connectivity.goOffline();
      opens(_chapter(), downloaded: true);

      await viewModel.loadChapter(chapterId);
      await _settle();

      verifyNever(() => repository.refreshNavigation(any()));
    });

    test('a failed refresh keeps the saved chapter', () async {
      final saved = _chapter(next: const ChapterId('next'));
      opens(saved, downloaded: true);
      when(
        () => repository.refreshNavigation(saved),
      ).thenThrow(NetworkException());

      await viewModel.loadChapter(chapterId);
      await _settle();

      expect(viewModel.chapter, saved);
      expect(viewModel.error, isNull);
    });

    test('reconnecting refreshes the navigation', () async {
      connectivity.goOffline();
      final saved = _chapter();
      opens(saved, downloaded: true);
      when(
        () => repository.refreshNavigation(saved),
      ).thenAnswer((_) async => saved);
      await viewModel.loadChapter(chapterId);

      connectivity.reconnect();
      await _settle();

      verify(() => repository.refreshNavigation(saved)).called(1);
    });
  });

  group('progress', () {
    test('setCurrentPage updates currentPageIndex once per change', () async {
      var emissions = 0;
      final sub = viewModel.stateStream.listen((_) => emissions++);

      viewModel.setCurrentPage(3, isAutoSave: false);
      expect(viewModel.currentPageIndex, 3);
      await _settle();
      expect(emissions, 2);

      viewModel.setCurrentPage(3, isAutoSave: false);
      await _settle();
      expect(emissions, 2);
      await sub.cancel();
    });

    test('setCurrentPage saves progress', () async {
      opens(_chapter());

      await viewModel.loadChapter(chapterId);
      viewModel.setCurrentPage(3);

      verify(
        () => coordinator.saveProgress(
          chapterId: id,
          bookId: const BookId('book-1'),
          pageIndex: const PositiveInt(3),
          totalPages: const PositiveInt(0),
          completed: false,
        ),
      ).called(1);
    });

    test('a downloaded chapter saves progress offline', () async {
      connectivity.goOffline();
      opens(_chapter(contentType: ContentType.text), downloaded: true);

      await viewModel.loadChapter(chapterId);

      verify(
        () => coordinator.saveProgress(
          chapterId: id,
          bookId: const BookId('book-1'),
          pageIndex: const PositiveInt(0),
          totalPages: const PositiveInt(0),
          completed: true,
        ),
      ).called(1);
    });
  });
}
