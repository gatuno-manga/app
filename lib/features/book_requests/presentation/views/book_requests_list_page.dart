import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../view_models/book_requests_list_view_model.dart';
import '../components/molecules/book_request_card.dart';

class BookRequestsListPage extends StatefulWidget {
  const BookRequestsListPage({super.key});

  @override
  State<BookRequestsListPage> createState() => _BookRequestsListPageState();
}

class _BookRequestsListPageState extends State<BookRequestsListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookRequestsListViewModel>().fetchRequests(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BookRequestsListViewModel>().fetchRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<BookRequestsListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookRequestsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/requests/create'),
          ),
        ],
      ),
      body: StreamBuilder<BookRequestsListState>(
        stream: viewModel.stateStream,
        initialData: viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () => viewModel.fetchRequests(refresh: true),
            child: _buildBody(viewModel, state, l10n),
          );
        }
      ),
    );
  }

  Widget _buildBody(BookRequestsListViewModel viewModel, BookRequestsListState state, AppLocalizations l10n) {
    if (state.isLoading && state.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => viewModel.fetchRequests(refresh: true),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.errorRetry),
            ),
          ],
        ),
      );
    }

    if (state.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.bookRequestsEmpty,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/requests/create'),
              icon: const Icon(Icons.add),
              label: Text(l10n.bookRequestsCreateTitle),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.requests.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.requests.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final request = state.requests[index];
        return BookRequestCard(request: request);
      },
    );
  }
}
