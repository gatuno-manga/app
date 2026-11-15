import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_network_rules_storage.dart';
import 'package:gatuno/features/downloads/domain/entities/download_network.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DownloadNetworkRulesStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = DownloadNetworkRulesStorage();
  });

  test('nothing stored reads as null', () async {
    for (final type in BookType.values) {
      expect(await storage.read(type), isNull);
    }
  });

  test('a written rule reads back, one key per type', () async {
    await storage.write(BookType.manhwa, DownloadNetwork.any);
    await storage.write(BookType.book, DownloadNetwork.unmetered);

    expect(await storage.read(BookType.manhwa), DownloadNetwork.any);
    expect(await storage.read(BookType.book), DownloadNetwork.unmetered);
    expect(await storage.read(BookType.manga), isNull);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('download_network_manhwa'), 'any');
    expect(prefs.getString('download_network_book'), 'unmetered');
  });

  test('an unknown stored value reads as null', () async {
    SharedPreferences.setMockInitialValues({
      'download_network_manga': 'satellite',
    });

    expect(await storage.read(BookType.manga), isNull);
  });
}
