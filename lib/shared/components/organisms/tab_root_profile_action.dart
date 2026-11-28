import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/router/shell_navigation.dart';
import '../../presentation/view_models/navigation_view_model.dart';
import '../molecules/app_profile_action.dart';

/// The profile action for tab roots that have no view model of their own
/// (Livros, Biblioteca): reads the signed-in user from the shell's
/// [NavigationViewModel] and opens the merged "Perfil e configurações" screen
/// in the current tab.
class TabRootProfileAction extends StatelessWidget {
  const TabRootProfileAction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<NavigationViewModel>();
    return StreamBuilder<NavigationState>(
      stream: viewModel.stateStream,
      initialData: viewModel.state,
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
