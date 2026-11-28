import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/organisms/app_top_bar.dart';
import 'package:gatuno/shared/components/templates/app_top_bar_scaffold.dart';

const _inset = EdgeInsets.only(top: 40, left: 24, right: 24);

Future<FocusNode> _pump(
  WidgetTester tester, {
  EdgeInsets padding = _inset,
  EdgeInsets viewInsets = EdgeInsets.zero,
}) async {
  final focus = FocusNode();
  addTearDown(focus.dispose);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: padding, viewInsets: viewInsets),
        child: child!,
      ),
      home: AppTopBarScaffold(
        topBar: AppTopBar(
          title: 'Livros',
          searchField: TextField(key: const Key('search'), focusNode: focus),
        ),
        slivers: [
          SliverList.builder(
            itemCount: 60,
            itemBuilder: (_, i) => SizedBox(height: 56, child: Text('row $i')),
          ),
        ],
      ),
    ),
  );
  return focus;
}

double _top(WidgetTester tester, Finder finder) => tester.getTopLeft(finder).dy;

void main() {
  testWidgets('the bar starts below the status bar at rest', (tester) async {
    await _pump(tester);

    expect(_top(tester, find.text('Livros')), greaterThanOrEqualTo(40));
    expect(_top(tester, find.byKey(const Key('search'))), greaterThan(40));
  });

  testWidgets('the bar stays below the status bar when it floats back', (
    tester,
  ) async {
    await _pump(tester);
    final list = find.byType(CustomScrollView);

    await tester.drag(list, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.drag(list, const Offset(0, 60));
    await tester.pumpAndSettle();

    expect(find.text('Livros'), findsOneWidget);
    expect(_top(tester, find.text('Livros')), greaterThanOrEqualTo(40));
  });

  testWidgets('list content is clipped below the status bar', (tester) async {
    await _pump(tester);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    final scrollTop = tester.getTopLeft(find.byType(CustomScrollView)).dy;
    expect(scrollTop, greaterThanOrEqualTo(40));
  });

  testWidgets('focusing the field keeps it below the status bar', (
    tester,
  ) async {
    final focus = await _pump(
      tester,
      viewInsets: const EdgeInsets.only(bottom: 300),
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('search')));
    await tester.pumpAndSettle();

    expect(focus.hasFocus, isTrue);
    expect(_top(tester, find.byKey(const Key('search'))), greaterThan(40));
  });

  testWidgets('landscape side insets are respected', (tester) async {
    await _pump(tester);

    expect(
      tester.getTopLeft(find.byKey(const Key('search'))).dx,
      greaterThanOrEqualTo(24),
    );
  });
}
