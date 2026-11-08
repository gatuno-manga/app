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

  @override
  Widget build(BuildContext context) {
    return ReaderSettingRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: DropdownButton<T>(
        value: value,
        underline: const SizedBox.shrink(),
        items: [
          for (final option in options)
            DropdownMenuItem(value: option.value, child: Text(option.label)),
        ],
        onChanged: (picked) {
          if (picked != null) onChanged(picked);
        },
      ),
    );
  }
}
