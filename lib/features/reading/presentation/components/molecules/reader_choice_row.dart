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
    final theme = Theme.of(context);
    return ReaderSettingRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Semantics(
        label: title,
        child: DropdownButton<T>(
          value: value,
          // Fills the control width the row allows (55% of the row, enough
          // for the longest label at the default text scale); longer
          // labels ellipsise instead of overflowing.
          isExpanded: true,
          // Items grow with their text instead of clipping inside 48 dp.
          itemHeight: null,
          // `Interface/Botão`; the default titleMedium is an unmapped role.
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          iconEnabledColor: theme.colorScheme.onSurfaceVariant,
          underline: const SizedBox.shrink(),
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option.value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(option.label, softWrap: true),
                ),
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
    );
  }
}
