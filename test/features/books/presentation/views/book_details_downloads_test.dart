import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/presentation/components/atoms/chapter_download_indicator.dart';
import 'package:gatuno/features/books/presentation/components/molecules/chapter_selection_actions.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/books/presentation/view_models/book_details_view_model.dart';
import 'package:gatuno/features/books/presentation/view_models/book_downloads_view_model.dart';
import 'package:gatuno/features/books/presentation/views/book_details_screen.dart';
import 'package:gatuno/features/downloads/domain/entities/chapter_download.dart';
import 'package:gatuno/features/downloads/domain/entities/download_scope.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/shared/components/atoms/app_text_button.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_injection.dart';
import '../../helpers/book_downloads_fixture.dart';

class MockBookDetailsViewModel extends Mock implements BookDetailsViewModel {}

const c1 = ChapterId('c1');
const c2 = ChapterId('c2');
const c3 = ChapterId('c3');

void main() {
  final fixture = BookDownloadsFixture();
  late MockBookDetailsViewModel details;
  late BookDownloadsViewModel downloads;

  setUpAll(() {
    BookDownloadsFixture.registerFallbacks();
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() async {
    final dioClient = MockDioClient();
    await initTestDI(dioClient: dioClient);
    when(
      () => (dioClient.dio as MockDio).get<List<int>>(
        any(),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response(
        data: <int>[],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );

    const book = Book(
      id: fixtureBook,
      title: BookTitle('Test Book'),
      totalChapters: PositiveInt(3),
    );
    final chapters = ChapterList(
      data: [
        for (final (i, id) in [c1, c2, c3].indexed)
          Chapter(id: id, index: ChapterIndex(i + 1)),
      ],
      nextCursor: null,
      hasNextPage: false,
    );
    final state = BookDetailsState.initial().copyWith(
      book: () => book,
      chapterList: () => chapters,
    );
    details = MockBookDetailsViewModel();
    when(() => details.state).thenReturn(state);
    when(() => details.stateStream).thenAnswer((_) => Stream.value(state));
    when(() => details.chapterList).thenReturn(chapters);
    when(() => details.isLoadingChapters).thenReturn(false);
    when(() => details.hasReadingProgress).thenReturn(false);
    when(() => details.chaptersError).thenReturn(null);
    when(() => details.fetchBookDetails()).thenAnswer((_) async {});
    when(() => details.loadMoreChapters()).thenAnswer((_) async {});

    fixture.setUp();
  });

  tearDown(() async {
    downloads.dispose();
    await fixture.tearDown();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    downloads = fixture.build();
    await tester.pumpApp(
      Provider<BookDetailsViewModel>.value(
        value: details,
        child: Provider<BookDownloadsViewModel>.value(
          value: downloads,
          child: const BookDetailsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> show(WidgetTester tester, List<ChapterDownload> chapters) async {
    fixture.show(chapters);
    await tester.pumpAndSettle();
  }

  /// An action of the selection mode's bottom bar.
  Finder barAction(String label) => find.descendant(
    of: find.byType(ChapterSelectionActions),
    matching: find.text(label),
  );

  Future<void> openOptions(WidgetTester tester) async {
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
  }

  group('chapter indicator', () {
    testWidgets('no downloads: no summary, and a tap downloads', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.textContaining('chapters downloaded'), findsNothing);
      expect(
        find.bySemanticsLabel('Not downloaded. Tap to download'),
        findsNWidgets(3),
      );

      await tester.tap(
        find.bySemanticsLabel('Not downloaded. Tap to download').first,
      );
      await tester.pumpAndSettle();

      verify(() => fixture.downloads.enqueueChapters(fixtureBook, [c1]));
    });

    testWidgets('an active chapter pauses on tap', (tester) async {
      await pumpPage(tester);
      await show(tester, [
        chapterDownload(c1, DownloadState.running, filesDone: 1, filesTotal: 2),
      ]);

      await tester.tap(find.bySemanticsLabel('Downloading, 50%. Tap to pause'));
      await tester.pumpAndSettle();

      verify(() => fixture.downloads.pause(const DownloadScope.chapters([c1])));
    });

    testWidgets('a failed chapter opens its sheet; Try again retries', (
      tester,
    ) async {
      await pumpPage(tester);
      await show(tester, [
        chapterDownload(
          c1,
          DownloadState.failed,
          error: DownloadErrors.storageFull,
        ),
      ]);

      await tester.tap(
        find.bySemanticsLabel('Download failed. Tap for options'),
      );
      await tester.pumpAndSettle();

      expect(find.text('The download failed'), findsOneWidget);
      expect(
        find.text("There isn't enough free space on this device."),
        findsOneWidget,
      );

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      verify(() => fixture.downloads.retry(const DownloadScope.chapters([c1])));
      expect(find.text('The download failed'), findsNothing);
    });

    testWidgets('a downloaded chapter opens its sheet; Delete deletes', (
      tester,
    ) async {
      await pumpPage(tester);
      await show(tester, [
        chapterDownload(c1, DownloadState.done, bytes: 2048),
      ]);

      await tester.tap(find.bySemanticsLabel('Downloaded. Tap for options'));
      await tester.pumpAndSettle();

      expect(find.text('Downloaded · 2 KB'), findsOneWidget);

      await tester.tap(find.text('Delete download'));
      await tester.pumpAndSettle();

      verify(
        () => fixture.downloads.delete(const DownloadScope.chapters([c1])),
      );
    });
  });

  group('summary', () {
    testWidgets('counts against the total and pauses all', (tester) async {
      await pumpPage(tester);
      await show(tester, [
        chapterDownload(c1, DownloadState.running, filesDone: 1, filesTotal: 2),
        chapterDownload(c2, DownloadState.done, bytes: 1024),
      ]);

      expect(find.text('1 of 3 chapters downloaded · 1 KB'), findsOneWidget);
      expect(find.text('Downloading 1 chapter'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Pause all'));
      await tester.pumpAndSettle();

      verify(
        () => fixture.downloads.pause(const DownloadScope.book(fixtureBook)),
      );
    });

    testWidgets('failed chapters offer a retry with their count', (
      tester,
    ) async {
      await pumpPage(tester);
      await show(tester, [
        chapterDownload(c1, DownloadState.failed),
        chapterDownload(c2, DownloadState.failed),
      ]);

      expect(find.text('2 chapters failed'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);

      await tester.tap(find.text('Try again (2)'));
      await tester.pumpAndSettle();

      verify(
        () => fixture.downloads.retry(const DownloadScope.book(fixtureBook)),
      );
    });
  });

  group('book options', () {
    testWidgets('Download all downloads the whole book', (tester) async {
      await pumpPage(tester);
      await openOptions(tester);

      expect(find.text('Book options'), findsOneWidget);
      expect(find.text('Delete all downloads'), findsNothing);

      await tester.tap(find.text('Download all'));
      await tester.pumpAndSettle();

      verify(() => fixture.downloads.enqueueBook(fixtureBook));
      expect(find.text('Book options'), findsNothing);
    });

    testWidgets('offline, Download all is disabled', (tester) async {
      fixture.connectivity.subject.add(ConnectivityStatus.offline);
      await pumpPage(tester);
      await openOptions(tester);

      expect(find.text('Needs a connection to the server'), findsOneWidget);

      await tester.tap(find.text('Download all'));
      await tester.pumpAndSettle();

      verifyNever(() => fixture.downloads.enqueueBook(any()));
    });

    testWidgets('Delete all asks first, with the count', (tester) async {
      await pumpPage(tester);
      await show(tester, [
        chapterDownload(c1, DownloadState.done, bytes: 1024),
        chapterDownload(c2, DownloadState.paused),
      ]);
      await openOptions(tester);

      expect(find.text('2 chapters · 1 KB'), findsOneWidget);

      await tester.tap(find.text('Delete all downloads'));
      await tester.pumpAndSettle();

      expect(find.text('Delete all downloads of this book?'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppTextButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(
        () => fixture.downloads.delete(const DownloadScope.book(fixtureBook)),
      );
    });

    testWidgets('cancelling Delete all keeps the downloads', (tester) async {
      await pumpPage(tester);
      await show(tester, [chapterDownload(c1, DownloadState.done)]);
      await openOptions(tester);
      await tester.tap(find.text('Delete all downloads'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppTextButton, 'Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => fixture.downloads.delete(any()));
    });

    testWidgets('the switch turns automatic download on', (tester) async {
      await pumpPage(tester);
      await openOptions(tester);

      await tester.tap(find.text('Download new chapters'));
      await tester.pumpAndSettle();

      verify(() => fixture.prefs.enable(fixtureBook));
      verifyNever(() => fixture.downloads.enqueueBook(any()));
    });
  });

  group('selection', () {
    testWidgets('long press enters, a tap toggles, Download acts and leaves', (
      tester,
    ) async {
      await pumpPage(tester);

      await tester.longPress(find.text('Chapter 1'));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('Select'), findsNothing);
      expect(
        find.byType(ChapterDownloadIndicator),
        findsNWidgets(3),
        reason: 'indicators stay visible',
      );
      expect(
        tester
            .widgetList<ChapterDownloadIndicator>(
              find.byType(ChapterDownloadIndicator),
            )
            .map((i) => i.semanticLabel),
        everyElement('Not downloaded'),
        reason: 'display-only indicators drop the tap hint',
      );

      await tester.tap(find.text('Chapter 2'));
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsOneWidget);

      await tester.tap(barAction('Download'));
      await tester.pumpAndSettle();

      verify(() => fixture.downloads.enqueueChapters(fixtureBook, [c1, c2]));
      expect(find.text('2 selected'), findsNothing);
    });

    testWidgets('a tap on an indicator toggles instead of downloading', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.longPress(find.text('Chapter 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ChapterDownloadIndicator).at(1));
      await tester.pumpAndSettle();

      expect(find.text('2 selected'), findsOneWidget);
      verifyNever(() => fixture.downloads.enqueueChapters(any(), any()));
    });

    testWidgets('the Select button enters with nothing picked', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      expect(find.text('None selected'), findsOneWidget);

      await tester.tap(barAction('Download'));
      await tester.pumpAndSettle();

      verifyNever(() => fixture.downloads.enqueueChapters(any(), any()));
      expect(find.text('None selected'), findsOneWidget);
    });

    testWidgets('select loaded picks every chapter, then disables', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Select loaded chapters'));
      await tester.pumpAndSettle();

      expect(find.text('3 selected'), findsOneWidget);
      final button = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.done_all),
          matching: find.byType(IconButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('deleting several downloaded chapters asks first', (
      tester,
    ) async {
      await pumpPage(tester);
      await show(tester, [
        chapterDownload(c1, DownloadState.done, bytes: 1024),
        chapterDownload(c2, DownloadState.done, bytes: 1024),
      ]);
      await tester.longPress(find.text('Chapter 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chapter 2'));
      await tester.pumpAndSettle();

      await tester.tap(barAction('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete 2 chapters?'), findsOneWidget);

      await tester.tap(find.widgetWithText(AppTextButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(
        () => fixture.downloads.delete(const DownloadScope.chapters([c1, c2])),
      );
    });

    testWidgets('Delete is disabled when nothing selected is downloaded', (
      tester,
    ) async {
      await pumpPage(tester);
      await tester.longPress(find.text('Chapter 1'));
      await tester.pumpAndSettle();

      await tester.tap(barAction('Delete'));
      await tester.pumpAndSettle();

      verifyNever(() => fixture.downloads.delete(any()));
    });

    testWidgets('the paused selection offers Resume', (tester) async {
      await pumpPage(tester);
      await show(tester, [chapterDownload(c1, DownloadState.paused)]);
      await tester.longPress(find.text('Chapter 1'));
      await tester.pumpAndSettle();

      expect(barAction('Pause'), findsNothing);
      expect(barAction('Retry'), findsNothing);

      await tester.tap(barAction('Resume'));
      await tester.pumpAndSettle();

      verify(
        () => fixture.downloads.resume(const DownloadScope.chapters([c1])),
      );
    });

    testWidgets('close and Back leave selection mode', (tester) async {
      await pumpPage(tester);
      await tester.longPress(find.text('Chapter 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Leave selection'));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsNothing);

      await tester.longPress(find.text('Chapter 1'));
      await tester.pumpAndSettle();
      final popped = await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(find.text('1 selected'), findsNothing);
      expect(find.text('Test Book'), findsOneWidget);
    });
  });

  testWidgets('the last chapter clears the selection bar', (tester) async {
    await pumpPage(tester);
    await tester.longPress(find.text('Chapter 1'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await tester.pumpAndSettle();

    final bar = tester.getRect(find.byType(ChapterSelectionActions));
    expect(bar.height, lessThan(120), reason: 'the bar keeps its height');
    expect(
      tester.getRect(find.byType(ListTile).last).bottom,
      lessThanOrEqualTo(bar.top),
    );
  });

  testWidgets('chapters still being scraped cannot be selected', (
    tester,
  ) async {
    final chapters = ChapterList(
      data: const [
        Chapter(id: c1, index: ChapterIndex(1)),
        Chapter(
          id: c2,
          index: ChapterIndex(2),
          scrapingStatus: ScrapingStatus.process,
        ),
      ],
      nextCursor: null,
      hasNextPage: false,
    );
    when(() => details.chapterList).thenReturn(chapters);
    await pumpPage(tester);

    expect(find.byType(ChapterDownloadIndicator), findsOneWidget);

    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chapter 2'));
    await tester.pumpAndSettle();
    expect(find.text('None selected'), findsOneWidget);

    await tester.tap(find.byTooltip('Select loaded chapters'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(barAction('Download'));
    await tester.pumpAndSettle();
    verify(() => fixture.downloads.enqueueChapters(fixtureBook, [c1]));
  });

  testWidgets('Delete all of one download reads in the singular', (
    tester,
  ) async {
    await pumpPage(tester);
    await show(tester, [chapterDownload(c1, DownloadState.done, bytes: 1024)]);
    await openOptions(tester);
    await tester.tap(find.text('Delete all downloads'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'The chapter will be deleted from this device, freeing 1\u00A0KB. '
        'You can download it again later.',
      ),
      findsOneWidget,
    );
  });

  group('offline and guest', () {
    testWidgets('offline, an active chapter waits for connection', (
      tester,
    ) async {
      fixture.connectivity.subject.add(ConnectivityStatus.offline);
      await pumpPage(tester);
      await show(tester, [chapterDownload(c1, DownloadState.queued)]);

      expect(
        find.bySemanticsLabel('Waiting for connection. Tap to pause'),
        findsOneWidget,
      );
      expect(find.text('Waiting for connection'), findsOneWidget);
    });

    testWidgets('a guest is asked to sign in instead of downloading', (
      tester,
    ) async {
      fixture.authState.add(AuthState.unauthenticated);
      await pumpPage(tester);

      await tester.tap(
        find.bySemanticsLabel('Not downloaded. Tap to download').first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign in to download chapters.'), findsOneWidget);
      verifyNever(() => fixture.downloads.enqueueChapters(any(), any()));

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Signin Page'), findsOneWidget);
    });

    testWidgets('a guest turning automatic download on sees the prompt', (
      tester,
    ) async {
      fixture.authState.add(AuthState.unauthenticated);
      await pumpPage(tester);
      await openOptions(tester);

      await tester.tap(find.text('Download new chapters'));
      await tester.pumpAndSettle();

      expect(find.text('Book options'), findsNothing);
      expect(find.text('Sign in to download chapters.'), findsOneWidget);
      verifyNever(() => fixture.prefs.enable(any()));
    });

    testWidgets('a failing command shows an error', (tester) async {
      when(
        () => fixture.downloads.enqueueChapters(any(), any()),
      ).thenThrow(Exception('boom'));
      await pumpPage(tester);

      await tester.tap(
        find.bySemanticsLabel('Not downloaded. Tap to download').first,
      );
      await tester.pumpAndSettle();

      expect(
        find.text("Couldn't update the downloads. Try again."),
        findsOneWidget,
      );
    });
  });
}
