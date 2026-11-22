import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/di/injection.dart';
import 'presentation/view_models/book_details_view_model.dart';
import 'presentation/view_models/book_downloads_view_model.dart';
import 'presentation/views/book_details_screen.dart';

/// Book detail, mounted under each tab root (see `shellPushedRoutes`).
GoRoute bookDetailsRoute(String path) => GoRoute(
  path: path,
  builder: (context, state) {
    final bookId = state.pathParameters['bookId']!;
    return Provider<BookDetailsViewModel>(
      create: (_) => sl<BookDetailsViewModel>(param1: bookId),
      child: Provider<BookDownloadsViewModel>(
        create: (_) => sl<BookDownloadsViewModel>(param1: bookId),
        dispose: (_, vm) => vm.dispose(),
        child: const BookDetailsPage(),
      ),
    );
  },
);
