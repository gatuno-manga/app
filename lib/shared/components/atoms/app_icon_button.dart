import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;
  final bool filled;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return IconButton.filled(
        onPressed: onPressed,
        icon: Icon(icon),
        color: color,
        tooltip: tooltip,
      );
    }
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: color,
      tooltip: tooltip,
    );
  }
}
