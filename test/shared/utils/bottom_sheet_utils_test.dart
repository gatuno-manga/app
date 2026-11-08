import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/utils/bottom_sheet_utils.dart';

void main() {
  testWidgets('keeps the sheet content above the bottom system inset', (
    tester,
  ) async {
    // FakeViewPadding is in physical pixels; keep the ratio at 1.
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.padding = const FakeViewPadding(bottom: 40);
    tester.view.viewPadding = const FakeViewPadding(bottom: 40);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppModalBottomSheet<void>(
                context: context,
                builder: (_) => const SizedBox(
                  key: Key('content'),
                  height: 100,
                  width: double.infinity,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final screenBottom =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final contentBottom = tester
        .getRect(find.byKey(const Key('content')))
        .bottom;
    expect(screenBottom - contentBottom, greaterThanOrEqualTo(40));
  });
}
