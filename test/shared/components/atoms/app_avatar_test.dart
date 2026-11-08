import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

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

    testWidgets('uses the network image and keeps initials underneath', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppAvatar(name: 'maria', imageUrl: 'http://localhost/a.png'),
        ),
      );
      expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).foregroundImage,
        isA<NetworkImage>(),
      );
      expect(find.text('M'), findsOneWidget);
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
