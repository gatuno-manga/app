import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../view_models/reading_view_model.dart';

class ReadingOverlay extends StatelessWidget {
  final ReadingChapter chapter;

  const ReadingOverlay({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final viewModel = context.watch<ReadingViewModel>();

    return Column(
      children: [
        // Top Bar
        Container(
          padding: EdgeInsets.only(top: topPadding, left: 8, right: 8, bottom: 8),
          color: Colors.black.withValues(alpha: 0.8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.bookTitle,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      chapter.title ?? 'Chapter ${chapter.index}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Bottom Bar
        Container(
          padding: EdgeInsets.only(bottom: bottomPadding + 8, left: 16, right: 16, top: 16),
          color: Colors.black.withValues(alpha: 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (chapter.pages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    l10n.commonPageOf(viewModel.currentPageIndex + 1, chapter.pages.length),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: chapter.previous != null
                        ? () => context.pushReplacement('/chapters/${chapter.previous}')
                        : null,
                    tooltip: l10n.readingPreviousChapter,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: chapter.next != null
                        ? () => context.pushReplacement('/chapters/${chapter.next}')
                        : null,
                    tooltip: l10n.readingNextChapter,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
