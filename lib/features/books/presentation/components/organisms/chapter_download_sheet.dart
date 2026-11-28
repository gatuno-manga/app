import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../core/theme/semantic_colors.dart';
import '../../../../../shared/components/atoms/app_button.dart';
import '../../../../../shared/components/atoms/app_outlined_button.dart';
import '../../../../../shared/components/atoms/app_sheet_handle.dart';
import '../../../../../shared/components/atoms/app_sheet_title.dart';

/// The sheet of a failed or downloaded chapter (Figma `1025:6109` and
/// `1025:6181`): its status, the failure reason, and Retry and Delete.
class ChapterDownloadSheet extends StatelessWidget {
  /// "Capítulo N - Title", as the tile shows it.
  final String title;

  /// The localized failure reason; null for a downloaded chapter.
  final String? failureReason;

  /// The chapter's size, already formatted; shown when it is downloaded.
  final String size;

  /// Shown only for a failed chapter.
  final VoidCallback? onRetry;
  final VoidCallback onDelete;

  const ChapterDownloadSheet.failed({
    super.key,
    required this.title,
    required String reason,
    required VoidCallback this.onRetry,
    required this.onDelete,
  }) : failureReason = reason,
       size = '';

  const ChapterDownloadSheet.done({
    super.key,
    required this.title,
    required this.size,
    required this.onDelete,
  }) : failureReason = null,
       onRetry = null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final failed = failureReason != null;
    final statusColor = theme.legible(
      failed ? theme.colorScheme.error : theme.successColor,
    );
    final onRetry = this.onRetry;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSheetHandle(),
          AppSheetTitle(text: title),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                failed ? Icons.error_outline : Icons.check,
                size: 20,
                color: statusColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  failed
                      ? l10n.booksChapterDownloadFailed
                      : l10n.booksChapterDownloaded(size),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (failed) ...[
            const SizedBox(height: 8),
            Text(failureReason!, style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 16),
          if (onRetry != null) ...[
            AppButton(text: l10n.booksChapterDownloadRetry, onPressed: onRetry),
            const SizedBox(height: 12),
          ],
          AppOutlinedButton(
            text: l10n.booksChapterDownloadDelete,
            tone: AppOutlinedButtonTone.danger,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
