import 'package:flutter/material.dart';

/// A short centered line at the end of the book list, such as the end of the
/// saved books or why paging is paused offline.
class BooksListNote extends StatelessWidget {
  final String message;

  /// Announce the note when it appears, for a note that replaces controls
  /// (paging) so a screen reader user learns why they went away.
  final bool announce;

  const BooksListNote({
    super.key,
    required this.message,
    this.announce = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: announce,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
