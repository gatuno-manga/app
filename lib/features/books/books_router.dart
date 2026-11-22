import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'presentation/views/books_screen.dart';
import 'presentation/view_models/books_view_model.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/shell_pushed_routes.dart';
import '../../../shared/presentation/branch_scroll_scope.dart';

final GlobalKey<NavigatorState> booksNavigatorKey = GlobalKey<NavigatorState>();

final StatefulShellBranch booksBranch = StatefulShellBranch(
  navigatorKey: booksNavigatorKey,
  routes: [
    GoRoute(
      path: '/books',
      builder: (context, state) => TabRootScrollScope(
        child: Provider<BooksViewModel>(
          create: (_) => sl<BooksViewModel>(),
          dispose: (_, vm) => vm.dispose(),
          child: const BooksPage(),
        ),
      ),
      routes: shellPushedRoutes(bookPath: ':bookId'),
    ),
  ],
);
