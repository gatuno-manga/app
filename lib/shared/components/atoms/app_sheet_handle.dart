import 'package:flutter/material.dart';

/// Grabber of a bottom sheet, drawn inside the sheet content so it follows
/// the content's theme.
class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          // Material 3 drag handle: onSurfaceVariant at 40%.
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
      ),
    );
  }
}
