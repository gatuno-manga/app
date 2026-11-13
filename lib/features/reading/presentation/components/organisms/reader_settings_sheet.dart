import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/utils/bottom_sheet_utils.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import '../templates/reader_sheet_template.dart';
import 'reader_preferences_controls.dart';

/// Bottom sheet of the reader settings (Figma `Leitor · Ajustes`): the
/// shared theme picker followed by each reader's own [sections]. Changes
/// apply live through the [ReaderPreferencesService] in the tree.
class ReaderSettingsSheet extends StatelessWidget {
  final ReaderSettingsSections sections;

  const ReaderSettingsSheet({super.key, required this.sections});

  /// Opens the sheet. [context] must be under the reader's
  /// [ReaderPreferencesService] provider; the modal route is not, so the
  /// service is re-provided to the sheet.
  static Future<void> show(
    BuildContext context, {
    required ReaderSettingsSections sections,
  }) {
    final service = context.read<ReaderPreferencesService>();
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (_) => Provider<ReaderPreferencesService>.value(
        value: service,
        child: ReaderSettingsSheet(sections: sections),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReaderSheetTemplate(
      title: AppLocalizations.of(context)!.readingSettingsTitle,
      body: ReaderPreferencesControls(sections: sections),
    );
  }
}
