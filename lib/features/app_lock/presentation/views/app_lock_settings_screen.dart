import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/components/atoms/app_switch.dart';
// Shared on purpose with the settings feature: this page is a settings
// sub-page and must look like its siblings (MFA, certificates).
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
  }) => appLockPromptMessages(
    l10n,
    reason: l10n.appLockConfirmReason,
    title: l10n.appLockTitle,
    allowDeviceCredential: allowDeviceCredential,
  );

  Future<void> _toggleLock(bool enabled) => _apply(
    (l10n) => _service.setEnabled(
      enabled,
      messages: _confirmMessages(
        l10n,
        allowDeviceCredential: _service.state.deviceCredentialAllowed,
      ),
    ),
    // With the fallback off, a missing biometric has a way out right below.
    explain: (l10n, outcome) => switch (outcome) {
      DeviceAuthOutcome.noBiometrics ||
      DeviceAuthOutcome.noBiometricHardware => l10n.appLockEnableNeedsBiometric,
      _ => appLockOutcomeText(l10n, outcome),
    },
  );

  // Turning the fallback off proves a biometric works first, so the hint
  // must not mention the PIN, and a refusal is explained in those terms.
  Future<void> _toggleFallback(bool allowed) => _apply(
    (l10n) async {
      if (allowed) {
        await _service.allowDeviceCredential();
        return null;
      }
      return _service.requireBiometrics(
        messages: _confirmMessages(l10n, allowDeviceCredential: false),
      );
    },
    explain: (l10n, outcome) => switch (outcome) {
      DeviceAuthOutcome.noBiometrics => l10n.appLockFallbackNeedsBiometric,
      DeviceAuthOutcome.noBiometricHardware => l10n.appLockFallbackNoSensor,
      _ => appLockOutcomeText(l10n, outcome),
    },
  );

  Future<void> _chooseGrace(AppLockGrace grace) => _apply((_) async {
    await _service.setGrace(grace);
    return null;
  });

  /// Runs a preference change (prompt-guarded or not) and explains a
  /// refused prompt or a failed save in a SnackBar.
  Future<void> _apply(
    Future<DeviceAuthOutcome?> Function(AppLocalizations l10n) change, {
    String? Function(AppLocalizations l10n, DeviceAuthOutcome outcome)? explain,
  }) async {
    if (_service.state.isAuthenticating) return;
    final l10n = AppLocalizations.of(context)!;
    String? message;
    try {
      final outcome = await change(l10n);
      // A dismissed prompt simply leaves the switch where it was.
      if (outcome == null || outcome == DeviceAuthOutcome.cancelled) return;
      message = (explain ?? appLockOutcomeText)(l10n, outcome);
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
                if (!state.isSupported) ...[
                  // Support is re-probed on every resume, so this can swap
                  // while the page is open.
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      state.enabled
                          ? l10n.appLockUnsupportedEnabledDesc
                          : l10n.appLockUnsupportedDesc,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (state.isManageable) ..._controls(l10n, state),
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
        subtitle: state.deviceCredentialAllowed
            ? l10n.appLockSwitchDesc
            : l10n.appLockSwitchDescBiometricOnly,
        value: state.enabled,
        onChanged: _toggleLock,
      ),
      // The fallback stays reachable while the lock is off: a biometric-only
      // refusal when enabling must have a way out.
      AppSwitch(
        title: l10n.appLockFallbackTitle,
        subtitle: state.deviceCredentialAllowed
            ? l10n.appLockFallbackOnDesc
            : l10n.appLockFallbackOffDesc,
        value: state.deviceCredentialAllowed,
        onChanged: _toggleFallback,
      ),
      if (state.enabled) ...[
        const Divider(height: 32),
        SettingsSectionHeader(title: l10n.appLockGraceTitle),
        RadioGroup<AppLockGrace>(
          groupValue: state.grace,
          onChanged: (grace) {
            if (grace != null) _chooseGrace(grace);
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
      ],
    ];
  }
}
