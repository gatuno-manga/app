import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reading_chapter.dart';
import 'reader_overlay_wrapper.dart';

class DocumentReader extends StatelessWidget {
  final ReadingChapter chapter;

  const DocumentReader({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ReaderOverlayWrapper(
      chapter: chapter,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.readingDeferredDocumentMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.booksDocumentFormat(
                  chapter.documentFormat?.value.toUpperCase() ??
                      l10n.booksUnknownFormat,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.errorBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
