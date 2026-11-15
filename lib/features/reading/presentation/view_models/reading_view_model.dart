import 'dart:async';

import 'package:equatable/equatable.dart';

import '../../../../core/base/base_stream_view_model.dart';
import '../../../../core/connectivity/connectivity_service.dart';
import '../../../../core/logging/logger.dart';
import '../../../../core/network/exceptions.dart';
import '../../domain/entities/reading_chapter.dart';
import '../../domain/entities/reading_enums.dart';
import '../../domain/repositories/reading_repository.dart';
import '../../domain/use_cases/reading_progress_coordinator.dart';
import '../../../../features/books/domain/value_objects/chapter_id.dart';
import '../../../../shared/domain/value_objects/positive_int.dart';

class ReadingState extends Equatable {
  final ReadingChapter? chapter;
  final bool isLoading;
  final String? error;
  final int currentPageIndex;

  /// The server cannot be reached.
  final bool isOffline;

  /// Offline, and the chapter is not downloaded: nothing to show yet.
  final bool isOfflineMiss;

  /// The offline retry is probing the server.
  final bool isRetrying;

  /// Offline retries in a row that could not open the chapter either; 0
  /// until one fails. A count, not a flag, so each failure is announced.
  final int offlineRetryFailures;

  /// Whether the previous and next chapters are downloaded, so they open
  /// while offline. `null` until checked, which happens only offline, and
  /// for a neighbour that does not exist; `null` never disables a button.
  final bool? previousDownloaded;
  final bool? nextDownloaded;

  const ReadingState({
    this.chapter,
    required this.isLoading,
    this.error,
    required this.currentPageIndex,
    this.isOffline = false,
    this.isOfflineMiss = false,
    this.isRetrying = false,
    this.offlineRetryFailures = 0,
    this.previousDownloaded,
    this.nextDownloaded,
  });

  factory ReadingState.initial() {
    return const ReadingState(
      chapter: null,
      isLoading: false,
      error: null,
      currentPageIndex: 0,
    );
  }

  /// Offline, the previous chapter is not downloaded, so it cannot open.
  bool get previousUnavailable => isOffline && previousDownloaded == false;

  /// Offline, the next chapter is not downloaded, so it cannot open.
  bool get nextUnavailable => isOffline && nextDownloaded == false;

  ReadingState copyWith({
    ReadingChapter? Function()? chapter,
    bool? isLoading,
    String? Function()? error,
    int? currentPageIndex,
    bool? isOffline,
    bool? isOfflineMiss,
    bool? isRetrying,
    int? offlineRetryFailures,
    bool? Function()? previousDownloaded,
    bool? Function()? nextDownloaded,
  }) {
    return ReadingState(
      chapter: chapter != null ? chapter() : this.chapter,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isOffline: isOffline ?? this.isOffline,
      isOfflineMiss: isOfflineMiss ?? this.isOfflineMiss,
      isRetrying: isRetrying ?? this.isRetrying,
      offlineRetryFailures: offlineRetryFailures ?? this.offlineRetryFailures,
      previousDownloaded: previousDownloaded != null
          ? previousDownloaded()
          : this.previousDownloaded,
      nextDownloaded: nextDownloaded != null
          ? nextDownloaded()
          : this.nextDownloaded,
    );
  }

  @override
  List<Object?> get props => [
    chapter,
    isLoading,
    error,
    currentPageIndex,
    isOffline,
    isOfflineMiss,
    isRetrying,
    offlineRetryFailures,
    previousDownloaded,
    nextDownloaded,
  ];
}

class ReadingViewModel extends BaseStreamViewModel<ReadingState> {
  final ReadingRepository _repository;
  final ReadingProgressCoordinator _progressCoordinator;
  final ConnectivityService _connectivity;
  late final StreamSubscription<ConnectivityStatus> _statusSubscription;
  late final StreamSubscription<void> _reconnectSubscription;
  static const String _logTag = 'ReadingViewModel';

