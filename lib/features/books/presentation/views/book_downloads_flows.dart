import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../shared/components/organisms/app_confirm_dialog.dart';
import '../../../../shared/utils/bottom_sheet_utils.dart';
import '../../../../shared/utils/format_bytes.dart';
import '../../../downloads/domain/entities/download_state.dart';
import '../../domain/entities/chapter.dart';
import '../components/molecules/book_downloads_summary.dart';
import '../components/molecules/chapter_selection_actions.dart';
import '../components/organisms/book_options_sheet.dart';
import '../components/organisms/chapter_download_sheet.dart';
import '../view_models/book_downloads_view_model.dart';

/// The download interactions of the book page: sheets, confirmations and
/// the texts derived from [BookDownloadsState]. Kept apart from the layout
/// so the page's widgets only arrange what these return.
class BookDownloadsFlows {
  final BookDownloadsViewModel viewModel;

  const BookDownloadsFlows(this.viewModel);

  static String sizeOf(BuildContext context, int bytes) =>
      formatBytes(bytes, Localizations.localeOf(context).toString());

  /// "Capítulo N - Title", as the tile and the sheets show it.
  static String chapterTitle(AppLocalizations l10n, Chapter chapter) {
    final index = chapter.index.value;
    final label = l10n.booksChapterLabel(
      index == index.toInt() ? index.toInt().toString() : index.toString(),
    );
    final title = chapter.title?.value;
    return title == null || title.isEmpty ? label : '$label - $title';
  }

  /// The localized reason of a `DownloadErrors` code.
  static String failureReason(AppLocalizations l10n, String? code) =>
      switch (code) {
        DownloadErrors.signInRequired => l10n.booksDownloadErrorSignIn,
        DownloadErrors.storageFull => l10n.booksDownloadErrorStorageFull,
        DownloadErrors.notFound => l10n.booksDownloadErrorNotFound,
        DownloadErrors.timedOut => l10n.booksDownloadErrorTimedOut,
        DownloadErrors.server => l10n.booksDownloadErrorServer,
        _ => l10n.booksDownloadErrorUnknown,
      };

  /// The summary strip, or null when the book has no downloads.
  static BookDownloadsSummary? summary(
    BuildContext context,
    BookDownloadsState state, {
    required int? totalChapters,
    required VoidCallback onAction,
  }) {
    final phase = state.phase;
    if (phase == null) return null;
    final l10n = AppLocalizations.of(context)!;
    final done = state.count(DownloadState.done);
    final size = sizeOf(context, state.download!.bytes);
    final active =
        phase == BookDownloadPhase.active ||
        phase == BookDownloadPhase.waitingForConnection;
    return BookDownloadsSummary(
      countLabel: totalChapters == null
          ? l10n.booksDownloadsSummary(done, size)
          : l10n.booksDownloadsSummaryOfTotal(done, totalChapters, size),
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
      onAction: onAction,
      progress: active ? state.activeProgress : null,
      progressMuted: phase == BookDownloadPhase.waitingForConnection,
    );
  }

  /// The selection mode's bottom bar.
  ChapterSelectionActions selectionActions(
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
          onPressed: picked ? viewModel.downloadSelection : null,
        ),
        SelectionAction(
          icon: Icons.delete_outline,
          label: l10n.booksSelectionDelete,
          danger: true,
          onPressed: state.selectionHasDownload
              ? () => deleteSelection(context)
              : null,
        ),
        if (state.selectionHas({DownloadState.queued, DownloadState.running}))
          SelectionAction(
            icon: Icons.pause,
            label: l10n.booksSelectionPause,
            onPressed: viewModel.pauseSelection,
          ),
        if (state.selectionHas({DownloadState.paused}))
          SelectionAction(
            icon: Icons.play_arrow,
            label: l10n.booksSelectionResume,
            onPressed: viewModel.resumeSelection,
          ),
        if (state.selectionHas({DownloadState.failed}))
          SelectionAction(
            icon: Icons.refresh,
            label: l10n.booksSelectionRetry,
            onPressed: viewModel.retrySelection,
          ),
      ],
    );
  }

  /// Deletes the selected downloads, after a confirmation when there is
  /// more than one.
  Future<void> deleteSelection(BuildContext context) async {
    final state = viewModel.state;
    final withDownload = [
      for (final id in state.selection)
        if (state.chapter(id) != null) id,
    ];
    if (withDownload.length > 1) {
      final l10n = AppLocalizations.of(context)!;
      final confirmed = await AppConfirmDialog.show(
        context,
        title: l10n.booksDeleteChaptersTitle(withDownload.length),
        body: l10n.booksDeleteChaptersBody(
          withDownload.length,
          sizeOf(context, state.bytesOf(withDownload)),
        ),
        confirmLabel: l10n.booksDeleteConfirm,
        destructive: true,
      );
      if (!confirmed) return;
    }
    await viewModel.deleteSelection();
  }

  /// The book's ⋮ sheet; it follows the downloads while open.
  Future<void> openBookOptions(BuildContext context) {
    return showAppModalBottomSheet<void>(
      context: context,
      glass: true,
      builder: (sheetContext) => StreamBuilder<BookDownloadsState>(
        stream: viewModel.stateStream,
        initialData: viewModel.state,
        builder: (sheetContext, snapshot) {
          final state = snapshot.data!;
          return BookOptionsSheet(
            canDownloadAll: state.canDownloadAll,
            downloadCount: state.downloadCount,
            downloadSize: sizeOf(sheetContext, state.download?.bytes ?? 0),
            autoDownloadOn: state.autoDownloadOn,
            onDownloadAll: () {
              Navigator.of(sheetContext).pop();
              viewModel.downloadAll();
            },
            onDeleteAll: () {
              Navigator.of(sheetContext).pop();
              deleteAll(context);
            },
            onAutoDownloadChanged: viewModel.setAutoDownload,
          );
        },
      ),
    );
  }

  /// Deletes every download of the book after a confirmation.
  Future<void> deleteAll(BuildContext context) async {
    final state = viewModel.state;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppConfirmDialog.show(
      context,
      title: l10n.booksDeleteAllTitle,
      body: l10n.booksDeleteChaptersBody(
        state.downloadCount,
        sizeOf(context, state.download?.bytes ?? 0),
      ),
      confirmLabel: l10n.booksDeleteConfirm,
      destructive: true,
    );
    if (confirmed) await viewModel.deleteAll();
  }

  /// A tap on [chapter]'s indicator: acts directly, or opens the sheet of
  /// a failed or downloaded chapter.
  Future<void> tapIndicator(BuildContext context, Chapter chapter) async {
    final sheet = await viewModel.tapIndicator(chapter.id);
    if (sheet == null || !context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final download = viewModel.state.chapter(chapter.id);
    if (download == null) return;
    final title = chapterTitle(l10n, chapter);
    await showAppModalBottomSheet<void>(
      context: context,
      glass: true,
      builder: (sheetContext) {
        void close() => Navigator.of(sheetContext).pop();
        return sheet == ChapterIndicatorAction.openFailed
            ? ChapterDownloadSheet.failed(
                title: title,
                reason: failureReason(l10n, download.error),
                onRetry: () {
                  close();
                  viewModel.retry([chapter.id]);
                },
                onDelete: () {
                  close();
                  viewModel.delete([chapter.id]);
                },
              )
            : ChapterDownloadSheet.done(
                title: title,
                size: sizeOf(sheetContext, download.bytes),
                onDelete: () {
                  close();
                  viewModel.delete([chapter.id]);
                },
              );
      },
    );
  }
}
