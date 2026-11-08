import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../core/di/injection.dart';
import '../../../domain/use_cases/app_lock_service.dart';

/// Settings entry for the app lock. Renders nothing on devices without a
/// screen lock, so the settings page does not need to know about support.
class AppLockSettingsTile extends StatefulWidget {
  final VoidCallback onTap;

  const AppLockSettingsTile({super.key, required this.onTap});

  @override
  State<AppLockSettingsTile> createState() => _AppLockSettingsTileState();
}

class _AppLockSettingsTileState extends State<AppLockSettingsTile> {
  late final AppLockService _service;
  late final Stream<bool> _supported;

  @override
  void initState() {
    super.initState();
    _service = sl<AppLockService>();
    _supported = _service.stateStream.map((s) => s.isSupported).distinct();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<bool>(
      stream: _supported,
      initialData: _service.state.isSupported,
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return ListTile(
          title: Text(l10n.appLockTitle),
          subtitle: Text(l10n.settingsAppLockDesc),
          leading: const Icon(Icons.lock_outline),
          trailing: const Icon(Icons.chevron_right),
          onTap: widget.onTap,
        );
      },
    );
  }
}
