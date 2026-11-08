import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/components/atoms/app_switch.dart';
import '../../../settings/presentation/components/molecules/settings_section_header.dart';
import '../../domain/use_cases/app_lock_service.dart';
import '../../domain/value_objects/app_lock_grace.dart';
import '../app_lock_texts.dart';
import '../view_models/app_lock_settings_view_model.dart';

class AppLockSettingsPage extends StatefulWidget {
  /// Test seam; production creates (and owns) its own view model.
  final AppLockSettingsViewModel? viewModel;

  const AppLockSettingsPage({super.key, this.viewModel});

  @override
  State<AppLockSettingsPage> createState() => _AppLockSettingsPageState();
}

class _AppLockSettingsPageState extends State<AppLockSettingsPage> {
  late final AppLockSettingsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel ?? AppLockSettingsViewModel(sl<AppLockService>());
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _toggleLock(bool enabled) async {
    if (_vm.state.isAuthenticating) return;
    final l10n = AppLocalizations.of(context)!;
    final outcome = await _vm.setEnabled(
      enabled,
      reason: l10n.appLockPromptReason,
    );
    final message = appLockOutcomeText(l10n, outcome);
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<AppLockState>(
      stream: _vm.stateStream,
      initialData: _vm.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.appLockTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: state.isSupported
                ? _controls(l10n, state)
                : [Text(l10n.appLockUnsupportedDesc)],
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
            if (grace != null) _vm.setGrace(grace);
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
          onChanged: _vm.setDeviceCredentialAllowed,
        ),
      ],
    ];
  }
}
