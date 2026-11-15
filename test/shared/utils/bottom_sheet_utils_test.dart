import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/theme.dart';
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

  Future<void> open(WidgetTester tester, {required bool glass}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppModalBottomSheet<void>(
                context: context,
                glass: glass,
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
  }

  testWidgets('glass: blurred context-menu background, 16 dp corners', (
    tester,
  ) async {
    await open(tester, glass: true);

    final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(sheet.backgroundColor, Colors.transparent);
    expect(
      (sheet.shape! as RoundedRectangleBorder).borderRadius,
      const BorderRadius.vertical(top: Radius.circular(16)),
    );
    expect(find.byType(BackdropFilter), findsOneWidget);
    final background = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.byKey(const Key('content')),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      (background.decoration as BoxDecoration).color,
      darkPalette.contextMenuBackground,
    );
  });

  testWidgets('without glass the sheet keeps its theme and 20 dp corners', (
    tester,
  ) async {
    await open(tester, glass: false);

    final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(sheet.backgroundColor, isNot(Colors.transparent));
    expect(
      (sheet.shape! as RoundedRectangleBorder).borderRadius,
      const BorderRadius.vertical(top: Radius.circular(20)),
    );
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
