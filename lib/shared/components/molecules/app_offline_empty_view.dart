import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../atoms/app_button.dart';
import 'app_empty_view.dart';

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
  static const double maxContentWidth = AppEmptyView.maxContentWidth;

  const AppOfflineEmptyView({
    super.key,
    required this.onRetry,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppEmptyView(
      icon: Icons.cloud_off_outlined,
      title: l10n.offlineEmptyTitle,
      message: l10n.offlineEmptyMessage,
      action: AppButton(
        text: l10n.errorRetry,
        onPressed: onRetry,
        isLoading: isRetrying,
      ),
    );
  }
}
