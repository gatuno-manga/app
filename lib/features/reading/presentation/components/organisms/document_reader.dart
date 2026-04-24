import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/reading_chapter.dart';

class DocumentReader extends StatelessWidget {
  final ReadingChapter chapter;

  const DocumentReader({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.readingDeferredDocumentMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Format: ${chapter.documentFormat?.value.toUpperCase() ?? 'Unknown'}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(l10n.errorBack),
            ),
          ],
        ),
      ),
    );
  }
}
