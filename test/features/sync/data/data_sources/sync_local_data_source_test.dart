import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/sync/data/data_sources/sync_local_data_source.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/shared/domain/value_objects/timestamp.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('last sync round-trips per user and can be cleared', () async {
    final source = SyncLocalDataSource();
    const u1 = UserId('u1');
    const u2 = UserId('u2');
    final at = Timestamp(DateTime.utc(2026, 1, 1));

    expect(await source.getLastSyncAt(u1), isNull);
    await source.setLastSyncAt(u1, at);
    expect((await source.getLastSyncAt(u1))?.value, at.value);
    expect(await source.getLastSyncAt(u2), isNull);

    await source.clearLastSyncAt(u1);
    expect(await source.getLastSyncAt(u1), isNull);
  });
}
