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
    final viewModel = context.watch<BookRequestsListViewModel>();

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
      body: RefreshIndicator(
        onRefresh: () => viewModel.fetchRequests(refresh: true),
        child: _buildBody(viewModel, l10n),
      ),
    );
  }

  Widget _buildBody(BookRequestsListViewModel viewModel, AppLocalizations l10n) {
    if (viewModel.isLoading && viewModel.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && viewModel.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(viewModel.error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () => viewModel.fetchRequests(refresh: true),
              child: Text(l10n.errorRetry),
            ),
          ],
        ),
      );
    }

    if (viewModel.requests.isEmpty) {
      return Center(
        child: Text(l10n.bookRequestsEmpty),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: viewModel.requests.length + (viewModel.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.requests.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final request = viewModel.requests[index];
        return BookRequestCard(request: request);
      },
    );
  }
}
