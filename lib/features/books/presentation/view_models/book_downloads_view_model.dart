import 'dart:async';

import 'package:equatable/equatable.dart';

import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/logging/logger.dart';
import '../../../authentication/domain/use_cases/auth_service.dart';
import '../../../downloads/domain/entities/auto_download.dart';
import '../../../downloads/domain/entities/book_download.dart';
import '../../../downloads/domain/entities/chapter_download.dart';
import '../../../downloads/domain/entities/download_scope.dart';
import '../../../downloads/domain/entities/download_state.dart';
import '../../../downloads/domain/repositories/auto_download_preferences.dart';
import '../../../downloads/domain/repositories/download_service.dart';
import '../../domain/value_objects/book_id.dart';
import '../../domain/value_objects/chapter_id.dart';
import '../models/download_display.dart';

export '../models/download_display.dart';

/// A one-off message for the screen to show, then clear with
/// [BookDownloadsViewModel.clearNotice].
enum BookDownloadsNotice {
  /// A guest tried to start a download: offer to sign in.
  signInRequired,

  /// A download command threw.
  actionFailed,
}

/// What a tap on a chapter's download indicator leads to.
enum ChapterIndicatorAction {
  download,
  pause,
  resume,

  /// Show the failed chapter's reason with Retry and Delete.
  openFailed,

  /// Show the done chapter's size with Delete.
  openDone,
}

/// The single book-wide action of the summary strip.
enum BookDownloadAction { pauseAll, resumeAll, retryFailed }

class BookDownloadsState extends Equatable {
  /// The book's downloads; `null` when it has none.
  final BookDownload? download;

  /// Automatic download of new chapters; `null` while it is off.
  final AutoDownload? autoDownload;

  final bool offline;
  final bool authenticated;

  /// Selection mode is on; it may have nothing picked yet.
  final bool selecting;

  /// Chapters picked in selection mode; empty outside it.
  final Set<ChapterId> selection;

  final BookDownloadsNotice? notice;

  const BookDownloadsState({
    required this.download,
    required this.autoDownload,
    required this.offline,
    required this.authenticated,
    required this.selecting,
    required this.selection,
    required this.notice,
  });

  factory BookDownloadsState.initial({
    required bool offline,
    required bool authenticated,
  }) => BookDownloadsState(
    download: null,
    autoDownload: null,
    offline: offline,
    authenticated: authenticated,
    selecting: false,
    selection: const {},
    notice: null,
  );

  BookDownloadsState copyWith({
    BookDownload? Function()? download,
    AutoDownload? Function()? autoDownload,
    bool? offline,
    bool? authenticated,
    bool? selecting,
    Set<ChapterId>? selection,
    BookDownloadsNotice? Function()? notice,
  }) => BookDownloadsState(
    download: download != null ? download() : this.download,
    autoDownload: autoDownload != null ? autoDownload() : this.autoDownload,
    offline: offline ?? this.offline,
    authenticated: authenticated ?? this.authenticated,
    selecting: selecting ?? this.selecting,
    selection: selection ?? this.selection,
    notice: notice != null ? notice() : this.notice,
  );

  bool get autoDownloadOn => autoDownload != null;

  /// Download all pages the chapter list from the server, so it needs it.
  bool get canDownloadAll => !offline;

  /// The download of [chapterId], or `null` when it has none.
  ChapterDownload? chapter(ChapterId chapterId) {
    for (final c in download?.chapters ?? const <ChapterDownload>[]) {
      if (c.chapterId == chapterId) return c;
    }
    return null;
  }

  /// Queued or running while the server is unreachable: the engine plans it
  /// on reconnect.
  bool waitingForConnection(ChapterId chapterId) {
    final state = chapter(chapterId)?.state;
    return offline &&
        (state == DownloadState.queued || state == DownloadState.running);
  }

  ChapterIndicatorAction indicatorAction(ChapterId chapterId) {
    switch (chapter(chapterId)?.state) {
      case null:
        return ChapterIndicatorAction.download;
      case DownloadState.queued:
      case DownloadState.running:
        return ChapterIndicatorAction.pause;
      case DownloadState.paused:
        return ChapterIndicatorAction.resume;
      case DownloadState.failed:
        return ChapterIndicatorAction.openFailed;
      case DownloadState.done:
        return ChapterIndicatorAction.openDone;
    }
  }

  /// Whether any selected chapter is in one of [states], to offer the
  /// matching selection action.
  bool selectionHas(Set<DownloadState> states) =>
      selection.any((id) => states.contains(chapter(id)?.state));

  /// Bytes on disk of [chapterIds], for the delete confirmation.
  int bytesOf(Iterable<ChapterId> chapterIds) =>
      chapterIds.fold(0, (sum, id) => sum + (chapter(id)?.bytes ?? 0));

