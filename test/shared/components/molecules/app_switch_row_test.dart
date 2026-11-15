import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/molecules/app_switch_row.dart';

void main() {
  Future<List<bool>> pump(
    WidgetTester tester, {
    bool value = false,
    bool enabled = true,
  }) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSwitchRow(
            icon: Icons.sync,
            title: 'Download new chapters',
            subtitle: 'Automatically downloads new chapters',
            value: value,
            onChanged: enabled ? changes.add : null,
          ),
        ),
      ),
    );
    return changes;
  }

  testWidgets('shows the icon, texts and switch', (tester) async {
    await pump(tester, value: true);

    expect(find.byIcon(Icons.sync), findsOneWidget);
    expect(find.text('Download new chapters'), findsOneWidget);
    expect(find.text('Automatically downloads new chapters'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('a tap anywhere on the row toggles it', (tester) async {
    final changes = await pump(tester);

    await tester.tap(find.text('Automatically downloads new chapters'));
    await tester.tap(find.byType(Switch));

    expect(changes, [true, true]);
  });

  testWidgets('screen readers hear one toggled switch', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, value: true);

    expect(
      tester.getSemantics(find.byType(AppSwitchRow)),
      matchesSemantics(
        label: 'Download new chapters\nAutomatically downloads new chapters',
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('without onChanged it is disabled', (tester) async {
    final changes = await pump(tester, enabled: false);

    await tester.tap(find.text('Download new chapters'));

    expect(changes, isEmpty);
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });
}
