import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/components/atoms/app_icon_button.dart';

/// The "Ajustes" action of the reader bars.
class ReaderSettingsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ReaderSettingsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: Icons.settings_outlined,
      color: Theme.of(context).colorScheme.onSurface,
      tooltip: AppLocalizations.of(context)!.readingSettingsAction,
      onPressed: onPressed,
    );
  }
}
