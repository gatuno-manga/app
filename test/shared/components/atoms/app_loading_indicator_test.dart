import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/atoms/app_loading_indicator.dart';

void main() {
  group('AppLoadingIndicator', () {
    testWidgets('renders CircularProgressIndicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLoadingIndicator.medium())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    for (final (name, widget, dp) in [
      ('small', const AppLoadingIndicator.small(), 20.0),
      ('medium', const AppLoadingIndicator.medium(), 24.0),
      ('large', const AppLoadingIndicator.large(), 40.0),
    ]) {
      testWidgets('$name is $dp dp with a 2 dp stroke', (tester) async {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

        final SizedBox sizedBox = tester.widget(find.byType(SizedBox));
        expect(sizedBox.height, dp);
        expect(sizedBox.width, dp);
        final CircularProgressIndicator indicator = tester.widget(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.strokeWidth, 2);
      });
    }

    testWidgets('respects custom color', (WidgetTester tester) async {
      const Color customColor = Colors.red;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppLoadingIndicator.medium(color: customColor)),
        ),
      );

      final CircularProgressIndicator indicator = tester.widget(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.color, customColor);
    });

    testWidgets('uses theme primary color by default', (
      WidgetTester tester,
    ) async {
      const Color primaryColor = Colors.purple;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          ),
          home: const Scaffold(body: AppLoadingIndicator.medium()),
        ),
      );

      final CircularProgressIndicator indicator = tester.widget(
        find.byType(CircularProgressIndicator),
      );
      // In ThemeData.fromSeed, primary color might be slightly different from seed color,
      // but it will be the one from the theme.
      final theme = Theme.of(tester.element(find.byType(AppLoadingIndicator)));
      expect(indicator.color, theme.colorScheme.primary);
    });
  });
}
