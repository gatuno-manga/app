import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../components/templates/home_template.dart';
import '../components/organisms/home_app_bar.dart';
import '../components/organisms/home_sections.dart';
import '../../../../shared/components/molecules/app_offline_empty_view.dart';
import '../view_models/home_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<HomeViewModel>();

    return StreamBuilder<HomeState>(
      stream: viewModel.stateStream,
      initialData: viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        final ctaRoute = state.isAuthenticated
            ? '/requests'
            : '/auth/signin?redirect=/requests';

        return HomeTemplate(
          appBar: HomeAppBar(
            title: l10n.homeTitle,
            isAuthenticated: state.isAuthenticated,
            isLoading: !state.isInitialized,
            // Guest while the profile loads keeps the avatar skeleton.
            displayName: state.user.isGuest ? null : state.user.displayName,
            imageUrl: state.user.profilePictureUrl,
            onProfilePressed: () => context.push('/settings/profile'),
            onSignInPressed: () => context.push('/auth/signin'),
            profileTooltip: l10n.homeProfile,
            signInTooltip: l10n.homeSignIn,
          ),
          body: state.showOfflineEmpty
              ? AppOfflineEmptyView(
                  onRetry: viewModel.retry,
                  isRetrying: state.isRetrying,
                )
              : HomeSections(
                  featuredBooks: state.featuredBooks,
                  isLoadingFeatured: state.latestUpdated.isLoading,
                  continueReadingBooks: state.continueReadingBooks,
                  isLoadingContinueReading: state.isLoadingContinueReading,
                  latestUpdatedBooks: state.latestUpdated.books,
                  isLoadingLatestUpdated: state.latestUpdated.isLoading,
                  onViewAllLatestUpdated: () =>
                      context.push('/books?orderBy=updatedAt&order=desc'),
                  recentlyAddedBooks: state.recentlyAdded.books,
                  isLoadingRecentlyAdded: state.recentlyAdded.isLoading,
                  onViewAllRecentlyAdded: () =>
                      context.push('/books?orderBy=createdAt&order=desc'),
                  ctaButtonText: state.isAuthenticated
                      ? l10n.bookRequestsTitle
                      : l10n.homeCtaSignInButton,
                  ctaButtonIcon: state.isAuthenticated
                      ? Icons.library_add
                      : Icons.login,
                  // Both destinations need the server.
                  onCtaPressed: state.isOffline
                      ? null
                      : () => context.push(ctaRoute),
                  ctaNote: state.isOffline ? l10n.homeCtaOfflineNote : null,
                ),
        );
      },
    );
  }
}
