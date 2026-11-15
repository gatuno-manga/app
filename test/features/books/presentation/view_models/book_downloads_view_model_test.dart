import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/presentation/view_models/book_downloads_view_model.dart';
import 'package:gatuno/features/downloads/domain/entities/auto_download.dart';
import 'package:gatuno/features/downloads/domain/entities/book_download.dart';
import 'package:gatuno/features/downloads/domain/entities/chapter_download.dart';
import 'package:gatuno/features/downloads/domain/entities/download_scope.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/downloads/domain/repositories/auto_download_preferences.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

class MockDownloadService extends Mock implements DownloadService {}

class MockAutoDownloadPreferences extends Mock
    implements AutoDownloadPreferences {}

class MockAuthService extends Mock implements AuthService {}

class FakeConnectivityService implements ConnectivityService {
  final BehaviorSubject<ConnectivityStatus> subject;

  FakeConnectivityService(ConnectivityStatus initial)
    : subject = BehaviorSubject.seeded(initial);

  @override
  ConnectivityStatus get status => subject.value;

  @override
  Stream<ConnectivityStatus> get statusStream => subject.stream;

  @override
  Stream<void> get onReconnected => const Stream.empty();

  @override
  Future<void> checkNow() async {}

  @override
  void reportReachable() {}

  @override
  void reportUnreachable() {}
}

const book = BookId('book-1');
const c1 = ChapterId('c1');
const c2 = ChapterId('c2');
const c3 = ChapterId('c3');

ChapterDownload chapter(ChapterId id, DownloadState state, {int bytes = 0}) =>
    ChapterDownload(chapterId: id, bookId: book, state: state, bytes: bytes);

void main() {
  late MockDownloadService downloads;
  late MockAutoDownloadPreferences prefs;
  late MockAuthService auth;
  late FakeConnectivityService connectivity;
  late BehaviorSubject<BookDownload?> bookDownload;
  late BehaviorSubject<AutoDownload?> autoDownload;
  late BehaviorSubject<AuthState> authState;
  late BookDownloadsViewModel vm;

  setUpAll(() {
    registerFallbackValue(const DownloadScope.all());
    registerFallbackValue(book);
  });

  BookDownloadsViewModel build() => BookDownloadsViewModel(
    downloads: downloads,
    autoDownload: prefs,
    connectivity: connectivity,
    auth: auth,
    bookId: book,
  );

  Future<void> show(List<ChapterDownload> chapters) async {
    bookDownload.add(BookDownload(bookId: book, chapters: chapters));
    await pumpEventQueue();
  }

  setUp(() async {
    downloads = MockDownloadService();
    prefs = MockAutoDownloadPreferences();
    auth = MockAuthService();
    connectivity = FakeConnectivityService(ConnectivityStatus.online);
    bookDownload = BehaviorSubject.seeded(null);
    autoDownload = BehaviorSubject.seeded(null);
    authState = BehaviorSubject.seeded(AuthState.authenticated);

    when(() => downloads.watchBook(book)).thenAnswer((_) => bookDownload);
    when(() => prefs.watch(book)).thenAnswer((_) => autoDownload);
    when(
      () => auth.authenticated,
    ).thenAnswer((_) => authState.value == AuthState.authenticated);
    when(() => auth.authStateStream).thenAnswer((_) => authState);
    for (final stub in <Future<void> Function()>[
      () => downloads.enqueueChapters(any(), any()),
      () => downloads.enqueueBook(any()),
      () => downloads.pause(any()),
      () => downloads.resume(any()),
      () => downloads.retry(any()),
      () => downloads.delete(any()),
      () => prefs.enable(any()),
      () => prefs.disable(any()),
    ]) {
      when(stub).thenAnswer((_) async {});
    }

    vm = build();
    await pumpEventQueue();
  });

  tearDown(() async {
    vm.dispose();
    await bookDownload.close();
    await autoDownload.close();
    await authState.close();
    await connectivity.subject.close();
  });

  group('state', () {
    test(
      'follows the book download, the setting, connectivity and auth',
      () async {
        final since = DateTime(2026, 11, 15);
        await show([chapter(c1, DownloadState.done)]);
        autoDownload.add(AutoDownload(bookId: book, since: since));
        connectivity.subject.add(ConnectivityStatus.offline);
        authState.add(AuthState.unauthenticated);
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
      authState.add(AuthState.unauthenticated);
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

    expect(bookDownload.hasListener, isFalse);
    expect(autoDownload.hasListener, isFalse);
    expect(authState.hasListener, isFalse);
    expect(connectivity.subject.hasListener, isFalse);
    vm = build();
  });
}
