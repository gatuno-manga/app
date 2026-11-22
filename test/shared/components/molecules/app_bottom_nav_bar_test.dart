import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/molecules/app_bottom_nav_bar.dart';
import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    Locale? locale,
  }) => tester.pumpApp(
    Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: onTap ?? (_) {},
      ),
    ),
    locale: locale,
  );

  group('AppBottomNavBar', () {
    testWidgets('shows Home, Library and Books labels in order', (
      tester,
    ) async {
      await pumpBar(tester);

      final labels = ['Home', 'Library', 'Books'];
      final dx = [for (final l in labels) tester.getCenter(find.text(l)).dx];
      expect(dx, orderedEquals([...dx]..sort()));
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('uses the Portuguese labels', (tester) async {
      await pumpBar(tester, locale: const Locale('pt'));

      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Biblioteca'), findsOneWidget);
      expect(find.text('Livros'), findsOneWidget);
    });

    testWidgets('is 80 dp tall', (tester) async {
      await pumpBar(tester);

      final row = find.descendant(
        of: find.byType(AppBottomNavBar),
        matching: find.byType(SizedBox),
      );
      expect(tester.getSize(row.first).height, AppBottomNavBar.height);
    });

    testWidgets('marks only the current item as selected', (tester) async {
      await pumpBar(tester, currentIndex: 1);

      expect(
        tester.getSemantics(find.text('Library')),
        matchesSemantics(
          label: 'Library',
          isSelected: true,
          hasSelectedState: true,
          isButton: true,
          hasTapAction: true,
          hasEnabledState: false,
        ),
      );
      expect(
        tester.getSemantics(find.text('Home')),
        matchesSemantics(
          label: 'Home',
          isSelected: false,
          hasSelectedState: true,
          isButton: true,
          hasTapAction: true,
          hasEnabledState: false,
        ),
      );
    });

    testWidgets('reports the tapped index', (tester) async {
      int tapped = -1;
      await pumpBar(tester, onTap: (i) => tapped = i);

      await tester.tap(find.text('Books'));
      expect(tapped, 2);
      await tester.tap(find.text('Library'));
      expect(tapped, 1);
    });

    testWidgets('gives the items a Material of their own for tap ink', (
      tester,
    ) async {
      await pumpBar(tester);

      final material = find.ancestor(
        of: find.text('Home'),
        matching: find.byType(Material),
      );
      // The nearest Material sits inside the bar, below its opaque
      // background, so splashes are visible.
      final nearest = tester.element(material.first);
      expect(
        find.descendant(
          of: find.byType(AppBottomNavBar),
          matching: find.byWidget(nearest.widget),
        ),
        findsOneWidget,
      );
    });
  });
}
