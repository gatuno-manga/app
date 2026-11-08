import 'package:flutter/material.dart';

/// One row of the reader settings sheet (Figma `Leitor/Item de ajuste`):
/// icon tile, title, subtitle and a trailing control.
class ReaderSettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  /// Announces [title] changes to screen readers (a title that carries the
  /// current value of a stepper).
  final bool liveTitle;

  const ReaderSettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.liveTitle = false,
  });

  // Controls take at most this share of the row, so the texts keep room
  // while a dropdown still shows its current value whole.
  static const double _maxControlFraction = 0.55;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
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
                  Semantics(
                    liveRegion: liveTitle,
                    child: Text(title, style: theme.textTheme.labelLarge),
                  ),
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
            // Last child, so every control ends on the trailing edge.
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth * _maxControlFraction,
              ),
              child: trailing,
            ),
          ],
        ),
      ),
    );
  }
}
