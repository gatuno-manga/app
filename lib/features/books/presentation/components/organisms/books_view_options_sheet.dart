import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../shared/components/atoms/app_sheet_title.dart';
import '../../../../../shared/utils/bottom_sheet_utils.dart';
import '../../../domain/entities/books_view_preferences.dart';
import '../../view_models/books_view_model.dart';
import '../molecules/books_columns_picker.dart';
import '../molecules/books_navigation_mode_picker.dart';

/// Columns and navigation mode; every change applies at once.
class BooksViewOptionsSheet extends StatelessWidget {
  final Stream<BooksViewPreferences> preferences;
  final BooksViewPreferences initial;
  final ValueChanged<int> onColumnsChanged;
  final ValueChanged<BooksNavigationMode> onNavigationChanged;

  const BooksViewOptionsSheet({
    super.key,
    required this.preferences,
    required this.initial,
    required this.onColumnsChanged,
    required this.onNavigationChanged,
  });

  static Future<void> show(BuildContext context, BooksViewModel viewModel) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (_) => BooksViewOptionsSheet(
        preferences: viewModel.stateStream.map((s) => s.preferences),
        initial: viewModel.preferences,
        onColumnsChanged: viewModel.setColumns,
        onNavigationChanged: viewModel.setNavigationMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<BooksViewPreferences>(
      stream: preferences,
      initialData: initial,
      builder: (context, snapshot) {
        final preferences = snapshot.data!;
        final hasColumns = preferences.layout != BooksLayoutMode.list;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              AppSheetTitle(text: l10n.booksViewOptions),
              BooksColumnsPicker(
                value: preferences.columns,
                onChanged: hasColumns ? onColumnsChanged : null,
              ),
              BooksNavigationModePicker(
                value: preferences.navigation,
                onChanged: onNavigationChanged,
              ),
            ],
          ),
        );
      },
    );
  }
}
