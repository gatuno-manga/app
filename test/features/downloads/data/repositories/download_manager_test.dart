import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/covers/cover_store.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_type.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';
import 'package:gatuno/features/books/domain/entities/chapter_page_options.dart';
import 'package:gatuno/features/books/domain/repositories/books_repository.dart';
import 'package:gatuno/features/books/domain/value_objects/book_cover.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_records.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_remote_data_source.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_storage.dart';
import 'package:gatuno/features/downloads/data/data_sources/transfer_queue.dart';
import 'package:gatuno/features/downloads/data/database/downloads_database.dart';
import 'package:gatuno/features/downloads/data/repositories/download_manager.dart';
import 'package:gatuno/features/downloads/domain/entities/book_download.dart';
import 'package:gatuno/features/downloads/domain/entities/chapter_download.dart';
import 'package:gatuno/features/downloads/domain/entities/download_network.dart';
import 'package:gatuno/features/downloads/domain/entities/download_scope.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/downloads/domain/entities/download_totals.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_network_policy.dart';
import 'package:gatuno/features/downloads/exceptions/download_exceptions.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements DownloadRemoteDataSource {}

class MockBooksRepository extends Mock implements BooksRepository {}

class MockCoverStore extends Mock implements CoverStore {}

class FakeConnectivity implements ConnectivityService {
  @override
  ConnectivityStatus status = ConnectivityStatus.online;
  final StreamController<void> reconnected = StreamController<void>.broadcast();

  @override
  Stream<void> get onReconnected => reconnected.stream;

  @override
  Stream<ConnectivityStatus> get statusStream => Stream.value(status);

  @override
  Future<void> checkNow() async {}

  @override
  void reportReachable() {}

  @override
  void reportUnreachable() {}

  Future<void> close() => reconnected.close();
}

class FakePolicy implements DownloadNetworkPolicy {
  final Map<BookType, DownloadNetwork> rules = {};
  final StreamController<void> changed = StreamController<void>.broadcast();

  @override
  Future<DownloadNetwork> requirementFor(BookType type) async =>
      rules[type] ?? DownloadNetwork.any;

  @override
  Stream<void> get changes => changed.stream;

  Future<void> close() => changed.close();
}

class FakeTransferQueue implements TransferQueue {
  final StreamController<TransferEvent> controller =
      StreamController<TransferEvent>.broadcast();
  final List<FileTransfer> enqueued = [];
  final List<String> cancelled = [];
  final Set<String> active = {};
  int permissionRequests = 0;

  @override
  Stream<TransferEvent> get events => controller.stream;

  @override
  Future<void> start() async {}

  @override
  Future<void> enqueue(List<FileTransfer> transfers) async {
    enqueued.addAll(transfers);
    active.addAll(transfers.map((t) => t.taskId));
  }

  @override
  Future<void> cancel(Iterable<String> taskIds) async {
    cancelled.addAll(taskIds);
    active.removeAll(taskIds);
  }

  @override
  Future<void> cancelAll() => cancel([...active]);

  @override
  Future<Set<String>> activeTaskIds() async => {...active};

  @override
  Future<void> requestNotificationPermission() async => permissionRequests++;

  /// The transfers of [chapterId] still queued natively.
  Future<void> close() => controller.close();

  List<FileTransfer> queuedFor(String chapterId) => enqueued
      .where((t) => t.group == chapterId && active.contains(t.taskId))
      .toList();
}

const _book = BookId('book-1');

Map<String, dynamic> imageManifest(String id, {int pages = 2}) => {
  'id': id,
  'originalUrl': 'https://origin/$id',
  'index': 1,
  'contentType': 'image',
  'retries': 0,
  'isFinal': false,
  'bookId': _book.value,
  'bookTitle': 'Book',
  'totalChapters': 3,
  'pages': [
    // Out of order on purpose: files follow the page index.
    for (var i = pages; i >= 1; i--)
      {'id': 'p$i', 'path': '/s3/$id/$i.webp', 'index': i},
  ],
  'comments': <dynamic>[],
};

Map<String, dynamic> textManifest(String id) => {
  ...imageManifest(id, pages: 0),
  'contentType': 'text',
  'content': '# Hello',
  'contentFormat': 'markdown',
};

