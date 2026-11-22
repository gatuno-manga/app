import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/features/books/books_launch_intent.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';

void main() {
  testWidgets('goToBooks gives every call a new nonce', (tester) async {
    final uris = <Uri>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => context.goToBooks(
                  orderBy: 'updatedAt',
                  order: SortOrder.desc,
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/books',
          builder: (context, state) {
            uris.add(state.uri);
            return Scaffold(
              body: TextButton(
                onPressed: () => context.go('/'),
                child: const Text('back'),
              ),
            );
          },
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('back'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 5));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(uris, hasLength(2));
    expect(uris[0].queryParameters['orderBy'], 'updatedAt');
    expect(uris[0].queryParameters['order'], 'desc');
    final first = BooksLaunchIntent.fromUri(uris[0]);
    final second = BooksLaunchIntent.fromUri(uris[1]);
    expect(first, isNotNull);
    expect(second!.nonce, isNot(first!.nonce));
    expect(second.orderBy, 'updatedAt');
  });
}
