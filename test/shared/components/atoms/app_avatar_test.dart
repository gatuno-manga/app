import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/image/image_loading_strategy.dart';
import 'package:gatuno/core/image/strategy_image_provider.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';

import '../../../helpers/test_injection.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

ImageProvider? _foregroundImage(WidgetTester tester) =>
    tester.widget<CircleAvatar>(find.byType(CircleAvatar)).foregroundImage;

void main() {
  group('AppAvatar', () {
    testWidgets('shows initials without an image', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(name: 'maria')));
      expect(find.text('M'), findsOneWidget);
      expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).foregroundImage,
        isNull,
      );
    });

    testWidgets('empty image url falls back to initials', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppAvatar(name: 'maria', imageUrl: '')),
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

    testWidgets('uses the registered strategy when none is given', (
      tester,
    ) async {
      final registered = FailingImageLoadingStrategy();
      await sl.reset();
      sl.registerSingleton<ImageLoadingStrategy>(registered);
      addTearDown(sl.reset);

      await tester.pumpWidget(
        _wrap(
          const AppAvatar(name: 'maria', imageUrl: 'http://localhost/a.png'),
        ),
      );
      expect(
        _foregroundImage(tester),
        isA<StrategyImageProvider>().having(
          (p) => p.strategy,
          'strategy',
          same(registered),
        ),
      );
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

    testWidgets('edit badge appears and taps call onEdit', (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          AppAvatar(name: 'maria', editLabel: 'Change', onEdit: () => taps++),
        ),
      );
      expect(find.byIcon(Icons.edit), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(taps, 1);
      expect(find.bySemanticsLabel(RegExp('Change')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('no edit affordance without onEdit', (tester) async {
      await tester.pumpWidget(_wrap(const AppAvatar(name: 'maria')));
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('busy shows a spinner and blocks editing', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(AppAvatar(name: 'maria', isBusy: true, onEdit: () => taps++)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
      expect(taps, 0);
    });
  });
}
