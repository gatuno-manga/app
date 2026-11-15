import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../core/theme/theme.dart';
import '../../../../../shared/components/molecules/app_labeled_segmented_button.dart';
import '../../../../downloads/domain/entities/download_network.dart';
import '../../../../downloads/domain/repositories/download_network_rules.dart';
import '../../../../reading/domain/entities/reading_enums.dart';
import '../molecules/settings_notice.dart';

/// The network each book type may download on, one choice per type, with
/// the note on what a stricter rule does to running downloads.
class DownloadNetworkRulesForm extends StatelessWidget {
  final Map<BookType, DownloadNetwork> rules;

  /// Null while the rules load: every choice is disabled.
  final void Function(BookType type, DownloadNetwork network)? onChanged;

  const DownloadNetworkRulesForm({
    super.key,
    required this.rules,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final onChanged = this.onChanged;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.settingsDownloadNetwork,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.textSecondary,
            ),
          ),
        ),
        for (final type in BookType.values)
          AppLabeledSegmentedButton<DownloadNetwork>(
            label: _label(l10n, type),
            description: type == BookType.other
                ? l10n.settingsDownloadOtherHint
                : null,
            expanded: true,
            segments: [
              ButtonSegment(
                value: DownloadNetwork.unmetered,
                label: Text(l10n.settingsDownloadWifiOnly),
              ),
              ButtonSegment(
                value: DownloadNetwork.any,
                label: Text(l10n.settingsDownloadWifiAndMobile),
              ),
            ],
            value: rules[type] ?? DownloadNetworkRules.defaultRule,
            onChanged: onChanged == null
                ? null
                : (network) => onChanged(type, network),
          ),
        SettingsNotice(text: l10n.settingsDownloadNetworkNotice),
      ],
    );
  }

  static String _label(AppLocalizations l10n, BookType type) => switch (type) {
    BookType.manga => l10n.bookTypeManga,
    BookType.manhwa => l10n.bookTypeManhwa,
    BookType.manhua => l10n.bookTypeManhua,
    BookType.book => l10n.bookTypeBook,
    BookType.other => l10n.bookTypeOther,
  };
}
