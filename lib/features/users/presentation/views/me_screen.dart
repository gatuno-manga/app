import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../view_models/me_view_model.dart';
import '../components/molecules/user_profile_header.dart';
import 'package:gatuno/features/settings/presentation/components/organisms/me_settings_list.dart';
import '../components/templates/profile_template.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<MeViewModel>();

    return StreamBuilder<MeState>(
      stream: viewModel.stateStream,
      initialData: viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        return ProfileTemplate(
          title: l10n.userMeTitle,
          isLoading: state.isLoading,
          header: UserProfileHeader(
            displayName: state.user.displayName,
            email: state.user.email.value,
          ),
          settings: MeSettingsList(
            logoutButton: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await viewModel.logout();
                  if (!context.mounted) return;
                  context.go('/settings');
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.commonLogout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
