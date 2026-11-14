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

void main() {
  late MockFileDownloader downloader;
  late StreamController<TaskUpdate> updates;
  late BackgroundDownloaderTransferQueue queue;
  late List<TransferEvent> events;
  late StreamSubscription<TransferEvent> sub;

  const transfer = FileTransfer(
    taskId: 'c1/1@s.1',
    url: 'https://srv/s3/1.jpg',
    directory: 'downloads/b/c1/pages',
    filename: '0001.jpg',
    group: 'c1',
  );

  setUpAll(() {
    registerFallbackValue(DownloadTask(url: 'https://x'));
    registerFallbackValue(<Task>[]);
  });

  setUp(() async {
    downloader = MockFileDownloader();
    updates = StreamController<TaskUpdate>.broadcast();
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
    when(() => downloader.resumeAll()).thenAnswer((_) async => []);
    when(
      () => downloader.cancelTasksWithIds(any()),
    ).thenAnswer((_) async => true);
    queue = BackgroundDownloaderTransferQueue(
      downloader: downloader,
      texts: () => _texts,
    );
    events = [];
    sub = queue.events.listen(events.add);
    await queue.start();
  });

  tearDown(() async {
    await sub.cancel();
    await queue.dispose();
    await updates.close();
  });

  test('large files run in the foreground on Android', () {
    final android =
        verify(
              () => downloader.configure(
                globalConfig: any<dynamic>(named: 'globalConfig'),
                androidConfig: captureAny<dynamic>(named: 'androidConfig'),
                iOSConfig: any<dynamic>(named: 'iOSConfig'),
              ),
            ).captured.single
            as List<Object?>;
    expect(
      android,
      contains((
        Config.runInForegroundIfFileLargerThan,
        BackgroundDownloaderTransferQueue.foregroundAboveMegabytes,
      )),
    );
  });

  test('only this queue\'s tasks count as active', () async {
    when(
      () => downloader.allTaskIds(allGroups: true),
    ).thenAnswer((_) async => ['c1/1@s1.2', 'someone-else', 'x@y']);

    expect(await queue.activeTaskIds(), {'c1/1@s1.2'});
  });

  test('start disables the holding queue and resumes paused tasks', () {
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
    verify(() => downloader.resumeAll()).called(1);
  });

  test('a paused task is resumed', () async {
    final task = DownloadTask(taskId: 'c1/1@s.1', url: 'https://srv/1.jpg');
    when(() => downloader.resume(any())).thenAnswer((_) async => true);

    updates.add(TaskStatusUpdate(task, TaskStatus.paused));
    await Future<void>.delayed(Duration.zero);

    verify(() => downloader.resume(any())).called(1);
    expect(events, isEmpty);
  });

  test('a paused task that cannot resume fails', () async {
    final task = DownloadTask(taskId: 'c1/1@s.1', url: 'https://srv/1.jpg');
    when(() => downloader.resume(any())).thenAnswer((_) async => false);

    updates.add(TaskStatusUpdate(task, TaskStatus.paused));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    verify(() => downloader.cancelTasksWithIds(['c1/1@s.1'])).called(1);
    expect(events, [const TransferFailed('c1/1@s.1', DownloadErrors.unknown)]);
  });

  test('a native enqueue that throws fails every file', () async {
    when(() => downloader.enqueueAll(any())).thenThrow(Exception('boom'));

    await queue.enqueue(const [transfer]);
    await Future<void>.delayed(Duration.zero);

    expect(events, [const TransferFailed('c1/1@s.1', DownloadErrors.unknown)]);
  });

  test('a refused enqueue fails that file', () async {
    when(() => downloader.enqueueAll(any())).thenAnswer((_) async => [false]);

    await queue.enqueue(const [transfer]);
    await Future<void>.delayed(Duration.zero);

    expect(events, [const TransferFailed('c1/1@s.1', DownloadErrors.unknown)]);
  });

  test('enqueue builds app-support download tasks', () async {
    when(() => downloader.enqueueAll(any())).thenAnswer((_) async => [true]);

    await queue.enqueue(const [transfer]);

    final task =
        (verify(() => downloader.enqueueAll(captureAny())).captured.single
                as List<Task>)
            .single;
    expect(task.taskId, 'c1/1@s.1');
    expect(task.baseDirectory, BaseDirectory.applicationSupport);
    expect(task.directory, 'downloads/b/c1/pages');
    expect(task.filename, '0001.jpg');
    expect(task.retries, BackgroundDownloaderTransferQueue.retries);
  });
}
