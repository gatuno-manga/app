import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../books/domain/entities/book.dart';
import '../../../../../shared/components/atoms/app_image.dart';
import '../../../../../shared/components/atoms/app_button.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/image/image_loading_strategy.dart';
import 'package:gatuno/l10n/app_localizations.dart';

class FeaturedCarouselContent extends StatelessWidget {
  final Book book;

  const FeaturedCarouselContent({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Cover
          if (book.cover != null)
            Hero(
              tag: 'book_cover_${book.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 150,
                  child: AppImage(
                    imageUrl: book.cover!,
                    blurHash: book.metadata?.blurHash,
                    fit: BoxFit.cover,
                    strategy: sl<ImageLoadingStrategy>(),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (book.description != null && book.description!.isNotEmpty)
                  Text(
                    book.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 16),
                AppButton(
                  text: l10n.homeFeaturedReadNow,
                  onPressed: () => context.push('/books/${book.id}'),
                ),
                const SizedBox(height: 16), // space for dots
              ],
            ),
          ),
        ],
      ),
    );
  }
}
