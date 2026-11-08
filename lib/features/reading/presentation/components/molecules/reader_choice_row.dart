import 'package:flutter/material.dart';

import 'reader_setting_row.dart';

/// A labelled option of a [ReaderChoiceRow].
class ReaderChoice<T> {
  final T value;
  final String label;

  const ReaderChoice(this.value, this.label);
}

/// A [ReaderSettingRow] whose control is a dropdown over [options].
class ReaderChoiceRow<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final T value;
  final List<ReaderChoice<T>> options;
  final ValueChanged<T> onChanged;

  const ReaderChoiceRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  static const double _maxWidth = 180;

  @override
  Widget build(BuildContext context) {
    return ReaderSettingRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Semantics(
        label: title,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: [
              for (final option in options)
                DropdownMenuItem(
                  value: option.value,
                  child: Text(option.label),
                ),
            ],
            // The closed button shows only the current label, ellipsised,
            // instead of reserving the width of the widest option.
            selectedItemBuilder: (context) => [
              for (final option in options)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (picked) {
              if (picked != null) onChanged(picked);
            },
          ),
        ),
      ),
    );
  }
}
