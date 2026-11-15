import 'package:flutter/material.dart';
import '../../../../../features/books/domain/entities/chapter.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../../../../shared/components/atoms/app_icon_button.dart';
import '../../../../../shared/components/molecules/app_error_view.dart';
import '../../../../../shared/components/molecules/app_offline_empty_view.dart';

class ReadingTemplate extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final ReadingChapter? chapter;

  /// Offline, and the chapter is not downloaded.
  final bool isOfflineMiss;
  final bool isRetrying;

  /// The last offline retry failed: say so under the offline view.
  final bool stillOffline;

  /// The offline view's retry: probe the server, then reload. A plain
  /// reload would only miss again, since offline the network is skipped.
  final VoidCallback onOfflineRetry;
  final VoidCallback onRetry;
  final VoidCallback onGoBack;
  final Widget Function(ReadingChapter) readerBuilder;

  const ReadingTemplate({
    super.key,
    required this.isLoading,
    this.error,
    this.chapter,
    this.isOfflineMiss = false,
    this.isRetrying = false,
    this.stillOffline = false,
    required this.onOfflineRetry,
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

    if (isOfflineMiss) {
      return Scaffold(
        appBar: AppBar(
          leading: AppIconButton(
            icon: Icons.arrow_back,
            tooltip: l10n.errorBack,
            onPressed: onGoBack,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: AppOfflineEmptyView(
                onRetry: onOfflineRetry,
                isRetrying: isRetrying,
              ),
            ),
            if (stillOffline)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  // Announced by screen readers when it appears.
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.readingStillOffline,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: AppErrorView(error: error!, onRetry: onRetry, onGoBack: onGoBack),
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
