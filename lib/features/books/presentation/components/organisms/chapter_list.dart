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

  /// Download indicators and selection mode; null hides the indicators.
  final ChapterListDownloads? downloads;

  const ChapterList({
    super.key,
    required this.chapters,
    required this.isLoading,
    required this.hasNextPage,
    required this.onChapterTap,
    this.error,
    this.onRetry,
    this.downloads,
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
          // With the Scaffold's extendBody, the bottom padding includes the
          // selection bar and the system inset: every footer clears both.
          final bottom = MediaQuery.paddingOf(context).bottom;
          if (isLoading) {
            return Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
                child: const CircularProgressIndicator(),
              ),
            );
          }
          if (error != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
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
          return SizedBox(height: 32 + bottom);
        }

        final chapter = chapters[index];
        final readable = chapter.isReadable;
        final downloads = this.downloads;
        if (downloads == null) {
          return ChapterTile(
            chapter: chapter,
            onTap: readable ? () => onChapterTap(chapter) : null,
          );
        }
        final display = downloads.displayOf(chapter);
        final selecting = downloads.selecting;
        return ChapterTile(
          chapter: chapter,
          // Chapters the server is still scraping cannot download yet, so
          // they are neither selectable nor shown a download button; one
          // that already has a download keeps its indicator.
          onTap: !readable
              ? null
              : selecting
              ? () => downloads.onToggleSelected(chapter)
              : () => onChapterTap(chapter),
          onLongPress: readable && !selecting
              ? () => downloads.onLongPress(chapter)
              : null,
          // No checkbox on a chapter that cannot be picked.
          selected: selecting && readable
              ? downloads.isSelected(chapter)
              : null,
          reserveSelectionSlot: selecting && !readable,
          download: readable || display.status != ChapterDownloadStatus.none
              ? display
              : null,
          onDownloadTap: selecting
              ? null
              : () => downloads.onIndicatorTap(chapter),
        );
      }, childCount: chapters.length + 1),
    );
  }
}
