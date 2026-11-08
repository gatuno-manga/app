import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/components/atoms/app_sheet_handle.dart';
import '../../../../../shared/utils/bottom_sheet_utils.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import '../../preferences/reader_preferences_builder.dart';
import '../../theme/reader_theme_scope.dart';
import '../molecules/reader_theme_picker.dart';

/// Builds a reader's own rows of the settings sheet for [preferences].
typedef ReaderSettingsSections =
    List<Widget> Function(ReaderPreferences preferences);

/// Bottom sheet of the reader settings (Figma `Leitor · Ajustes`): the
/// shared theme picker followed by each reader's own [sections]. Changes
/// apply live through [service].
class ReaderSettingsSheet extends StatelessWidget {
  final ReaderPreferencesService service;
  final ReaderSettingsSections sections;

  const ReaderSettingsSheet({
    super.key,
    required this.service,
    required this.sections,
  });

  /// Material 3 modal sheets cap at this width on large screens.
  static const double _maxWidth = 640;

  static Future<void> show(
    BuildContext context, {
    required ReaderPreferencesService service,
    required ReaderSettingsSections sections,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (_) => Provider<ReaderPreferencesService>.value(
        value: service,
        child: ReaderSettingsSheet(service: service, sections: sections),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.85;
    final bottomInset = media.viewPadding.bottom;
    return ReaderPreferencesBuilder(
      builder: (context, preferences) => ReaderThemeScope(
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
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _maxWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  l10n.readingSettingsTitle,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ReaderThemePicker(
                                selected: preferences.theme,
                                onSelected: (theme) => service.update(
                                  (current) => current.copyWith(theme: theme),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...sections(preferences),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
