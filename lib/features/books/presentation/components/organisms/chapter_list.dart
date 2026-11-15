import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/features/books/domain/entities/chapter.dart';
import '../../../../../shared/components/atoms/app_text_button.dart';
import '../../models/download_display.dart';
import '../molecules/chapter_tile.dart';

class ChapterList extends StatelessWidget {
  final List<Chapter> chapters;
  final bool isLoading;
  final bool hasNextPage;
  final void Function(Chapter) onChapterTap;
  final String? error;
  final VoidCallback? onRetry;

  /// The download indicator of each chapter; null hides the indicators.
  final ChapterDownloadStatus Function(Chapter)? downloadStatusOf;
  final double Function(Chapter)? downloadProgressOf;
  final void Function(Chapter)? onDownloadTap;

  /// Selection mode: a tap toggles the chapter and the indicators are
  /// display-only.
  final bool selecting;
  final bool Function(Chapter)? isSelected;
  final void Function(Chapter)? onToggleSelected;

  /// Long press: enters selection mode with the chapter picked.
  final void Function(Chapter)? onLongPress;

  /// Room left after the last chapter, for a bar laid over the list.
  final double bottomPadding;

  const ChapterList({
    super.key,
    required this.chapters,
    required this.isLoading,
    required this.hasNextPage,
    required this.onChapterTap,
    this.error,
    this.onRetry,
    this.downloadStatusOf,
    this.downloadProgressOf,
    this.onDownloadTap,
    this.selecting = false,
    this.isSelected,
    this.onToggleSelected,
    this.onLongPress,
    this.bottomPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (chapters.isEmpty && !isLoading && error == null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(l10n.booksNoChaptersFound),
          ),
        ),
      );
    }

    if (chapters.isEmpty && isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (chapters.isEmpty && error != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(error!, textAlign: TextAlign.center),
                if (onRetry != null)
                  AppTextButton(text: l10n.errorRetry, onPressed: onRetry),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == chapters.length) {
          if (isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(error!, textAlign: TextAlign.center),
                    if (onRetry != null)
                      AppTextButton(text: l10n.errorRetry, onPressed: onRetry),
                  ],
                ),
              ),
            );
          }
          return SizedBox(height: 32 + bottomPadding);
        }

        final chapter = chapters[index];
        final readable =
            chapter.scrapingStatus == null ||
            chapter.scrapingStatus == ScrapingStatus.ready;
        final status = downloadStatusOf?.call(chapter);
        // Chapters the server is still scraping cannot download yet; one
        // that already has a download keeps its indicator.
        final showIndicator =
            status != null &&
            (readable || status != ChapterDownloadStatus.none);
        if (selecting) {
          return ChapterTile(
            chapter: chapter,
            selected: isSelected?.call(chapter) ?? false,
            onTap: () => onToggleSelected?.call(chapter),
            downloadStatus: showIndicator ? status : null,
            downloadProgress: downloadProgressOf?.call(chapter) ?? 0,
          );
        }
        return ChapterTile(
          chapter: chapter,
          onTap: readable ? () => onChapterTap(chapter) : null,
          onLongPress: onLongPress == null ? null : () => onLongPress!(chapter),
          downloadStatus: showIndicator ? status : null,
          downloadProgress: downloadProgressOf?.call(chapter) ?? 0,
          onDownloadTap: onDownloadTap == null
              ? null
              : () => onDownloadTap!(chapter),
        );
      }, childCount: chapters.length + 1),
    );
  }
}
