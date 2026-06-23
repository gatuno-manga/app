import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../components/templates/home_template.dart';
import '../../../../shared/components/molecules/app_cta_card.dart';
import '../view_models/home_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<HomeViewModel>();

    return HomeTemplate(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          AppCtaCard(
            title: l10n.homeCtaTitle,
            description: l10n.homeCtaDescription,
            buttonText: viewModel.isAuthenticated ? l10n.bookRequestsTitle : l10n.homeCtaSignInButton,
            buttonIcon: viewModel.isAuthenticated ? Icons.library_add : Icons.login,
            onPressed: () {
              if (viewModel.isAuthenticated) {
                context.push('/requests');
              } else {
                context.push('/auth/signin?redirect=/requests');
              }
            },
          ),
        ],
      ),
    );
  }
}
