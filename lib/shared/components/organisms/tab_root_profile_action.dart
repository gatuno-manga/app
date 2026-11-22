import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/shell_navigation.dart';
import '../../presentation/view_models/navigation_view_model.dart';
import '../molecules/app_profile_action.dart';

/// The profile action for tab roots that have no view model of their own
/// (Livros, Biblioteca): reads the signed-in user and opens the merged
/// "Perfil e configurações" screen in the current tab.
class TabRootProfileAction extends StatefulWidget {
  const TabRootProfileAction({super.key});

  @override
  State<TabRootProfileAction> createState() => _TabRootProfileActionState();
}

class _TabRootProfileActionState extends State<TabRootProfileAction> {
  late final NavigationViewModel _viewModel = sl<NavigationViewModel>();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<NavigationState>(
      stream: _viewModel.stateStream,
      initialData: _viewModel.state,
      builder: (context, snapshot) {
        final user = snapshot.data!.user;
        return AppProfileAction(
          isGuest: user.isGuest,
          imageUrl: user.profilePictureUrl,
          tooltip: user.isGuest ? l10n.homeSignIn : l10n.homeProfile,
          onPressed: () => context.pushInTab('/settings'),
        );
      },
    );
  }
}
