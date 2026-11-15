import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/shared/components/atoms/app_status_badge.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/semantic_colors.dart';
import 'package:gatuno/core/theme/theme.dart';

import '../../models/chapter_label.dart';
import '../../models/download_display.dart';
import '../atoms/chapter_download_indicator.dart';

class ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// The download indicator; null hides it.
  final ChapterDownloadDisplay? download;

  /// Null makes the indicator display-only.
  final VoidCallback? onDownloadTap;

  /// Whether the tile is picked; null outside selection mode.
  final bool? selected;

  const ChapterTile({
    super.key,
    required this.chapter,
    this.onTap,
    this.onLongPress,
    this.download,
    this.onDownloadTap,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final palette = theme.extension<GatunoColors>()?.palette ?? lightPalette;
    final selected = this.selected;
    final download = this.download;

    return ListTile(
      enabled: onTap != null,
      selected: selected ?? false,
      selectedColor: theme.colorScheme.onSurface,
      selectedTileColor: palette.primary10,
      // Every tile carries the border, transparent unless selected: the
      // border adds to the tile's height, and a selected tile must not
      // push the list down.
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected == true
              ? theme.colorScheme.primary
              : Colors.transparent,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      // The tile's `selected` flag carries the state for screen readers.
      leading: selected == null
          ? null
          : ExcludeSemantics(
              child: Icon(
                selected ? Icons.check : Icons.check_box_outline_blank,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.legible(theme.mutedColor),
              ),
            ),
      title: Text(chapterLabel(l10n, chapter)),
      subtitle: chapter.title != null ? Text(chapter.title!.value) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chapter.completed ? Icons.visibility : Icons.visibility_off,
            color: onTap == null
                ? theme.disabledColor
                : (chapter.completed
                      ? theme.legible(theme.successColor)
                      : (chapter.read
                            ? theme.legible(theme.warningColor)
                            : theme.mutedColor)),
            size: 20,
          ),
          if (download != null)
            ChapterDownloadIndicator(
              status: download.status,
              progress: download.progress,
              semanticLabel: _downloadLabel(l10n, download),
              onTap: onDownloadTap,
            ),
          if (chapter.scrapingStatus != null) ...[
            const SizedBox(width: 8),
            _getStatusBadge(l10n, theme, chapter.scrapingStatus)!,
          ],
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  /// The indicator's state, plus what a tap does when it is tappable.
  String _downloadLabel(
    AppLocalizations l10n,
    ChapterDownloadDisplay download,
  ) {
    final (status, hint) = switch (download.status) {
      ChapterDownloadStatus.none => (
        l10n.booksDownloadStatusNone,
        l10n.booksDownloadHintDownload,
      ),
      ChapterDownloadStatus.queued => (
        l10n.booksDownloadStatusQueued,
        l10n.booksDownloadHintPause,
      ),
      ChapterDownloadStatus.running => (
        l10n.booksDownloadStatusRunning((download.progress * 100).round()),
        l10n.booksDownloadHintPause,
      ),
      ChapterDownloadStatus.waitingForNetwork => (
        l10n.booksDownloadStatusWaitingWifi,
        l10n.booksDownloadHintPause,
      ),
      ChapterDownloadStatus.waitingForConnection => (
        l10n.booksDownloadStatusWaitingConnection,
        l10n.booksDownloadHintPause,
      ),
      ChapterDownloadStatus.paused => (
        l10n.booksDownloadStatusPaused,
        l10n.booksDownloadHintResume,
      ),
      ChapterDownloadStatus.failed => (
        l10n.booksDownloadStatusFailed,
        l10n.booksDownloadHintOptions,
      ),
      ChapterDownloadStatus.done => (
        l10n.booksDownloadStatusDone,
        l10n.booksDownloadHintOptions,
      ),
    };
    return onDownloadTap == null ? status : '$status. $hint';
  }

  Widget? _getStatusBadge(
    AppLocalizations l10n,
    ThemeData theme,
    ScrapingStatus? status,
  ) {
    if (status == null) return null;
    switch (status) {
      case ScrapingStatus.process:
        return AppStatusBadge(
          label: l10n.scrapingStatusProcess,
          color: theme.infoColor,
          textColor: theme.legible(theme.infoColor),
        );
      case ScrapingStatus.ready:
        return AppStatusBadge(
          label: l10n.scrapingStatusReady,
          color: theme.successColor,
          textColor: theme.legible(theme.successColor),
        );
      case ScrapingStatus.error:
        return AppStatusBadge(
          label: l10n.scrapingStatusError,
          color: theme.colorScheme.error,
          textColor: theme.legible(theme.colorScheme.error),
        );
    }
  }
}
