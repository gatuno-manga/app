import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/organisms/books_app_bar.dart';
import '../components/organisms/books_content.dart';
import '../components/organisms/books_filter_sheet.dart';
import '../components/templates/books_template.dart';
import '../view_models/books_view_model.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final TextEditingController _searchController = TextEditingController();
  late final BooksViewModel _viewModel;
  late StreamSubscription<BooksState> _subscription;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<BooksViewModel>();
    _subscription = _viewModel.stateStream.listen(_onStateChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewModel.bookList == null) {
        _viewModel.fetchBooks(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChanged(BooksState state) {
    if (state.error != null && mounted) {
      if (state.bookList != null && state.bookList!.data.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        _viewModel.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BooksState>(
      stream: _viewModel.stateStream,
      initialData: _viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;
        
        return BooksTemplate(
          appBar: BooksAppBar(
            searchController: _searchController,
            layoutMode: state.layoutMode,
            onToggleLayout: () => _viewModel.setLayoutMode(
              state.layoutMode == BooksLayoutMode.grid
                  ? BooksLayoutMode.list
                  : BooksLayoutMode.grid,
            ),
            onFilterPressed: () => BooksFilterSheet.show(context, _viewModel),
            onSearchChanged: (value) => _viewModel.setSearch(value),
            onSortChanged: (orderBy, order) =>
                _viewModel.setSort(orderBy, order),
          ),
          body: BooksContent(viewModel: _viewModel),
        );
      },
    );
  }
}
