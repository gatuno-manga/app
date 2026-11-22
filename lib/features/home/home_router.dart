import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'presentation/views/home_screen.dart';
import 'presentation/view_models/home_view_model.dart';
import '../../../core/di/injection.dart';
import '../../../core/router/shell_pushed_routes.dart';
import '../../../shared/presentation/branch_scroll_scope.dart';

final GlobalKey<NavigatorState> homeNavigatorKey = GlobalKey<NavigatorState>();

final StatefulShellBranch homeBranch = StatefulShellBranch(
  navigatorKey: homeNavigatorKey,
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => TabRootScrollScope(
        child: Provider<HomeViewModel>(
          create: (_) => sl<HomeViewModel>(),
          dispose: (_, vm) => vm.dispose(),
          child: const HomePage(),
        ),
      ),
      routes: shellPushedRoutes(bookPath: 'books/:bookId'),
    ),
  ],
);
