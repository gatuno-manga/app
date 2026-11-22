import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/shared/components/organisms/app_top_bar.dart';
import 'package:gatuno/shared/components/templates/app_top_bar_scaffold.dart';

Widget _app(Widget home, {List<RouteBase> extra = const []}) {
  return MaterialApp.router(
    routerConfig: GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => home),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Home Page')),
        ),
        ...extra,
      ],
    ),
  );
}

Widget _scaffold({AppTopBar? bar, bool longList = true}) => AppTopBarScaffold(
  topBar: bar ?? const AppTopBar(title: 'Title'),
  slivers: [
    SliverList.builder(
      itemCount: longList ? 60 : 1,
      itemBuilder: (_, i) => SizedBox(height: 80, child: Text('row $i')),
    ),
  ],
);

/// The extent of the bar on screen: 0 once it has scrolled away.
double _extent(WidgetTester tester) => tester
    .renderObject<RenderSliver>(find.byType(AppTopBar, skipOffstage: false))
    .geometry!
    .paintExtent;

void main() {
  group('AppTopBar', () {
    testWidgets('shows the title in a 64 dp row without back', (tester) async {
      await tester.pumpWidget(_app(_scaffold()));

      expect(find.text('Title'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(_extent(tester), 64);
    });

    testWidgets('showLogo swaps the title for the logo', (tester) async {
      await tester.pumpWidget(
        _app(_scaffold(bar: const AppTopBar(title: 'Home', showLogo: true))),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('shows the actions', (tester) async {
      await tester.pumpWidget(
        _app(
          _scaffold(
            bar: const AppTopBar(
              title: 'T',
              actions: [Icon(Icons.search), Icon(Icons.add)],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('the back button is hidden unless asked for', (tester) async {
      await tester.pumpWidget(
        _app(_scaffold(bar: const AppTopBar(title: 'T', showBack: true))),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.pumpWidget(
        _app(_scaffold(bar: const AppTopBar(title: 'T', showBack: false))),
      );
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('back goes to /home when there is nothing to pop', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(_scaffold(bar: const AppTopBar(title: 'T', showBack: true))),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('back pops when it can', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('Root')),
          ),
          GoRoute(
            path: '/pushed',
            builder: (_, _) =>
                _scaffold(bar: const AppTopBar(title: 'T', showBack: true)),
          ),
          GoRoute(
            path: '/home',
            builder: (_, _) => const Scaffold(body: Text('Home Page')),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.push('/pushed');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Root'), findsOneWidget);
      expect(find.text('Home Page'), findsNothing);
    });

    testWidgets('onBack overrides the default', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _app(
          _scaffold(
            bar: AppTopBar(
              title: 'T',
              showBack: true,
              onBack: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));

      expect(called, isTrue);
    });

    testWidgets('the search field sits in a 56 dp row under the bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _scaffold(
            bar: const AppTopBar(
              title: 'T',
              searchField: TextField(key: Key('search')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('search')), findsOneWidget);
      expect(_extent(tester), 120);
    });

    testWidgets('hides on scroll down and returns on scroll up', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_scaffold()));
      expect(_extent(tester), 64);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(_extent(tester), 0);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, 100));
      await tester.pumpAndSettle();
      expect(_extent(tester), 64);
    });

    testWidgets('the search row hides with the bar', (tester) async {
      await tester.pumpWidget(
        _app(
          _scaffold(
            bar: const AppTopBar(
              title: 'T',
              searchField: TextField(key: Key('search')),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(_extent(tester), 0);
    });

    testWidgets('a pinned bar stays on screen', (tester) async {
      await tester.pumpWidget(
        _app(_scaffold(bar: const AppTopBar(title: 'Title', pinned: true))),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(_extent(tester), 64);
    });

    testWidgets('a short list never hides the bar', (tester) async {
      await tester.pumpWidget(_app(_scaffold(longList: false)));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(_extent(tester), 64);
    });
  });

  group('AppPinnedBarSliver', () {
    testWidgets('pins the given bar while the list scrolls', (tester) async {
      await tester.pumpWidget(
        _app(
          AppTopBarScaffold(
            topBar: AppPinnedBarSliver(
              bar: AppBar(title: const Text('Selection')),
            ),
            slivers: [
              SliverList.builder(
                itemCount: 60,
                itemBuilder: (_, i) => SizedBox(height: 80, child: Text('$i')),
              ),
            ],
          ),
        ),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Selection').hitTestable(), findsOneWidget);
    });
  });
}
