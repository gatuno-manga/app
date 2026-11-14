/// DownloadManager: planning, commands and queries.
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';
import 'package:gatuno/features/books/domain/entities/chapter_page_options.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/downloads/data/repositories/download_manager.dart';
import 'package:gatuno/features/downloads/domain/entities/book_download.dart';
import 'package:gatuno/features/downloads/domain/entities/download_scope.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/downloads/domain/entities/download_totals.dart';
import 'package:gatuno/features/downloads/exceptions/download_exceptions.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/download_test_doubles.dart';
import '../../helpers/download_manager_harness.dart';

void main() {
  setUpDownloadManager();

  group('planning', () {
    test(
      'enqueue stores the manifest and queues every page, in order',
      () async {
        manifest('c1', imageManifest('c1'));

        await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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
        expect(chapterOf(transfers.enqueued.first), 'c1');
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

        await manager.enqueueChapters(testBook, const [ChapterId('c1')]);

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

      await manager.enqueueChapters(testBook, const [ChapterId('t1')]);

      await untilState('t1', DownloadState.done);
      expect(transfers.enqueued, isEmpty);
      expect((await chapter('t1'))!.progress, 1);
    });

    test('a document chapter downloads one document file', () async {
      manifest('d1', documentManifest('d1'));

      await manager.enqueueChapters(testBook, const [ChapterId('d1')]);
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

      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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

      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);

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

        await manager.enqueueChapters(testBook, const [
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
      when(() => books.getBookChapters(testBook, any())).thenAnswer((i) async {
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

      await manager.enqueueBook(testBook);

      await untilState('t1', DownloadState.done);
      await untilState('t2', DownloadState.done);
    });
  });

  group('delete', () {
    test(
      'deleting the last chapter removes the book and unpins the cover',
      () async {
        manifest('c1', imageManifest('c1'));
        manifest('t1', textManifest('t1'));
        await manager.enqueueChapters(testBook, const [
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

        await manager.delete(const DownloadScope.book(testBook));

        expect(await manager.watchBook(testBook).first, isNull);
        expect(Directory('${dir.path}/downloads/book-1').existsSync(), isFalse);
        verify(
          () => covers.unpin('book-1', DownloadManager.coverPinOwner),
        ).called(1);
        expect(await manager.totals(), DownloadTotals.empty);
      },
    );

    test('clearAll wipes every download, file and native task', () async {
      manifest('c1', imageManifest('c1'));
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
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
      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);

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
        await manager.enqueueChapters(testBook, const [
          ChapterId('t1'),
          ChapterId('c1'),
        ]);
        await untilState('t1', DownloadState.done);
        await untilState('c1', DownloadState.failed);

        manifest('c1', imageManifest('c1'));
        await manager.enqueueChapters(testBook, const [
          ChapterId('t1'),
          ChapterId('c1'),
        ]);

        await until(() => transfers.enqueued.length == 2, reason: 'replan');
        expect((await chapter('t1'))!.state, DownloadState.done);
        expect((await chapter('c1'))!.state, DownloadState.queued);
      },
    );
  });

  test('watchAll groups chapters by book in enqueue order', () async {
    manifest('t1', textManifest('t1'));
    manifest('t2', textManifest('t2'));
    await manager.enqueueChapters(testBook, const [
      ChapterId('t2'),
      ChapterId('t1'),
    ]);
    await untilState('t1', DownloadState.done);
    await untilState('t2', DownloadState.done);

    final List<BookDownload> all = await manager.watchAll().first;
    expect(all.single.bookId, testBook);
    expect(all.single.chapters.map((c) => c.chapterId.value), ['t2', 't1']);
  });
}
