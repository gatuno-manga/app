import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../core/theme/semantic_colors.dart';

/// Says the books on screen come from this device's offline cache and what
/// that limits. Shown above a cache list and in the filter sheet offline.
///
/// The filters sentence is a separate string: it describes books whose tags,
/// authors and classification aren't known locally, which goes away once the
/// API sends them in list items (#133).
class BooksOfflineNotice extends StatelessWidget {
  const BooksOfflineNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final message =
        '${l10n.booksOfflineNotice} ${l10n.booksOfflineFiltersNotice}';

    return Semantics(
      container: true,
      label: message,
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        color: theme.colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: theme.legible(theme.infoColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
