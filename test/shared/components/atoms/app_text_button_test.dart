import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/shared/components/atoms/app_text_button.dart';

void main() {
  Future<void> pump(WidgetTester tester, AppTextButton button) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: Center(child: button)),
        ),
      );

  Color labelColor(WidgetTester tester, String text) => tester
      .widget<RichText>(
        find.descendant(of: find.text(text), matching: find.byType(RichText)),
      )
      .text
      .style!
      .color!;

  group('AppTextButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = 0;
      await pump(tester, AppTextButton(text: 'Go', onPressed: () => pressed++));

      await tester.tap(find.text('Go'));

      expect(pressed, 1);
    });

    testWidgets('is disabled without onPressed', (tester) async {
      await pump(tester, const AppTextButton(text: 'Go', onPressed: null));

      expect(
        tester.widget<TextButton>(find.byType(TextButton)).enabled,
        isFalse,
      );
    });

    testWidgets('each tone paints its theme color', (tester) async {
      final scheme = AppTheme.lightTheme.colorScheme;
      final cases = {
        AppTextButtonTone.neutral: scheme.onSurface,
        AppTextButtonTone.primary: scheme.primary,
        AppTextButtonTone.danger: scheme.error,
      };
      for (final MapEntry(key: tone, value: color) in cases.entries) {
        await pump(
          tester,
          AppTextButton(text: tone.name, onPressed: () {}, tone: tone),
        );
        // Material animates the label style between tones.
        await tester.pumpAndSettle();
        expect(labelColor(tester, tone.name), color, reason: tone.name);
      }
    });

    testWidgets('keeps a 48dp tap target and a label-wide width', (
      tester,
    ) async {
      await pump(tester, AppTextButton(text: 'OK', onPressed: () {}));

      final size = tester.getSize(find.byType(TextButton));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, lessThan(88)); // Not Material's 64dp+ minimum box.
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('an icon leads the label in the tone color', (tester) async {
      var taps = 0;
      await pump(
        tester,
        AppTextButton(
          text: 'Select',
          icon: Icons.check_circle_outline,
          tone: AppTextButtonTone.primary,
          onPressed: () => taps++,
        ),
      );
      await tester.pumpAndSettle();

      final icon = find.byIcon(Icons.check_circle_outline);
      expect(icon, findsOneWidget);
      expect(
        tester.getCenter(icon).dx,
        lessThan(tester.getCenter(find.text('Select')).dx),
      );
      expect(
        IconTheme.of(tester.element(icon)).color,
        AppTheme.lightTheme.colorScheme.primary,
      );
      expect(
        tester.getSize(find.byType(AppTextButton)).height,
        greaterThanOrEqualTo(48),
      );

      await tester.tap(find.text('Select'));
      expect(taps, 1);
    });
  });
}
