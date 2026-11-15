import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_network_rules_storage.dart';
import 'package:gatuno/features/downloads/data/repositories/stored_download_network_rules.dart';
import 'package:gatuno/features/downloads/domain/entities/download_network.dart';
import 'package:gatuno/features/downloads/domain/repositories/download_network_rules.dart';
import 'package:gatuno/features/downloads/exceptions/download_exceptions.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRulesStorage extends Mock implements DownloadNetworkRulesStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(BookType.manga);
    registerFallbackValue(DownloadNetwork.any);
  });

  group('with stored preferences', () {
    late StoredDownloadNetworkRules rules;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'download_network_manhua': 'any',
      });
      rules = StoredDownloadNetworkRules(DownloadNetworkRulesStorage());
    });

    tearDown(() => rules.dispose());

    test('a type never set is Wi-Fi only', () async {
      expect(DownloadNetworkRules.defaultRule, DownloadNetwork.unmetered);
      expect(
        await rules.requirementFor(BookType.manga),
        DownloadNetwork.unmetered,
      );
      expect(await rules.requirementFor(BookType.manhua), DownloadNetwork.any);
    });

    test('watch emits every type', () async {
      final all = await rules.watch().first;

      expect(all.keys, unorderedEquals(BookType.values));
      expect(all[BookType.manhua], DownloadNetwork.any);
      expect(all[BookType.other], DownloadNetwork.unmetered);
    });

    test('set saves the rule, updates watch and fires changes', () async {
      final changes = <void>[];
      final sub = rules.changes.listen(changes.add);

      await rules.set(BookType.book, DownloadNetwork.any);
      await pumpEventQueue();

      expect(await rules.requirementFor(BookType.book), DownloadNetwork.any);
      expect((await rules.watch().first)[BookType.book], DownloadNetwork.any);
      expect(changes, hasLength(1));

      final reopened = StoredDownloadNetworkRules(
        DownloadNetworkRulesStorage(),
      );
      expect(await reopened.requirementFor(BookType.book), DownloadNetwork.any);
      await reopened.dispose();
      await sub.cancel();
    });

    test('setting the current rule fires nothing', () async {
      final changes = <void>[];
      final sub = rules.changes.listen(changes.add);

      await rules.set(BookType.manga, DownloadNetwork.unmetered);
      await rules.set(BookType.manhua, DownloadNetwork.any);
      await pumpEventQueue();

      expect(changes, isEmpty);
      await sub.cancel();
    });

    test('quick changes apply in order', () async {
      await Future.wait([
        rules.set(BookType.manga, DownloadNetwork.any),
        rules.set(BookType.manga, DownloadNetwork.unmetered),
        rules.set(BookType.manga, DownloadNetwork.any),
      ]);

      expect(await rules.requirementFor(BookType.manga), DownloadNetwork.any);
    });
  });

  group('when storage fails', () {
    late MockRulesStorage storage;
    late StoredDownloadNetworkRules rules;

    setUp(() {
      storage = MockRulesStorage();
      when(() => storage.read(any())).thenAnswer((_) async => null);
      rules = StoredDownloadNetworkRules(storage);
    });

    tearDown(() => rules.dispose());

    test('a failed write keeps the rule and fires nothing', () async {
      when(
        () => storage.write(any(), any()),
      ).thenThrow(NetworkRuleNotSavedException('manga'));
      final changes = <void>[];
      final sub = rules.changes.listen(changes.add);

      await expectLater(
        rules.set(BookType.manga, DownloadNetwork.any),
        throwsA(isA<NetworkRuleNotSavedException>()),
      );
      await pumpEventQueue();

      expect(
        await rules.requirementFor(BookType.manga),
        DownloadNetwork.unmetered,
      );
      expect(changes, isEmpty);
      await sub.cancel();
    });

    test('a failed write does not block the next one', () async {
      var calls = 0;
      when(() => storage.write(any(), any())).thenAnswer((_) async {
        if (calls++ == 0) throw NetworkRuleNotSavedException('manga');
      });

      await expectLater(
        rules.set(BookType.manga, DownloadNetwork.any),
        throwsA(isA<NetworkRuleNotSavedException>()),
      );
      await rules.set(BookType.manga, DownloadNetwork.any);

      expect(await rules.requirementFor(BookType.manga), DownloadNetwork.any);
    });

    test('an unreadable rule falls back to Wi-Fi only', () async {
      when(
        () => storage.read(BookType.manhwa),
      ).thenThrow(Exception('disk error'));
      when(
        () => storage.read(BookType.book),
      ).thenAnswer((_) async => DownloadNetwork.any);

      expect(
        await rules.requirementFor(BookType.manhwa),
        DownloadNetwork.unmetered,
      );
      expect(await rules.requirementFor(BookType.book), DownloadNetwork.any);
    });
  });
}