Map<String, dynamic> documentManifest(String id) => {
  ...imageManifest(id, pages: 0),
  'contentType': 'document',
  'documentPath': '/s3/$id/book.pdf',
  'documentFormat': 'pdf',
};

void main() {
  late DownloadsDatabase db;
  late Directory dir;
  late DownloadStorage storage;
  late FakeTransferQueue transfers;
  late MockRemote remote;
  late MockBooksRepository books;
  late MockCoverStore covers;
  late FakePolicy policy;
  late FakeConnectivity connectivity;
  late StreamController<bool> unmetered;
  late DownloadManager manager;

  DownloadManager build() => DownloadManager(
    records: DownloadRecords(db),
    storage: storage,
    transfers: transfers,
    remote: remote,
    books: books,
    covers: covers,
    policy: policy,
    connectivity: connectivity,
    unmetered: unmetered.stream,
    planRetryDelay: const Duration(milliseconds: 30),
  );

  /// Waits until [condition] holds: planning and events run asynchronously,
  /// with real file I/O in between.
  Future<void> until(
    FutureOr<bool> Function() condition, {
    String reason = 'condition',
  }) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!await condition()) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for $reason');
      }
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
  }

  Future<ChapterDownload?> chapter(String id) async {
    final all = await manager.watchAll().first;
    for (final book in all) {
      for (final c in book.chapters) {
        if (c.chapterId.value == id) return c;
      }
    }
    return null;
  }

  Future<void> untilState(String id, DownloadState state) => until(
    () async => (await chapter(id))?.state == state,
    reason: '$id $state',
  );

  /// Writes the file of [transfer] where the native downloader would.
  Future<void> land(FileTransfer transfer, {int bytes = 5}) async {
    final file = File('${dir.path}/${transfer.directory}/${transfer.filename}');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(List.filled(bytes, 1));
    transfers.active.remove(transfer.taskId);
    transfers.controller.add(TransferCompleted(transfer.taskId));
  }

  setUpAll(() {
    registerFallbackValue(const BookId('x'));
    registerFallbackValue(const ChapterPageOptions());
  });

  setUp(() async {
    db = DownloadsDatabase(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('gatuno-downloads');
    storage = DownloadStorage(() async => dir);
    transfers = FakeTransferQueue();
    remote = MockRemote();
    books = MockBooksRepository();
    covers = MockCoverStore();
    policy = FakePolicy();
    connectivity = FakeConnectivity();
    unmetered = StreamController<bool>.broadcast();

    when(
      () => remote.resolve(any()),
    ).thenAnswer((i) => 'https://srv${i.positionalArguments.first}');
    when(() => remote.fileHeaders).thenReturn({'Referer': 'r'});
    when(() => books.getBook(any())).thenAnswer(
      (_) async => const Book(
        id: _book,
        title: BookTitle('Book'),
        type: TypeBook.manga,
        cover: BookCover('https://srv/cover.webp'),
      ),
    );
    when(() => covers.pin(any(), any())).thenAnswer((_) async {});
    when(() => covers.unpin(any(), any())).thenAnswer((_) async {});
    when(() => covers.ensure(any(), any())).thenAnswer((_) async => null);

    manager = build();
    await manager.start();
  });

  tearDown(() async {
    await manager.dispose();
    await transfers.close();
    await policy.close();
    await connectivity.close();
    await unmetered.close();
    await db.close();
    dir.deleteSync(recursive: true);
  });

  /// Changes a rule as a settings screen would: through the policy's
  /// change stream.
  Future<void> setRule(BookType type, DownloadNetwork network) async {
    policy.rules[type] = network;
    policy.changed.add(null);
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  void manifest(String id, Map<String, dynamic> json) =>
      when(() => remote.fetchManifest(id)).thenAnswer((_) async => json);

  group('planning', () {
    test(
      'enqueue stores the manifest and queues every page, in order',
      () async {
        manifest('c1', imageManifest('c1'));

        await manager.enqueueChapters(_book, const [ChapterId('c1')]);
        await until(() => transfers.enqueued.length == 2, reason: 'enqueue');

        final c = await chapter('c1');
        expect(c!.state, DownloadState.queued);
        expect(c.filesTotal, 2);
        expect(c.bytes, greaterThan(0), reason: 'the manifest counts');
        expect(
          transfers.enqueued.map((t) => (t.url, t.directory, t.filename)),
          [
            (
              'https://srv/s3/c1/1.webp',
              'downloads/book-1/c1/pages',
              '0001.webp',
            ),
            (
              'https://srv/s3/c1/2.webp',
              'downloads/book-1/c1/pages',
              '0002.webp',
            ),
          ],
        );
        expect(transfers.enqueued.first.group, 'c1');
        expect(transfers.enqueued.first.requiresWiFi, isFalse);
        expect(transfers.enqueued.first.headers, {'Referer': 'r'});
        expect(
          File('${dir.path}/downloads/book-1/c1/chapter.json').existsSync(),
          isTrue,
        );
      },
    );

    test(
      'enqueue pins and fetches the cover, and asks for notifications',
      () async {
        manifest('c1', imageManifest('c1'));

        await manager.enqueueChapters(_book, const [ChapterId('c1')]);

        verify(
          () => covers.pin('book-1', DownloadManager.coverPinOwner),
        ).called(1);
        verify(
          () => covers.ensure('book-1', 'https://srv/cover.webp'),
        ).called(1);
        expect(transfers.permissionRequests, 1);
      },
    );

    test('a text chapter is done once its manifest is stored', () async {
      manifest('t1', textManifest('t1'));

      await manager.enqueueChapters(_book, const [ChapterId('t1')]);

      await untilState('t1', DownloadState.done);
      expect(transfers.enqueued, isEmpty);
      expect((await chapter('t1'))!.progress, 1);
    });

    test('a document chapter downloads one document file', () async {
      manifest('d1', documentManifest('d1'));

      await manager.enqueueChapters(_book, const [ChapterId('d1')]);
      await until(() => transfers.enqueued.isNotEmpty, reason: 'enqueue');

      expect(transfers.enqueued.single.filename, 'document.pdf');
      expect(transfers.enqueued.single.directory, 'downloads/book-1/d1');
    });

    test('offline planning keeps the chapter queued until reconnect', () async {
      var reachable = false;
      when(() => remote.fetchManifest('c1')).thenAnswer((_) async {
        if (!reachable) throw NetworkException();
        return imageManifest('c1');
      });

      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await until(
        () async => (await chapter('c1')) != null,
        reason: 'the chapter row',
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect((await chapter('c1'))!.state, DownloadState.queued);
      expect(transfers.enqueued, isEmpty);

      reachable = true;
      connectivity.reconnected.add(null);
      await until(() => transfers.enqueued.length == 2, reason: 'replan');
    });

    test('a 401 fails the chapter with signInRequired', () async {
      when(() => remote.fetchManifest('c1')).thenThrow(UnauthorizedException());

      await manager.enqueueChapters(_book, const [ChapterId('c1')]);

      await untilState('c1', DownloadState.failed);
      expect((await chapter('c1'))!.error, DownloadErrors.signInRequired);
    });

    test(
      'a missing chapter, or one without pages, fails with notFound',
      () async {
        when(
          () => remote.fetchManifest('gone'),
        ).thenThrow(ChapterUnavailableException('gone'));
        manifest('empty', imageManifest('empty', pages: 0));

        await manager.enqueueChapters(_book, const [
          ChapterId('gone'),
          ChapterId('empty'),
        ]);

        await untilState('gone', DownloadState.failed);
        await untilState('empty', DownloadState.failed);
        expect((await chapter('gone'))!.error, DownloadErrors.notFound);
        expect((await chapter('empty'))!.error, DownloadErrors.notFound);
      },
    );

    test('enqueueBook pages through every chapter', () async {
      when(() => books.getBookChapters(_book, any())).thenAnswer((i) async {
        final options = i.positionalArguments[1] as ChapterPageOptions;
        return options.cursor == null
            ? const ChapterList(
                data: [Chapter(id: ChapterId('t1'), index: ChapterIndex(1))],
                nextCursor: 'next',
                hasNextPage: true,
              )
            : const ChapterList(
                data: [Chapter(id: ChapterId('t2'), index: ChapterIndex(2))],
                hasNextPage: false,
              );
      });
      manifest('t1', textManifest('t1'));
      manifest('t2', textManifest('t2'));

      await manager.enqueueBook(_book);

      await untilState('t1', DownloadState.done);
      await untilState('t2', DownloadState.done);
    });
  });

  group('native events', () {
    setUp(() async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2, reason: 'enqueue');
    });

    test('a started file makes the chapter running', () async {
      transfers.controller.add(
        TransferStarted(transfers.enqueued.first.taskId),
      );
      await untilState('c1', DownloadState.running);
    });

    test('the chapter is done when every file is on disk', () async {
      await land(transfers.enqueued[0], bytes: 7);
      await until(
        () async => (await chapter('c1'))!.filesDone == 1,
        reason: 'first file',
      );
      expect((await chapter('c1'))!.state, DownloadState.queued);

      await land(transfers.enqueued[1], bytes: 3);
      await untilState('c1', DownloadState.done);

      final c = (await chapter('c1'))!;
      expect(c.filesDone, 2);
      final manifestBytes = File(
        '${dir.path}/downloads/book-1/c1/chapter.json',
      ).lengthSync();
      expect(c.bytes, manifestBytes + 10);
      expect(
        await manager.totals(),
        DownloadTotals(chapters: 1, bytes: manifestBytes + 10),
      );
    });

    test('a failed file fails the chapter and cancels the rest', () async {
      final [first, second] = transfers.enqueued;
      await land(first);
      transfers.controller.add(
        TransferFailed(second.taskId, DownloadErrors.storageFull),
      );

      await untilState('c1', DownloadState.failed);
      expect((await chapter('c1'))!.error, DownloadErrors.storageFull);
    });

    test('retry downloads only the missing files, as new attempts', () async {
      final [first, second] = transfers.enqueued;
      await land(first);
      await until(() async => (await chapter('c1'))!.filesDone == 1);
      transfers.controller.add(
        TransferFailed(second.taskId, DownloadErrors.server),
      );
      await untilState('c1', DownloadState.failed);

      await manager.retry(const DownloadScope.chapters([ChapterId('c1')]));

      await untilState('c1', DownloadState.queued);
      final again = transfers.queuedFor('c1');
      expect(again.map((t) => t.filename), ['0002.webp']);
      expect(again.single.taskId, isNot(second.taskId));
      expect((await chapter('c1'))!.error, isNull);
    });

    test('pause cancels native tasks; resume queues them again', () async {
      final firstAttempt = [...transfers.enqueued];

      await manager.pause(const DownloadScope.book(_book));

      expect((await chapter('c1'))!.state, DownloadState.paused);
      expect(transfers.cancelled, firstAttempt.map((t) => t.taskId));
      // Our own cancel events must not change anything.
      for (final t in firstAttempt) {
        transfers.controller.add(TransferCancelled(t.taskId));
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect((await chapter('c1'))!.state, DownloadState.paused);

      await manager.resume(const DownloadScope.all());

      await until(
        () => transfers.queuedFor('c1').length == 2,
        reason: 'resume',
      );
      expect((await chapter('c1'))!.state, DownloadState.queued);
    });

    test('a file finished while paused is not downloaded again', () async {
      final [first, _] = transfers.enqueued;
      await manager.pause(const DownloadScope.all());
      // The download won the race with the cancel.
      await land(first);

      await manager.resume(const DownloadScope.all());

      await until(
        () => transfers.queuedFor('c1').length == 1,
        reason: 'resume',
      );
      expect(transfers.queuedFor('c1').single.filename, '0002.webp');
    });

    test('a cancel from the notification pauses the chapter', () async {
      final [first, second] = transfers.enqueued;
      transfers.active.remove(first.taskId);
      transfers.controller.add(TransferCancelled(first.taskId));

      await untilState('c1', DownloadState.paused);
      expect(transfers.cancelled, [second.taskId]);
    });

    test('events of a replaced attempt are ignored', () async {
      final stale = transfers.enqueued.first.taskId;
      await manager.pause(const DownloadScope.all());
      await manager.resume(const DownloadScope.all());
      await until(() => transfers.queuedFor('c1').length == 2);

      transfers.controller.add(TransferFailed(stale, DownloadErrors.server));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect((await chapter('c1'))!.state, DownloadState.queued);
    });
  });

  group('delete', () {
    test(
      'deleting the last chapter removes the book and unpins the cover',
      () async {
        manifest('c1', imageManifest('c1'));
        manifest('t1', textManifest('t1'));
        await manager.enqueueChapters(_book, const [
          ChapterId('c1'),
          ChapterId('t1'),
        ]);
        await until(() => transfers.enqueued.length == 2);
        await untilState('t1', DownloadState.done);

        await manager.delete(const DownloadScope.chapters([ChapterId('c1')]));

        expect(transfers.cancelled, transfers.enqueued.map((t) => t.taskId));
        expect(await chapter('c1'), isNull);
        expect(
          Directory('${dir.path}/downloads/book-1/c1').existsSync(),
          isFalse,
        );
        expect(
          Directory('${dir.path}/downloads/book-1/t1').existsSync(),
          isTrue,
        );
        verifyNever(() => covers.unpin(any(), any()));

        await manager.delete(const DownloadScope.book(_book));

        expect(await manager.watchBook(_book).first, isNull);
        expect(Directory('${dir.path}/downloads/book-1').existsSync(), isFalse);
        verify(
          () => covers.unpin('book-1', DownloadManager.coverPinOwner),
        ).called(1);
        expect(await manager.totals(), DownloadTotals.empty);
      },
    );

    test('clearAll wipes every download, file and native task', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);

      await manager.clearAll();

      expect(await manager.watchAll().first, isEmpty);
      expect(transfers.active, isEmpty);
      expect(Directory('${dir.path}/downloads').existsSync(), isFalse);
      verify(
        () => covers.unpin('book-1', DownloadManager.coverPinOwner),
      ).called(1);
    });

    test('a manifest arriving after a delete is dropped', () async {
      final gate = Completer<Map<String, dynamic>>();
      when(() => remote.fetchManifest('c1')).thenAnswer((_) => gate.future);
      await manager.enqueueChapters(_book, const [ChapterId('c1')]);

      await manager.delete(const DownloadScope.all());
      gate.complete(imageManifest('c1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(transfers.enqueued, isEmpty);
      expect(
        Directory('${dir.path}/downloads/book-1/c1').existsSync(),
        isFalse,
      );
    });
  });

  group('enqueue again', () {
    test(
      'a done chapter is left alone; a failed one is queued again',
      () async {
        manifest('t1', textManifest('t1'));
        when(
          () => remote.fetchManifest('c1'),
        ).thenThrow(ChapterUnavailableException('c1'));
        await manager.enqueueChapters(_book, const [
          ChapterId('t1'),
          ChapterId('c1'),
        ]);
        await untilState('t1', DownloadState.done);
        await untilState('c1', DownloadState.failed);

        manifest('c1', imageManifest('c1'));
        await manager.enqueueChapters(_book, const [
          ChapterId('t1'),
          ChapterId('c1'),
        ]);

        await until(() => transfers.enqueued.length == 2, reason: 'replan');
        expect((await chapter('t1'))!.state, DownloadState.done);
        expect((await chapter('c1'))!.state, DownloadState.queued);
      },
    );
  });

  group('restart', () {
    test(
      'files finished while closed are done; lost tasks are queued again',
      () async {
        manifest('c1', imageManifest('c1', pages: 3));
        await manager.enqueueChapters(_book, const [ChapterId('c1')]);
        await until(() => transfers.enqueued.length == 3);
        final [first, second, third] = transfers.enqueued;

        // The app dies: the first file lands without an event, the second task
        // is lost, the third is still queued natively.
        await manager.dispose();
        final file = File('${dir.path}/${first.directory}/${first.filename}');
        await file.parent.create(recursive: true);
        await file.writeAsBytes([1, 2, 3]);
        transfers.active
          ..remove(first.taskId)
          ..remove(second.taskId);
        final before = transfers.enqueued.length;

        manager = build();
        await manager.start();

        final c = (await chapter('c1'))!;
        expect(c.filesDone, 1);
        final requeued = transfers.enqueued.skip(before).toList();
        expect(requeued.map((t) => t.filename), ['0002.webp']);
        expect(transfers.active, contains(third.taskId));
      },
    );

    test('a planned chapter whose files all landed is done on start', () async {
      manifest('c1', imageManifest('c1', pages: 1));
      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 1);
      final only = transfers.enqueued.single;

      await manager.dispose();
      final file = File('${dir.path}/${only.directory}/${only.filename}');
      await file.parent.create(recursive: true);
      await file.writeAsBytes([1]);
      transfers.active.clear();

      manager = build();
      await manager.start();

      expect((await chapter('c1'))!.state, DownloadState.done);
    });

    test('chapters left unplanned are planned on start', () async {
      connectivity.status = ConnectivityStatus.offline;
      manifest('t1', textManifest('t1'));
      await manager.enqueueChapters(_book, const [ChapterId('t1')]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect((await chapter('t1'))!.state, DownloadState.queued);

      await manager.dispose();
      connectivity.status = ConnectivityStatus.online;
      manager = build();
      await manager.start();

      await untilState('t1', DownloadState.done);
    });
  });

  group('network rule', () {
    test('files of an unmetered-only type require Wi-Fi', () async {
      await setRule(BookType.manga, DownloadNetwork.unmetered);
      manifest('c1', imageManifest('c1'));

      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);

      expect(transfers.enqueued.every((t) => t.requiresWiFi), isTrue);
    });

    test(
      'a pending chapter on mobile data is waiting for the network',
      () async {
        await setRule(BookType.manga, DownloadNetwork.unmetered);
        manifest('c1', imageManifest('c1'));
        await manager.enqueueChapters(_book, const [ChapterId('c1')]);
        await until(() => transfers.enqueued.length == 2);

        final reasons = manager
            .watchBook(_book)
            .map((b) => b!.chapters.single.reason)
            .distinct();
        final seen = <DownloadWaitReason>[];
        final sub = reasons.listen(seen.add);
        await until(() => seen.isNotEmpty);
        expect(seen.last, DownloadWaitReason.waitingForNetwork);

        unmetered.add(true);
        await until(() => seen.last == DownloadWaitReason.none);
        await sub.cancel();
      },
    );

    test(
      'a rule change queues pending files again under the new rule',
      () async {
        manifest('c1', imageManifest('c1'));
        await manager.enqueueChapters(_book, const [ChapterId('c1')]);
        await until(() => transfers.enqueued.length == 2);
        final firstAttempt = [...transfers.enqueued];

        policy.rules[BookType.manga] = DownloadNetwork.unmetered;
        policy.changed.add(null);

        await until(() => transfers.enqueued.length == 4, reason: 'requeue');
        expect(transfers.cancelled, firstAttempt.map((t) => t.taskId));
        expect(transfers.queuedFor('c1').every((t) => t.requiresWiFi), isTrue);
      },
    );
  });

  test('watchAll groups chapters by book in enqueue order', () async {
    manifest('t1', textManifest('t1'));
    manifest('t2', textManifest('t2'));
    await manager.enqueueChapters(_book, const [
      ChapterId('t2'),
      ChapterId('t1'),
    ]);
    await untilState('t1', DownloadState.done);
    await untilState('t2', DownloadState.done);

    final List<BookDownload> all = await manager.watchAll().first;
    expect(all.single.bookId, _book);
    expect(all.single.chapters.map((c) => c.chapterId.value), ['t2', 't1']);
  });

  group('resilience', () {
    test('a manifest that keeps timing out fails after 3 tries', () async {
      var calls = 0;
      when(() => remote.fetchManifest('slow')).thenAnswer((_) async {
        calls++;
        throw NetworkException();
      });
      manifest('t1', textManifest('t1'));

      await manager.enqueueChapters(_book, const [
        ChapterId('slow'),
        ChapterId('t1'),
      ]);

      await untilState('slow', DownloadState.failed);
      expect(calls, DownloadManager.maxTransientAttempts);
      expect((await chapter('slow'))!.error, DownloadErrors.server);
      await untilState('t1', DownloadState.done);
    });

    test('offline does not count against a chapter', () async {
      connectivity.status = ConnectivityStatus.offline;
      when(() => remote.fetchManifest('c1')).thenThrow(NetworkException());

      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect((await chapter('c1'))!.state, DownloadState.queued);
    });

    test('clearAll wipes even when the native cancel throws', () async {
      await manager.dispose();
      transfers = _ThrowingCancelQueue();
      manager = build();
      await manager.start();
      manifest('t1', textManifest('t1'));
      await manager.enqueueChapters(_book, const [ChapterId('t1')]);
      await untilState('t1', DownloadState.done);

      await manager.clearAll();

      expect(await manager.watchAll().first, isEmpty);
      expect(Directory('${dir.path}/downloads').existsSync(), isFalse);
    });

    test('a failed re-plan does not keep counting the old manifest', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);
      transfers.controller.add(
        TransferFailed(
          transfers.enqueued.first.taskId,
          DownloadErrors.notFound,
        ),
      );
      await untilState('c1', DownloadState.failed);
      when(
        () => remote.fetchManifest('c1'),
      ).thenThrow(ChapterUnavailableException('c1'));

      await manager.retry(const DownloadScope.chapters([ChapterId('c1')]));

      await until(
        () async => (await chapter('c1'))!.filesTotal == 0,
        reason: 'plan reset',
      );
      await untilState('c1', DownloadState.failed);
      expect((await chapter('c1'))!.bytes, 0);
      expect(await manager.totals(), DownloadTotals(chapters: 1, bytes: 0));
    });

    test('start deletes chapter directories no download owns', () async {
      manifest('t1', textManifest('t1'));
      await manager.enqueueChapters(_book, const [ChapterId('t1')]);
      await untilState('t1', DownloadState.done);
      await manager.dispose();
      final stray = Directory('${dir.path}/downloads/book-1/gone/pages')
        ..createSync(recursive: true);
      final strayBook = Directory('${dir.path}/downloads/other-book/c9')
        ..createSync(recursive: true);

      manager = build();
      await manager.start();

      expect(stray.parent.existsSync(), isFalse);
      expect(strayBook.parent.existsSync(), isFalse);
      expect(
        File('${dir.path}/downloads/book-1/t1/chapter.json').existsSync(),
        isTrue,
      );
    });

    test('retry after notFound downloads every page again', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);
      final [first, second] = transfers.enqueued;
      await land(first);
      await until(() async => (await chapter('c1'))!.filesDone == 1);
      transfers.controller.add(
        TransferFailed(second.taskId, DownloadErrors.notFound),
      );
      await untilState('c1', DownloadState.failed);

      await manager.retry(const DownloadScope.chapters([ChapterId('c1')]));

      await until(
        () => transfers.queuedFor('c1').length == 2,
        reason: 'both pages again',
      );
      expect((await chapter('c1'))!.filesDone, 0);
      expect(
        File('${dir.path}/${first.directory}/${first.filename}').existsSync(),
        isFalse,
      );
    });

    test('start cancels native tasks no record points at', () async {
      await manager.dispose();
      transfers.active.add('ghost@old.1');

      manager = build();
      await manager.start();

      expect(transfers.cancelled, ['ghost@old.1']);
    });

    test('an enqueue issued before a delete does not come back', () async {
      final details = Completer<Book>();
      when(() => books.getBook(any())).thenAnswer((_) => details.future);
      manifest('t1', textManifest('t1'));

      final enqueued = manager.enqueueChapters(_book, const [ChapterId('t1')]);
      await manager.delete(const DownloadScope.book(_book));
      details.complete(const Book(id: _book, title: BookTitle('Book')));
      await enqueued;

      expect(await manager.watchBook(_book).first, isNull);
      verifyNever(() => covers.pin(any(), any()));
    });

    test('native task ids differ across app sessions', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);
      final firstSession = transfers.enqueued.map((t) => t.taskId).toSet();

      await manager.dispose();
      transfers.active.clear();
      manager = build();
      await manager.start();

      final secondSession = transfers.queuedFor('c1').map((t) => t.taskId);
      expect(secondSession, hasLength(2));
      expect(secondSession.toSet().intersection(firstSession), isEmpty);
    });

    test('planning retries a slow request even without a reconnect', () async {
      var calls = 0;
      when(() => remote.fetchManifest('c1')).thenAnswer((_) async {
        if (++calls == 1) throw NetworkException();
        return imageManifest('c1');
      });

      await manager.enqueueChapters(_book, const [ChapterId('c1')]);

      await until(() => transfers.enqueued.length == 2, reason: 'retry');
      expect(calls, 2);
    });

    test('a busy server leaves the chapter queued, then plans it', () async {
      var calls = 0;
      when(() => remote.fetchManifest('c1')).thenAnswer((_) async {
        if (++calls == 1) throw TransientServerException(503);
        return imageManifest('c1');
      });

      await manager.enqueueChapters(_book, const [ChapterId('c1')]);

      await until(() => transfers.enqueued.length == 2, reason: 'retry');
      expect((await chapter('c1'))!.state, isNot(DownloadState.failed));
    });

    test('files reach the native queue in enqueue order', () async {
      final slow = Completer<Map<String, dynamic>>();
      when(() => remote.fetchManifest('c1')).thenAnswer((_) => slow.future);
      manifest('c2', imageManifest('c2', pages: 1));

      await manager.enqueueChapters(_book, const [
        ChapterId('c1'),
        ChapterId('c2'),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(transfers.enqueued, isEmpty, reason: 'c2 waits for c1');
      slow.complete(imageManifest('c1', pages: 1));

      await until(() => transfers.enqueued.length == 2);
      expect(transfers.enqueued.map((t) => t.group), ['c1', 'c2']);
    });

    test('retry after notFound fetches the manifest again', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);
      transfers.controller.add(
        TransferFailed(transfers.enqueued.last.taskId, DownloadErrors.notFound),
      );
      await untilState('c1', DownloadState.failed);

      // Re-scraped on the server: now a single page.
      manifest('c1', imageManifest('c1', pages: 1));
      await manager.retry(const DownloadScope.chapters([ChapterId('c1')]));

      await until(
        () async => (await chapter('c1'))!.filesTotal == 1,
        reason: 'replan',
      );
      verify(() => remote.fetchManifest('c1')).called(2);
    });

    test('a rule change leaves other book types alone', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(_book, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);

      await setRule(BookType.book, DownloadNetwork.unmetered);

      expect(transfers.cancelled, isEmpty);
      expect(transfers.enqueued, hasLength(2));
    });

    test(
      'a book type unknown at first is recorded on a later enqueue',
      () async {
        when(() => books.getBook(any())).thenThrow(OfflineException());
        manifest('t1', textManifest('t1'));
        await manager.enqueueChapters(_book, const [ChapterId('t1')]);
        await untilState('t1', DownloadState.done);

        when(() => books.getBook(any())).thenAnswer(
          (_) async => const Book(
            id: _book,
            title: BookTitle('Book'),
            type: TypeBook.manga,
          ),
        );
        manifest('c1', imageManifest('c1'));
        await manager.enqueueChapters(_book, const [ChapterId('c1')]);
        await until(() => transfers.enqueued.length == 2);

        await setRule(BookType.manga, DownloadNetwork.unmetered);

        await until(() => transfers.queuedFor('c1').length == 2);
        expect(transfers.queuedFor('c1').every((t) => t.requiresWiFi), isTrue);
      },
    );

    test('commands wait for start to apply the native state', () async {
      await manager.dispose();
      final gate = Completer<void>();
      final slowQueue = _GatedTransferQueue(gate.future);
      transfers = slowQueue;
      manager = build();
      manifest('t1', textManifest('t1'));

      final started = manager.start();
      final enqueued = manager.enqueueChapters(_book, const [ChapterId('t1')]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(await DownloadRecords(db).chapter('t1'), isNull);

      gate.complete();
      await started;
      await enqueued;
      await untilState('t1', DownloadState.done);
    });
  });
}

/// A transfer queue whose start waits for [gate].
class _GatedTransferQueue extends FakeTransferQueue {
  final Future<void> gate;

  _GatedTransferQueue(this.gate);

  @override
  Future<void> start() => gate;
}

/// A transfer queue whose cancelAll fails, as with the plugin unavailable.
class _ThrowingCancelQueue extends FakeTransferQueue {
  @override
  Future<void> cancelAll() => Future.error(StateError('no plugin'));
}
