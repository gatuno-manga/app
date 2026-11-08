import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../models/filter_option.dart';
import 'books_option_picker_sheet.dart';

/// A filter section: selected options as removable chips, an Add button that
/// opens [BooksOptionPickerSheet], and an optional and/or logic toggle.
class BooksOptionFilter extends StatelessWidget {
  final String title;
  final List<String>? selectedIds;
  final Future<List<FilterOption>> Function() loadOptions;
  final ValueChanged<List<String>> onChanged;

  /// 'and' | 'or'. Null hides the toggle.
  final String? logic;
  final ValueChanged<String>? onLogicChanged;

  const BooksOptionFilter({
    super.key,
    required this.title,
    required this.selectedIds,
    required this.loadOptions,
    required this.onChanged,
    this.logic,
    this.onLogicChanged,
  });

  Future<void> _openPicker(BuildContext context) async {
    final result = await BooksOptionPickerSheet.show(
      context,
      title: title,
      loadOptions: loadOptions,
      initialSelected: {...?selectedIds},
    );
    if (result != null) onChanged(result.toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ids = selectedIds ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            TextButton.icon(
              onPressed: () => _openPicker(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.booksFilterAdd),
            ),
          ],
        ),
        if (ids.isNotEmpty)
          FutureBuilder<List<FilterOption>>(
            future: loadOptions(),
            builder: (context, snapshot) {
              final names = {
                for (final o in snapshot.data ?? const <FilterOption>[])
                  o.id: o.label,
              };
              return Wrap(
                spacing: 8,
                children: [
                  for (final id in ids)
                    InputChip(
                      label: Text(names[id] ?? id),
                      onDeleted: () =>
                          onChanged(ids.where((e) => e != id).toList()),
                    ),
                ],
              );
            },
          ),
        if (logic != null && ids.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: 'and',
                  label: Text(l10n.booksFilterLogicAll),
                ),
                ButtonSegment(
                  value: 'or',
                  label: Text(l10n.booksFilterLogicAny),
                ),
              ],
              selected: {logic!},
              onSelectionChanged: (s) => onLogicChanged?.call(s.first),
            ),
          ),
      ],
    );
  }
}
