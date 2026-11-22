import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/features/books/books_router.dart';
import 'package:gatuno/features/home/home_router.dart';
import 'package:gatuno/features/library/library_router.dart';

void main() {
  // The real builders need the whole DI graph, so this checks the route tree
  // the shell is built from: every tab root must carry the pushed screens
  // that `context.pushInTab` resolves to.
  const tabs = {
    'home': (branch: 'homeBranch', bookPath: 'books/:bookId'),
    'library': (branch: 'libraryBranch', bookPath: 'books/:bookId'),
    'books': (branch: 'booksBranch', bookPath: ':bookId'),
  };

  StatefulShellBranch branchOf(String tab) => switch (tab) {
    'home' => homeBranch,
    'library' => libraryBranch,
    _ => booksBranch,
  };

  for (final entry in tabs.entries) {
    test('/${entry.key} mounts settings, requests and book detail', () {
      final root = branchOf(entry.key).routes.single as GoRoute;
      expect(root.path, '/${entry.key}');

      final children = root.routes.cast<GoRoute>();
      final paths = [for (final c in children) c.path];
      expect(
        paths,
        containsAll([
          'settings',
          'requests',
          'requests/create',
          entry.value.bookPath,
        ]),
      );
      // A book id must never shadow the static segments.
      expect(
        paths.indexOf(entry.value.bookPath),
        greaterThan(paths.indexOf('settings')),
      );

      final settings = children.firstWhere((c) => c.path == 'settings');
      expect(
        [for (final c in settings.routes.cast<GoRoute>()) c.path],
        containsAll(['profile', 'download', 'app-lock', 'mfa', 'certificates']),
      );
    });
  }

  test('each tab gets its own route instances', () {
    final home = (homeBranch.routes.single as GoRoute).routes;
    final books = (booksBranch.routes.single as GoRoute).routes;
    expect(home.first, isNot(same(books.first)));
  });
}
