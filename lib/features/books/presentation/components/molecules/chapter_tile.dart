import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/shared/components/atoms/app_status_badge.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/semantic_colors.dart';
import 'package:gatuno/core/theme/theme.dart';

import '../../models/download_display.dart';
import '../atoms/chapter_download_indicator.dart';

class ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// The download indicator's state; null hides it.
  final ChapterDownloadStatus? downloadStatus;
  final double downloadProgress;

  /// Null makes the indicator display-only.
  final VoidCallback? onDownloadTap;

  /// Whether the tile is picked; null outside selection mode.
  final bool? selected;

  const ChapterTile({
    super.key,
    required this.chapter,
    this.onTap,
    this.onLongPress,
    this.downloadStatus,
    this.downloadProgress = 0,
    this.onDownloadTap,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final palette = theme.extension<GatunoColors>()?.palette ?? lightPalette;
    final selected = this.selected;
    final downloadStatus = this.downloadStatus;

    final formattedIndex = chapter.index.value == chapter.index.value.toInt()
        ? chapter.index.value.toInt().toString()
        : chapter.index.value.toString();

    return Semantics(
      selected: selected,
      child: ListTile(
        enabled: onTap != null,
        selected: selected ?? false,
        selectedColor: theme.colorScheme.onSurface,
        selectedTileColor: palette.primary10,
        shape: selected == true
            ? RoundedRectangleBorder(
                side: BorderSide(color: theme.colorScheme.primary),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              )
            : null,
        leading: selected == null
            ? null
            : Icon(
                selected ? Icons.check : Icons.check_box_outline_blank,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.legible(theme.mutedColor),
                semanticLabel: selected
                    ? l10n.booksSelectionSelected
                    : l10n.booksSelectionNotSelected,
              ),
        title: Text(l10n.booksChapterLabel(formattedIndex)),
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
            if (downloadStatus != null)
              ChapterDownloadIndicator(
                status: downloadStatus,
                progress: downloadProgress,
                semanticLabel: _downloadLabel(l10n, downloadStatus),
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
      ),
    );
  }

  String _downloadLabel(AppLocalizations l10n, ChapterDownloadStatus status) =>
      switch (status) {
        ChapterDownloadStatus.none => l10n.booksDownloadStatusNone,
        ChapterDownloadStatus.queued => l10n.booksDownloadStatusQueued,
        ChapterDownloadStatus.running => l10n.booksDownloadStatusRunning(
          (downloadProgress * 100).round(),
        ),
        ChapterDownloadStatus.waitingForNetwork =>
          l10n.booksDownloadStatusWaitingWifi,
        ChapterDownloadStatus.waitingForConnection =>
          l10n.booksDownloadStatusWaitingConnection,
        ChapterDownloadStatus.paused => l10n.booksDownloadStatusPaused,
        ChapterDownloadStatus.failed => l10n.booksDownloadStatusFailed,
        ChapterDownloadStatus.done => l10n.booksDownloadStatusDone,
      };

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
