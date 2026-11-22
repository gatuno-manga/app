import 'package:go_router/go_router.dart';
import 'features/authentication/auth_router.dart';
import 'features/home/home_router.dart';
import 'features/books/books_router.dart';
import 'features/reading/reading_router.dart';
import 'features/welcome/welcome_router.dart';
import 'features/library/library_router.dart';
import 'shared/presentation/error_screen.dart';
import 'shared/components/organisms/navigation_shell.dart';
import 'core/logging/logger.dart';
import 'core/router/router_keys.dart';

/// The Home-tab copy of a pre-shell top-level `/settings` or `/requests`
/// location, or null for any other location.
String? redirectLegacyShellPath(Uri uri) {
  for (final legacy in const ['/settings', '/requests']) {
    if (uri.path == legacy || uri.path.startsWith('$legacy/')) {
      return '/home$uri';
    }
  }
  return null;
}

GoRouter createAppRouter(String initialLocation) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    // Settings and requests are pushed from a tab and live under each tab
    // root; the old top-level paths (and links that still use them) land on
    // the Home copy.
    redirect: (context, state) => redirectLegacyShellPath(state.uri),
    routes: [
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return NavigationShell(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: buildShellBranches,
        branches: [homeBranch, libraryBranch, booksBranch],
      ),
      ...authRoutes,
      ...welcomeRoutes,
      ...readingRoutes,
    ],
    errorBuilder: (context, state) {
      AppLogger.e('Router Error: ${state.uri}', state.error, null, 'ROUTER');
      return ErrorScreen(error: state.error);
    },
  );
}
