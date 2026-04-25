import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../view_models/reading_view_model.dart';

class ReadingBottomBar extends StatelessWidget {
  final ReadingChapter chapter;
  final double bottomPadding;

  const ReadingBottomBar({
    super.key,
    required this.chapter,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<ReadingViewModel>();
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomPadding + 8,
        left: 16,
        right: 16,
        top: 16,
      ),
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chapter.pages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                l10n.commonPageOf(
                  viewModel.currentPageIndex + 1,
                  chapter.pages.length,
                ),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: chapter.previous != null
                    ? () => context.pushReplacement(
                        '/chapters/${chapter.previous}',
                      )
                    : null,
                tooltip: l10n.readingPreviousChapter,
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: theme.colorScheme.onSurface),
                onPressed: chapter.next != null
                    ? () => context.pushReplacement('/chapters/${chapter.next}')
                    : null,
                tooltip: l10n.readingNextChapter,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
