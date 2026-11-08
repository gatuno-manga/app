import 'package:flutter/material.dart';

import '../atoms/app_icon_button.dart';

/// Minus and plus buttons for a numeric setting. A null callback disables
/// that side (the value is at its bound).
class AppStepper extends StatelessWidget {
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final String decrementTooltip;
  final String incrementTooltip;

  const AppStepper({
    super.key,
    required this.onDecrement,
    required this.onIncrement,
    required this.decrementTooltip,
    required this.incrementTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(
          icon: Icons.remove,
          onPressed: onDecrement,
          tooltip: decrementTooltip,
        ),
        AppIconButton(
          icon: Icons.add,
          onPressed: onIncrement,
          tooltip: incrementTooltip,
        ),
      ],
    );
  }
}
