import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Image to show over the initials; the initials remain if it is null,
  /// empty or fails to load.
  final String? imageUrl;

  /// When set, the avatar becomes tappable and shows an edit badge.
  final VoidCallback? onEdit;
  final String? editLabel;

  /// Dims the avatar and shows a spinner (e.g. while uploading).
  final bool isBusy;

  const AppAvatar({
    super.key,
    this.name,
    this.radius = 50,
    this.backgroundColor,
    this.foregroundColor,
    this.imageUrl,
    this.onEdit,
    this.editLabel,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    if (name == null) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
      );
    }

    final initials = name!.isNotEmpty ? name![0].toUpperCase() : '?';
    final theme = Theme.of(context);
    final url = imageUrl;
    final hasImage = url != null && url.isNotEmpty;

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundImage: hasImage ? NetworkImage(url) : null,
      onForegroundImageError: hasImage ? (_, _) {} : null,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: foregroundColor ?? theme.colorScheme.onPrimary,
        ),
      ),
    );

    if (onEdit == null && !isBusy) return avatar;

    final size = radius * 2;
    return Semantics(
      button: onEdit != null,
      label: editLabel,
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
