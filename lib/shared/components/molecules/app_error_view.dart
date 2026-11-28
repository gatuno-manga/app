import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../atoms/app_button.dart';
import '../atoms/app_text_button.dart';

/// Full-screen error with a retry action and, when [onGoBack] is given, a
/// back action (`App/Molecule/Vista de erro`).
class AppErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  /// Null hides the back button, for screens that already have a back bar.
  final VoidCallback? onGoBack;

  const AppErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onGoBack = this.onGoBack;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AppButton(text: l10n.errorRetry, onPressed: onRetry),
            if (onGoBack != null) ...[
              const SizedBox(height: 16),
              AppTextButton(text: l10n.errorBack, onPressed: onGoBack),
            ],
          ],
        ),
      ),
    );
  }
}
