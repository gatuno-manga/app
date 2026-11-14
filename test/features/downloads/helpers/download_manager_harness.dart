/// Shared setup of the DownloadManager tests: an in-memory database, a temp
/// directory and test doubles, rebuilt for every test.
library;

import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_type.dart';
import 'package:gatuno/features/books/domain/entities/chapter_page_options.dart';
import 'package:gatuno/features/books/domain/value_objects/book_cover.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_records.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_storage.dart';
import 'package:gatuno/features/downloads/data/data_sources/transfer_queue.dart';
import 'package:gatuno/features/downloads/data/database/downloads_database.dart';
import 'package:gatuno/features/downloads/data/repositories/download_manager.dart';
import 'package:gatuno/features/downloads/domain/entities/chapter_download.dart';
import 'package:gatuno/features/downloads/domain/entities/download_network.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:mocktail/mocktail.dart';
import 'download_test_doubles.dart';

late DownloadsDatabase db;
late Directory dir;
late DownloadStorage storage;
late FakeTransferQueue transfers;
late MockRemote remote;
late MockBooksRepository books;
late MockCoverStore covers;
late FakePolicy policy;
late FakeConnectivity connectivity;
late BehaviorSubject<bool> unmetered;
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

/// Changes a rule as a settings screen would: through the policy's
/// change stream.
Future<void> setRule(BookType type, DownloadNetwork network) async {
  policy.rules[type] = network;
  policy.changed.add(null);
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

void manifest(String id, Map<String, dynamic> json) =>
    when(() => remote.fetchManifest(id)).thenAnswer((_) async => json);

/// Registers the per-test setup and teardown; call it first in `main`.
void setUpDownloadManager() {
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
    unmetered = BehaviorSubject<bool>.seeded(false);

    when(
      () => remote.resolve(any()),
    ).thenAnswer((i) => 'https://srv${i.positionalArguments.first}');
    when(() => remote.fileHeaders).thenReturn({'Referer': 'r'});
    when(() => books.getBook(any())).thenAnswer(
      (_) async => const Book(
        id: testBook,
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
}
