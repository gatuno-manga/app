import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/shared/components/atoms/app_status_badge.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';
import 'package:gatuno/core/theme/semantic_colors.dart';

class ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback? onTap;

  const ChapterTile({super.key, required this.chapter, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final formattedIndex = chapter.index.value == chapter.index.value.toInt()
        ? chapter.index.value.toInt().toString()
        : chapter.index.value.toString();

    return ListTile(
      enabled: onTap != null,
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
                      ? theme.successColor
                      : (chapter.read ? theme.warningColor : theme.mutedColor)),
            size: 20,
          ),
          if (chapter.scrapingStatus != null) ...[
            const SizedBox(width: 8),
            _getStatusBadge(l10n, theme, chapter.scrapingStatus)!,
          ],
        ],
      ),
      onTap: onTap,
    );
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
          color: theme.warningColor,
        );
      case ScrapingStatus.ready:
        return AppStatusBadge(
          label: l10n.scrapingStatusReady,
          color: theme.successColor,
        );
      case ScrapingStatus.error:
        return AppStatusBadge(
          label: l10n.scrapingStatusError,
          color: theme.dangerColor,
        );
    }
  }
}
