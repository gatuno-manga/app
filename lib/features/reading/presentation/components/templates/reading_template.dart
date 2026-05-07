import 'package:flutter/material.dart';
import '../../../../../features/books/domain/entities/chapter.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../../../../shared/components/molecules/app_error_view.dart';

class ReadingTemplate extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final ReadingChapter? chapter;
  final VoidCallback onRetry;
  final VoidCallback onGoBack;
  final Widget Function(ReadingChapter) readerBuilder;

  const ReadingTemplate({
    super.key,
    required this.isLoading,
    this.error,
    this.chapter,
    required this.onRetry,
    required this.onGoBack,
    required this.readerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return Scaffold(
        body: AppErrorView(
          error: error!,
          onRetry: onRetry,
          onGoBack: onGoBack,
        ),
      );
    }

    if (chapter == null) {
      return Scaffold(body: Center(child: Text(l10n.booksNoChaptersFound)));
    }

    if (chapter!.scrapingStatus != null &&
        chapter!.scrapingStatus != ScrapingStatus.ready) {
      final statusText = chapter!.scrapingStatus == ScrapingStatus.process
          ? l10n.scrapingStatusProcessWarning
          : l10n.scrapingStatusErrorWarning;

      return Scaffold(
        body: AppErrorView(
          error: statusText,
          onRetry: onRetry,
          onGoBack: onGoBack,
        ),
      );
    }

    return Scaffold(body: readerBuilder(chapter!));
  }
}
