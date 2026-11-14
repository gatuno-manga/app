import 'package:gatuno/core/database/offline_cache_database.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/reading/data/database/reading_database.dart';

/// Settles pending async init, closes the reading and offline cache
/// databases that `initDI` builds, then resets `sl`, so nothing opens a file
/// or touches `sl` after the test ended.
Future<void> tearDownInjectionTest() async {
  await Future<void>.delayed(Duration.zero);
  if (sl.isRegistered<ReadingDatabase>()) {
    await sl<ReadingDatabase>().close();
  }
  if (sl.isRegistered<OfflineCacheDatabase>()) {
    await sl<OfflineCacheDatabase>().close();
  }
  await sl.reset();
}
