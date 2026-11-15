/// A [BookDownloadsViewModel] over mocked downloads, settings and auth, with
/// subjects the test drives.
library;

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

class MockDownloadsAuthService extends Mock implements AuthService {}

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

const fixtureBook = BookId('book-1');

ChapterDownload chapterDownload(
  ChapterId id,
  DownloadState state, {
  int bytes = 0,
  int filesDone = 0,
  int filesTotal = 0,
  DownloadWaitReason reason = DownloadWaitReason.none,
  String? error,
}) => ChapterDownload(
  chapterId: id,
  bookId: fixtureBook,
  state: state,
  bytes: bytes,
  filesDone: filesDone,
  filesTotal: filesTotal,
  reason: reason,
  error: error,
);

/// Call [setUp] in the test's `setUp` and [tearDown] in its `tearDown`.
class BookDownloadsFixture {
  late MockDownloadService downloads;
  late MockAutoDownloadPreferences prefs;
  late MockDownloadsAuthService auth;
  late FakeConnectivityService connectivity;
  late BehaviorSubject<BookDownload?> bookDownload;
  late BehaviorSubject<AutoDownload?> autoDownload;
  late BehaviorSubject<AuthState> authState;

  static void registerFallbacks() {
    registerFallbackValue(const DownloadScope.all());
    registerFallbackValue(fixtureBook);
  }

  void setUp({
    ConnectivityStatus status = ConnectivityStatus.online,
    AuthState auth = AuthState.authenticated,
  }) {
    downloads = MockDownloadService();
    prefs = MockAutoDownloadPreferences();
    this.auth = MockDownloadsAuthService();
    connectivity = FakeConnectivityService(status);
    bookDownload = BehaviorSubject.seeded(null);
    autoDownload = BehaviorSubject.seeded(null);
    authState = BehaviorSubject.seeded(auth);

    when(
      () => downloads.watchBook(fixtureBook),
    ).thenAnswer((_) => bookDownload);
    when(() => prefs.watch(fixtureBook)).thenAnswer((_) => autoDownload);
    when(
      () => this.auth.authenticated,
    ).thenAnswer((_) => authState.value == AuthState.authenticated);
    when(() => this.auth.authStateStream).thenAnswer((_) => authState);
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
  }

  BookDownloadsViewModel build() => BookDownloadsViewModel(
    downloads: downloads,
    autoDownload: prefs,
    connectivity: connectivity,
    auth: auth,
    bookId: fixtureBook,
  );

  void show(List<ChapterDownload> chapters) =>
      bookDownload.add(BookDownload(bookId: fixtureBook, chapters: chapters));

  Future<void> tearDown() async {
    await bookDownload.close();
    await autoDownload.close();
    await authState.close();
    await connectivity.subject.close();
  }
}
