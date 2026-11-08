import 'package:flutter/material.dart';

import '../atoms/app_icon_segment.dart';

class AppIconSegmentOption<T> {
  final T value;
  final IconData icon;
  final String label;

  const AppIconSegmentOption({
    required this.value,
    required this.icon,
    required this.label,
  });
}

/// Row of [AppIconSegment]s in a pill, one selected (Figma `Seletor cíclico`).
class AppIconSegmentedControl<T> extends StatelessWidget {
  final List<AppIconSegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  const AppIconSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            for (final option in options)
              AppIconSegment(
                icon: option.icon,
                label: option.label,
                selected: option.value == value,
                onTap: option.value == value
                    ? null
                    : () => onChanged(option.value),
              ),
          ],
        ),
      ),
    );
  }
}
