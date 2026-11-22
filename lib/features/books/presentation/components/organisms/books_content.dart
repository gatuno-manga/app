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

/// The body of Livros as slivers for the top bar's scroll view, plus the
/// wrapper that adds pull to refresh and infinite loading around it.
class BooksContent {
  final BooksViewModel viewModel;

  const BooksContent({required this.viewModel});

  bool get _infinite =>
      viewModel.preferences.navigation == BooksNavigationMode.infinite;

  bool get _hasBooks => viewModel.bookList?.data.isNotEmpty ?? false;

  bool get _isPlaceholder =>
      (viewModel.isOfflineMiss && !_hasBooks) ||
      (viewModel.isLoading && !_hasBooks) ||
      (viewModel.error != null && !_hasBooks);

  /// Pull to refresh and load more around the scroll view. The placeholders
  /// (loading, error, offline miss) have their own retry and do not pull.
  Widget wrap(BuildContext context, Widget scrollView) {
    if (_isPlaceholder) return scrollView;
    return LoadMoreListener(
      enabled:
          _hasBooks &&
          _infinite &&
          viewModel.hasMore &&
          !viewModel.isLoading &&
          !viewModel.isPagingPaused,
      onLoadMore: viewModel.loadMore,
      child: RefreshIndicator(onRefresh: viewModel.refresh, child: scrollView),
    );
  }

  /// The page controls, fixed under the list in pages mode.
  Widget? bottomBar(BuildContext context) {
    if (_infinite || !_hasBooks) return null;
    return viewModel.isPagingPaused
        ? _pausedNote(AppLocalizations.of(context)!, announce: true)
        : Pagination(
            currentPage: viewModel.options.page.value,
            totalPages: viewModel.bookList?.totalPages.value ?? 1,
            isLoading: viewModel.isLoading,
            onPageChanged: viewModel.setPage,
          );
  }

  List<Widget> slivers(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      SliverToBoxAdapter(
        child: BooksViewToolbar(
          layout: viewModel.preferences.layout,
          onLayoutChanged: viewModel.setLayoutMode,
          onOptionsPressed: () =>
              BooksViewOptionsSheet.show(context, viewModel),
        ),
      ),
      if (viewModel.isCacheList)
        const SliverToBoxAdapter(child: BooksOfflineNotice()),
      ..._body(context, l10n),
    ];
  }

  List<Widget> _body(BuildContext context, AppLocalizations l10n) {
    if (viewModel.isOfflineMiss && !_hasBooks) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppOfflineEmptyView(
            onRetry: viewModel.refresh,
            isRetrying: viewModel.isRefreshing || viewModel.isLoading,
          ),
        ),
      ];
    }

    if (viewModel.isLoading && !_hasBooks) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (viewModel.error != null && !_hasBooks) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text(viewModel.error!)),
        ),
      ];
    }

    if (!_hasBooks) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: BooksListNote(
            message: viewModel.isCacheList
                ? l10n.booksOfflineNoMatch
                : l10n.booksNoBooksFound,
          ),
        ),
      ];
    }

    return [
      BooksCollection(
        books: viewModel.bookList!.data,
        preferences: viewModel.preferences,
        footer: _footer(l10n),
      ),
    ];
  }

  /// Pull to refresh has no accessibility action, so the note offers the
  /// refresh itself to screen readers.
  Widget _pausedNote(AppLocalizations l10n, {required bool announce}) {
    return BooksListNote(
      message: l10n.booksOfflinePagingPaused,
      announce: announce,
      onAction: viewModel.refresh,
      actionHint: l10n.booksOfflineRefreshAction,
    );
  }

  Widget? _footer(AppLocalizations l10n) {
    if (viewModel.isLoadingMore) return const AppLoadMoreFooter();
    if (!_infinite) return null;
    // Reached by scrolling, so it is read in order; announcing it again
    // each time it is rebuilt would only repeat the shell's banner.
    if (viewModel.isPagingPaused) return _pausedNote(l10n, announce: false);
    if (viewModel.isCacheList && !viewModel.hasMore) {
      return BooksListNote(message: l10n.booksOfflineEndOfList);
    }
    return null;
  }
}
