import 'package:go_router/go_router.dart';
import 'presentation/views/reading_screen.dart';

final readingRoutes = [
  GoRoute(
    path: '/chapters/:id',
    name: 'reading',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      return ReadingScreen(chapterId: id);
    },
  ),
  GoRoute(
    path: '/chapters/:id/page/:index',
    name: 'reading-page',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      final indexStr = state.pathParameters['index']!;
      final index = int.tryParse(indexStr) ?? 0;
      return ReadingScreen(chapterId: id, initialPage: index);
    },
  ),
];
