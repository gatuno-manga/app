import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_network_rules_storage.dart';
import 'package:gatuno/features/downloads/data/repositories/stored_download_network_rules.dart';
import 'package:gatuno/features/downloads/domain/entities/download_network.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_network_rules.dart';
import 'package:gatuno/features/downloads/exceptions/download_exceptions.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/settings/presentation/components/molecules/settings_notice.dart';
import 'package:gatuno/features/settings/presentation/view_models/download_settings_view_model.dart';
import 'package:gatuno/features/settings/presentation/views/download_settings_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/pump_app.dart';

class MockRules extends Mock implements DownloadNetworkRules {}

void main() {
  setUpAll(() {
    registerFallbackValue(BookType.manga);
    registerFallbackValue(DownloadNetwork.any);
  });

  Future<DownloadSettingsViewModel> pumpPage(
    WidgetTester tester,
    DownloadNetworkRules rules,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final viewModel = DownloadSettingsViewModel(rules: rules);
    addTearDown(viewModel.dispose);
    await tester.pumpApp(
      Provider<DownloadSettingsViewModel>.value(
        value: viewModel,
        child: const DownloadSettingsPage(),
      ),
      theme: AppTheme.darkTheme,
    );
    await tester.pumpAndSettle();
    return viewModel;
  }

  SegmentedButton<DownloadNetwork> control(WidgetTester tester, int index) =>
      tester
          .widgetList<SegmentedButton<DownloadNetwork>>(
            find.byType(SegmentedButton<DownloadNetwork>),
          )
          .elementAt(index);

  testWidgets('shows every book type on Wi-Fi only by default, and the note', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final rules = StoredDownloadNetworkRules(DownloadNetworkRulesStorage());
    addTearDown(rules.dispose);
    await pumpPage(tester, rules);

    expect(find.text('Downloads'), findsOneWidget);
    for (final label in ['Manga', 'Manhwa', 'Manhua', 'Book', 'Other']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Includes books with no type'), findsOneWidget);
    expect(find.byType(SegmentedButton<DownloadNetwork>), findsNWidgets(5));
    for (var i = 0; i < 5; i++) {
      expect(control(tester, i).selected, {DownloadNetwork.unmetered});
      expect(control(tester, i).onSelectionChanged, isNotNull);
    }
    expect(find.byType(SettingsNotice), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('switch to Wi-Fi only')),
      findsOneWidget,
    );
  });

  testWidgets('a tap saves the rule of that type', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final rules = StoredDownloadNetworkRules(DownloadNetworkRulesStorage());
    addTearDown(rules.dispose);
    await pumpPage(tester, rules);

    // Book is the fourth row.
    await tester.tap(find.text('Wi-Fi and data').at(3));
    await tester.pumpAndSettle();

    expect(control(tester, 3).selected, {DownloadNetwork.any});
    expect(await rules.requirementFor(BookType.book), DownloadNetwork.any);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('download_network_book'), 'any');
  });

  testWidgets('a failed save restores the choice and says so', (tester) async {
    final rules = MockRules();
    final stored = BehaviorSubject.seeded({
      for (final type in BookType.values) type: DownloadNetwork.unmetered,
    });
    addTearDown(stored.close);
    when(rules.watch).thenAnswer((_) => stored.stream);
    when(
      () => rules.set(any(), any()),
    ).thenThrow(NetworkRuleNotSavedException('manga'));
    await pumpPage(tester, rules);

    await tester.tap(find.text('Wi-Fi and data').first);
    await tester.pumpAndSettle();

    expect(
      find.text('Could not save. The previous rule was kept.'),
      findsOneWidget,
    );
    expect(control(tester, 0).selected, {DownloadNetwork.unmetered});
  });

  testWidgets('the choices are disabled until the rules load', (tester) async {
    final rules = MockRules();
    when(rules.watch).thenAnswer((_) => const Stream.empty());
    await pumpPage(tester, rules);

    for (var i = 0; i < 5; i++) {
      expect(control(tester, i).onSelectionChanged, isNull);
    }
  });

  testWidgets('the heading is only the heading for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues({});
    final rules = StoredDownloadNetworkRules(DownloadNetworkRulesStorage());
    addTearDown(rules.dispose);
    await pumpPage(tester, rules);

    final heading = tester.getSemantics(find.text('Download network'));
    expect(heading.flagsCollection.isHeader, isTrue);
    expect(heading.label, 'Download network');
    // The notice and each row's caption are their own nodes.
    expect(
      find.bySemanticsLabel(RegExp(r'^When you switch to Wi-Fi only')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp(r'^Other\s+Includes')), findsOneWidget);
    semantics.dispose();
  });
}
