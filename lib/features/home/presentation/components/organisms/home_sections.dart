import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../books/domain/entities/book.dart';
import '../../../../../shared/components/molecules/app_cta_card.dart';
import '../molecules/home_section_header.dart';
import 'featured_carousel.dart';
import 'horizontal_book_list.dart';

/// The scrollable home content: featured carousel, the book rows and the
/// request call to action.
///
/// A row (header included) is left out when it has nothing to show and is
/// not loading, so an empty list never leaves a bare header behind.
class HomeSections extends StatelessWidget {
  final List<Book> featuredBooks;

  final List<Book> continueReadingBooks;
  final bool isLoadingContinueReading;

  final List<Book> latestUpdatedBooks;
  final bool isLoadingLatestUpdated;
  final VoidCallback onViewAllLatestUpdated;

  final List<Book> recentlyAddedBooks;
  final bool isLoadingRecentlyAdded;
  final VoidCallback onViewAllRecentlyAdded;

  final String ctaButtonText;
  final IconData ctaButtonIcon;

  /// Null disables the call to action; [ctaNote] says why.
  final VoidCallback? onCtaPressed;
  final String? ctaNote;

  const HomeSections({
    super.key,
    required this.featuredBooks,
    required this.continueReadingBooks,
    required this.isLoadingContinueReading,
    required this.latestUpdatedBooks,
    required this.isLoadingLatestUpdated,
    required this.onViewAllLatestUpdated,
    required this.recentlyAddedBooks,
    required this.isLoadingRecentlyAdded,
    required this.onViewAllRecentlyAdded,
    required this.ctaButtonText,
    required this.ctaButtonIcon,
    required this.onCtaPressed,
    this.ctaNote,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left out while empty, like the rows below.
          if (featuredBooks.isNotEmpty) FeaturedCarousel(books: featuredBooks),
          _BookRow(
            title: l10n.homeContinueReadingTitle,
            books: continueReadingBooks,
            isLoading: isLoadingContinueReading,
          ),
          _BookRow(
            title: l10n.homeLatestUpdatesTitle,
            books: latestUpdatedBooks,
            isLoading: isLoadingLatestUpdated,
            actionLabel: l10n.homeViewAll,
            onActionPressed: onViewAllLatestUpdated,
          ),
          _BookRow(
            title: l10n.homeRecentlyAddedTitle,
            books: recentlyAddedBooks,
            isLoading: isLoadingRecentlyAdded,
            actionLabel: l10n.homeViewAll,
            onActionPressed: onViewAllRecentlyAdded,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AppCtaCard(
              title: l10n.homeCtaTitle,
              description: l10n.homeCtaDescription,
              buttonText: ctaButtonText,
              buttonIcon: ctaButtonIcon,
              onPressed: onCtaPressed,
              note: ctaNote,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// A titled horizontal row of books, or nothing when it is empty and idle.
class _BookRow extends StatelessWidget {
  final String title;
  final List<Book> books;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const _BookRow({
    required this.title,
    required this.books,
    required this.isLoading,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        HomeSectionHeader(
          title: title,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
        ),
        HorizontalBookList(books: books, isLoading: isLoading),
      ],
    );
  }
}
