import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/theme.dart';

/// A row of the book sheet (Figma `Lista/Item`): icon, title and subtitle.
/// [danger] paints the title and icon in raw `color/danger`, like the other
/// delete actions.
class BookOptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  /// Null disables the row; [subtitle] then says why.
  final VoidCallback? onTap;
  final bool danger;

  const BookOptionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = theme.extension<GatunoColors>()?.palette ?? lightPalette;
    final enabled = onTap != null;
    final color = !enabled
        ? palette.textMuted
        : danger
        ? scheme.error
        : scheme.onSurface;
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: enabled,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: color,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
