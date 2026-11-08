import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/components/atoms/app_switch.dart';
import '../../../settings/presentation/components/molecules/settings_section_header.dart';
import '../../domain/device_authenticator.dart';
import '../../domain/use_cases/app_lock_service.dart';
import '../../domain/value_objects/app_lock_grace.dart';
import '../app_lock_texts.dart';

class AppLockSettingsPage extends StatefulWidget {
  /// Test seam; production resolves the service from the locator.
  final AppLockService? service;

  const AppLockSettingsPage({super.key, this.service});

  @override
  State<AppLockSettingsPage> createState() => _AppLockSettingsPageState();
}

class _AppLockSettingsPageState extends State<AppLockSettingsPage> {
  late final AppLockService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? sl<AppLockService>();
  }

  DeviceAuthMessages _confirmMessages(
    AppLocalizations l10n, {
    required bool allowDeviceCredential,
  }) => DeviceAuthMessages(
    reason: l10n.appLockConfirmReason,
    title: l10n.appLockTitle,
    hint: allowDeviceCredential
        ? l10n.appLockPromptHintWithCredential
        : l10n.appLockPromptHint,
    cancel: l10n.commonCancel,
  );

  Future<void> _toggleLock(bool enabled) => _confirm(
    (l10n) => _service.setEnabled(
      enabled,
      messages: _confirmMessages(
        l10n,
        allowDeviceCredential: _service.state.deviceCredentialAllowed,
      ),
    ),
  );

  // Turning the fallback off proves a biometric works first, so the hint
  // must not mention the PIN.
  Future<void> _toggleFallback(bool allowed) => _confirm(
    (l10n) => _service.setDeviceCredentialAllowed(
      allowed,
      messages: _confirmMessages(l10n, allowDeviceCredential: allowed),
    ),
  );

  /// Runs a change guarded by the OS prompt and explains any refusal.
  Future<void> _confirm(
    Future<DeviceAuthOutcome> Function(AppLocalizations l10n) change,
  ) async {
    if (_service.state.isAuthenticating) return;
    final l10n = AppLocalizations.of(context)!;
    String? message;
    try {
      final outcome = await change(l10n);
      // A dismissed prompt simply leaves the switch where it was.
      if (outcome == DeviceAuthOutcome.cancelled) return;
      message = appLockOutcomeText(l10n, outcome);
    } catch (_) {
      message = l10n.appLockErrorSave;
    }
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<AppLockState>(
      stream: _service.stateStream,
      initialData: _service.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.appLockTitle)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // A lock enabled before the screen lock was removed must
                // still be switchable off.
                if (!state.isSupported) Text(l10n.appLockUnsupportedDesc),
                if (state.isSupported || state.enabled)
                  ..._controls(l10n, state),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _controls(AppLocalizations l10n, AppLockState state) {
    return [
      AppSwitch(
        title: l10n.appLockSwitchTitle,
        subtitle: l10n.appLockSwitchDesc,
        value: state.enabled,
        onChanged: _toggleLock,
      ),
      if (state.enabled) ...[
        const Divider(height: 32),
        SettingsSectionHeader(title: l10n.appLockGraceTitle),
        RadioGroup<AppLockGrace>(
          groupValue: state.grace,
          onChanged: (grace) {
            if (grace != null) _service.setGrace(grace);
          },
          child: Column(
            children: [
              for (final grace in AppLockGrace.values)
                RadioListTile<AppLockGrace>(
                  value: grace,
                  title: Text(appLockGraceLabel(l10n, grace)),
                ),
            ],
          ),
        ),
        const Divider(height: 32),
        AppSwitch(
          title: l10n.appLockFallbackTitle,
          subtitle: state.deviceCredentialAllowed
              ? l10n.appLockFallbackOnDesc
              : l10n.appLockFallbackOffDesc,
          value: state.deviceCredentialAllowed,
          onChanged: _toggleFallback,
        ),
      ],
    ];
  }
}
