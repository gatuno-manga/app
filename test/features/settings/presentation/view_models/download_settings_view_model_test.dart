import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/domain/entities/download_network.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_network_rules.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/settings/presentation/view_models/download_settings_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

class MockRules extends Mock implements DownloadNetworkRules {}

void main() {
  late MockRules rules;
  late BehaviorSubject<Map<BookType, DownloadNetwork>> stored;
  late DownloadSettingsViewModel viewModel;

  final initial = {
    for (final type in BookType.values) type: DownloadNetwork.unmetered,
  };

  setUpAll(() {
    registerFallbackValue(BookType.manga);
    registerFallbackValue(DownloadNetwork.any);
  });

  setUp(() {
    rules = MockRules();
    stored = BehaviorSubject.seeded(initial);
    when(() => rules.watch()).thenAnswer((_) => stored.stream);
    viewModel = DownloadSettingsViewModel(rules: rules);
  });

  tearDown(() async {
    viewModel.dispose();
    await stored.close();
  });

  test('starts empty, then follows the stored rules', () async {
    expect(DownloadSettingsState.initial().isLoaded, isFalse);

    await pumpEventQueue();
    expect(viewModel.state.isLoaded, isTrue);
    expect(viewModel.state.rules, initial);

    stored.add({...initial, BookType.book: DownloadNetwork.any});
    await pumpEventQueue();
    expect(viewModel.state.rules[BookType.book], DownloadNetwork.any);
  });

  test('setRule saves the rule and reports success', () async {
    when(() => rules.set(any(), any())).thenAnswer((_) async {});

    final saved = await viewModel.setRule(BookType.manga, DownloadNetwork.any);

    expect(saved, isTrue);
    verify(() => rules.set(BookType.manga, DownloadNetwork.any)).called(1);
  });

  test('setRule shows the new rule before the save finishes', () async {
    final save = Completer<void>();
    when(() => rules.set(any(), any())).thenAnswer((_) => save.future);
    await pumpEventQueue();

    final saving = viewModel.setRule(BookType.manga, DownloadNetwork.any);

    expect(viewModel.state.rules[BookType.manga], DownloadNetwork.any);
    save.complete();
    expect(await saving, isTrue);
  });

  test(
    'a saved rule of one type does not undo a pending choice of another',
    () async {
      final mangaSave = Completer<void>();
      final manhwaSave = Completer<void>();
      when(
        () => rules.set(BookType.manga, any()),
      ).thenAnswer((_) => mangaSave.future);
      when(
        () => rules.set(BookType.manhwa, any()),
      ).thenAnswer((_) => manhwaSave.future);
      await pumpEventQueue();

      final manga = viewModel.setRule(BookType.manga, DownloadNetwork.any);
      final manhwa = viewModel.setRule(BookType.manhwa, DownloadNetwork.any);
      // Manga lands and the stored rules report it; Manhwa is still saving.
      stored.add({...initial, BookType.manga: DownloadNetwork.any});
      mangaSave.complete();
      await manga;
      await pumpEventQueue();

      expect(viewModel.state.rules[BookType.manga], DownloadNetwork.any);
      expect(viewModel.state.rules[BookType.manhwa], DownloadNetwork.any);
      manhwaSave.complete();
      expect(await manhwa, isTrue);
      expect(viewModel.state.rules[BookType.manhwa], DownloadNetwork.any);
    },
  );

  test('a failed save reports failure and restores the saved rule', () async {
    when(() => rules.set(any(), any())).thenThrow(Exception('disk full'));
    await pumpEventQueue();

    final saved = await viewModel.setRule(BookType.manga, DownloadNetwork.any);

    expect(saved, isFalse);
    expect(viewModel.state.rules[BookType.manga], DownloadNetwork.unmetered);
  });
}
