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
    testWidgets('shows initials without an image', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(name: 'maria', strategy: _strategy)),
      );
      expect(find.text('M'), findsOneWidget);
      expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).foregroundImage,
        isNull,
      );
    });

    testWidgets('empty image url falls back to initials', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppAvatar(name: 'maria', imageUrl: '', strategy: _strategy),
        ),
      );
      expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).foregroundImage,
        isNull,
      );
    });

    testWidgets('loads the image through the given strategy', (tester) async {
      final strategy = FailingImageLoadingStrategy();
      await tester.pumpWidget(
        _wrap(
          AppAvatar(
            name: 'maria',
            imageUrl: 'http://localhost/a.png',
            strategy: strategy,
          ),
        ),
      );
      expect(
        _foregroundImage(tester),
        isA<StrategyImageProvider>()
            .having((p) => p.url, 'url', 'http://localhost/a.png')
            .having((p) => p.strategy, 'strategy', same(strategy)),
      );
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('keeps the initials when the image fails to load', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          AppAvatar(
            name: 'maria',
            imageUrl: 'http://localhost/a.png',
            strategy: FailingImageLoadingStrategy(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('M'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('initials are not announced to screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(const AppAvatar(name: 'maria', strategy: _strategy)),
      );

      expect(find.text('M'), findsOneWidget);
      expect(find.bySemanticsLabel('M'), findsNothing);
      semantics.dispose();
    });

    testWidgets('uses the whole first character of the name', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(name: '\u{1F431}gato', strategy: _strategy)),
      );
      expect(find.text('\u{1F431}'), findsOneWidget);
    });

    testWidgets('edit badge appears and taps call onEdit', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          AppAvatar(
            name: 'maria',
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
      await tester.pumpWidget(
        _wrap(const AppAvatar(name: 'maria', strategy: _strategy)),
      );
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('busy shows a spinner and blocks editing', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          AppAvatar(
            name: 'maria',
            strategy: _strategy,
            isBusy: true,
            onEdit: () => taps++,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
      expect(taps, 0);
    });
  });
}
