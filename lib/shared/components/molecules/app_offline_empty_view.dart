import 'package:flutter/material.dart';

import '../../../core/theme/semantic_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../atoms/app_button.dart';

/// Shown in place of content that is not saved on the device while the app
/// is offline (an `OfflineException` from a repository).
///
/// The message promises the content loads once the server is back, so the
/// screen that shows this view must reload on `ConnectivityService
/// .onReconnected`.
class AppOfflineEmptyView extends StatelessWidget {
  /// Runs when the user taps retry. While offline, repositories skip the
  /// network, so a plain reload only misses the cache again: call
  /// `ConnectivityService.checkNow()` first, then reload.
  final VoidCallback onRetry;

  /// Shows progress on the retry button while [onRetry]'s work runs.
  final bool isRetrying;

  /// The widest the content column gets, so tablets keep a readable measure.
  static const double maxContentWidth = 480;

  const AppOfflineEmptyView({
    super.key,
    required this.onRetry,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          // Keeps the message to a readable line length on tablets.
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
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
                // Essential copy: the default text color, since
                // `color/text-secondary` misses AA in some themes.
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: l10n.errorRetry,
                onPressed: onRetry,
                isLoading: isRetrying,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
