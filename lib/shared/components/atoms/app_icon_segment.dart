import 'package:flutter/material.dart';

/// One tile of an icon segmented control (Figma `Seletor cíclico`).
class AppIconSegment extends StatelessWidget {
  static const double size = 36;

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const AppIconSegment({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const radius = BorderRadius.all(Radius.circular(8));

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Material(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: SizedBox.square(
              dimension: size,
              child: Icon(
                icon,
                size: 20,
                color: selected ? colors.onPrimary : colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
