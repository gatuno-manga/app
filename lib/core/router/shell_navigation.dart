import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

const _tabRoots = {'home', 'library', 'books'};

/// Pushed screens (settings, requests, book detail) are mounted under every
/// tab root so the bottom bar keeps the tab they were opened from. These
/// helpers turn a tab-less path such as `/settings/profile` into the copy
/// under the current tab (`/books/settings/profile` from Livros).
extension ShellNavigation on BuildContext {
  String _currentTab() {
    final segments = GoRouterState.of(this).uri.pathSegments;
    if (segments.isNotEmpty && _tabRoots.contains(segments.first)) {
      return segments.first;
    }
    return 'home';
  }

  /// [path] under the current tab. Book detail is `/books/:id` in the Livros
  /// tab already, so it is returned unchanged there.
  String inTab(String path) {
    final tab = _currentTab();
    if (tab == 'books' && path.startsWith('/books/')) return path;
    return '/$tab$path';
  }

  Future<T?> pushInTab<T extends Object?>(String path) => push<T>(inTab(path));

  void goInTab(String path) => go(inTab(path));
}
