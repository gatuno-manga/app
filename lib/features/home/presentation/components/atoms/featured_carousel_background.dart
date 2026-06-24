import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../books/domain/entities/book.dart';
import '../../../../../shared/components/atoms/app_image.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/image/image_loading_strategy.dart';

class FeaturedCarouselBackground extends StatelessWidget {
  final Book book;

  const FeaturedCarouselBackground({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = book.metadata?.dominantColor != null
        ? Color(int.parse(book.metadata!.dominantColor!.replaceFirst('#', '0xFF')))
        : theme.colorScheme.surfaceContainerHighest;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image with Blur
        if (book.cover != null)
          AppImage(
            imageUrl: book.cover!.value,
            blurHash: book.metadata?.blurHash,
            fit: BoxFit.cover,
            strategy: sl<ImageLoadingStrategy>(),
          )
        else
          Container(color: bgColor),
          
        // Blur Overlay
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ),
        
        // Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
