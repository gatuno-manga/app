import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../../../core/theme/semantic_colors.dart';
import '../../../../../shared/components/atoms/app_icon_button.dart';

/// Height and corner radius of the field (`campo de busca`, radius/lg).
const double searchFieldHeight = 48;
const double searchFieldRadius = 12;

/// The 48 dp search field in its own row under the Livros top bar.
class BooksSearchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(String?) onChanged;

  const BooksSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.focusNode,
  });

  @override
  State<BooksSearchField> createState() => _BooksSearchFieldState();
}

class _BooksSearchFieldState extends State<BooksSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textStyle = theme.textTheme.bodySmall;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(searchFieldRadius),
      borderSide: BorderSide(color: colors.outline),
    );

    // Figma `campo de busca`: 12 dp padding, a 20 dp icon, 8 dp gap, then the
    // text; 48 dp high.
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      textInputAction: TextInputAction.search,
      style: textStyle,
      decoration: InputDecoration(
        hintText: l10n.booksSearchHint,
        hintStyle: textStyle?.copyWith(color: theme.mutedColor),
        isDense: true,
        filled: true,
        fillColor: theme.fieldFillColor,
        constraints: const BoxConstraints.tightFor(height: searchFieldHeight),
        contentPadding: const EdgeInsets.only(right: 12),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(Icons.search, size: 20, color: theme.mutedColor),
        ),
        prefixIconConstraints: const BoxConstraints(),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.primary),
        ),
        suffixIcon: widget.controller.text.isNotEmpty
            ? AppIconButton(
                icon: Icons.clear,
                tooltip: l10n.booksSearchClear,
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged(null);
                },
              )
            : null,
      ),
      onSubmitted: widget.onChanged,
    );
  }
}
