import 'package:flutter/material.dart';

/// Profile banner image with a placeholder fallback. Pass [onEdit] to show an
/// edit button (own profile only).
class UserBanner extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final VoidCallback? onEdit;
  final String? editLabel;
  final bool isBusy;

  const UserBanner({
    super.key,
    this.imageUrl,
    this.height = 140,
    this.onEdit,
    this.editLabel,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = imageUrl;
    final placeholder = ColoredBox(color: scheme.surfaceContainerHighest);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null && url.isNotEmpty)
              Image.network(
                url,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => placeholder,
              )
            else
              placeholder,
            if (isBusy)
              ColoredBox(
                color: scheme.scrim.withValues(alpha: 0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
            if (onEdit != null && !isBusy)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  onPressed: onEdit,
                  tooltip: editLabel,
                  icon: const Icon(Icons.edit),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
