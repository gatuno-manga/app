import 'package:flutter/material.dart';

import '../../../core/image/image_loading_strategy.dart';
import '../../../core/image/strategy_image_provider.dart';

/// The user's avatar (`Core/Atom/Avatar/Perfil`): the photo, a generic user
/// icon when there is none, and a bare icon for guests.
class AppAvatar extends StatelessWidget {
  /// Signed-out users see the bare user icon, no circle.
  final bool guest;

  /// Draws a neutral placeholder circle while the profile loads.
  final bool isLoading;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Photo shown over the fallback icon; the icon remains if it is null, empty
  /// or fails to load.
  final String? imageUrl;

  /// Loads [imageUrl] through the app's image pipeline, so avatars honour
  /// trusted certificates and headers like every other image.
  final ImageLoadingStrategy strategy;

  /// When set, the avatar becomes tappable and shows an edit badge.
  final VoidCallback? onEdit;
  final String? editLabel;

  /// Dims the avatar and shows a spinner (e.g. while uploading).
  final bool isBusy;

  const AppAvatar({
    super.key,
    this.guest = false,
    this.isLoading = false,
    this.radius = 50,
    this.backgroundColor,
    this.foregroundColor,
    this.imageUrl,
    required this.strategy,
    this.onEdit,
    this.editLabel,
    this.isBusy = false,
  });

  /// The 2 dp ring is drawn from 48 dp up, like the web `user-menu`.
  static const double _ringMinSize = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = radius * 2;

    if (isLoading) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
      );
    }

    if (guest) {
      return SizedBox(
        width: size,
        height: size,
        child: ExcludeSemantics(
          child: Icon(
            Icons.person_outline,
            size: size,
            color: theme.colorScheme.onSurface,
          ),
        ),
      );
    }

    final url = imageUrl;
    final hasImage = url != null && url.isNotEmpty;
    final ring = size >= _ringMinSize;

    final circle = CircleAvatar(
      radius: ring ? radius - 2 : radius,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      foregroundImage: hasImage
          ? StrategyImageProvider(url: url, strategy: strategy)
          : null,
      onForegroundImageError: hasImage ? (_, _) {} : null,
      // Visual fallback only; the parent (tooltip, tile) carries the meaning.
      child: ExcludeSemantics(
        child: Icon(
          Icons.person,
          size: radius,
          color: theme.colorScheme.primary,
        ),
      ),
    );

    final avatar = ring
        ? DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            ),
            child: circle,
          )
        : circle;

    if (onEdit == null && !isBusy) return avatar;

    return Semantics(
      container: true,
      button: onEdit != null && !isBusy,
      label: editLabel,
      onTap: isBusy ? null : onEdit,
      liveRegion: isBusy,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            avatar,
            if (isBusy)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.scrim.withValues(alpha: 0.5),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            if (onEdit != null && !isBusy)
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(onTap: onEdit),
                ),
              ),
            if (onEdit != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
