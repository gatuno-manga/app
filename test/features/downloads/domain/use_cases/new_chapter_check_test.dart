import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_records.dart';
import 'package:gatuno/features/downloads/data/database/downloads_database.dart';
import 'package:gatuno/features/downloads/data/repositories/records_new_chapter_ledger.dart';
import 'package:gatuno/features/downloads/domain/entities/book_download.dart';
import 'package:gatuno/features/downloads/domain/entities/chapter_download.dart';
import 'package:gatuno/features/downloads/domain/entities/download_scope.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/downloads/domain/entities/listed_chapter.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_service.dart';
import 'package:gatuno/features/downloads/domain/repositories/new_chapter_ledger.dart';
import 'package:gatuno/features/downloads/domain/repositories/new_chapter_source.dart';
import 'package:gatuno/features/downloads/domain/use_cases/new_chapter_check.dart';
import 'package:mocktail/mocktail.dart';

class MockDownloadService extends Mock implements DownloadService {}

class MockLedger extends Mock implements NewChapterLedger {}

/// Serves [chapters] by book; books not in it are "not returned".
class FakeSource implements NewChapterSource {
  final Map<BookId, List<ListedChapter>> chapters = {};
  final List<List<BookId>> calls = [];
  Object? error;
  void Function()? onCall;

  @override
  Future<Map<BookId, List<ListedChapter>>> chaptersOf(
    List<BookId> bookIds,
  ) async {
    calls.add(bookIds);
    onCall?.call();
    if (error != null) throw error!;
    return {for (final id in bookIds) id: ?chapters[id]};
  }
}

ListedChapter ready(String id) => ListedChapter(id: ChapterId(id), ready: true);
ListedChapter scraping(String id) =>
    ListedChapter(id: ChapterId(id), ready: false);

