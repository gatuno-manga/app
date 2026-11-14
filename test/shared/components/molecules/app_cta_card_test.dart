import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/molecules/app_cta_card.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('AppCtaCard', () {
    Widget card({VoidCallback? onPressed, String? note}) => Scaffold(
      body: AppCtaCard(
        title: 'Title',
        description: 'Description',
        buttonText: 'Go',
        buttonIcon: Icons.login,
        onPressed: onPressed,
        note: note,
      ),
    );

    testWidgets('runs the action when enabled', (tester) async {
      var taps = 0;
      await tester.pumpApp(card(onPressed: () => taps++));

      await tester.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('a null action disables the button and shows the note', (
      tester,
    ) async {
      await tester.pumpApp(card(note: 'Back soon'));

      final button = tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text('Go'),
          matching: find.bySubtype<ButtonStyleButton>(),
        ),
      );
      expect(button.enabled, isFalse);
      expect(find.text('Back soon'), findsOneWidget);
    });

    testWidgets('shows no note by default', (tester) async {
      await tester.pumpApp(card(onPressed: () {}));

      expect(find.text('Back soon'), findsNothing);
    });
  });
}
