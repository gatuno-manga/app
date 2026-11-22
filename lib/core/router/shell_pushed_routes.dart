import 'package:go_router/go_router.dart';

import '../../features/book_requests/book_requests_router.dart';
import '../../features/books/book_details_route.dart';
import '../../features/settings/settings_router.dart';

/// Screens pushed from a tab root. Every branch mounts its own copy (a
/// [GoRoute] instance cannot have two parents), so the bar stays visible with
/// the opener's tab selected.
///
/// [bookPath] is `:bookId` under Livros (`/books/:bookId`) and
/// `books/:bookId` under the other tabs. Static segments come before it so a
/// book id never shadows them.
List<RouteBase> shellPushedRoutes({required String bookPath}) => [
  ...settingsRoutes(),
  ...bookRequestsRoutes(),
  bookDetailsRoute(bookPath),
];
