import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/users/data/data_sources/user_local_data_source.dart';

void main() {
  late Directory dir;
  late UserStorage storage;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('user_storage_test');
    storage = UserStorage(directoryProvider: () async => dir);
  });

  tearDown(() => dir.delete(recursive: true));

  test('readProfile is null when nothing is cached', () async {
    expect(await storage.readProfile(), isNull);
  });

  test('writeProfile then readProfile round-trips', () async {
    await storage.writeProfile({'id': '1', 'profileImageUrl': 'http://x/a'});
    expect(await storage.readProfile(), {
      'id': '1',
      'profileImageUrl': 'http://x/a',
    });
  });

  test('clear removes the cache and tolerates an empty one', () async {
    await storage.writeProfile({'id': '1'});
    await storage.clear();
    expect(await storage.readProfile(), isNull);
    await storage.clear();
  });

  test('a corrupt cache file reads as null', () async {
    await File('${dir.path}/user_profile.json').writeAsString('{not json');
    expect(await storage.readProfile(), isNull);
  });
}
