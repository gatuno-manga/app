import 'package:flutter/material.dart';

import '../../../core/theme/semantic_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../atoms/app_button.dart';

/// Shown in place of content that is not saved on the device while the app
/// is offline (an `OfflineException` from a repository).
class AppOfflineEmptyView extends StatelessWidget {
  final VoidCallback onRetry;

  const AppOfflineEmptyView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: theme.mutedColor,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                l10n.offlineEmptyTitle,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.offlineEmptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.mutedColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(text: l10n.errorRetry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
