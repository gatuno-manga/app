import 'package:flutter/material.dart';
import '../../../../../shared/components/organisms/app_top_bar.dart';
import '../../../../../shared/components/templates/app_top_bar_scaffold.dart';
import '../molecules/book_error_view.dart';

class BookDetailsError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const BookDetailsError({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppTopBarScaffold(
      topBar: const AppTopBar(showBack: true),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: BookErrorView(error: error, onRetry: onRetry),
        ),
      ],
    );
  }
}
