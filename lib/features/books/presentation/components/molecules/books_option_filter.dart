import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../domain/entities/book_page_options.dart';
import '../../models/filter_option.dart';
import 'books_option_picker_sheet.dart';

/// A filter section: selected options as removable chips, an Add button that
/// opens [BooksOptionPickerSheet], and an and/or logic toggle.
///
/// [loadOptions] must be cheap to call repeatedly (the view model caches it).
class BooksOptionFilter extends StatefulWidget {
  final String title;
  final List<String>? selectedIds;
  final Future<List<FilterOption>> Function() loadOptions;
  final ValueChanged<List<String>> onChanged;

  /// 'and' | 'or' (see `FilterLogic`).
  final String logic;
  final ValueChanged<String> onLogicChanged;

  const BooksOptionFilter({
    super.key,
    required this.title,
    required this.selectedIds,
    required this.loadOptions,
    required this.onChanged,
    required this.logic,
    required this.onLogicChanged,
  });

  @override
  State<BooksOptionFilter> createState() => _BooksOptionFilterState();
}

class _BooksOptionFilterState extends State<BooksOptionFilter> {
  // Requested only once a chip needs a label, so an empty section never
  // fires (or leaks the error of) a request.
  Future<List<FilterOption>>? _options;

  Future<void> _openPicker() async {
    final result = await BooksOptionPickerSheet.show(
      context,
      title: widget.title,
      loadOptions: widget.loadOptions,
      initialSelected: {...?widget.selectedIds},
    );
    if (!mounted) return;
    // The picker may have retried a failed load; re-resolve the chip labels.
    setState(() {
      _options = null;
    });
    if (result != null) widget.onChanged(result.toList());
  }

  Widget _chips(AppLocalizations l10n, List<String> ids) {
    return FutureBuilder<List<FilterOption>>(
      future: _options ??= widget.loadOptions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text(l10n.booksFilterLoadError);
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        final names = {for (final o in data) o.id: o.label};
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final id in ids)
              if (names[id] case final label?)
                InputChip(
                  label: Text(label),
                  onDeleted: () =>
                      widget.onChanged(ids.where((e) => e != id).toList()),
                ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final ids = widget.selectedIds ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(widget.title, style: theme.textTheme.titleMedium),
            ),
            Semantics(
              label: '${l10n.booksFilterAdd} ${widget.title}',
              excludeSemantics: true,
              button: true,
              child: TextButton.icon(
                onPressed: _openPicker,
                icon: const Icon(Icons.add),
                label: Text(l10n.booksFilterAdd),
              ),
            ),
          ],
        ),
        if (ids.isNotEmpty) _chips(l10n, ids),
        if (ids.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: FilterLogic.and,
                  label: Text(l10n.booksFilterLogicAll),
                ),
                ButtonSegment(
                  value: FilterLogic.or,
                  label: Text(l10n.booksFilterLogicAny),
                ),
              ],
              selected: {widget.logic},
              onSelectionChanged: (s) => widget.onLogicChanged(s.first),
            ),
          ),
      ],
    );
  }
}
