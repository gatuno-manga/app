import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class AppErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onGoBack;

  const AppErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.errorRetry)),
            const SizedBox(height: 8),
            TextButton(onPressed: onGoBack, child: Text(l10n.errorBack)),
          ],
        ),
      ),
    );
  }
}
