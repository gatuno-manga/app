import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/shared/components/molecules/pagination.dart';
import 'package:gatuno/features/books/presentation/view_models/books_view_model.dart';
import 'books_collection.dart';

class BooksContent extends StatelessWidget {
  final BooksViewModel viewModel;

  const BooksContent({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (viewModel.isLoading && (viewModel.bookList?.data.isEmpty ?? true)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && (viewModel.bookList?.data.isEmpty ?? true)) {
      return Center(child: Text(viewModel.error!));
    }

    final books = viewModel.bookList?.data ?? [];

    if (books.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => viewModel.fetchBooks(refresh: true, resetPage: false),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(child: Text(l10n.booksNoBooksFound)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                viewModel.fetchBooks(refresh: true, resetPage: false),
            child: BooksCollection(
              books: books,
              preferences: viewModel.preferences,
            ),
          ),
        ),
        Pagination(
          currentPage: viewModel.options.page.value,
          totalPages: viewModel.bookList?.totalPages.value ?? 1,
          isLoading: viewModel.isLoading,
          onPageChanged: (page) => viewModel.setPage(page),
        ),
      ],
    );
  }
}
