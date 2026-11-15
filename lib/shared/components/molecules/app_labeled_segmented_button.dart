import 'package:flutter/material.dart';

import '../../../core/theme/semantic_colors.dart';

/// A label above a single-choice [SegmentedButton] (Figma `Seletor
/// segmentado`, styled by the theme's `segmentedButtonTheme`); a null
/// [onChanged] disables both.
class AppLabeledSegmentedButton<T> extends StatelessWidget {
  final String label;

  /// A secondary line under [label], for what the label alone leaves out.
  final String? description;
  final List<ButtonSegment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;

  /// Stretches the segments to the full available width.
  final bool expanded;

  const AppLabeledSegmentedButton({
    super.key,
    required this.label,
    required this.segments,
    required this.value,
    this.description,
    this.onChanged,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onChanged != null;
    // Same 38% onSurface the disabled segments use.
    final disabled = theme.colorScheme.onSurface.withValues(alpha: 0.38);
    final secondary = theme.mutedColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        // Its own node, read right before its segments, not merged into
        // whatever text surrounds the control.
        Semantics(
          container: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: enabled ? null : disabled,
                ),
              ),
              if (description != null)
                Text(
                  description!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: enabled ? secondary : disabled,
                  ),
                ),
            ],
          ),
        ),
        SegmentedButton<T>(
          segments: [for (final segment in segments) _named(segment)],
          selected: {value},
          expandedInsets: expanded ? EdgeInsets.zero : null,
          onSelectionChanged: enabled ? (s) => onChanged!(s.first) : null,
        ),
      ],
    );
  }

  /// Puts [label] in each segment's spoken name, so a screen reader exploring
  /// by touch knows which choice a segment belongs to.
  ButtonSegment<T> _named(ButtonSegment<T> segment) => ButtonSegment<T>(
    value: segment.value,
    icon: segment.icon,
    tooltip: segment.tooltip,
    enabled: segment.enabled,
    label: segment.label == null
        ? null
        : Semantics(label: label, child: segment.label),
  );
}
