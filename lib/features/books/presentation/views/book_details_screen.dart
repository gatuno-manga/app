import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../components/organisms/book_details_content.dart';
import '../components/organisms/book_details_error.dart';
import '../components/organisms/book_details_loading.dart';
import '../view_models/book_details_view_model.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late final BookDetailsViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<BookDetailsViewModel>();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchBookDetails();
    });
  }

  @override
  void dispose() {
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

        return BookDetailsContent(
          viewModel: _viewModel,
          book: book,
          scrollController: _scrollController,
        );
      },
    );
  }
}
