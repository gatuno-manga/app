import 'package:flutter/material.dart';

/// Round primary badge with a check mark, marking the selected swatch.
class SelectedCheckBadge extends StatelessWidget {
  const SelectedCheckBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
      child: Icon(Icons.check, size: 14, color: scheme.onPrimary),
    );
  }
}
