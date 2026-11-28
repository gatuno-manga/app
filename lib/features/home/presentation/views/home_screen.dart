import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../components/templates/home_template.dart';
import '../components/organisms/home_sections.dart';
import '../../../../shared/components/molecules/app_offline_empty_view.dart';
import '../view_models/home_view_model.dart';
import '../../../../core/router/shell_navigation.dart';
import '../../../../shared/components/molecules/app_profile_action.dart';
import '../../../../shared/components/organisms/app_top_bar.dart';
import '../../../books/books_launch_intent.dart';
import '../../../books/domain/entities/book_page_options.dart';

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
        return HomeTemplate(
          topBar: AppTopBar(
            title: l10n.homeTitle,
            showLogo: true,
            actions: [
              AppProfileAction(
                isGuest: state.user.isGuest,
                // Guest while the profile loads keeps the avatar skeleton.
                isLoading: !state.isInitialized,
                imageUrl: state.user.profilePictureUrl,
                tooltip: state.isAuthenticated
                    ? l10n.homeProfile
                    : l10n.homeSignIn,
                onPressed: () => context.pushInTab('/settings'),
              ),
            ],
          ),
          slivers: [
            if (state.showOfflineEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppOfflineEmptyView(
                  onRetry: viewModel.retry,
                  isRetrying: state.isRetrying,
                ),
              )
            else
              HomeSections(
                featuredBooks: state.featuredBooks,
                continueReadingBooks: state.continueReadingBooks,
                isLoadingContinueReading: state.isLoadingContinueReading,
                latestUpdatedBooks: state.latestUpdated.books,
                isLoadingLatestUpdated: state.latestUpdated.isLoading,
                onViewAllLatestUpdated: () => context.goToBooks(
                  orderBy: 'updatedAt',
                  order: SortOrder.desc,
                ),
                recentlyAddedBooks: state.recentlyAdded.books,
                isLoadingRecentlyAdded: state.recentlyAdded.isLoading,
                onViewAllRecentlyAdded: () => context.goToBooks(
                  orderBy: 'createdAt',
                  order: SortOrder.desc,
                ),
                ctaButtonText: state.isAuthenticated
                    ? l10n.bookRequestsTitle
                    : l10n.homeCtaSignInButton,
                ctaButtonIcon: state.isAuthenticated
                    ? Icons.library_add
                    : Icons.login,
                // Both destinations need the server.
                onCtaPressed: state.isOffline
                    ? null
                    : () => state.isAuthenticated
                          ? context.pushInTab('/requests')
                          : context.push('/auth/signin?redirect=/requests'),
                ctaNote: state.isOffline ? l10n.homeCtaOfflineNote : null,
              ),
          ],
        );
      },
    );
  }
}
