import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../domain/entities/book_page_options.dart';
import '../../../domain/entities/book_type.dart';
import '../../models/filter_option.dart';
import 'books_option_filter.dart';
import 'books_sensitive_content_filter.dart';
import 'books_types_filter.dart';
import 'books_year_filter.dart';

class BooksFilterContent extends StatelessWidget {
  final BookPageOptions options;
  final TextEditingController yearController;
  final void Function(String?) onOperatorChanged;
  final void Function(String) onYearChanged;
  final void Function(TypeBook, bool) onTypeSelected;
  final void Function(String, bool) onSensitiveContentSelected;
  final Future<List<FilterOption>> Function() loadTags;
  final Future<List<FilterOption>> Function() loadAuthors;
  final ValueChanged<List<String>> onTagsChanged;
  final ValueChanged<String> onTagsLogicChanged;
  final ValueChanged<List<String>> onExcludeTagsChanged;
  final ValueChanged<String> onExcludeTagsLogicChanged;
  final ValueChanged<List<String>> onAuthorsChanged;
  final ValueChanged<String> onAuthorsLogicChanged;

  const BooksFilterContent({
    super.key,
    required this.options,
    required this.yearController,
    required this.onOperatorChanged,
    required this.onYearChanged,
    required this.onTypeSelected,
    required this.onSensitiveContentSelected,
    required this.loadTags,
    required this.loadAuthors,
    required this.onTagsChanged,
    required this.onTagsLogicChanged,
    required this.onExcludeTagsChanged,
    required this.onExcludeTagsLogicChanged,
    required this.onAuthorsChanged,
    required this.onAuthorsLogicChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BooksYearFilter(
            operator: options.publicationOperator,
            yearController: yearController,
            onOperatorChanged: onOperatorChanged,
            onYearChanged: onYearChanged,
          ),
          const SizedBox(height: 16),
          BooksTypesFilter(
            selectedTypes: options.type,
            onSelected: onTypeSelected,
          ),
          const SizedBox(height: 16),
          BooksSensitiveContentFilter(
            selectedContent: options.sensitiveContent,
            onSelected: onSensitiveContentSelected,
          ),
          const SizedBox(height: 16),
          BooksOptionFilter(
            title: l10n.booksIncludedTags,
            selectedIds: options.tags,
            loadOptions: loadTags,
            onChanged: onTagsChanged,
            logic: options.tagsLogic ?? 'and',
            onLogicChanged: onTagsLogicChanged,
          ),
          const SizedBox(height: 16),
          BooksOptionFilter(
            title: l10n.booksExcludedTags,
            selectedIds: options.excludeTags,
            loadOptions: loadTags,
            onChanged: onExcludeTagsChanged,
            logic: options.excludeTagsLogic ?? 'or',
            onLogicChanged: onExcludeTagsLogicChanged,
          ),
          const SizedBox(height: 16),
          BooksOptionFilter(
            title: l10n.booksAuthors,
            selectedIds: options.authors,
            loadOptions: loadAuthors,
            onChanged: onAuthorsChanged,
            logic: options.authorsLogic ?? 'and',
            onLogicChanged: onAuthorsLogicChanged,
          ),
        ],
      ),
    );
  }
}
