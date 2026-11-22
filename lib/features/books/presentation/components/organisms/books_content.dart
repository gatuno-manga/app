import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../shared/components/atoms/app_load_more_footer.dart';
import '../../../../../shared/components/molecules/app_offline_empty_view.dart';
import '../../../../../shared/components/molecules/pagination.dart';
import '../../../../../shared/utils/load_more_listener.dart';
import '../../../../../shared/components/templates/app_top_bar_scaffold.dart';
import '../../../domain/entities/books_view_preferences.dart';
import '../../view_models/books_view_model.dart';
import '../atoms/books_list_note.dart';
import '../molecules/books_offline_notice.dart';
import 'books_collection.dart';
import 'books_view_options_sheet.dart';
import 'books_view_toolbar.dart';

/// Livros: the top bar over the toolbar and the book list, with pull to
/// refresh and infinite loading around the list. The placeholders (loading,
/// error, offline miss, no books) fill the screen and do not pull.
class BooksContent extends StatelessWidget {
  final BooksViewModel viewModel;
  final Widget topBar;

  const BooksContent({
    super.key,
    required this.viewModel,
    required this.topBar,
  });

  bool get _infinite =>
      viewModel.preferences.navigation == BooksNavigationMode.infinite;

  bool get _hasBooks => viewModel.bookList?.data.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final header = [
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
    ];

    final placeholder = _placeholder(l10n);
    if (placeholder != null) {
      return AppTopBarScaffold(
        topBar: topBar,
        slivers: [
          ...header,
          SliverFillRemaining(hasScrollBody: false, child: placeholder),
        ],
      );
    }

    return AppTopBarScaffold(
      topBar: topBar,
      slivers: [
        ...header,
        BooksCollection(
          books: viewModel.bookList!.data,
          preferences: viewModel.preferences,
          footer: _footer(l10n),
        ),
      ],
      bottomBar: _bottomBar(l10n),
      wrap: (scrollView) => LoadMoreListener(
        enabled:
            _infinite &&
            viewModel.hasMore &&
            !viewModel.isLoading &&
            !viewModel.isPagingPaused,
        onLoadMore: viewModel.loadMore,
        child: RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: scrollView,
        ),
      ),
    );
  }

  /// What fills the screen instead of the list, or null when there are books.
  Widget? _placeholder(AppLocalizations l10n) {
    if (_hasBooks) return null;
    if (viewModel.isOfflineMiss) {
      return AppOfflineEmptyView(
        onRetry: viewModel.refresh,
        isRetrying: viewModel.isRefreshing || viewModel.isLoading,
      );
    }
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null) {
      return Center(child: Text(viewModel.error!));
    }
    return BooksListNote(
      message: viewModel.isCacheList
          ? l10n.booksOfflineNoMatch
          : l10n.booksNoBooksFound,
    );
  }

  /// The page controls, fixed under the list in pages mode.
  Widget? _bottomBar(AppLocalizations l10n) {
    if (_infinite) return null;
    return viewModel.isPagingPaused
        ? _pausedNote(l10n, announce: true)
        : Pagination(
            currentPage: viewModel.options.page.value,
            totalPages: viewModel.bookList?.totalPages.value ?? 1,
            isLoading: viewModel.isLoading,
            onPageChanged: viewModel.setPage,
          );
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
