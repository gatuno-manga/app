/// DownloadManager: transient failures, races and recovery.
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_type.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_records.dart';
import 'package:gatuno/features/downloads/data/data_sources/transfer_queue.dart';
import 'package:gatuno/features/downloads/data/repositories/download_manager.dart';
import 'package:gatuno/features/downloads/domain/entities/download_network.dart';
import 'package:gatuno/features/downloads/domain/entities/download_scope.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/downloads/domain/entities/download_totals.dart';
import 'package:gatuno/features/downloads/exceptions/download_exceptions.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/download_test_doubles.dart';
import '../../helpers/download_manager_harness.dart';

void main() {
  setUpDownloadManager();

  group('resilience', () {
    test('new commands do not cut the backoff short', () async {
      await manager.dispose();
      manager = DownloadManager(
        records: DownloadRecords(db),
        storage: storage,
        transfers: transfers,
        remote: remote,
        books: books,
        covers: covers,
        policy: policy,
        connectivity: connectivity,
        unmetered: unmetered.stream,
        planRetryDelay: const Duration(milliseconds: 300),
      );
      await manager.start();
      var calls = 0;
      when(() => remote.fetchManifest('c1')).thenAnswer((_) async {
        calls++;
        throw TransientServerException(503);
      });
      manifest('t1', textManifest('t1'));

      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
      await until(() => calls == 1);
      // The user keeps tapping download while the server is busy.
      await manager.enqueueChapters(testBook, const [ChapterId('t1')]);
      await manager.resume(const DownloadScope.all());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(calls, 1, reason: 'still backing off');
      await until(() => calls == 2, reason: 'the timer');
    });

    test('a resync cancels native tasks no record points at', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);
      // A late duplicate, such as a task iOS resumed under an old id.
      transfers.active.add('c1/1@old.1');

      transfers.controller.add(const TransfersResynced());

      await until(() => transfers.cancelled.contains('c1/1@old.1'));
      expect(transfers.enqueued, hasLength(2), reason: 'nothing requeued');
    });

    test('a book type known only later reapplies the network rule', () async {
      await setRule(BookType.manga, DownloadNetwork.unmetered);
      when(() => books.getBook(any())).thenThrow(OfflineException());
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);
      expect(transfers.enqueued.any((t) => t.requiresWiFi), isFalse);

      when(() => books.getBook(any())).thenAnswer(
        (_) async => const Book(
          id: testBook,
          title: BookTitle('Book'),
          type: TypeBook.manga,
        ),
      );
      manifest('t1', textManifest('t1'));
      await manager.enqueueChapters(testBook, const [ChapterId('t1')]);

      await until(() => transfers.queuedFor('c1').every((t) => t.requiresWiFi));
      expect(transfers.queuedFor('c1'), hasLength(2));
    });

    test('a timeout counts once the probe finds the server up', () async {
      // As the connectivity interceptor does: a timeout flips the status
      // offline until the confirming probe answers.
      var calls = 0;
      when(() => remote.fetchManifest('slow')).thenAnswer((_) async {
        calls++;
        connectivity.status = ConnectivityStatus.offline;
        throw NetworkException();
      });
      connectivity.onCheck = () =>
          connectivity.status = ConnectivityStatus.online;

      await manager.enqueueChapters(testBook, const [ChapterId('slow')]);

      await untilState('slow', DownloadState.failed);
      expect(calls, DownloadManager.maxTransientAttempts);
    });

    test('a resync queues files whose native task vanished', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);
      final lost = transfers.enqueued.first;
      transfers.active.remove(lost.taskId);

      transfers.controller.add(const TransfersResynced());

      await until(() => transfers.enqueued.length == 3, reason: 'requeue');
      expect(transfers.enqueued.last.filename, lost.filename);
      expect(transfers.enqueued.last.taskId, isNot(lost.taskId));
    });

    test('ids left on a paused chapter are cancelled on start', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);
      final first = [for (final t in transfers.enqueued) t.taskId];
      // Killed after the pause was written, before its native cancel.
      await manager.dispose();
      await DownloadRecords(
        db,
      ).setState('c1', DownloadState.paused, null, clearTasks: true);

      manager = build();
      await manager.start();
      expect(transfers.cancelled, unorderedEquals(first));

      await manager.resume(const DownloadScope.all());
      await until(() => transfers.queuedFor('c1').length == 2);
    });

    test('a manifest that keeps timing out fails after 3 tries', () async {
      var calls = 0;
      when(() => remote.fetchManifest('slow')).thenAnswer((_) async {
        calls++;
        throw NetworkException();
      });
      manifest('t1', textManifest('t1'));

      await manager.enqueueChapters(testBook, const [
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

      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect((await chapter('c1'))!.state, DownloadState.queued);
    });

    test('a failed re-plan does not keep counting the old manifest', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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
      await manager.enqueueChapters(testBook, const [ChapterId('t1')]);
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
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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

      final enqueued = manager.enqueueChapters(testBook, const [
        ChapterId('t1'),
      ]);
      await manager.delete(const DownloadScope.book(testBook));
      details.complete(const Book(id: testBook, title: BookTitle('Book')));
      await enqueued;

      expect(await manager.watchBook(testBook).first, isNull);
      verifyNever(() => covers.pin(any(), any()));
    });

    test('native task ids differ across app sessions', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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

      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);

      await until(() => transfers.enqueued.length == 2, reason: 'retry');
      expect(calls, 2);
    });

    test('a busy server leaves the chapter queued, then plans it', () async {
      var calls = 0;
      when(() => remote.fetchManifest('c1')).thenAnswer((_) async {
        if (++calls == 1) throw TransientServerException(503);
        return imageManifest('c1');
      });

      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);

      await until(() => transfers.enqueued.length == 2, reason: 'retry');
      expect((await chapter('c1'))!.state, isNot(DownloadState.failed));
    });

    test('files reach the native queue in enqueue order', () async {
      final slow = Completer<Map<String, dynamic>>();
      when(() => remote.fetchManifest('c1')).thenAnswer((_) => slow.future);
      manifest('c2', imageManifest('c2', pages: 1));

      await manager.enqueueChapters(testBook, const [
        ChapterId('c1'),
        ChapterId('c2'),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(transfers.enqueued, isEmpty, reason: 'c2 waits for c1');
      slow.complete(imageManifest('c1', pages: 1));

      await until(() => transfers.enqueued.length == 2);
      expect(transfers.enqueued.map(chapterOf), ['c1', 'c2']);
    });

    test('retry after notFound fetches the manifest again', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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
        await manager.enqueueChapters(testBook, const [ChapterId('t1')]);
        await untilState('t1', DownloadState.done);

        when(() => books.getBook(any())).thenAnswer(
          (_) async => const Book(
            id: testBook,
            title: BookTitle('Book'),
            type: TypeBook.manga,
          ),
        );
        manifest('c1', imageManifest('c1'));
        await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
        await until(() => transfers.enqueued.length == 2);

        await setRule(BookType.manga, DownloadNetwork.unmetered);

        await until(() => transfers.queuedFor('c1').length == 2);
        expect(transfers.queuedFor('c1').every((t) => t.requiresWiFi), isTrue);
      },
    );

    test('commands wait for start to apply the native state', () async {
      await manager.dispose();
      final gate = Completer<void>();
      final slowQueue = GatedTransferQueue(gate.future);
      transfers = slowQueue;
      manager = build();
      manifest('t1', textManifest('t1'));

      final started = manager.start();
      final enqueued = manager.enqueueChapters(testBook, const [
        ChapterId('t1'),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(await DownloadRecords(db).chapter('t1'), isNull);

      gate.complete();
      await started;
      await enqueued;
      await untilState('t1', DownloadState.done);
    });
  });
}
