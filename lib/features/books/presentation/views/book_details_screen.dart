import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../components/organisms/book_details_content.dart';
import '../components/organisms/book_details_error.dart';
import '../components/organisms/book_details_loading.dart';
import '../view_models/book_details_view_model.dart';
import '../view_models/book_downloads_view_model.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late final BookDetailsViewModel _viewModel;
  late final BookDownloadsViewModel _downloads;
  late final StreamSubscription<BookDownloadsNotice?> _notices;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<BookDetailsViewModel>();
    _downloads = context.read<BookDownloadsViewModel>();
    _notices = _downloads.stateStream
        .map((s) => s.notice)
        .distinct()
        .listen(_showNotice);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchBookDetails();
    });
  }

  @override
  void dispose() {
    unawaited(_notices.cancel());
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMoreChapters();
    }
  }

  void _showNotice(BookDownloadsNotice? notice) {
    if (notice == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(switch (notice) {
        BookDownloadsNotice.signInRequired => SnackBar(
          content: Text(l10n.booksDownloadSignInRequired),
          action: SnackBarAction(
            label: l10n.booksDownloadSignIn,
            onPressed: () => router.push('/auth/signin'),
          ),
        ),
        BookDownloadsNotice.actionFailed => SnackBar(
          content: Text(l10n.booksDownloadActionFailed),
        ),
      });
    _downloads.clearNotice();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<BookDetailsState>(
      stream: _viewModel.stateStream,
      initialData: _viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        if (state.isLoading && state.book == null) {
          return const BookDetailsLoading();
        }

        if (state.error != null && state.book == null) {
          return BookDetailsError(
            error: state.error!,
            onRetry: _viewModel.fetchBookDetails,
          );
        }

        final book = state.book;
        if (book == null) {
          return BookDetailsError(
            error: l10n.booksNoBooksFound,
            onRetry: _viewModel.fetchBookDetails,
          );
        }

        return StreamBuilder<BookDownloadsState>(
          stream: _downloads.stateStream,
          initialData: _downloads.state,
          builder: (context, snapshot) {
            final downloads = snapshot.data!;
            // Back leaves selection mode before it leaves the page.
            return PopScope(
              canPop: !downloads.selecting,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) _downloads.clearSelection();
              },
              child: BookDetailsContent(
                viewModel: _viewModel,
                downloadsViewModel: _downloads,
                downloads: downloads,
                book: book,
                scrollController: _scrollController,
              ),
            );
          },
        );
      },
    );
  }
}
