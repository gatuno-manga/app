/// DownloadManager: native events and restart reconciliation.
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/data/data_sources/transfer_queue.dart';
import 'package:gatuno/features/downloads/domain/entities/download_scope.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/downloads/domain/entities/download_totals.dart';
import '../../helpers/download_test_doubles.dart';
import '../../helpers/download_manager_harness.dart';

void main() {
  setUpDownloadManager();

  group('native events', () {
    setUp(() async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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

      await manager.pause(const DownloadScope.book(testBook));

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

    test('a cancel from the notification pauses every download', () async {
      manifest('c2', imageManifest('c2', pages: 1));
      await manager.enqueueChapters(testBook, const [ChapterId('c2')]);
      await until(() => transfers.enqueued.length == 3);
      final [first, second, third] = transfers.enqueued;
      transfers.active.remove(first.taskId);

      transfers.controller.add(TransferCancelled(first.taskId));

      await untilState('c1', DownloadState.paused);
      await untilState('c2', DownloadState.paused);
      // Cancelling the already cancelled first task again is a no-op.
      expect(transfers.cancelled, containsAll([second.taskId, third.taskId]));
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

  group('restart', () {
    test('a done chapter whose files are gone is paused, unplanned', () async {
      manifest('t1', textManifest('t1'));
      await manager.enqueueChapters(testBook, const [ChapterId('t1')]);
      await untilState('t1', DownloadState.done);

      // A backup restored onto another device: records without files.
      await manager.dispose();
      Directory('${dir.path}/downloads').deleteSync(recursive: true);
      manager = build();
      await manager.start();

      final lost = (await chapter('t1'))!;
      expect(lost.state, DownloadState.paused);
      expect(lost.bytes, 0);

      await manager.resume(const DownloadScope.all());
      await untilState('t1', DownloadState.done);
    });

    test('a notification cancel while closed pauses every download', () async {
      manifest('c1', imageManifest('c1'));
      manifest('c2', imageManifest('c2', pages: 1));
      await manager.enqueueChapters(testBook, const [
        ChapterId('c1'),
        ChapterId('c2'),
      ]);
      await until(() => transfers.enqueued.length == 3);
      final cancelledFile = transfers.enqueued.first.taskId;

      // The app is closed; the user taps Cancel on the notification, which
      // reaches the files running at that moment.
      await manager.dispose();
      transfers.active.remove(cancelledFile);
      transfers.userCancelsWhileClosed = {cancelledFile};
      final before = transfers.enqueued.length;
      manager = build();
      await manager.start();

      expect((await chapter('c1'))!.state, DownloadState.paused);
      expect((await chapter('c2'))!.state, DownloadState.paused);
      expect(transfers.enqueued.length, before, reason: 'nothing requeued');
      expect(transfers.active, isEmpty, reason: 'the rest cancelled');

      await manager.resume(const DownloadScope.all());
      await until(() => transfers.queuedFor('c1').length == 2);
      await until(() => transfers.queuedFor('c2').length == 1);
    });

    test(
      'files finished while closed are done; lost tasks are queued again',
      () async {
        manifest('c1', imageManifest('c1', pages: 3));
        await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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
      await manager.enqueueChapters(testBook, const [ChapterId('t1')]);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect((await chapter('t1'))!.state, DownloadState.queued);

      await manager.dispose();
      connectivity.status = ConnectivityStatus.online;
      manager = build();
      await manager.start();

      await untilState('t1', DownloadState.done);
    });
  });
}
