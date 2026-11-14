import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/atoms/app_button.dart';
import 'package:gatuno/shared/components/molecules/app_offline_empty_view.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('AppOfflineEmptyView', () {
    testWidgets('explains the content is not saved and retries', (
      tester,
    ) async {
      var retries = 0;
      await tester.pumpApp(
        Scaffold(body: AppOfflineEmptyView(onRetry: () => retries++)),
      );

      expect(find.text("You're offline"), findsOneWidget);
      expect(
        find.textContaining("This isn't saved on this device yet"),
        findsOneWidget,
      );

      await tester.tap(find.byType(AppButton));
      expect(retries, 1);
    });

    testWidgets('shows progress while retrying', (tester) async {
      await tester.pumpApp(
        Scaffold(body: AppOfflineEmptyView(onRetry: () {}, isRetrying: true)),
      );

      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isLoading,
        isTrue,
      );
    });

    testWidgets('the title is a heading', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(Scaffold(body: AppOfflineEmptyView(onRetry: () {})));

      expect(
        tester.getSemantics(find.text("You're offline")),
        matchesSemantics(label: "You're offline", isHeader: true),
      );
      handle.dispose();
    });
  });
}
