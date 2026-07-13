import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/core/logging/logger.dart';
import '../view_models/settings_view_model.dart';
import '../../../../shared/components/atoms/app_switch.dart';
import '../components/molecules/settings_profile_card.dart';
import '../components/molecules/settings_section_header.dart';
import '../components/organisms/settings_api_form.dart';
import '../components/templates/settings_template.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _handleApiSave(
    BuildContext context,
    SettingsViewModel viewModel,
    String url,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await viewModel.updateApiUrl(url);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l10n.settingsApiUrlSuccess : l10n.settingsApiUrlError,
        ),
      ),
    );
  }

  Future<void> _handleExportLogs(BuildContext context) async {
    final path = await AppLogger.getLogFilePath();
    await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
  }

  Future<void> _handleOpenLogs(BuildContext context) async {
    final path = await AppLogger.getLogFilePath();
    await OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<SettingsViewModel>();

    return StreamBuilder<SettingsState>(
      stream: viewModel.stateStream,
      initialData: viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        
        return SettingsTemplate(
          appBarTitle: Text(l10n.settingsTitle),
          profileCard: SettingsProfileCard(
            name: state.isAuthenticated
                ? state.user.displayName
                : l10n.commonGuest,
            email: state.isAuthenticated ? state.user.email.value : null,
            onTap: () {
              if (state.isAuthenticated) {
                context.push('/settings/profile');
              } else {
                context.push('/auth/signin');
              }
            },
          ),
          generalSectionHeader: SettingsSectionHeader(
            title: l10n.settingsGeneralSection,
          ),
          sensitiveContentToggle: AppSwitch(
            title: l10n.userMeSensitiveContent,
            subtitle: l10n.userMeSensitiveContentDesc,
            value: state.sensitiveContentEnabled,
            onChanged: (value) => viewModel.setSensitiveContentEnabled(value),
          ),
          apiSectionHeader: SettingsSectionHeader(title: l10n.settingsApiSection),
          apiForm: SettingsApiForm(
            initialUrl: state.apiUrl ?? '',
            isLoading: state.isLoading,
            onSave: (url) => _handleApiSave(context, viewModel, url),
          ),
          certificatesSectionHeader: SettingsSectionHeader(
            title: l10n.settingsCertificatesSection,
          ),
          certificatesTile: ListTile(
            title: Text(l10n.settingsCertificatesSection),
            subtitle: Text(l10n.settingsCertificatesDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/certificates'),
          ),
          diagnosticsSectionHeader: SettingsSectionHeader(
            title: l10n.settingsDiagnosticsSection,
          ),
          exportLogsTile: ListTile(
            title: Text(l10n.settingsExportLogs),
            subtitle: Text(l10n.settingsExportLogsDesc),
            leading: const Icon(Icons.share),
            onTap: () => _handleExportLogs(context),
          ),
          openLogsTile: ListTile(
            title: Text(l10n.settingsOpenLogs),
            subtitle: Text(l10n.settingsOpenLogsDesc),
            leading: const Icon(Icons.file_open),
            onTap: () => _handleOpenLogs(context),
          ),
        );
      },
    );
  }
}
