import 'package:flutter/material.dart';
import 'package:gatuno/l10n/app_localizations.dart';

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
    final colors = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.outlineVariant),
    );

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.booksSearchHint,
        isDense: true,
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.primary),
        ),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
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