  /// The last chapter asked for, so a retry or a reconnect can open it
  /// again.
  String? _requestedId;
  int? _requestedPage;

  /// The open chapter came from the device's downloads.
  bool _openedDownloaded = false;

  ReadingViewModel(
    this._repository,
    this._progressCoordinator,
    this._connectivity,
  ) : super(
        ReadingState.initial().copyWith(isOffline: _connectivity.isOffline),
      ) {
    _statusSubscription = _connectivity.statusStream.listen(_onStatus);
    _reconnectSubscription = _connectivity.onReconnected.listen(
      (_) => _onReconnected(),
    );
  }

  ReadingChapter? get chapter => state.chapter;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  int get currentPageIndex => state.currentPageIndex;

  @override
  void dispose() {
    _statusSubscription.cancel();
    _reconnectSubscription.cancel();
    super.dispose();
  }

  Future<void> loadChapter(String chapterId, {int? initialPage}) async {
    if (state.isLoading) return;
    _requestedId = chapterId;
    _requestedPage = initialPage;
    _openedDownloaded = false;
    AppLogger.i(
      'Loading chapter: $chapterId, initialPage: $initialPage',
      _logTag,
    );
    emit(
      state.copyWith(
        isLoading: true,
        error: () => null,
        isOfflineMiss: false,
        offlineRetryFailures: 0,
        currentPageIndex: initialPage ?? 0,
      ),
    );

    try {
      final opened = await _repository.openChapter(ChapterId(chapterId));
      final fetchedChapter = opened.chapter;
      _openedDownloaded = opened.isDownloaded;
      AppLogger.i(
        'Chapter loaded successfully: ${fetchedChapter.title?.value}',
        _logTag,
      );
      final isTextChapter = fetchedChapter.contentType == ContentType.text;

      emit(
        state.copyWith(
          isLoading: false,
          chapter: () => fetchedChapter,
          previousDownloaded: () => null,
          nextDownloaded: () => null,
        ),
      );
      saveProgress(completed: isTextChapter);
      if (_connectivity.isOffline) {
        unawaited(_checkNeighbours(fetchedChapter));
      } else if (opened.isDownloaded) {
        unawaited(_refreshNavigation(fetchedChapter));
      }
    } on OfflineException {
      AppLogger.i('Chapter $chapterId is not downloaded (offline)', _logTag);
      emit(
        state.copyWith(
          isLoading: false,
          isOfflineMiss: true,
          chapter: () => null,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error loading chapter', e, stackTrace, _logTag);
      emit(state.copyWith(isLoading: false, error: () => e.toString()));
    }
  }

  /// The error view's retry: opens the last chapter asked for again.
  Future<void> retry() async {
    final chapterId = _requestedId;
    if (chapterId == null) return;
    await loadChapter(chapterId, initialPage: _requestedPage);
  }

  /// The offline view's retry. Offline, the repository skips the network, so
  /// the server is probed first; the chapter opens only if it answers. When
  /// it still cannot open, [ReadingState.offlineRetryFailures] counts it and the
  /// offline view stays as it is. A tap while a retry runs is ignored.
  Future<void> retryOffline() async {
    final chapterId = _requestedId;
    if (chapterId == null || state.isRetrying) return;
    // A load in between resets the count: keep it to add this failure.
    final failures = state.offlineRetryFailures;
    emit(state.copyWith(isRetrying: true));
    try {
      await _connectivity.checkNow();
    } catch (e, stackTrace) {
      AppLogger.e('Connectivity probe failed', e, stackTrace, _logTag);
    }
    emit(state.copyWith(isRetrying: false));
    if (!_connectivity.isOffline) {
      await loadChapter(chapterId, initialPage: _requestedPage);
    }
    if (state.isOfflineMiss) {
      emit(state.copyWith(offlineRetryFailures: failures + 1));
    }
  }

  /// Going offline is when neighbours start to matter: check them afresh
  /// each time, since one may have been downloaded while online.
  void _onStatus(ConnectivityStatus status) {
    final offline = status == ConnectivityStatus.offline;
    emit(
      state.copyWith(
        isOffline: offline,
        previousDownloaded: () => null,
        nextDownloaded: () => null,
      ),
    );
    final current = state.chapter;
    if (offline && current != null) {
      unawaited(_checkNeighbours(current));
    }
  }

  void _onReconnected() {
    final chapterId = _requestedId;
    if (chapterId == null) return;
    if (state.isOfflineMiss) {
      AppLogger.i('Reconnected: opening chapter $chapterId', _logTag);
      loadChapter(chapterId, initialPage: _requestedPage);
      return;
    }
    final current = state.chapter;
    if (current != null && _openedDownloaded) {
      unawaited(_refreshNavigation(current));
    }
  }

  /// Which neighbours open offline. Checked when a chapter opens offline and
  /// each time the status turns offline.
  Future<void> _checkNeighbours(ReadingChapter chapter) async {
    // A missing neighbour stays null: there is nothing to be unavailable.
    final (previous, next) = await (
      _isDownloaded(chapter.hasPrevious ? chapter.previous : null),
      _isDownloaded(chapter.hasNext ? chapter.next : null),
    ).wait;
    // Only for the neighbours checked, and only while still offline: a
    // navigation refresh may have replaced them, or a reconnect dropped the
    // check, meanwhile.
    final current = state.chapter;
    if (!state.isOffline ||
        current == null ||
        current.id != chapter.id ||
        current.previous != chapter.previous ||
        current.next != chapter.next) {
      return;
    }
    emit(
      state.copyWith(
        previousDownloaded: () => previous,
        nextDownloaded: () => next,
      ),
    );
  }

  Future<bool?> _isDownloaded(ChapterId? id) async =>
      id == null ? null : _repository.isDownloaded(id);

  /// A downloaded copy keeps the neighbours it had when it was saved: ask
  /// the server for the current ones, so later chapters stay reachable.
  Future<void> _refreshNavigation(ReadingChapter chapter) async {
    final ReadingChapter refreshed;
    try {
      refreshed = await _repository.refreshNavigation(chapter);
    } catch (e, stackTrace) {
      // The saved neighbours still work; nothing to tell the reader.
      AppLogger.e(
        'Could not refresh the chapter navigation',
        e,
        stackTrace,
        _logTag,
      );
      return;
    }
    final current = state.chapter;
    if (current == null || current.id != chapter.id) return;
    if (current.previous == refreshed.previous &&
        current.next == refreshed.next) {
      return;
    }
    emit(
      state.copyWith(
        chapter: () => refreshed,
        previousDownloaded: () => null,
        nextDownloaded: () => null,
      ),
    );
    if (_connectivity.isOffline) await _checkNeighbours(refreshed);
  }

  void setCurrentPage(int index, {bool isAutoSave = true}) {
    if (state.currentPageIndex != index) {
      emit(state.copyWith(currentPageIndex: index));

      if (isAutoSave && state.chapter != null) {
        final totalPages = state.chapter!.pages.length;
        final isLastPage = totalPages > 0 && index == totalPages - 1;
        saveProgress(completed: isLastPage);
      }
    }
  }

  Future<void> saveProgress({bool completed = false}) async {
    final chapterToSave = state.chapter;
    if (chapterToSave == null) return;

    try {
      await _progressCoordinator.saveProgress(
        chapterId: chapterToSave.id,
        bookId: chapterToSave.bookId,
        pageIndex: PositiveInt(state.currentPageIndex),
        totalPages: PositiveInt(chapterToSave.pages.length),
        completed: completed,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error saving progress in ViewModel', e, stackTrace, _logTag);
    }
  }
}
