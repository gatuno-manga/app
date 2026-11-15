import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme.dart';

/// A settings row with an on/off switch (Figma `Leitor/Item de ajuste`,
/// Controle=Switch): icon tile, title, subtitle and the switch on the
/// trailing edge. Tapping anywhere on the row toggles it, and a screen
/// reader hears the row as one switch.
///
/// Shared copy of the reader's switch row, for sheets outside the reader.
class AppSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;

  /// Null disables the row.
  final ValueChanged<bool>? onChanged;

  const AppSwitchRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = theme.extension<GatunoColors>()?.palette ?? lightPalette;
    final onChanged = this.onChanged;
    return MergeSemantics(
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.hover,
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
                        color: palette.textSecondary,
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
