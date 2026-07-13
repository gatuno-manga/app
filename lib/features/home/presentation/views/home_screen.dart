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
    final viewModel = context.read<HomeViewModel>();

    return StreamBuilder<HomeState>(
      stream: viewModel.stateStream,
      initialData: viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        return HomeTemplate(
          appBar: AppBar(title: Text(l10n.homeTitle)),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.isLoadingFeatured || state.featuredBooks.isNotEmpty)
                  FeaturedCarousel(books: state.featuredBooks),

                if (state.isLoadingContinueReading || state.continueReadingBooks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  HomeSectionHeader(title: l10n.homeContinueReadingTitle),
                  HorizontalBookList(
                    books: state.continueReadingBooks,
                    isLoading: state.isLoadingContinueReading,
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
                  books: state.latestUpdatedBooks,
                  isLoading: state.isLoadingGrid,
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
                  books: state.recentlyAddedBooks,
                  isLoading: state.isLoadingRecentlyAdded,
                ),

                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AppCtaCard(
                    title: l10n.homeCtaTitle,
                    description: l10n.homeCtaDescription,
                    buttonText: state.isAuthenticated ? l10n.bookRequestsTitle : l10n.homeCtaSignInButton,
                    buttonIcon: state.isAuthenticated ? Icons.library_add : Icons.login,
                    onPressed: () {
                      if (state.isAuthenticated) {
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
      },
    );
  }
}
