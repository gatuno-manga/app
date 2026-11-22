import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../shared/components/molecules/app_empty_view.dart';

/// Placeholder for the Biblioteca tab until #130 builds the real screen. The
/// same for guests and signed-in users.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.libraryTitle)),
      body: AppEmptyView(
        icon: Icons.bookmark_border,
        title: l10n.libraryComingSoonTitle,
        message: l10n.libraryComingSoonBody,
      ),
    );
  }
}