void main() {
  const bookA = BookId('book-a');
  const bookB = BookId('book-b');
  late DownloadsDatabase db;
  late DownloadRecords records;
  late RecordsNewChapterLedger ledger;
  late FakeSource source;
  late MockDownloadService downloads;
  late Map<BookId, BookDownload?> existing;
  late bool signedIn;
  late String? server;
  late DateTime now;
  late NewChapterCheck check;

  setUpAll(() {
    registerFallbackValue(bookA);
    registerFallbackValue(const DownloadScope.all());
  });

  setUp(() {
    db = DownloadsDatabase(NativeDatabase.memory());
    records = DownloadRecords(db);
    ledger = RecordsNewChapterLedger(records);
    source = FakeSource();
    downloads = MockDownloadService();
    existing = {};
    signedIn = true;
    server = 'https://a.example/api';
    now = DateTime(2026, 11, 15, 12);
    when(() => downloads.watchBook(any())).thenAnswer(
      (i) => Stream.value(existing[i.positionalArguments[0] as BookId]),
    );
    when(
      () => downloads.enqueueChapters(any(), any()),
    ).thenAnswer((_) async {});
    when(() => downloads.delete(any())).thenAnswer((_) async {});
    check = NewChapterCheck(
      ledger: ledger,
      source: source,
      downloads: downloads,
      signedIn: () async => signedIn,
      server: () => server,
      now: () => now,
    );
  });

  tearDown(() => db.close());

  Future<void> enable(BookId book) =>
      records.enableAutoDownload(book.value, DateTime(2026, 11, 15, 10));

  /// Turns [book] on and records its baseline with [chapters].
  Future<void> withBaseline(BookId book, List<ListedChapter> chapters) async {
    await enable(book);
    source.chapters[book] = chapters;
    await check.run(only: book);
    now = now.add(const Duration(hours: 6));
  }

  test(
    'the first check records the existing chapters and queues none',
    () async {
      await enable(bookA);
      source.chapters[bookA] = [ready('c1'), scraping('c2')];

      final result = await check.run();

      expect(result.outcome, NewChapterCheckOutcome.done);
      expect(result.queued, isEmpty);
      verifyNever(() => downloads.enqueueChapters(any(), any()));
      expect(await ledger.seen(bookA), {
        const ChapterId('c1'),
        const ChapterId('c2'),
      });
    },
  );

  test('queues a ready chapter that appeared after the baseline', () async {
    await withBaseline(bookA, [ready('c1')]);
    source.chapters[bookA] = [ready('c1'), ready('c2'), scraping('c3')];

    final result = await check.run();

    expect(result.queued, {
      bookA: [const ChapterId('c2')],
    });
    verify(
      () => downloads.enqueueChapters(bookA, [const ChapterId('c2')]),
    ).called(1);
    expect(await ledger.seen(bookA), contains(const ChapterId('c2')));
    expect(await ledger.seen(bookA), isNot(contains(const ChapterId('c3'))));
  });

  test('a chapter scraping now is queued once it is ready', () async {
    await withBaseline(bookA, [ready('c1')]);
    source.chapters[bookA] = [ready('c1'), scraping('c2')];
    await check.run();

    source.chapters[bookA] = [ready('c1'), ready('c2')];
    final result = await check.run();

    expect(result.queued, {
      bookA: [const ChapterId('c2')],
    });
  });

  test('a queued chapter is not queued again, even once deleted', () async {
    await withBaseline(bookA, [ready('c1')]);
    source.chapters[bookA] = [ready('c1'), ready('c2')];
    await check.run();

    final result = await check.run();

    expect(result.queued, isEmpty);
    verify(() => downloads.enqueueChapters(any(), any())).called(1);
  });

  test('a new chapter downloaded by hand is recorded, not resumed', () async {
    await withBaseline(bookA, [ready('c1')]);
    source.chapters[bookA] = [ready('c1'), ready('c2')];
    existing[bookA] = const BookDownload(
      bookId: bookA,
      chapters: [
        ChapterDownload(
          chapterId: ChapterId('c2'),
          bookId: bookA,
          state: DownloadState.paused,
        ),
      ],
    );

    final result = await check.run();

    expect(result.queued, isEmpty);
    verifyNever(() => downloads.enqueueChapters(any(), any()));
    expect(await ledger.seen(bookA), contains(const ChapterId('c2')));
  });

  test('signed out: nothing is read or written', () async {
    await enable(bookA);
    signedIn = false;

    final result = await check.run();

    expect(result.outcome, NewChapterCheckOutcome.signedOut);
    expect(source.calls, isEmpty);
    expect((await ledger.books()).single.checkedAt, isNull);
  });

  test('without a server nothing is read', () async {
    await enable(bookA);
    server = null;

    expect((await check.run()).outcome, NewChapterCheckOutcome.noServer);
    expect(source.calls, isEmpty);
  });

  test('a server change mid-check stops before queueing', () async {
    await withBaseline(bookA, [ready('c1')]);
    source.chapters[bookA] = [ready('c1'), ready('c2')];
    source.onCall = () => server = 'https://b.example/api';

    final result = await check.run();

    expect(result.outcome, NewChapterCheckOutcome.serverChanged);
    verifyNever(() => downloads.enqueueChapters(any(), any()));
  });

  test('a book the server did not return is skipped, setting kept', () async {
    await enable(bookA);
    await enable(bookB);
    source.chapters[bookB] = [ready('c1')];

    final result = await check.run();

    expect(result.outcome, NewChapterCheckOutcome.done);
    final books = await ledger.books();
    expect(books.map((b) => b.bookId), containsAll([bookA, bookB]));
    final missing = books.firstWhere((b) => b.bookId == bookA);
    // Checked, so it does not hold the first slot of every run.
    expect(missing.checkedAt, now);
    expect(missing.hasBaseline, isFalse);
    expect(books.firstWhere((b) => b.bookId == bookB).hasBaseline, isTrue);
  });

  test('a book turned off while the server answers gets nothing', () async {
    await withBaseline(bookA, [ready('c1')]);
    source.chapters[bookA] = [ready('c1'), ready('c2')];
    source.onCall = () => unawaited(records.disableAutoDownload('book-a'));

    final result = await check.run();

    expect(result.queued, isEmpty);
    verifyNever(() => downloads.enqueueChapters(any(), any()));
  });

  test('a book turned off while queueing gets its chapters back', () async {
    await withBaseline(bookA, [ready('c1')]);
    source.chapters[bookA] = [ready('c1'), ready('c2')];
    when(
      () => downloads.enqueueChapters(any(), any()),
    ).thenAnswer((_) => records.disableAutoDownload('book-a'));

    final result = await check.run();

    expect(result.queued, isEmpty);
    verify(
      () => downloads.delete(const DownloadScope.chapters([ChapterId('c2')])),
    ).called(1);
  });

  test('stops before the next book once asked to', () async {
    await enable(bookA);
    await enable(bookB);
    source.chapters[bookA] = [ready('c1')];
    source.chapters[bookB] = [ready('c1')];
    var stop = false;
    source.onCall = () => stop = true;

    final result = await check.run(stopRequested: () => stop);

    expect(result.outcome, NewChapterCheckOutcome.stopped);
    expect((await ledger.books()).every((b) => b.checkedAt == null), isTrue);
  });

  test('a failure reading the records is reported, not thrown', () async {
    final broken = MockLedger();
    when(broken.books).thenThrow(StateError('database closed'));
    check = NewChapterCheck(
      ledger: broken,
      source: source,
      downloads: downloads,
      signedIn: () async => true,
      server: () => server,
    );

    expect((await check.run()).outcome, NewChapterCheckOutcome.failed);
    expect(
      (await check.runIfStale(const Duration(hours: 1)))?.outcome,
      NewChapterCheckOutcome.failed,
    );
  });

  test('a server error ends the check as failed', () async {
    await enable(bookA);
    source.error = ServerException();

    expect((await check.run()).outcome, NewChapterCheckOutcome.failed);
    expect((await ledger.books()).single.checkedAt, isNull);
  });

  test('a failed enqueue leaves the chapter new for the next check', () async {
    await withBaseline(bookA, [ready('c1')]);
    source.chapters[bookA] = [ready('c1'), ready('c2')];
    when(
      () => downloads.enqueueChapters(any(), any()),
    ).thenThrow(Exception('disk'));

    final result = await check.run();

    expect(result.outcome, NewChapterCheckOutcome.done);
    expect(result.queued, isEmpty);
    expect(await ledger.seen(bookA), isNot(contains(const ChapterId('c2'))));
  });

  test('reads books in batches of the source limit', () async {
    for (var i = 0; i < NewChapterSource.maxBooks + 1; i++) {
      await enable(BookId('book-$i'));
    }

    await check.run();

    expect(source.calls.map((c) => c.length), [NewChapterSource.maxBooks, 1]);
  });

  test('stops at the deadline; the next run starts with the rest', () async {
    for (var i = 0; i < NewChapterSource.maxBooks + 1; i++) {
      await enable(BookId('book-$i'));
      source.chapters[BookId('book-$i')] = [ready('c$i')];
    }
    // The first batch is read in time, the deadline passes during the
    // second request.
    final deadline = now.add(const Duration(seconds: 15));
    source.onCall = () => now = now.add(const Duration(seconds: 10));

    final result = await check.run(deadline: deadline);

    expect(result.outcome, NewChapterCheckOutcome.stopped);
    expect(source.calls, hasLength(2));
    final unread = source.calls[1].single;

    source.onCall = null;
    await check.run();
    expect(source.calls[2].first, unread);
  });

  test('only checks the given book', () async {
    await enable(bookA);
    await enable(bookB);

    await check.run(only: bookB);

    expect(source.calls, [
      [bookB],
    ]);
  });

  test('one check at a time', () async {
    await enable(bookA);
    source.chapters[bookA] = [ready('c1')];
    final gate = Completer<void>();
    var running = 0;
    var overlapped = false;
    source.onCall = () {
      running++;
      if (running > 1) overlapped = true;
    };
    when(() => downloads.watchBook(any())).thenAnswer((_) async* {
      await gate.future;
      running--;
      yield null;
    });

    final first = check.run();
    final second = check.run();
    await Future<void>.delayed(Duration.zero);
    gate.complete();
    await Future.wait([first, second]);

    expect(source.calls, hasLength(2));
    expect(overlapped, isFalse);
  });

  group('runIfStale', () {
    test('skips when every book was checked recently', () async {
      await withBaseline(bookA, [ready('c1')]);
      now = now.subtract(const Duration(hours: 5, minutes: 30));

      expect(await check.runIfStale(const Duration(hours: 1)), isNull);
      expect(source.calls, hasLength(1));
    });

    test('runs when the least recently checked book is old', () async {
      await withBaseline(bookA, [ready('c1')]);

      expect(await check.runIfStale(const Duration(hours: 1)), isNotNull);
      expect(source.calls, hasLength(2));
    });

    test('a fresh check of one book does not hide the others', () async {
      await enable(bookA);
      await withBaseline(bookB, [ready('c1')]);
      now = now.subtract(const Duration(hours: 6));

      expect(await check.runIfStale(const Duration(hours: 1)), isNotNull);
    });

    test('skips when no book has it on', () async {
      expect(await check.runIfStale(const Duration(hours: 1)), isNull);
      expect(source.calls, isEmpty);
    });
  });
}
