import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/image/strategy_image_provider.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';

import '../../../helpers/test_injection.dart';

const _strategy = FailingImageLoadingStrategy();

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

ImageProvider? _foregroundImage(WidgetTester tester) =>
    tester.widget<CircleAvatar>(find.byType(CircleAvatar)).foregroundImage;

void main() {
  group('AppAvatar', () {
    testWidgets('shows the user icon without an image', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(strategy: _strategy)));
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(_foregroundImage(tester), isNull);
    });

    testWidgets('empty image url falls back to the icon', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(imageUrl: '', strategy: _strategy)),
      );
      expect(_foregroundImage(tester), isNull);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('loads the image through the given strategy', (tester) async {
      final strategy = FailingImageLoadingStrategy();
      await tester.pumpWidget(
        _wrap(
          AppAvatar(imageUrl: 'http://localhost/a.png', strategy: strategy),
        ),
      );
      expect(
        _foregroundImage(tester),
        isA<StrategyImageProvider>()
            .having((p) => p.url, 'url', 'http://localhost/a.png')
            .having((p) => p.strategy, 'strategy', same(strategy)),
      );
    });

    testWidgets('keeps the icon when the image fails to load', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppAvatar(
            imageUrl: 'http://localhost/a.png',
            strategy: FailingImageLoadingStrategy(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the icon is not announced to screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(const AppAvatar(strategy: _strategy)));

      expect(find.bySemanticsLabel(RegExp('person')), findsNothing);
      semantics.dispose();
    });

    testWidgets('a guest is a bare icon with no circle', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(guest: true, radius: 12, strategy: _strategy)),
      );
      expect(find.byType(CircleAvatar), findsNothing);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(tester.getSize(find.byType(AppAvatar)), const Size(24, 24));
    });

    testWidgets('loading draws a neutral circle', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppAvatar(isLoading: true, radius: 12, strategy: _strategy),
        ),
      );
      expect(find.byType(CircleAvatar), findsNothing);
      expect(find.byIcon(Icons.person), findsNothing);
      expect(tester.getSize(find.byType(AppAvatar)), const Size(24, 24));
    });

    testWidgets('the 2 dp ring starts at 48 dp', (tester) async {
      Finder ring() => find.descendant(
        of: find.byType(AppAvatar),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).border != null,
        ),
      );

      await tester.pumpWidget(
        _wrap(const AppAvatar(radius: 12, strategy: _strategy)),
      );
      expect(ring(), findsNothing);

      await tester.pumpWidget(
        _wrap(const AppAvatar(radius: 24, strategy: _strategy)),
      );
      expect(ring(), findsOneWidget);
      expect(tester.getSize(find.byType(AppAvatar)), const Size(48, 48));
    });

    testWidgets('edit badge appears and taps call onEdit', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          AppAvatar(
            strategy: _strategy,
            editLabel: 'Change',
            onEdit: () => taps++,
          ),
        ),
      );
      expect(find.byIcon(Icons.edit), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(taps, 1);
      expect(find.bySemanticsLabel(RegExp('Change')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('no edit affordance without onEdit', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(strategy: _strategy)));
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('busy shows a spinner and blocks editing', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          AppAvatar(strategy: _strategy, isBusy: true, onEdit: () => taps++),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
      expect(taps, 0);
    });
  });
}