  ChapterDownloadStatus statusOf(ChapterId chapterId) {
    final c = chapter(chapterId);
    if (c == null) return ChapterDownloadStatus.none;
    switch (c.state) {
      case DownloadState.queued:
      case DownloadState.running:
        if (offline) return ChapterDownloadStatus.waitingForConnection;
        if (c.reason == DownloadWaitReason.waitingForNetwork) {
          return ChapterDownloadStatus.waitingForNetwork;
        }
        return c.state == DownloadState.running
            ? ChapterDownloadStatus.running
            : ChapterDownloadStatus.queued;
      case DownloadState.paused:
        return ChapterDownloadStatus.paused;
      case DownloadState.failed:
        return ChapterDownloadStatus.failed;
      case DownloadState.done:
        return ChapterDownloadStatus.done;
    }
  }

  List<ChapterDownload> get _chapters =>
      download?.chapters ?? const <ChapterDownload>[];

  List<ChapterDownload> get _active => [
    for (final c in _chapters)
      if (c.state == DownloadState.queued || c.state == DownloadState.running)
        c,
  ];

  int count(DownloadState state) => download?.count(state) ?? 0;

  /// Every chapter download of the book, in any state: what Delete all
  /// removes.
  int get downloadCount => _chapters.length;

  int get activeCount => _active.length;

  /// Every active chapter waits for Wi-Fi.
  bool get allActiveWaitForWifi =>
      _active.isNotEmpty &&
      _active.every((c) => c.reason == DownloadWaitReason.waitingForNetwork);

  /// The strip's status line: active > waiting for connection > paused >
  /// failed > done. `null` when the book has no downloads.
  BookDownloadPhase? get phase {
    if (_chapters.isEmpty) return null;
    if (_active.isNotEmpty) {
      return offline
          ? BookDownloadPhase.waitingForConnection
          : BookDownloadPhase.active;
    }
    if (count(DownloadState.paused) > 0) return BookDownloadPhase.paused;
    if (count(DownloadState.failed) > 0) return BookDownloadPhase.failed;
    return BookDownloadPhase.done;
  }

  /// Files on disk out of the files known, over the active chapters only:
  /// the strip's bar, shown while any chapter is active.
  double get activeProgress {
    var done = 0;
    var total = 0;
    for (final c in _active) {
      done += c.filesDone;
      total += c.filesTotal;
    }
    return total == 0 ? 0 : done / total;
  }

  /// Some selected chapter has a download, so Delete has something to do.
  bool get selectionHasDownload => selection.any((id) => chapter(id) != null);

  /// The strip's action: pause while anything is active, then resume what is
  /// paused, then retry what failed.
  BookDownloadAction? get stripAction {
    final d = download;
    if (d == null) return null;
    if (d.count(DownloadState.queued) + d.count(DownloadState.running) > 0) {
      return BookDownloadAction.pauseAll;
    }
    if (d.count(DownloadState.paused) > 0) return BookDownloadAction.resumeAll;
    if (d.count(DownloadState.failed) > 0) {
      return BookDownloadAction.retryFailed;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    download,
    autoDownload,
    offline,
    authenticated,
    selecting,
    selection,
    notice,
  ];
}

/// Download controls of one book: per-chapter and book-wide actions,
/// selection mode and the automatic download setting.
///
/// Guests can pause and delete, but anything that starts a download asks
/// them to sign in. Offline, chapters still queue (they wait for the
/// server), but Download all cannot page the chapter list.
class BookDownloadsViewModel extends BaseStreamViewModel<BookDownloadsState> {
  final DownloadService _downloads;
  final AutoDownloadPreferences _autoDownload;
  final ConnectivityService _connectivity;
  final AuthService _auth;
  final BookId bookId;
  static const String _logTag = 'BookDownloadsViewModel';

  final List<StreamSubscription<Object?>> _subscriptions = [];

  BookDownloadsViewModel({
    required DownloadService downloads,
    required AutoDownloadPreferences autoDownload,
    required ConnectivityService connectivity,
    required AuthService auth,
    required this.bookId,
  }) : _downloads = downloads,
       _autoDownload = autoDownload,
       _connectivity = connectivity,
       _auth = auth,
       super(
         BookDownloadsState.initial(
           offline: connectivity.isOffline,
           authenticated: auth.authenticated,
         ),
       ) {
    _subscriptions
      ..add(
        _downloads
            .watchBook(bookId)
            .listen(_onDownload, onError: _onStreamError),
      )
      ..add(
        _autoDownload
            .watch(bookId)
            .listen(
              (a) => emit(state.copyWith(autoDownload: () => a)),
              onError: _onStreamError,
            ),
      )
      ..add(
        _connectivity.statusStream.listen(
          (s) => emit(state.copyWith(offline: s == ConnectivityStatus.offline)),
        ),
      )
      ..add(
        _auth.authStateStream.listen(
          (s) =>
              emit(state.copyWith(authenticated: s == AuthState.authenticated)),
        ),
      );
  }

  void _onDownload(BookDownload? download) =>
      emit(state.copyWith(download: () => download));

  void _onStreamError(Object error, StackTrace stackTrace) =>
      AppLogger.e('Download stream failed', error, stackTrace, _logTag);

