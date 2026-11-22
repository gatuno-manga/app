import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../shared/components/molecules/app_empty_view.dart';
import '../../../../shared/components/organisms/app_top_bar.dart';
import '../../../../shared/components/organisms/tab_root_profile_action.dart';
import '../../../../shared/components/templates/app_top_bar_scaffold.dart';

/// Placeholder for the Biblioteca tab until #130 builds the real screen. The
/// same for guests and signed-in users.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppTopBarScaffold(
      topBar: AppTopBar(
        title: l10n.libraryTitle,
        actions: const [TabRootProfileAction()],
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppEmptyView(
            icon: Icons.bookmark_border,
            title: l10n.libraryComingSoonTitle,
            message: l10n.libraryComingSoonBody,
          ),
        ),
      ],
    );
  }
}
