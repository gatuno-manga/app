import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../shared/components/atoms/app_button.dart';
import '../../../../shared/icons/icons.dart';
import '../../domain/device_authenticator.dart';
import '../app_lock_texts.dart';

/// Full-screen cover shown while the app is locked.
class AppLockScreen extends StatelessWidget {
  final bool isAuthenticating;
  final DeviceAuthOutcome? lastOutcome;
  final VoidCallback onUnlock;

  const AppLockScreen({
    super.key,
    required this.isAuthenticating,
    required this.lastOutcome,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final error = appLockOutcomeText(l10n, lastOutcome);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(child: AppIcons.logo(height: 96)),
                const SizedBox(height: 24),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.appLockLockedTitle,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.appLockLockedDesc,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      error,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                AppButton(
                  text: error == null
                      ? l10n.appLockUnlockButton
                      : l10n.appLockRetryButton,
                  isLoading: isAuthenticating,
                  onPressed: onUnlock,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
