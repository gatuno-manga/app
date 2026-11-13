import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/utils/bottom_sheet_utils.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import '../templates/reader_sheet_template.dart';
import 'reader_accessibility_section.dart';
import 'reader_preferences_controls.dart';

/// Bottom sheet of the accessibility options of the text reader (Figma
/// `Leitor · Ajustes · Acessibilidade (folha)`): the dyslexia preset, the
/// theme picker and the rows of [ReaderAccessibilitySection]. Changes apply
/// live through the [ReaderPreferencesService] in the tree.
class ReaderAccessibilitySheet extends StatelessWidget {
  const ReaderAccessibilitySheet({super.key});

  /// Opens the sheet. [context] must be under the
  /// [ReaderPreferencesService] provider; the modal route is not, so the
  /// service is re-provided to the sheet.
  static Future<void> show(BuildContext context) {
    final service = context.read<ReaderPreferencesService>();
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (_) => Provider<ReaderPreferencesService>.value(
        value: service,
        child: const ReaderAccessibilitySheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<ReaderPreferencesService>();
    return ReaderSheetTemplate(
      title: AppLocalizations.of(context)!.readingAccessibilityTitle,
      body: ReaderPreferencesControls(
        leading: ReaderAccessibilitySection.leadingFor(service),
        sections: ReaderAccessibilitySection.sectionsFor(service),
      ),
    );
  }
}
