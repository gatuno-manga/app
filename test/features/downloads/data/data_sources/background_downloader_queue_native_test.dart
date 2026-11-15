import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/background_downloader_transfer_queue.dart';
import 'package:gatuno/features/downloads/data/data_sources/transfer_queue.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:mocktail/mocktail.dart';

class MockFileDownloader extends Mock implements FileDownloader {}

const _texts = DownloadNotificationTexts(
  runningTitle: 'r',
  runningBody: 'rb',
  completeTitle: 'c',
  completeBody: 'cb',
  errorTitle: 'e',
  errorBody: 'eb',
  cancel: 'x',
);

const _transfer = FileTransfer(
  taskId: 'c1/1@s.1',
  url: 'https://srv/s3/1.jpg',
  directory: 'downloads/b/c1/pages',
  filename: '0001.jpg',
);

void main() {
  late MockFileDownloader downloader;
  late StreamController<TaskUpdate> updates;
  late List<TransferEvent> events;
  BackgroundDownloaderTransferQueue? queue;
  StreamSubscription<TransferEvent>? sub;

  setUpAll(() {
    registerFallbackValue(DownloadTask(url: 'https://x'));
    registerFallbackValue(<Task>[]);
  });

  setUp(() {
    downloader = MockFileDownloader();
    updates = StreamController<TaskUpdate>.broadcast();
    events = [];
    when(() => downloader.updates).thenAnswer((_) => updates.stream);
    when(
      () => downloader.configure(
        globalConfig: any<dynamic>(named: 'globalConfig'),
        androidConfig: any<dynamic>(named: 'androidConfig'),
        iOSConfig: any<dynamic>(named: 'iOSConfig'),
      ),
    ).thenAnswer((_) async => []);
    when(
      () => downloader.configureNotification(
        running: any(named: 'running'),
        complete: any(named: 'complete'),
        error: any(named: 'error'),
        progressBar: any(named: 'progressBar'),
        groupNotificationId: any(named: 'groupNotificationId'),
      ),
    ).thenReturn(downloader);
    when(() => downloader.resumeFromBackground()).thenAnswer((_) async {});
    when(
      () => downloader.resumeAll(group: any(named: 'group')),
    ).thenAnswer((_) async => []);
    when(
      () => downloader.allTaskIds(group: any(named: 'group')),
    ).thenAnswer((_) async => []);
    when(() => downloader.resume(any())).thenAnswer((_) async => false);
    when(() => downloader.enqueueAll(any())).thenAnswer((_) async => [true]);
  });

  Future<BackgroundDownloaderTransferQueue> start({required bool ios}) async {
    final q = queue = BackgroundDownloaderTransferQueue(
      downloader: downloader,
      texts: () => _texts,
      resumesPausedTasks: ios,
    );
    sub = q.events.listen(events.add);
    await q.start();
    // Broadcast events reach listeners a microtask later.
    await Future<void>.delayed(Duration.zero);
    return q;
  }

  tearDown(() async {
    await sub?.cancel();
    await queue?.dispose();
    await updates.close();
  });

  Task enqueuedTask() =>
      (verify(() => downloader.enqueueAll(captureAny())).captured.single
              as List<Task>)
          .single;

  TaskStatusUpdate paused() => TaskStatusUpdate(
    DownloadTask(taskId: 'c1/1@s.1', url: 'https://srv/1.jpg'),
    TaskStatus.paused,
  );

  test('start disables the holding queue', () async {
    await start(ios: false);

    final config =
        verify(
              () => downloader.configure(
                globalConfig: captureAny<dynamic>(named: 'globalConfig'),
                androidConfig: any<dynamic>(named: 'androidConfig'),
                iOSConfig: any<dynamic>(named: 'iOSConfig'),
              ),
            ).captured.single
            as List<Object?>;
    expect(config, contains((Config.holdingQueue, false)));
  });

  group('Android', () {
    test(
      'tasks do not allow pause (interim: no resume across 9 min)',
      () async {
        final q = await start(ios: false);

        await q.enqueue(const [_transfer]);

        expect((enqueuedTask() as DownloadTask).allowPause, isFalse);
      },
    );

    test('a paused update is ignored', () async {
      await start(ios: false);

      updates.add(paused());
      await Future<void>.delayed(
        BackgroundDownloaderTransferQueue.resumeSettle * 2,
      );

      verifyNever(() => downloader.resume(any()));
      verifyNever(() => downloader.resumeAll(group: any(named: 'group')));
      expect(events, isEmpty);
    });
  });

  group('iOS', () {
    test('start opens the session, then resumes paused tasks once', () async {
      await start(ios: true);

      verifyInOrder([
        () => downloader.resumeFromBackground(),
        () => downloader.allTaskIds(
          group: BackgroundDownloaderTransferQueue.group,
        ),
        () => downloader.resumeAll(
          group: BackgroundDownloaderTransferQueue.group,
        ),
      ]);
      verifyNever(() => downloader.resume(any()));
      // The caller reconciles right after start: no extra resync.
      expect(events, isEmpty);
    });

    test('paused updates settle into one resume sweep', () async {
      await start(ios: true);
      clearInteractions(downloader);
      events.clear();

      updates
        ..add(paused())
        ..add(paused());
      await Future<void>.delayed(
        BackgroundDownloaderTransferQueue.resumeSettle * 2,
      );

      verify(() => downloader.resumeAll(group: any(named: 'group'))).called(1);
      expect(events, [const TransfersResynced()]);
    });

    test('tasks do not allow pause', () async {
      final q = await start(ios: true);

      await q.enqueue(const [_transfer]);

      expect((enqueuedTask() as DownloadTask).allowPause, isFalse);
    });
  });

  test('a native enqueue that throws fails every file', () async {
    final q = await start(ios: false);
    when(() => downloader.enqueueAll(any())).thenThrow(Exception('boom'));

    await q.enqueue(const [_transfer]);
    await Future<void>.delayed(Duration.zero);

    expect(events, [const TransferFailed('c1/1@s.1', DownloadErrors.unknown)]);
  });

  test('a refused enqueue fails that file', () async {
    final q = await start(ios: false);
    when(() => downloader.enqueueAll(any())).thenAnswer((_) async => [false]);

    await q.enqueue(const [_transfer]);
    await Future<void>.delayed(Duration.zero);

    expect(events, [const TransferFailed('c1/1@s.1', DownloadErrors.unknown)]);
  });

  test('enqueue builds app-support download tasks', () async {
    final q = await start(ios: false);

    await q.enqueue(const [_transfer]);

    final task = enqueuedTask();
    expect(task.taskId, 'c1/1@s.1');
    expect(task.baseDirectory, BaseDirectory.applicationSupport);
    expect(task.directory, 'downloads/b/c1/pages');
    expect(task.filename, '0001.jpg');
    expect(task.retries, BackgroundDownloaderTransferQueue.retries);
  });

  test('tasks live in one plugin group, listed by that group', () async {
    final q = await start(ios: false);
    when(
      () =>
          downloader.allTaskIds(group: BackgroundDownloaderTransferQueue.group),
    ).thenAnswer((_) async => ['c1/1@s1.2']);

    await q.enqueue(const [_transfer]);

    expect(enqueuedTask().group, BackgroundDownloaderTransferQueue.group);
    expect(await q.activeTaskIds(), {'c1/1@s1.2'});
  });
}
