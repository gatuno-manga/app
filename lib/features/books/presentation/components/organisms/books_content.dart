import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/shared/components/molecules/app_load_more_footer.dart';
import 'package:gatuno/shared/components/molecules/load_more_listener.dart';
import 'package:gatuno/shared/components/molecules/pagination.dart';
import 'package:gatuno/features/books/domain/entities/books_view_preferences.dart';
import 'package:gatuno/features/books/presentation/view_models/books_view_model.dart';
import 'books_collection.dart';
import 'books_view_options_sheet.dart';
import 'books_view_toolbar.dart';

class BooksContent extends StatelessWidget {
  final BooksViewModel viewModel;

  const BooksContent({super.key, required this.viewModel});

  bool get _infinite =>
      viewModel.preferences.navigation == BooksNavigationMode.infinite;

  bool get _hasBooks => viewModel.bookList?.data.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BooksViewToolbar(
          layout: viewModel.layoutMode,
          onLayoutChanged: viewModel.setLayoutMode,
          onOptionsPressed: () =>
              BooksViewOptionsSheet.show(context, viewModel),
        ),
        Expanded(child: _body(context)),
        if (!_infinite && _hasBooks)
          Pagination(
            currentPage: viewModel.options.page.value,
            totalPages: viewModel.bookList?.totalPages.value ?? 1,
            isLoading: viewModel.isLoading,
            onPageChanged: viewModel.setPage,
          ),
      ],
    );
  }

  Widget _body(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (viewModel.isLoading && !_hasBooks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && !_hasBooks) {
      return Center(child: Text(viewModel.error!));
    }

    if (!_hasBooks) {
      return RefreshIndicator(
        onRefresh: _refresh,
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

    return LoadMoreListener(
      enabled: _infinite && viewModel.hasMore && !viewModel.isLoading,
      onLoadMore: viewModel.loadMore,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: BooksCollection(
          books: viewModel.bookList!.data,
          preferences: viewModel.preferences,
          footer: _infinite && viewModel.isLoading
              ? const AppLoadMoreFooter()
              : null,
        ),
      ),
    );
  }

  // Infinite mode holds pages 1..N, so a refresh starts over from page 1;
  // pages mode keeps the page the user is on.
  Future<void> _refresh() =>
      viewModel.fetchBooks(refresh: true, resetPage: _infinite);
}
