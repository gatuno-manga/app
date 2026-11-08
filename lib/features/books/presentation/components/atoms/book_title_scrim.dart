import 'package:flutter/material.dart';

import 'book_title.dart';

/// Title over a dark bottom gradient, for text laid on top of a cover.
///
/// Covers are arbitrary art, so the scrim is black and the text white on
/// purpose; theme tokens have no contrast over images.
class BookTitleScrim extends StatelessWidget {
  final String title;

  const BookTitleScrim({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.9),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      child: BookTitle(
        title: title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
