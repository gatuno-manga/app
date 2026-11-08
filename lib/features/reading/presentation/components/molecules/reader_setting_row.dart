import 'package:flutter/material.dart';

/// One row of the reader settings sheet (Figma `Leitor/Item de ajuste`):
/// icon tile, title, subtitle and a trailing control.
class ReaderSettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const ReaderSettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              // `color/hover`: text at 8%, visible on every reader surface.
              color: scheme.onSurface.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: SizedBox.square(
              dimension: 40,
              child: Icon(icon, color: scheme.onSurface),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelLarge),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Bounded, so a wide control (a dropdown with long labels at a
          // large text scale) shrinks instead of overflowing the row.
          Flexible(child: trailing),
        ],
      ),
    );
  }
}
