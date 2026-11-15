import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/presentation/view_models/book_downloads_view_model.dart';
import 'package:gatuno/features/downloads/domain/entities/auto_download.dart';
import 'package:gatuno/features/downloads/domain/entities/book_download.dart';
import 'package:gatuno/features/downloads/domain/entities/chapter_download.dart';
import 'package:gatuno/features/downloads/domain/entities/download_scope.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/book_downloads_fixture.dart';

const book = fixtureBook;
const c1 = ChapterId('c1');
const c2 = ChapterId('c2');
const c3 = ChapterId('c3');

ChapterDownload chapter(ChapterId id, DownloadState state, {int bytes = 0}) =>
    ChapterDownload(chapterId: id, bookId: book, state: state, bytes: bytes);

void main() {
  late MockDownloadService downloads;
  late MockAutoDownloadPreferences prefs;
  late MockDownloadsAuthService auth;
  late FakeConnectivityService connectivity;
  late BookDownloadsViewModel vm;

  final fixture = BookDownloadsFixture();

  setUpAll(BookDownloadsFixture.registerFallbacks);

  BookDownloadsViewModel build() => BookDownloadsViewModel(
    downloads: downloads,
    autoDownload: prefs,
    connectivity: connectivity,
    auth: auth,
    bookId: book,
  );

  Future<void> show(List<ChapterDownload> chapters) async {
    fixture.bookDownload.add(BookDownload(bookId: book, chapters: chapters));
    await pumpEventQueue();
  }

  setUp(() async {
    fixture.setUp();
    downloads = fixture.downloads;
    prefs = fixture.prefs;
    auth = fixture.auth;
    connectivity = fixture.connectivity;

    vm = build();
    await pumpEventQueue();
  });

  tearDown(() async {
    vm.dispose();
    await fixture.tearDown();
  });

  group('state', () {
    test(
      'follows the book download, the setting, connectivity and auth',
      () async {
        final since = DateTime(2026, 11, 15);
        await show([chapter(c1, DownloadState.done)]);
        fixture.autoDownload.add(AutoDownload(bookId: book, since: since));
        connectivity.subject.add(ConnectivityStatus.offline);
        fixture.authState.add(AuthState.unauthenticated);
        await pumpEventQueue();

        expect(vm.state.chapter(c1)?.state, DownloadState.done);
        expect(vm.state.chapter(c2), isNull);
        expect(vm.state.autoDownloadOn, isTrue);
        expect(vm.state.offline, isTrue);
        expect(vm.state.authenticated, isFalse);
      },
    );

    test('indicator action per state', () async {
      const paused = ChapterId('p');
      const failed = ChapterId('f');
      await show([
        chapter(c1, DownloadState.queued),
        chapter(c2, DownloadState.running),
        chapter(paused, DownloadState.paused),
        chapter(failed, DownloadState.failed),
        chapter(c3, DownloadState.done),
      ]);

      expect(
        vm.state.indicatorAction(const ChapterId('none')),
        ChapterIndicatorAction.download,
      );
      expect(vm.state.indicatorAction(c1), ChapterIndicatorAction.pause);
      expect(vm.state.indicatorAction(c2), ChapterIndicatorAction.pause);
      expect(vm.state.indicatorAction(paused), ChapterIndicatorAction.resume);
      expect(
        vm.state.indicatorAction(failed),
        ChapterIndicatorAction.openFailed,
      );
      expect(vm.state.indicatorAction(c3), ChapterIndicatorAction.openDone);
    });

    test('active chapters wait for connection only offline', () async {
      await show([
        chapter(c1, DownloadState.queued),
        chapter(c2, DownloadState.done),
      ]);
      expect(vm.state.waitingForConnection(c1), isFalse);

      connectivity.subject.add(ConnectivityStatus.offline);
      await pumpEventQueue();

      expect(vm.state.waitingForConnection(c1), isTrue);
      expect(vm.state.waitingForConnection(c2), isFalse);
    });

    test('strip action: pause, then resume, then retry, else none', () async {
      expect(vm.state.stripAction, isNull);

      await show([
        chapter(c1, DownloadState.running),
        chapter(c2, DownloadState.paused),
        chapter(c3, DownloadState.failed),
      ]);
      expect(vm.state.stripAction, BookDownloadAction.pauseAll);

      await show([
        chapter(c2, DownloadState.paused),
        chapter(c3, DownloadState.failed),
      ]);
      expect(vm.state.stripAction, BookDownloadAction.resumeAll);

      await show([chapter(c3, DownloadState.failed)]);
      expect(vm.state.stripAction, BookDownloadAction.retryFailed);

      await show([chapter(c3, DownloadState.done)]);
      expect(vm.state.stripAction, isNull);
    });

    test('bytesOf sums the chapters on disk', () async {
      await show([
        chapter(c1, DownloadState.done, bytes: 10),
        chapter(c2, DownloadState.done, bytes: 5),
      ]);

      expect(vm.state.bytesOf([c1, c2, c3]), 15);
    });
  });

  group('indicator tap', () {
    test('downloads a chapter with no download', () async {
      expect(await vm.tapIndicator(c1), isNull);

      verify(() => downloads.enqueueChapters(book, [c1])).called(1);
    });

    test('pauses an active chapter', () async {
      await show([chapter(c1, DownloadState.running)]);

      expect(await vm.tapIndicator(c1), isNull);

      verify(() => downloads.pause(const DownloadScope.chapters([c1])));
    });

    test('resumes a paused chapter', () async {
      await show([chapter(c1, DownloadState.paused)]);

      await vm.tapIndicator(c1);

      verify(() => downloads.resume(const DownloadScope.chapters([c1])));
    });

    test('returns the sheet for failed and done chapters', () async {
      await show([
        chapter(c1, DownloadState.failed),
        chapter(c2, DownloadState.done),
      ]);

      expect(await vm.tapIndicator(c1), ChapterIndicatorAction.openFailed);
      expect(await vm.tapIndicator(c2), ChapterIndicatorAction.openDone);
      verifyNever(() => downloads.retry(any()));
      verifyNever(() => downloads.delete(any()));
    });
  });

  group('book-wide', () {
    test('download all and delete all act on the whole book', () async {
      await vm.downloadAll();
      await vm.deleteAll();

      verify(() => downloads.enqueueBook(book)).called(1);
      verify(() => downloads.delete(const DownloadScope.book(book))).called(1);
    });

    test('the strip action acts on the whole book', () async {
      await show([chapter(c1, DownloadState.running)]);
      await vm.runStripAction();
      verify(() => downloads.pause(const DownloadScope.book(book))).called(1);

      await show([chapter(c1, DownloadState.paused)]);
      await vm.runStripAction();
      verify(() => downloads.resume(const DownloadScope.book(book))).called(1);

      await show([chapter(c1, DownloadState.failed)]);
      await vm.runStripAction();
      verify(() => downloads.retry(const DownloadScope.book(book))).called(1);
    });

    test('auto-download on and off', () async {
      await vm.setAutoDownload(true);
      await vm.setAutoDownload(false);

      verify(() => prefs.enable(book)).called(1);
      verify(() => prefs.disable(book)).called(1);
      verifyNever(() => downloads.enqueueBook(any()));
    });
  });

  group('offline', () {
    setUp(() async {
      connectivity.subject.add(ConnectivityStatus.offline);
      await pumpEventQueue();
    });

    test('download all is disabled', () async {
      expect(vm.state.canDownloadAll, isFalse);

      await vm.downloadAll();

      verifyNever(() => downloads.enqueueBook(any()));
    });

    test('chapters still queue, and pause and delete work', () async {
      await vm.download([c1]);
      await show([chapter(c2, DownloadState.failed)]);
      await vm.retry([c2]);
      await vm.pause([c1]);
      await vm.delete([c2]);

      verify(() => downloads.enqueueChapters(book, [c1])).called(1);
      verify(() => downloads.retry(const DownloadScope.chapters([c2])));
      verify(() => downloads.pause(const DownloadScope.chapters([c1])));
      verify(() => downloads.delete(const DownloadScope.chapters([c2])));
    });
  });

  group('guest', () {
    setUp(() async {
      fixture.authState.add(AuthState.unauthenticated);
      await pumpEventQueue();
    });

    test('starting a download asks to sign in instead', () async {
      await vm.download([c1]);
      expect(vm.state.notice, BookDownloadsNotice.signInRequired);
      vm.clearNotice();
      expect(vm.state.notice, isNull);

      await vm.resume([c1]);
      await vm.retry([c1]);
      await vm.downloadAll();
      await vm.setAutoDownload(true);

      expect(vm.state.notice, BookDownloadsNotice.signInRequired);
      verifyNever(() => downloads.enqueueChapters(any(), any()));
      verifyNever(() => downloads.resume(any()));
      verifyNever(() => downloads.retry(any()));
      verifyNever(() => downloads.enqueueBook(any()));
      verifyNever(() => prefs.enable(any()));
    });

    test('pause, delete and turning auto-download off still work', () async {
      await vm.pause([c1]);
      await vm.delete([c1]);
      await vm.deleteAll();
      await vm.setAutoDownload(false);

      expect(vm.state.notice, isNull);
      verify(() => downloads.pause(any())).called(1);
      verify(() => downloads.delete(any())).called(2);
      verify(() => prefs.disable(book)).called(1);
    });
  });

  group('selection', () {
    test('long-press enters with the chapter picked', () {
      vm.startSelection(c1);
      expect(vm.state.selecting, isTrue);
      expect(vm.state.selection, {c1});

      vm.toggleSelection(c2);
      expect(vm.state.selection, {c1, c2});
    });

    test('the Select button enters with nothing picked', () {
      vm.startSelection();

      expect(vm.state.selecting, isTrue);
      expect(vm.state.selection, isEmpty);
    });

    test('unpicking every chapter keeps the mode', () {
      vm.startSelection(c1);
      vm.toggleSelection(c1);

      expect(vm.state.selecting, isTrue);
      expect(vm.state.selection, isEmpty);
    });

    test('select all adds every loaded chapter; clear leaves', () {
      vm.startSelection(c1);
      vm.selectAll([c1, c2, c3]);
      expect(vm.state.selection, {c1, c2, c3});

      vm.clearSelection();
      expect(vm.state.selecting, isFalse);
    });

    test('offers the actions matching the selected states', () async {
      await show([
        chapter(c1, DownloadState.paused),
        chapter(c2, DownloadState.done),
      ]);
      vm.startSelection(c1);
      vm.toggleSelection(c2);

      expect(vm.state.selectionHas({DownloadState.paused}), isTrue);
      expect(vm.state.selectionHas({DownloadState.failed}), isFalse);
      expect(
        vm.state.selectionHas({DownloadState.queued, DownloadState.running}),
        isFalse,
      );
    });

    test('an action applies to the selection and leaves the mode', () async {
      vm.startSelection(c1);
      vm.toggleSelection(c2);

      await vm.downloadSelection();

      verify(() => downloads.enqueueChapters(book, [c1, c2])).called(1);
      expect(vm.state.selecting, isFalse);

      vm.startSelection(c3);
      await vm.deleteSelection();
      verify(() => downloads.delete(const DownloadScope.chapters([c3])));

      vm.startSelection(c1);
      await vm.pauseSelection();
      vm.startSelection(c1);
      await vm.resumeSelection();
      vm.startSelection(c1);
      await vm.retrySelection();
      verify(() => downloads.pause(const DownloadScope.chapters([c1])));
      verify(() => downloads.resume(const DownloadScope.chapters([c1])));
      verify(() => downloads.retry(const DownloadScope.chapters([c1])));
    });

    test('an empty selection does nothing and keeps the mode', () async {
      vm.startSelection();

      await vm.downloadSelection();

      verifyNever(() => downloads.enqueueChapters(any(), any()));
      expect(vm.state.selecting, isTrue);
    });
  });

  test('a failing command sets the failure notice', () async {
    when(() => downloads.delete(any())).thenThrow(Exception('disk'));

    await vm.delete([c1]);

    expect(vm.state.notice, BookDownloadsNotice.actionFailed);
  });

  test('dispose stops following the streams', () async {
    vm.dispose();

    expect(fixture.bookDownload.hasListener, isFalse);
    expect(fixture.autoDownload.hasListener, isFalse);
    expect(fixture.authState.hasListener, isFalse);
    expect(connectivity.subject.hasListener, isFalse);
    vm = build();
  });

  group('display', () {
    test('statusOf maps states, the Wi-Fi wait and offline', () async {
      const wifi = ChapterId('w');
      const paused = ChapterId('p');
      const failed = ChapterId('f');
      const done = ChapterId('d');
      await show([
        chapterDownload(c1, DownloadState.queued),
        chapterDownload(c2, DownloadState.running),
        chapterDownload(
          wifi,
          DownloadState.queued,
          reason: DownloadWaitReason.waitingForNetwork,
        ),
        chapterDownload(paused, DownloadState.paused),
        chapterDownload(failed, DownloadState.failed),
        chapterDownload(done, DownloadState.done),
      ]);

      expect(vm.state.statusOf(c3), ChapterDownloadStatus.none);
      expect(vm.state.statusOf(c1), ChapterDownloadStatus.queued);
      expect(vm.state.statusOf(c2), ChapterDownloadStatus.running);
      expect(vm.state.statusOf(wifi), ChapterDownloadStatus.waitingForNetwork);
      expect(vm.state.statusOf(paused), ChapterDownloadStatus.paused);
      expect(vm.state.statusOf(failed), ChapterDownloadStatus.failed);
      expect(vm.state.statusOf(done), ChapterDownloadStatus.done);

      connectivity.subject.add(ConnectivityStatus.offline);
      await pumpEventQueue();

      for (final id in [c1, c2, wifi]) {
        expect(
          vm.state.statusOf(id),
          ChapterDownloadStatus.waitingForConnection,
          reason: 'offline wins for $id',
        );
      }
      expect(vm.state.statusOf(paused), ChapterDownloadStatus.paused);
    });

    test('phase by priority, and null without downloads', () async {
      expect(vm.state.phase, isNull);

      await show([
        chapterDownload(c1, DownloadState.running),
        chapterDownload(c2, DownloadState.paused),
        chapterDownload(c3, DownloadState.failed),
      ]);
      expect(vm.state.phase, BookDownloadPhase.active);

      connectivity.subject.add(ConnectivityStatus.offline);
      await pumpEventQueue();
      expect(vm.state.phase, BookDownloadPhase.waitingForConnection);

      await show([
        chapterDownload(c2, DownloadState.paused),
        chapterDownload(c3, DownloadState.failed),
      ]);
      expect(vm.state.phase, BookDownloadPhase.paused);

      await show([chapterDownload(c3, DownloadState.failed)]);
      expect(vm.state.phase, BookDownloadPhase.failed);

      await show([chapterDownload(c3, DownloadState.done)]);
      expect(vm.state.phase, BookDownloadPhase.done);
    });

    test('the bar measures the files of active chapters only', () async {
      await show([
        chapterDownload(c1, DownloadState.running, filesDone: 1, filesTotal: 4),
        chapterDownload(c2, DownloadState.queued, filesTotal: 4),
        chapterDownload(c3, DownloadState.done, filesDone: 10, filesTotal: 10),
      ]);

      expect(vm.state.activeProgress, 1 / 8);
      expect(vm.state.activeCount, 2);
      expect(vm.state.downloadCount, 3);
    });

    test('the bar is 0 before any manifest is known', () async {
      await show([chapterDownload(c1, DownloadState.queued)]);

      expect(vm.state.activeProgress, 0);
    });

    test('waiting for Wi-Fi only when every active chapter does', () async {
      const wifi = DownloadWaitReason.waitingForNetwork;
      await show([
        chapterDownload(c1, DownloadState.queued, reason: wifi),
        chapterDownload(c2, DownloadState.running, reason: wifi),
        chapterDownload(c3, DownloadState.done),
      ]);
      expect(vm.state.allActiveWaitForWifi, isTrue);

      await show([
        chapterDownload(c1, DownloadState.queued, reason: wifi),
        chapterDownload(c2, DownloadState.running),
      ]);
      expect(vm.state.allActiveWaitForWifi, isFalse);

      await show([chapterDownload(c3, DownloadState.done)]);
      expect(vm.state.allActiveWaitForWifi, isFalse);
    });

    test('selectionHasDownload', () async {
      await show([chapterDownload(c1, DownloadState.done)]);
      vm.startSelection(c2);
      expect(vm.state.selectionHasDownload, isFalse);

      vm.toggleSelection(c1);
      expect(vm.state.selectionHasDownload, isTrue);
    });
  });
}
