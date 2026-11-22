import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/core/di/injection.dart' as di;
import 'package:gatuno/core/router/shell_navigation.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:gatuno/shared/components/molecules/app_bottom_nav_bar.dart';
import 'package:gatuno/shared/components/organisms/navigation_shell.dart';
import 'package:gatuno/shared/presentation/branch_scroll_scope.dart';
import 'package:gatuno/shared/presentation/view_models/navigation_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockNavigationViewModel extends Mock implements NavigationViewModel {}

/// A tab root with a long list wired to the branch scroll controller, and a
/// button that pushes a detail screen under the same tab.
class _Root extends StatelessWidget {
  final String name;
  const _Root(this.name);

  @override
  Widget build(BuildContext context) {
    return TabRootScrollScope(
      child: Scaffold(
        body: ListView(
          children: [
            Text('$name root'),
            TextButton(
              onPressed: () => context.pushInTab('/detail'),
              child: Text('open detail $name'),
            ),
            for (var i = 0; i < 60; i++)
              SizedBox(height: 60, child: Text('$i')),
          ],
        ),
      ),
    );
  }
}

void main() {
  late MockNavigationViewModel navVm;

  setUp(() async {
    await di.sl.reset();
    navVm = MockNavigationViewModel();
    when(() => navVm.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => navVm.state).thenReturn(NavigationState.initial());
    di.sl.registerFactory<NavigationViewModel>(() => navVm);
  });

  tearDown(() => di.sl.reset());

  List<RouteBase> detail(String prefix) => [
    GoRoute(
      path: 'detail',
      builder: (context, state) => Scaffold(body: Text('detail in $prefix')),
    ),
  ];

  Future<GoRouter> pumpShell(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute(
          builder: (context, state, shell) =>
              NavigationShell(navigationShell: shell),
          navigatorContainerBuilder: buildShellBranches,
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (_, _) => const _Root('home'),
                  routes: detail('home'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/library',
                  builder: (_, _) => const _Root('library'),
                  routes: detail('library'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/books',
                  builder: (_, _) => const _Root('books'),
                  routes: detail('books'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  int selectedIndex(WidgetTester tester) =>
      tester.widget<AppBottomNavBar>(find.byType(AppBottomNavBar)).currentIndex;

  testWidgets('shows the bar with the labels and Home selected', (
    tester,
  ) async {
    await pumpShell(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Books'), findsOneWidget);
    expect(selectedIndex(tester), 0);
  });

  testWidgets('a pushed screen keeps the bar and the opener\'s tab', (
    tester,
  ) async {
    await pumpShell(tester);

    await tester.tap(find.text('Books'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open detail books'));
    await tester.pumpAndSettle();

    expect(find.text('detail in books'), findsOneWidget);
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(selectedIndex(tester), 2);
  });

  testWidgets('re-tapping the active tab pops to its root', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('open detail home'));
    await tester.pumpAndSettle();
    expect(find.text('detail in home'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('detail in home'), findsNothing);
    expect(find.text('home root'), findsOneWidget);
  });

  testWidgets('re-tapping at the root scrolls the list to the top', (
    tester,
  ) async {
    await pumpShell(tester);
    final list = find.byType(Scrollable).first;

    await tester.drag(list, const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(list).position.pixels, greaterThan(0));

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(tester.state<ScrollableState>(list).position.pixels, 0);
  });

  testWidgets('re-tapping another tab does not scroll the Home list', (
    tester,
  ) async {
    await pumpShell(tester);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -800));
    await tester.pumpAndSettle();
    final before = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;

    await tester.tap(find.text('Books'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Books'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    final home = find.byType(Scrollable).first;
    expect(before, greaterThan(0));
    expect(tester.state<ScrollableState>(home).position.pixels, before);
  });

  testWidgets('shellNavigation prefixes the current tab', (tester) async {
    late String path;
    final router = GoRouter(
      initialLocation: '/books/settings',
      routes: [
        GoRoute(
          path: '/books/settings',
          builder: (context, _) {
            path = context.inTab('/settings/profile');
            return const SizedBox();
          },
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(path, '/books/settings/profile');
  });
}
