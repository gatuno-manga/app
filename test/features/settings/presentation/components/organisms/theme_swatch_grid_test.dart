import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/app_theme_choice.dart';
import 'package:gatuno/features/settings/presentation/components/organisms/theme_swatch_grid.dart';
import 'package:gatuno/l10n/app_localizations.dart';

Widget _host(AppThemeChoice selected, ValueChanged<AppThemeChoice> onSelected) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: ThemeSwatchGrid(selected: selected, onSelected: onSelected),
    ),
  );
}

void main() {
  testWidgets('renders one card per choice and marks the selected one', (
    tester,
  ) async {
    await tester.pumpWidget(_host(AppThemeChoice.dracula, (_) {}));

    for (final choice in AppThemeChoice.values) {
      expect(
        find.byKey(ValueKey('theme-swatch-${choice.name}')),
        findsOneWidget,
      );
    }
    for (final label in [
      'System',
      'Light',
      'Dark',
      'True dark',
      'Dracula',
      'Slate',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('tapping a card reports the choice', (tester) async {
    AppThemeChoice? picked;
    await tester.pumpWidget(_host(AppThemeChoice.system, (c) => picked = c));

    await tester.tap(find.byKey(const ValueKey('theme-swatch-slate')));
    expect(picked, AppThemeChoice.slate);
  });

  testWidgets('exposes selected state to semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(AppThemeChoice.slate, (_) {}));

    expect(
      tester.getSemantics(find.byKey(const ValueKey('theme-swatch-slate'))),
      isSemantics(
        label: 'Slate',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });
}
