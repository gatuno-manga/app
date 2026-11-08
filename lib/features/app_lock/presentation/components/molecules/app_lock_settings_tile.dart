import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../core/di/injection.dart';
import '../../../domain/use_cases/app_lock_service.dart';

/// Settings entry for the app lock. Renders nothing on devices without a
/// screen lock, so the settings page does not need to know about support.
class AppLockSettingsTile extends StatelessWidget {
  final VoidCallback onTap;

  const AppLockSettingsTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final service = sl<AppLockService>();
    return StreamBuilder<bool>(
      stream: service.stateStream.map((s) => s.isSupported).distinct(),
      initialData: service.state.isSupported,
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return ListTile(
          title: Text(l10n.appLockTitle),
          subtitle: Text(l10n.settingsAppLockDesc),
          leading: const Icon(Icons.fingerprint),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        );
      },
    );
  }
}
