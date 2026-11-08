import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/components/atoms/app_sheet_handle.dart';
import '../../../../../shared/utils/bottom_sheet_utils.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import '../../theme/reader_theme_scope.dart';
import '../molecules/reader_theme_picker.dart';

/// Bottom sheet of the reader settings (Figma `Leitor · Ajustes`): the
/// shared theme picker followed by each reader's own [sections]. Changes
/// apply live through [service].
class ReaderSettingsSheet extends StatelessWidget {
  final ReaderPreferencesService service;
  final List<Widget> Function(ReaderPreferences preferences) sections;

  const ReaderSettingsSheet({
    super.key,
    required this.service,
    required this.sections,
  });

  static Future<void> show(
    BuildContext context, {
    required ReaderPreferencesService service,
    required List<Widget> Function(ReaderPreferences preferences) sections,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (_) => ReaderSettingsSheet(service: service, sections: sections),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    return StreamBuilder<ReaderPreferences>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) {
        final preferences = snapshot.data!;
        return ReaderThemeScope(
          theme: preferences.theme,
          child: Builder(
            builder: (context) => ColoredBox(
              // Painted here, not by the route, so it follows live changes.
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppSheetHandle(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(
                                l10n.readingSettingsTitle,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ReaderThemePicker(
                              selected: preferences.theme,
                              onSelected: (theme) => service.update(
                                preferences.copyWith(theme: theme),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...sections(preferences),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
