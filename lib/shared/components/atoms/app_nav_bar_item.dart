import 'package:flutter/material.dart';
import '../../../core/theme/semantic_colors.dart';

/// One destination of the bottom bar: an icon in an indicator pill over a
/// label (Figma `Shell/Item da barra inferior`).
class AppNavBarItem extends StatelessWidget {
  final IconData icon;

  /// Shown instead of [icon] while selected.
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// Drawn over the icon's top right corner (an unread count, for example).
  final Widget? badge;

  const AppNavBarItem({
    super.key,
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.mutedColor;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: InkResponse(
          onTap: onTap,
          highlightShape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // `Ink`, not `Container`: a filled Container would paint over
              // the tap feedback.
              Ink(
                width: 64,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.selectedSubtleColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        isSelected ? (selectedIcon ?? icon) : icon,
                        size: 24,
                        color: color,
                      ),
                      if (badge != null)
                        Positioned(top: -4, right: -6, child: badge!),
                    ],
                  ),
                ),
              ),
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
    );
  }
}
