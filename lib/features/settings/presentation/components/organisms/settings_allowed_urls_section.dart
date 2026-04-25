import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../molecules/settings_section_header.dart';
import '../molecules/settings_allowed_url_item.dart';
import '../molecules/settings_add_url_field.dart';

class SettingsAllowedUrlsSection extends StatefulWidget {
  final List<String> urls;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  const SettingsAllowedUrlsSection({
    super.key,
    required this.urls,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<SettingsAllowedUrlsSection> createState() =>
      _SettingsAllowedUrlsSectionState();
}

class _SettingsAllowedUrlsSectionState
    extends State<SettingsAllowedUrlsSection> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      widget.onAdd(url);
      _urlController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(title: l10n.settingsAllowedUrlsSection),
        const SizedBox(height: 16),
        SettingsAddUrlField(
          controller: _urlController,
          label: l10n.settingsAddUrlLabel,
          hint: l10n.settingsAddUrlHint,
          onAdd: _handleAdd,
        ),
        const SizedBox(height: 8),
        if (widget.urls.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No URLs allowed yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.urls.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final url = widget.urls[index];
              return SettingsAllowedUrlItem(
                url: url,
                onRemove: () => widget.onRemove(url),
              );
            },
          ),
      ],
    );
  }
}
