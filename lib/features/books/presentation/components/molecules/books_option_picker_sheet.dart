import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../../shared/components/atoms/app_loading_indicator.dart';
import '../../../../../shared/components/atoms/app_sheet_title.dart';
import '../../../../../shared/utils/bottom_sheet_utils.dart';
import '../../models/filter_option.dart';

/// Searchable multi-select list used to pick tags or authors.
class BooksOptionPickerSheet extends StatefulWidget {
  final String title;
  final Future<List<FilterOption>> Function() loadOptions;
  final Set<String> initialSelected;

  const BooksOptionPickerSheet({
    super.key,
    required this.title,
    required this.loadOptions,
    required this.initialSelected,
  });

  /// Returns the chosen ids, or null when dismissed without confirming.
  static Future<Set<String>?> show(
    BuildContext context, {
    required String title,
    required Future<List<FilterOption>> Function() loadOptions,
    required Set<String> initialSelected,
  }) {
    return showAppModalBottomSheet<Set<String>>(
      context: context,
      builder: (_) => BooksOptionPickerSheet(
        title: title,
        loadOptions: loadOptions,
        initialSelected: initialSelected,
      ),
    );
  }

  @override
  State<BooksOptionPickerSheet> createState() => _BooksOptionPickerSheetState();
}

class _BooksOptionPickerSheetState extends State<BooksOptionPickerSheet> {
  late Future<List<FilterOption>> _future;
  late final Set<String> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
    _future = widget.loadOptions();
  }

  void _retry() {
    setState(() {
      _future = widget.loadOptions();
    });
  }

  void _toggle(String id, bool value) {
    setState(() => value ? _selected.add(id) : _selected.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Cap against the space left above the keyboard, not the full screen,
    // so the list keeps room while the search field is focused.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final available = MediaQuery.sizeOf(context).height - keyboard;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: available + keyboard),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: keyboard + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: AppSheetTitle(text: widget.title)),
                TextButton(
                  onPressed: () => Navigator.pop(context, {..._selected}),
                  child: Text(l10n.booksFilterDone),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: l10n.booksFilterSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: FutureBuilder<List<FilterOption>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: AppLoadingIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.booksFilterLoadError),
                          TextButton(
                            onPressed: _retry,
                            child: Text(l10n.booksFilterRetry),
                          ),
                        ],
                      ),
                    );
                  }
                  final needle = _query.toLowerCase();
                  final options = (snapshot.data ?? const <FilterOption>[])
                      .where((o) => o.label.toLowerCase().contains(needle))
                      .toList();
                  if (options.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(l10n.booksFilterNoOptions)),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return CheckboxListTile(
                        value: _selected.contains(option.id),
                        title: Text(option.label),
                        onChanged: (v) => _toggle(option.id, v ?? false),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
