import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_palette.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/books/presentation/components/atoms/selection_action_button.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    VoidCallback? onPressed,
    bool danger = false,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Center(
          child: SelectionActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            onPressed: onPressed,
            danger: danger,
          ),
        ),
      ),
    ),
  );

  testWidgets('a screen reader can activate it', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pump(tester, onPressed: () => taps++);

    expect(
      tester.getSemantics(find.byType(SelectionActionButton)),
      matchesSemantics(
        label: 'Delete',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.byType(SelectionActionButton));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('danger paints raw danger; disabled paints muted', (
    tester,
  ) async {
    await pump(tester, onPressed: () {}, danger: true);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.delete_outline)).color,
      AppTheme.darkTheme.colorScheme.error,
    );

    await pump(tester, danger: true);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.delete_outline)).color,
      darkPalette.textMuted,
    );
  });
}
