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

  // Figma `Leitor/Item de ajuste`: texts take 172 of the 286 dp left after
  // the icon tile, the control 114 (3:2).
  static const int _textFlex = 3;
  static const int _controlFlex = 2;

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
            flex: _textFlex,
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
          // Bounded, so a wide control (a dropdown with long labels at a
          // large text scale) shrinks instead of overflowing; right-aligned
          // so narrow controls (the stepper) share the edge of wide ones.
          Flexible(
            flex: _controlFlex,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }
}
