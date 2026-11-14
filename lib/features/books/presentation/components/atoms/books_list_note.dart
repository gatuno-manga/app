import 'package:flutter/material.dart';

/// A short centered line at the end of the book list, such as the end of the
/// saved books or why paging is paused offline.
class BooksListNote extends StatelessWidget {
  final String message;

  const BooksListNote({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
