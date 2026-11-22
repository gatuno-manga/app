import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/views/library_screen.dart';
import '../../core/router/shell_pushed_routes.dart';

final GlobalKey<NavigatorState> libraryNavigatorKey =
    GlobalKey<NavigatorState>();

final StatefulShellBranch libraryBranch = StatefulShellBranch(
  navigatorKey: libraryNavigatorKey,
  routes: [
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryPage(),
      routes: shellPushedRoutes(bookPath: 'books/:bookId'),
    ),
  ],
);