  // Per chapter

  /// Applies the tap on [chapterId]'s indicator. Returns the sheet to open
  /// for a failed or done chapter, `null` when it acted directly.
  Future<ChapterIndicatorAction?> tapIndicator(ChapterId chapterId) async {
    final action = state.indicatorAction(chapterId);
    switch (action) {
      case ChapterIndicatorAction.download:
        await download([chapterId]);
      case ChapterIndicatorAction.pause:
        await pause([chapterId]);
      case ChapterIndicatorAction.resume:
        await resume([chapterId]);
      case ChapterIndicatorAction.openFailed:
      case ChapterIndicatorAction.openDone:
        return action;
    }
    return null;
  }

  Future<void> download(List<ChapterId> chapterIds) => _start(
    'download ${chapterIds.length} chapters',
    () => _downloads.enqueueChapters(bookId, chapterIds),
  );

  Future<void> pause(List<ChapterId> chapterIds) => _run(
    'pause ${chapterIds.length} chapters',
    () => _downloads.pause(DownloadScope.chapters(chapterIds)),
  );

  Future<void> resume(List<ChapterId> chapterIds) => _start(
    'resume ${chapterIds.length} chapters',
    () => _downloads.resume(DownloadScope.chapters(chapterIds)),
  );

  Future<void> retry(List<ChapterId> chapterIds) => _start(
    'retry ${chapterIds.length} chapters',
    () => _downloads.retry(DownloadScope.chapters(chapterIds)),
  );

  Future<void> delete(List<ChapterId> chapterIds) => _run(
    'delete ${chapterIds.length} chapters',
    () => _downloads.delete(DownloadScope.chapters(chapterIds)),
  );

  // Book-wide

  /// Queues every chapter of the book, loaded or not. Does nothing offline.
  Future<void> downloadAll() async {
    if (!state.canDownloadAll) return;
    await _start('download all', () => _downloads.enqueueBook(bookId));
  }

  Future<void> deleteAll() =>
      _run('delete all', () => _downloads.delete(DownloadScope.book(bookId)));

  /// Runs the strip's current action.
  Future<void> runStripAction() async {
    final scope = DownloadScope.book(bookId);
    switch (state.stripAction) {
      case BookDownloadAction.pauseAll:
        await _run('pause all', () => _downloads.pause(scope));
      case BookDownloadAction.resumeAll:
        await _start('resume all', () => _downloads.resume(scope));
      case BookDownloadAction.retryFailed:
        await _start('retry failed', () => _downloads.retry(scope));
      case null:
        return;
    }
  }

  /// Turning it on downloads nothing now; turning it off always works.
  Future<void> setAutoDownload(bool on) => on
      ? _start('auto-download on', () => _autoDownload.enable(bookId))
      : _run('auto-download off', () => _autoDownload.disable(bookId));

  // Selection mode

  /// Enters selection mode, with [chapterId] picked on a long-press or
  /// nothing picked from the Select button.
  void startSelection([ChapterId? chapterId]) =>
      emit(state.copyWith(selecting: true, selection: {?chapterId}));

  /// Picks or unpicks [chapterId]. The mode stays on with nothing picked.
  void toggleSelection(ChapterId chapterId) {
    final next = {...state.selection};
    if (!next.remove(chapterId)) next.add(chapterId);
    emit(state.copyWith(selection: next));
  }

  /// Picks every loaded chapter.
  void selectAll(Iterable<ChapterId> loaded) =>
      emit(state.copyWith(selection: {...state.selection, ...loaded}));

  /// Leaves selection mode (Back or clear).
  void clearSelection() =>
      emit(state.copyWith(selecting: false, selection: const {}));

  Future<void> downloadSelection() => _onSelection(download);
  Future<void> pauseSelection() => _onSelection(pause);
  Future<void> resumeSelection() => _onSelection(resume);
  Future<void> retrySelection() => _onSelection(retry);
  Future<void> deleteSelection() => _onSelection(delete);

  /// Applies [action] to the selection and leaves selection mode. With
  /// nothing picked, it does nothing and the mode stays.
  Future<void> _onSelection(
    Future<void> Function(List<ChapterId>) action,
  ) async {
    final ids = state.selection.toList();
    if (ids.isEmpty) return;
    clearSelection();
    await action(ids);
  }

  void clearNotice() => emit(state.copyWith(notice: () => null));

  /// [_run] for commands that start a download: guests are asked to sign
  /// in instead, since planning a chapter needs a session.
  Future<void> _start(String what, Future<void> Function() command) async {
    if (!state.authenticated) {
      emit(state.copyWith(notice: () => BookDownloadsNotice.signInRequired));
      return;
    }
    await _run(what, command);
  }

  Future<void> _run(String what, Future<void> Function() command) async {
    AppLogger.i('Downloads of $bookId: $what', _logTag);
    try {
      await command();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to $what', e, stackTrace, _logTag);
      emit(state.copyWith(notice: () => BookDownloadsNotice.actionFailed));
    }
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    super.dispose();
  }
}
