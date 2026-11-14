import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/background_downloader_transfer_queue.dart';
import 'package:gatuno/features/downloads/data/data_sources/transfer_queue.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';

void main() {
  final task = DownloadTask(taskId: 'c1/1@1', url: 'https://srv/s3/1.jpg');

  TransferEvent? map(TaskStatus status, [TaskException? exception]) =>
      BackgroundDownloaderTransferQueue.eventOf(
        TaskStatusUpdate(task, status, exception),
      );

  test('maps the states the manager acts on', () {
    expect(map(TaskStatus.running), const TransferStarted('c1/1@1'));
    expect(map(TaskStatus.complete), const TransferCompleted('c1/1@1'));
    expect(map(TaskStatus.canceled), const TransferCancelled('c1/1@1'));
    expect(
      map(TaskStatus.notFound),
      const TransferFailed('c1/1@1', DownloadErrors.notFound),
    );
  });

  test('ignores intermediate states and progress', () {
    expect(map(TaskStatus.enqueued), isNull);
    expect(map(TaskStatus.waitingToRetry), isNull);
    expect(map(TaskStatus.paused), isNull);
    expect(
      BackgroundDownloaderTransferQueue.eventOf(TaskProgressUpdate(task, 0.5)),
      isNull,
    );
  });

  test('classifies failures', () {
    expect(
      map(TaskStatus.failed, TaskHttpException('gone', 404)),
      const TransferFailed('c1/1@1', DownloadErrors.notFound),
    );
    expect(
      map(TaskStatus.failed, TaskHttpException('boom', 500)),
      const TransferFailed('c1/1@1', DownloadErrors.server),
    );
    expect(
      map(
        TaskStatus.failed,
        TaskFileSystemException('Insufficient space to store the file'),
      ),
      const TransferFailed('c1/1@1', DownloadErrors.storageFull),
    );
    expect(
      map(TaskStatus.failed, TaskConnectionException('reset')),
      const TransferFailed('c1/1@1', DownloadErrors.server),
    );
    expect(
      map(TaskStatus.failed),
      const TransferFailed('c1/1@1', DownloadErrors.unknown),
    );
  });

  test('task ids carry the file id and the attempt', () {
    expect(TransferIds.forAttempt('c1/3', 's1', 7), 'c1/3@s1.7');
  });
}
