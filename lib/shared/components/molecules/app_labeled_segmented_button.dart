import 'package:flutter/material.dart';

/// A label above a single-choice [SegmentedButton]; a null [onChanged]
/// disables both.
class AppLabeledSegmentedButton<T> extends StatelessWidget {
  final String label;
  final List<ButtonSegment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;

  const AppLabeledSegmentedButton({
    super.key,
    required this.label,
    required this.segments,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onChanged != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            // Same 38% onSurface the disabled segments use.
            color: enabled
                ? null
                : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
        SegmentedButton<T>(
          showSelectedIcon: false,
          segments: segments,
          selected: {value},
          onSelectionChanged: enabled ? (s) => onChanged!(s.first) : null,
        ),
      ],
    );
  }
}
