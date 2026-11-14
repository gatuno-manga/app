/// Test doubles and fixtures for the download manager tests.
library;

import 'dart:async';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/covers/cover_store.dart';
import 'package:gatuno/features/books/domain/repositories/books_repository.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_remote_data_source.dart';
import 'package:gatuno/features/downloads/data/data_sources/transfer_queue.dart';
import 'package:gatuno/features/downloads/domain/entities/download_network.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_network_policy.dart';
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

  /// Runs on [checkNow], like a probe answering.
  void Function()? onCheck;

  @override
  Future<void> checkNow() async => onCheck?.call();

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
      .where((t) => chapterOf(t) == chapterId && active.contains(t.taskId))
      .toList();
}

const testBook = BookId('book-1');

Map<String, dynamic> imageManifest(String id, {int pages = 2}) => {
  'id': id,
  'originalUrl': 'https://origin/$id',
  'index': 1,
  'contentType': 'image',
  'retries': 0,
  'isFinal': false,
  'bookId': testBook.value,
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

/// A transfer queue whose start waits for [gate].
class GatedTransferQueue extends FakeTransferQueue {
  final Future<void> gate;

  GatedTransferQueue(this.gate);

  @override
  Future<void> start() => gate;
}

/// A transfer queue whose cancelAll fails, as with the plugin unavailable.
class ThrowingCancelQueue extends FakeTransferQueue {
  @override
  Future<void> cancelAll() => Future.error(StateError('no plugin'));
}

/// The chapter of a transfer: task ids start with `<chapterId>/`.
String chapterOf(FileTransfer transfer) => transfer.taskId.split('/').first;
