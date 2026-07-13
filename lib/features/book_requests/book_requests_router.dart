import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/di/injection.dart';
import 'presentation/view_models/book_requests_list_view_model.dart';
import 'presentation/view_models/create_book_request_view_model.dart';
import 'presentation/views/book_requests_list_page.dart';
import 'presentation/views/create_book_request_page.dart';

final bookRequestsRoutes = [
  GoRoute(
    path: '/requests',
    builder: (context, state) => Provider(
      create: (_) => sl<BookRequestsListViewModel>(),
      child: const BookRequestsListPage(),
    ),
  ),
  GoRoute(
    path: '/requests/create',
    builder: (context, state) => Provider(
      create: (_) => sl<CreateBookRequestViewModel>(),
      child: const CreateBookRequestPage(),
    ),
  ),
];
