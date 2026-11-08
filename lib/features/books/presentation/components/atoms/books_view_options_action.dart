import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../shared/components/atoms/app_icon_button.dart';

class BooksViewOptionsAction extends StatelessWidget {
  final VoidCallback onPressed;

  const BooksViewOptionsAction({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppIconButton(
      icon: Icons.tune,
      tooltip: l10n.booksViewOptions,
      onPressed: onPressed,
    );
  }
}
