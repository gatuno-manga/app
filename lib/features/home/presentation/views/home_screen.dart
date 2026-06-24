import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../components/templates/home_template.dart';
import '../components/organisms/featured_carousel.dart';
import '../components/molecules/home_section_header.dart';
import '../components/organisms/horizontal_book_list.dart';
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (viewModel.isLoadingFeatured || viewModel.featuredBooks.isNotEmpty)
              FeaturedCarousel(books: viewModel.featuredBooks),

            if (viewModel.isLoadingContinueReading || viewModel.continueReadingBooks.isNotEmpty) ...[
              const SizedBox(height: 16),
              HomeSectionHeader(title: l10n.homeContinueReadingTitle),
              HorizontalBookList(
                books: viewModel.continueReadingBooks,
                isLoading: viewModel.isLoadingContinueReading,
              ),
            ],

            const SizedBox(height: 16),
            HomeSectionHeader(
              title: l10n.homeLatestUpdatesTitle,
              actionLabel: l10n.homeViewAll,
              onActionPressed: () {
                context.push('/books?orderBy=updatedAt&order=desc');
              },
            ),
            HorizontalBookList(
              books: viewModel.latestUpdatedBooks,
              isLoading: viewModel.isLoadingGrid,
            ),

            const SizedBox(height: 16),
            HomeSectionHeader(
              title: l10n.homeRecentlyAddedTitle,
              actionLabel: l10n.homeViewAll,
              onActionPressed: () {
                context.push('/books?orderBy=createdAt&order=desc');
              },
            ),
            HorizontalBookList(
              books: viewModel.recentlyAddedBooks,
              isLoading: viewModel.isLoadingRecentlyAdded,
            ),

            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppCtaCard(
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
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
