import 'package:flutter/material.dart';
import 'package:optional/optional.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../domain/entities/book_page_options.dart';
import '../../../domain/entities/book_type.dart';
import '../../models/filter_option.dart';
import 'books_option_filter.dart';
import 'books_sensitive_content_filter.dart';
import 'books_types_filter.dart';
import 'books_year_filter.dart';

// The API treats an empty list as no filter; send null instead.
List<String>? _nullIfEmpty(List<String> values) =>
    values.isEmpty ? null : values;

class BooksFilterContent extends StatelessWidget {
  final BookPageOptions options;
  final TextEditingController yearController;
  final void Function(String?) onOperatorChanged;
  final void Function(String) onYearChanged;
  final void Function(TypeBook, bool) onTypeSelected;
  final void Function(String, bool) onSensitiveContentSelected;
  final Future<List<FilterOption>> Function() loadTags;
  final Future<List<FilterOption>> Function() loadAuthors;

  /// Applies a change to the sheet's draft options (tags, exclusions, authors).
  final void Function(BookPageOptions Function(BookPageOptions)) onUpdate;

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
    required this.onUpdate,
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
            onChanged: (ids) => onUpdate(
              (o) => o.copyWith(tags: Optional.ofNullable(_nullIfEmpty(ids))),
            ),
            logic: options.tagsLogic ?? FilterLogic.and,
            onLogicChanged: (v) =>
                onUpdate((o) => o.copyWith(tagsLogic: Optional.of(v))),
          ),
          const SizedBox(height: 16),
          BooksOptionFilter(
            title: l10n.booksExcludedTags,
            selectedIds: options.excludeTags,
            loadOptions: loadTags,
            onChanged: (ids) => onUpdate(
              (o) => o.copyWith(
                excludeTags: Optional.ofNullable(_nullIfEmpty(ids)),
              ),
            ),
            logic: options.excludeTagsLogic ?? FilterLogic.or,
            onLogicChanged: (v) =>
                onUpdate((o) => o.copyWith(excludeTagsLogic: Optional.of(v))),
          ),
          const SizedBox(height: 16),
          BooksOptionFilter(
            title: l10n.booksAuthors,
            selectedIds: options.authors,
            loadOptions: loadAuthors,
            onChanged: (ids) => onUpdate(
              (o) =>
                  o.copyWith(authors: Optional.ofNullable(_nullIfEmpty(ids))),
            ),
            logic: options.authorsLogic ?? FilterLogic.and,
            onLogicChanged: (v) =>
                onUpdate((o) => o.copyWith(authorsLogic: Optional.of(v))),
          ),
        ],
      ),
    );
  }
}
