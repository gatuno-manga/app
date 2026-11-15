import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../shared/components/atoms/app_text_button.dart';
import '../../../downloads/domain/entities/download_state.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../components/molecules/book_downloads_summary.dart';
import '../components/molecules/chapter_selection_actions.dart';
import '../components/molecules/chapter_selection_bar.dart';
import '../components/organisms/book_details_content.dart';
import '../components/organisms/book_details_error.dart';
import '../components/organisms/book_details_loading.dart';
import '../view_models/book_details_view_model.dart';
import '../view_models/book_downloads_view_model.dart';
import 'book_downloads_flows.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late final BookDetailsViewModel _viewModel;
  late final BookDownloadsViewModel _downloads;
  late final BookDownloadsFlows _flows;
  late final StreamSubscription<BookDownloadsNotice?> _notices;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<BookDetailsViewModel>();
    _downloads = context.read<BookDownloadsViewModel>();
    _flows = BookDownloadsFlows(_downloads);
    _notices = _downloads.stateStream
        .map((s) => s.notice)
        .distinct()
        .listen(_showNotice);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchBookDetails();
    });
  }

  @override
  void dispose() {
    unawaited(_notices.cancel());
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMoreChapters();
    }
  }

  void _showNotice(BookDownloadsNotice? notice) {
    if (notice == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(switch (notice) {
        BookDownloadsNotice.signInRequired => SnackBar(
          content: Text(l10n.booksDownloadSignInRequired),
          action: SnackBarAction(
            label: l10n.booksDownloadSignIn,
            onPressed: () => router.push('/auth/signin'),
          ),
        ),
        BookDownloadsNotice.actionFailed => SnackBar(
          content: Text(l10n.booksDownloadActionFailed),
        ),
      });
    _downloads.clearNotice();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<BookDetailsState>(
      stream: _viewModel.stateStream,
      initialData: _viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        if (state.isLoading && state.book == null) {
          return const BookDetailsLoading();
        }

        if (state.error != null && state.book == null) {
          return BookDetailsError(
            error: state.error!,
            onRetry: _viewModel.fetchBookDetails,
          );
        }

        final book = state.book;
        if (book == null) {
          return BookDetailsError(
            error: l10n.booksNoBooksFound,
            onRetry: _viewModel.fetchBookDetails,
          );
        }

        return StreamBuilder<BookDownloadsState>(
          stream: _downloads.stateStream,
          initialData: _downloads.state,
          builder: (context, snapshot) =>
              _buildContent(context, book, snapshot.data!),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    Book book,
    BookDownloadsState downloads,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Only chapters the server has ready can be picked and downloaded.
    final selectable = [
      for (final c in _viewModel.chapterList?.data ?? const <Chapter>[])
        if (c.isReadable) c.id,
    ];
    final selecting = downloads.selecting;

    // Back leaves selection mode before it leaves the page.
    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _downloads.clearSelection();
      },
      child: BookDetailsContent(
        viewModel: _viewModel,
        book: book,
        scrollController: _scrollController,
        onMenuPressed: () => _flows.openBookOptions(context),
        selectionBar: selecting
            ? ChapterSelectionBar(
                countLabel: l10n.booksSelectionCount(
                  downloads.selection.length,
                ),
                closeTooltip: l10n.booksSelectionClose,
                selectLoadedTooltip: l10n.booksSelectionSelectLoaded,
                onClose: _downloads.clearSelection,
                onSelectLoaded: selectable.every(downloads.selection.contains)
                    ? null
                    : () => _downloads.selectAll(selectable),
              )
            : null,
        downloadSummary: _summary(context, book, downloads),
        // Hidden while selecting but keeping its room, so the list does
        // not move when the mode toggles.
        chapterControls: selectable.isEmpty
            ? null
            : Visibility(
                visible: !selecting,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: AppTextButton(
                  text: l10n.booksSelect,
                  icon: Icons.check_circle_outline,
                  onPressed: _downloads.startSelection,
                ),
              ),
        bottomBar: selecting ? _selectionActions(context, downloads) : null,
        chapterDownloads: ChapterListDownloads(
          displayOf: (chapter) => ChapterDownloadDisplay(
            status: downloads.statusOf(chapter.id),
            progress: downloads.chapter(chapter.id)?.progress ?? 0,
          ),
          selecting: selecting,
          isSelected: (chapter) => downloads.selection.contains(chapter.id),
          onToggleSelected: (chapter) => _downloads.toggleSelection(chapter.id),
          onLongPress: (chapter) => _downloads.startSelection(chapter.id),
          onIndicatorTap: (chapter) => _flows.tapIndicator(context, chapter),
        ),
      ),
    );
  }

  /// The summary strip, or null when the book has no downloads.
  BookDownloadsSummary? _summary(
    BuildContext context,
    Book book,
    BookDownloadsState state,
  ) {
    final phase = state.phase;
    if (phase == null) return null;
    final l10n = AppLocalizations.of(context)!;
    final done = state.count(DownloadState.done);
    final size = BookDownloadsFlows.sizeOf(context, state.download!.bytes);
    final total = book.totalChapters?.value;
    final active =
        phase == BookDownloadPhase.active ||
        phase == BookDownloadPhase.waitingForConnection;
    return BookDownloadsSummary(
      countLabel: total == null
          ? l10n.booksDownloadsSummary(done, size)
          : l10n.booksDownloadsSummaryOfTotal(done, total, size),
      statusLabel: switch (phase) {
        BookDownloadPhase.active =>
          state.allActiveWaitForWifi
              ? l10n.booksDownloadsPhaseWaitingWifi
              : l10n.booksDownloadsPhaseActive(state.activeCount),
        BookDownloadPhase.waitingForConnection =>
          l10n.booksDownloadsPhaseWaitingConnection,
        BookDownloadPhase.paused => l10n.booksDownloadsPhasePaused(
          state.count(DownloadState.paused),
        ),
        BookDownloadPhase.failed => l10n.booksDownloadsPhaseFailed(
          state.count(DownloadState.failed),
        ),
        BookDownloadPhase.done => null,
      },
      statusIsError: phase == BookDownloadPhase.failed,
      actionLabel: switch (state.stripAction) {
        BookDownloadAction.pauseAll => l10n.booksDownloadsPauseAll,
        BookDownloadAction.resumeAll => l10n.booksDownloadsResumeAll,
        BookDownloadAction.retryFailed => l10n.booksDownloadsRetryFailed(
          state.count(DownloadState.failed),
        ),
        null => null,
      },
      onAction: _downloads.runStripAction,
      progress: active ? state.activeProgress : null,
      progressMuted:
          phase == BookDownloadPhase.waitingForConnection ||
          state.allActiveWaitForWifi,
    );
  }

  ChapterSelectionActions _selectionActions(
    BuildContext context,
    BookDownloadsState state,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final picked = state.selection.isNotEmpty;
    return ChapterSelectionActions(
      actions: [
        SelectionAction(
          icon: Icons.download,
          label: l10n.booksSelectionDownload,
          onPressed: picked ? _downloads.downloadSelection : null,
        ),
        SelectionAction(
          icon: Icons.delete_outline,
          label: l10n.booksSelectionDelete,
          danger: true,
          onPressed: state.selectionHasDownload
              ? () => _flows.deleteSelection(context)
              : null,
        ),
        if (state.selectionHas({DownloadState.queued, DownloadState.running}))
          SelectionAction(
            icon: Icons.pause,
            label: l10n.booksSelectionPause,
            onPressed: _downloads.pauseSelection,
          ),
        if (state.selectionHas({DownloadState.paused}))
          SelectionAction(
            icon: Icons.play_arrow,
            label: l10n.booksSelectionResume,
            onPressed: _downloads.resumeSelection,
          ),
        if (state.selectionHas({DownloadState.failed}))
          SelectionAction(
            icon: Icons.refresh,
            label: l10n.booksSelectionRetry,
            onPressed: _downloads.retrySelection,
          ),
      ],
    );
  }
}
