import 'package:flutter/material.dart';

/// A settings row with an on/off switch (Figma
/// `Core/Molecule/Interruptor/Item`): optional icon tile, title, optional
/// subtitle and the switch on the trailing edge. Tapping anywhere on the row
/// toggles it, and a screen reader hears the row as one switch.
///
/// The row has no horizontal padding; the caller pads it like its neighbours.
/// Colors come from the [ColorScheme] so the row is legible on every surface,
/// including the reader's own themes.
class AppSwitchRow extends StatelessWidget {
  /// Null drops the icon tile (Figma Icon=No).
  final IconData? icon;
  final String title;

  /// Null hides the description (Figma Show description off).
  final String? subtitle;
  final bool value;

  /// Null disables the row.
  final ValueChanged<bool>? onChanged;

  const AppSwitchRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onChanged = this.onChanged;
    final icon = this.icon;
    final subtitle = this.subtitle;
    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    // `color/hover`: text at 8%, visible on every surface.
                    color: scheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: SizedBox.square(
                    dimension: 40,
                    child: Icon(icon, color: scheme.onSurface),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.labelLarge),
                    if (subtitle != null)
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
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
