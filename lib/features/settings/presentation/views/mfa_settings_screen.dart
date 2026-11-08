import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/shared/components/atoms/app_button.dart';
import 'package:gatuno/shared/components/atoms/app_text_field.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../authentication/presentation/views/mfa_challenge_screen.dart'
    show mfaErrorText;
import '../view_models/mfa_settings_view_model.dart';

class MfaSettingsPage extends StatefulWidget {
  final MfaSettingsViewModel viewModel;

  const MfaSettingsPage({super.key, required this.viewModel});

  @override
  State<MfaSettingsPage> createState() => _MfaSettingsPageState();
}

class _MfaSettingsPageState extends State<MfaSettingsPage> {
  MfaSettingsViewModel get _vm => widget.viewModel;
  final _codeController = TextEditingController();
  bool _savedConfirmed = false;

  @override
  void initState() {
    super.initState();
    _vm.load();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _enableOrReconfigure(bool enabled) async {
    final l10n = AppLocalizations.of(context)!;
    if (enabled) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.mfaReconfigureTitle),
          content: Text(l10n.mfaReconfigureWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.mfaReconfigureConfirm),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    _codeController.clear();
    await _vm.startSetup();
  }

  Future<void> _disable() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.mfaDisableTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.mfaDisableDescription),
            const SizedBox(height: 16),
            AppTextField(controller: controller, label: l10n.mfaCodeLabel),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.mfaDisableConfirm),
          ),
        ],
      ),
    );
    controller.dispose();
    if (code == null || code.trim().isEmpty) return;
    await _vm.disable(code);
  }

  Future<void> _copy(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<MfaSettingsState>(
      stream: _vm.stateStream,
      initialData: _vm.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        final blockBack = state.phase == MfaPhase.backupCodes;
        return PopScope(
          canPop: !blockBack,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.mfaTitle),
              automaticallyImplyLeading: !blockBack,
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: _body(context, l10n, state),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _error(
    BuildContext context,
    AppLocalizations l10n,
    MfaSettingsState s,
  ) {
    if (s.error == null) return const [];
    return [
      const SizedBox(height: 12),
      Semantics(
        liveRegion: true,
        child: Text(
          mfaErrorText(l10n, s.error!),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    ];
  }

  List<Widget> _body(
    BuildContext context,
    AppLocalizations l10n,
    MfaSettingsState s,
  ) {
    switch (s.phase) {
      case MfaPhase.loading:
        return const [Center(child: CircularProgressIndicator())];
      case MfaPhase.loadFailed:
        return [
          ..._error(context, l10n, s),
          const SizedBox(height: 16),
          AppButton(text: l10n.mfaRetryButton, onPressed: _vm.load),
        ];
      case MfaPhase.status:
        final enabled = s.status?.totpEnabled ?? false;
        return [
          Text(
            enabled ? l10n.mfaStatusEnabled : l10n.mfaStatusDisabled,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (enabled) ...[
            const SizedBox(height: 8),
            Text(l10n.mfaBackupCodesRemaining(s.status!.backupCodesRemaining)),
          ],
          ..._error(context, l10n, s),
          const SizedBox(height: 24),
          AppButton(
            text: enabled ? l10n.mfaReconfigureButton : l10n.mfaEnableButton,
            isLoading: s.isBusy,
            onPressed: () => _enableOrReconfigure(enabled),
          ),
          if (enabled) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: s.isBusy ? null : _disable,
              child: Text(l10n.mfaDisableButton),
            ),
          ],
        ];
      case MfaPhase.setup:
        final setup = s.setup!;
        return [
          Text(l10n.mfaSetupInstructions),
          const SizedBox(height: 16),
          SelectableText(
            setup.secret,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: Text(l10n.mfaCopySecret),
                onPressed: () => _copy(setup.secret, l10n.mfaCopied),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.mfaOpenAuthenticator),
                onPressed: () => launchUrl(
                  Uri.parse(setup.otpauthUri),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppTextField(
            controller: _codeController,
            label: l10n.mfaCodeLabel,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.shield_outlined),
          ),
          ..._error(context, l10n, s),
          const SizedBox(height: 24),
          AppButton(
            text: l10n.mfaConfirmButton,
            isLoading: s.isBusy,
            onPressed: () => _vm.confirmSetup(_codeController.text),
          ),
          TextButton(
            onPressed: _vm.cancelSetup,
            child: Text(l10n.commonCancel),
          ),
        ];
      case MfaPhase.backupCodes:
        final joined = s.backupCodes.join('\n');
        return [
          Text(
            l10n.mfaBackupCodesTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(l10n.mfaBackupCodesWarning),
          const SizedBox(height: 16),
          for (final code in s.backupCodes)
            SelectableText(
              code,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 18),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.share),
                label: Text(l10n.mfaShareCodes),
                onPressed: () =>
                    SharePlus.instance.share(ShareParams(text: joined)),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: Text(l10n.mfaCopyCodes),
                onPressed: () => _copy(joined, l10n.mfaCopied),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _savedConfirmed,
            onChanged: (v) => setState(() => _savedConfirmed = v ?? false),
            title: Text(l10n.mfaSavedConfirm),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: l10n.mfaDoneButton,
            onPressed: _savedConfirmed
                ? () {
                    setState(() => _savedConfirmed = false);
                    _vm.acknowledgeBackupCodes();
                  }
                : null,
          ),
        ];
    }
  }
}
