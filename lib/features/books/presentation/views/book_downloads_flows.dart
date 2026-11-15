import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../shared/components/organisms/app_confirm_dialog.dart';
import '../../../../shared/utils/bottom_sheet_utils.dart';
import '../../../../shared/utils/format_bytes.dart';
import '../../../downloads/domain/entities/download_state.dart';
import '../../domain/entities/chapter.dart';
import '../components/organisms/book_options_sheet.dart';
import '../components/organisms/chapter_download_sheet.dart';
import '../models/chapter_label.dart';
import '../view_models/book_downloads_view_model.dart';

/// The sheets and confirmations of the book page's downloads.
class BookDownloadsFlows {
  final BookDownloadsViewModel viewModel;

  const BookDownloadsFlows(this.viewModel);

  static String sizeOf(BuildContext context, int bytes) =>
      formatBytes(bytes, Localizations.localeOf(context).toString());

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
          void close() => Navigator.of(sheetContext).pop();
          return BookOptionsSheet(
            canDownloadAll: state.canDownloadAll,
            downloadCount: state.downloadCount,
            downloadSize: sizeOf(sheetContext, state.download?.bytes ?? 0),
            autoDownloadOn: state.autoDownloadOn,
            onDownloadAll: () {
              close();
              viewModel.downloadAll();
            },
            onDeleteAll: () {
              close();
              deleteAll(context);
            },
            onAutoDownloadChanged: (on) {
              // A guest is asked to sign in on the page's SnackBar, which
              // the sheet would cover.
              if (on && !state.authenticated) close();
              viewModel.setAutoDownload(on);
            },
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
  /// a failed or downloaded chapter. The sheet follows the download and
  /// closes once the chapter leaves that state (a retry from the summary,
  /// a delete); while it closes it keeps showing the last matching
  /// download, so it slides away whole.
  Future<void> tapIndicator(BuildContext context, Chapter chapter) async {
    final sheet = await viewModel.tapIndicator(chapter.id);
    if (sheet == null || !context.mounted) return;
    final shownState = sheet == ChapterIndicatorAction.openFailed
        ? DownloadState.failed
        : DownloadState.done;
    var shown = viewModel.state.chapter(chapter.id);
    if (shown == null || shown.state != shownState) return;
    final l10n = AppLocalizations.of(context)!;
    final title = chapterHeading(l10n, chapter);
    await showAppModalBottomSheet<void>(
      context: context,
      glass: true,
      builder: (sheetContext) => StreamBuilder<BookDownloadsState>(
        stream: viewModel.stateStream,
        initialData: viewModel.state,
        builder: (sheetContext, snapshot) {
          final navigator = Navigator.of(sheetContext);
          void close() => navigator.pop();
          if (snapshot.data!.chapter(chapter.id) case final d?
              when d.state == shownState) {
            shown = d;
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Gone already when its own button closed it.
              if (sheetContext.mounted &&
                  (ModalRoute.of(sheetContext)?.isCurrent ?? false)) {
                close();
              }
            });
          }
          final download = shown!;
          return shownState == DownloadState.failed
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
      ),
    );
  }
}
