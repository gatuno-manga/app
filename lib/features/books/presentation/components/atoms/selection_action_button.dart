import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/theme.dart';

/// One action of the selection bar: an icon over its label
/// (`Interface/Legenda`), at least 64 dp high. [danger] paints it in raw
/// `color/danger`, like the other delete actions; disabled is
/// `color/text-muted`.
class SelectionActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  /// Null disables it.
  final VoidCallback? onPressed;
  final bool danger;

  const SelectionActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<GatunoColors>()?.palette ?? lightPalette;
    final color = onPressed == null
        ? palette.textMuted
        : danger
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          // The label is on the node above; the ink well keeps the action.
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
