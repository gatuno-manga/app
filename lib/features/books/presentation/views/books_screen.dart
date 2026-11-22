import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../shared/components/organisms/app_top_bar.dart';
import '../../../../shared/components/organisms/tab_root_profile_action.dart';
import '../../../../shared/components/templates/app_top_bar_scaffold.dart';
import '../../books_launch_intent.dart';
import '../components/atoms/books_filter_action.dart';
import '../components/molecules/books_search_field.dart';
import '../components/molecules/books_sort_action.dart';
import '../components/organisms/books_content.dart';
import '../components/organisms/books_filter_sheet.dart';
import '../view_models/books_view_model.dart';

class BooksPage extends StatefulWidget {
  /// A request from another screen (Home's search and "view all" links).
  /// Applied once per [BooksLaunchIntent.nonce], also when this page was
  /// already open.
  final BooksLaunchIntent? intent;

  const BooksPage({super.key, this.intent});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  int? _appliedNonce;
  late final BooksViewModel _viewModel;
  late StreamSubscription<BooksState> _subscription;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<BooksViewModel>();
    _subscription = _viewModel.stateStream.listen(_onStateChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewModel.bookList == null) {
        _viewModel.fetchBooks();
      }
    });
    _applyIntent();
  }

  @override
  void didUpdateWidget(BooksPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyIntent();
  }

  void _applyIntent() {
    final intent = widget.intent;
    if (intent == null || intent.nonce == _appliedNonce) return;
    _appliedNonce = intent.nonce;
    if (intent.hasSort) {
      _viewModel.setSort(intent.orderBy!, intent.order!);
    }
    if (intent.focusSearch) {
      // After layout, so the revealed bar and the field exist.
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusSearch());
    }
  }

  void _focusSearch() {
    if (!mounted) return;
    final controller = PrimaryScrollController.maybeOf(context);
    if (controller != null && controller.hasClients) {
      // The floating bar comes back when the list is at the top.
      controller.jumpTo(0);
    }
    // The bar is laid out again on the next frame; ask for one, since a
    // post-frame callback alone does not schedule it.
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      })
      ..scheduleFrame();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<BooksState>(
      stream: _viewModel.stateStream,
      initialData: _viewModel.state,
      // Rebuilds the body on every state change; BooksContent reads the
      // view model directly.
      builder: (context, snapshot) {
        final content = BooksContent(viewModel: _viewModel);
        return AppTopBarScaffold(
          topBar: AppTopBar(
            title: l10n.booksTitle,
            searchField: BooksSearchField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (value) => _viewModel.setSearch(value),
            ),
            actions: [
              BooksSortAction(
                onSortChanged: (orderBy, order) =>
                    _viewModel.setSort(orderBy, order),
              ),
              BooksFilterAction(
                onPressed: () => BooksFilterSheet.show(context, _viewModel),
              ),
              const TabRootProfileAction(),
            ],
          ),
          slivers: content.slivers(context),
          bottomBar: content.bottomBar(context),
          wrap: (scrollView) => content.wrap(context, scrollView),
        );
      },
    );
  }
}
