import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../shared/components/atoms/app_sheet_handle.dart';
import '../../../../../shared/components/atoms/app_sheet_title.dart';
import '../../../../../shared/components/molecules/app_switch_row.dart';
import '../molecules/book_option_row.dart';

/// The book's ⋮ sheet, "Opções do livro" (Figma `1025:5929`), with its
/// Downloads group. Future book options join it as new groups.
class BookOptionsSheet extends StatelessWidget {
  /// Download all pages the chapter list from the server: off while it is
  /// unreachable.
  final bool canDownloadAll;

  /// Chapter downloads of the book in any state; Delete all is hidden at 0.
  final int downloadCount;

  /// Their size, already formatted.
  final String downloadSize;
  final bool autoDownloadOn;
  final VoidCallback onDownloadAll;
  final VoidCallback onDeleteAll;
  final ValueChanged<bool> onAutoDownloadChanged;

  const BookOptionsSheet({
    super.key,
    required this.canDownloadAll,
    required this.downloadCount,
    required this.downloadSize,
    required this.autoDownloadOn,
    required this.onDownloadAll,
    required this.onDeleteAll,
    required this.onAutoDownloadChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final palette = theme.extension<GatunoColors>()?.palette ?? lightPalette;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSheetHandle(),
          AppSheetTitle(text: l10n.booksOptionsTitle),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              l10n.booksOptionsDownloads,
              style: theme.textTheme.labelMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          BookOptionRow(
            icon: Icons.download,
            title: l10n.booksDownloadAll,
            subtitle: canDownloadAll
                ? l10n.booksDownloadAllSubtitle
                : l10n.booksDownloadAllOffline,
            onTap: canDownloadAll ? onDownloadAll : null,
          ),
          if (downloadCount > 0) ...[
            const Divider(height: 1),
            BookOptionRow(
              icon: Icons.delete_outline,
              title: l10n.booksDeleteAllDownloads,
              subtitle: l10n.booksDeleteAllDownloadsSubtitle(
                downloadCount,
                downloadSize,
              ),
              onTap: onDeleteAll,
              danger: true,
            ),
          ],
          const Divider(height: 1),
          AppSwitchRow(
            icon: Icons.sync,
            title: l10n.booksAutoDownload,
            subtitle: l10n.booksAutoDownloadSubtitle,
            value: autoDownloadOn,
            onChanged: onAutoDownloadChanged,
          ),
        ],
      ),
    );
  }
}
