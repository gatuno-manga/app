import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/shared/components/atoms/app_outlined_button.dart';

void main() {
  Future<void> pump(WidgetTester tester, AppOutlinedButton button) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: Center(child: button)),
        ),
      );

  Color? labelColor(WidgetTester tester, String text) => tester
      .widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text(text),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      )
      .style
      .color;

  group('AppOutlinedButton', () {
    testWidgets('is 48 dp high and calls onPressed', (tester) async {
      var pressed = 0;
      await pump(
        tester,
        AppOutlinedButton(text: 'Go', onPressed: () => pressed++),
      );

      expect(tester.getSize(find.byType(OutlinedButton)).height, 48);
      await tester.tap(find.text('Go'));
      expect(pressed, 1);
    });

    testWidgets('is disabled without onPressed', (tester) async {
      await pump(tester, const AppOutlinedButton(text: 'Go', onPressed: null));

      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).enabled,
        isFalse,
      );
    });

    testWidgets('tones color the label', (tester) async {
      final scheme = AppTheme.darkTheme.colorScheme;
      await pump(tester, AppOutlinedButton(text: 'Go', onPressed: () {}));
      expect(labelColor(tester, 'Go'), scheme.onSurface);

      await pump(
        tester,
        AppOutlinedButton(
          text: 'Go',
          onPressed: () {},
          tone: AppOutlinedButtonTone.danger,
        ),
      );
      await tester.pumpAndSettle();
      expect(labelColor(tester, 'Go'), scheme.error);
    });

    testWidgets('draws the icon before the label', (tester) async {
      await pump(
        tester,
        AppOutlinedButton(text: 'Copy', onPressed: () {}, icon: Icons.copy),
      );

      expect(find.byIcon(Icons.copy), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('isLoading shows a spinner and ignores taps', (tester) async {
      var pressed = false;
      await pump(
        tester,
        AppOutlinedButton(
          text: 'Go',
          onPressed: () => pressed = true,
          isLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Go'), findsNothing);
      await tester.tap(find.byType(OutlinedButton));
      expect(pressed, isFalse);
    });
  });
}
