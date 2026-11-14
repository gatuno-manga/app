import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../shared/components/atoms/app_load_more_footer.dart';
import '../../../../../shared/components/molecules/app_offline_empty_view.dart';
import '../../../../../shared/components/molecules/pagination.dart';
import '../../../../../shared/utils/load_more_listener.dart';
import '../../../domain/entities/books_view_preferences.dart';
import '../../view_models/books_view_model.dart';
import '../atoms/books_list_note.dart';
import '../molecules/books_offline_notice.dart';
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
          layout: viewModel.preferences.layout,
          onLayoutChanged: viewModel.setLayoutMode,
          onOptionsPressed: () =>
              BooksViewOptionsSheet.show(context, viewModel),
        ),
        if (viewModel.isCacheList) const BooksOfflineNotice(),
        Expanded(child: _body(context)),
        if (!_infinite && _hasBooks && viewModel.isPagingPaused)
          BooksListNote(
            message: AppLocalizations.of(context)!.booksOfflinePagingPaused,
          )
        else if (!_infinite && _hasBooks)
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

    if (viewModel.isOfflineMiss && !_hasBooks) {
      return AppOfflineEmptyView(
        onRetry: viewModel.refresh,
        isRetrying: viewModel.isRefreshing || viewModel.isLoading,
      );
    }

    if (viewModel.isLoading && !_hasBooks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && !_hasBooks) {
      return Center(child: Text(viewModel.error!));
    }

    if (!_hasBooks) {
      return RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: BooksListNote(
                message: viewModel.isCacheList
                    ? l10n.booksOfflineNoMatch
                    : l10n.booksNoBooksFound,
              ),
            ),
          ],
        ),
      );
    }

    return LoadMoreListener(
      enabled:
          _infinite &&
          viewModel.hasMore &&
          !viewModel.isLoading &&
          !viewModel.isPagingPaused,
      onLoadMore: viewModel.loadMore,
      child: RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: BooksCollection(
          books: viewModel.bookList!.data,
          preferences: viewModel.preferences,
          footer: _footer(l10n),
        ),
      ),
    );
  }

  Widget? _footer(AppLocalizations l10n) {
    if (viewModel.isLoadingMore) return const AppLoadMoreFooter();
    if (!_infinite) return null;
    if (viewModel.isPagingPaused) {
      return BooksListNote(message: l10n.booksOfflinePagingPaused);
    }
    if (viewModel.isCacheList && !viewModel.hasMore) {
      return BooksListNote(message: l10n.booksOfflineEndOfList);
    }
    return null;
  }
}
