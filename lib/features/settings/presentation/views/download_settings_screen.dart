import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../shared/components/organisms/app_top_bar.dart';
import '../../../../shared/components/templates/app_top_bar_scaffold.dart';
import '../../../downloads/domain/entities/download_network.dart';
import '../../../reading/domain/entities/reading_enums.dart';
import '../components/organisms/download_network_rules_form.dart';
import '../view_models/download_settings_view_model.dart';

/// /settings/download: which network each book type downloads on.
class DownloadSettingsPage extends StatelessWidget {
  const DownloadSettingsPage({super.key});

  Future<void> _setRule(
    BuildContext context,
    DownloadSettingsViewModel viewModel,
    BookType type,
    DownloadNetwork network,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = AppLocalizations.of(context)!.settingsDownloadSaveError;
    if (await viewModel.setRule(type, network)) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<DownloadSettingsViewModel>();

    return StreamBuilder<DownloadSettingsState>(
      stream: viewModel.stateStream,
      initialData: viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        return AppTopBarScaffold(
          topBar: AppTopBar(title: l10n.settingsDownloadTitle, showBack: true),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverToBoxAdapter(
                child: DownloadNetworkRulesForm(
                  rules: state.rules,
                  onChanged: state.isLoaded
                      ? (type, network) =>
                            _setRule(context, viewModel, type, network)
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
