import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'domain/entities/book_page_options.dart';

/// What another screen asks Livros to do when it opens it: focus the search
/// field and/or sort the list.
///
/// A new [nonce] marks a new request. The books branch keeps its page alive,
/// so opening the same link twice yields the same URI and would otherwise do
/// nothing the second time.
class BooksLaunchIntent {
  final int nonce;
  final bool focusSearch;
  final String? orderBy;
  final SortOrder? order;

  const BooksLaunchIntent({
    required this.nonce,
    this.focusSearch = false,
    this.orderBy,
    this.order,
  });

  bool get hasSort => orderBy != null && order != null;

  /// Reads `focus`, `orderBy`, `order` and `n`. Without a valid `n` there is
  /// no request (a plain `/books`); a half-given or unknown sort is ignored.
  static BooksLaunchIntent? fromUri(Uri uri) {
    final nonce = int.tryParse(uri.queryParameters['n'] ?? '');
    if (nonce == null) return null;
    final orderBy = uri.queryParameters['orderBy'];
    final order = switch (uri.queryParameters['order']) {
      'asc' => SortOrder.asc,
      'desc' => SortOrder.desc,
      _ => null,
    };
    final sortable = orderBy != null && orderBy.isNotEmpty && order != null;
    return BooksLaunchIntent(
      nonce: nonce,
      focusSearch: uri.queryParameters['focus'] == 'search',
      orderBy: sortable ? orderBy : null,
      order: sortable ? order : null,
    );
  }
}

/// Opens Livros (switching tab, not pushing) with a fresh [BooksLaunchIntent].
extension GoToBooks on BuildContext {
  void goToBooks({
    bool focusSearch = false,
    String? orderBy,
    SortOrder? order,
  }) {
    final query = <String, String>{
      'n': DateTime.now().microsecondsSinceEpoch.toString(),
      if (focusSearch) 'focus': 'search',
      if (orderBy != null && order != null) ...{
        'orderBy': orderBy,
        'order': order.name,
      },
    };
    go(Uri(path: '/books', queryParameters: query).toString());
  }
}
