import 'package:flutter/material.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../../../../shared/components/molecules/app_error_view.dart';

class ReadingTemplate extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final ReadingChapter? chapter;
  final VoidCallback onRetry;
  final Widget Function(ReadingChapter) readerBuilder;

  const ReadingTemplate({
    super.key,
    required this.isLoading,
    this.error,
    this.chapter,
    required this.onRetry,
    required this.readerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        body: AppErrorView(error: error!, onRetry: onRetry),
      );
    }

    if (chapter == null) {
      return const Scaffold(body: Center(child: Text('No chapter found')));
    }

    return Scaffold(
      body: readerBuilder(chapter!),
    );
  }
}
