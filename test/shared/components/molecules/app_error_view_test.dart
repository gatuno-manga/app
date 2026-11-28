import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/atoms/app_button.dart';
import 'package:gatuno/shared/components/atoms/app_text_button.dart';
import 'package:gatuno/shared/components/molecules/app_error_view.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('AppErrorView', () {
    testWidgets('shows the message in bodyMedium with atom buttons', (
      tester,
    ) async {
      await tester.pumpApp(
        AppErrorView(error: 'Boom', onRetry: () {}, onGoBack: () {}),
      );

      final text = tester.widget<Text>(find.text('Boom'));
      final theme = Theme.of(tester.element(find.text('Boom')));
      expect(text.style, theme.textTheme.bodyMedium);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.byType(AppTextButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onRetry and onGoBack', (tester) async {
      var retries = 0;
      var backs = 0;
      await tester.pumpApp(
        AppErrorView(
          error: 'Boom',
          onRetry: () => retries++,
          onGoBack: () => backs++,
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.tap(find.byType(AppTextButton));

      expect(retries, 1);
      expect(backs, 1);
    });

    testWidgets('hides the back button without onGoBack', (tester) async {
      await tester.pumpApp(AppErrorView(error: 'Boom', onRetry: () {}));

      expect(find.byType(AppButton), findsOneWidget);
      expect(find.byType(AppTextButton), findsNothing);
    });
  });
}
