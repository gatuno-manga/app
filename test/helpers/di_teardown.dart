import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/reading/data/database/reading_database.dart';

/// Settles pending async init, closes the reading database that
/// `initReadingDI` builds, then resets `sl`, so nothing opens a file or
/// touches `sl` after the test ended.
Future<void> tearDownInjectionTest() async {
  await Future<void>.delayed(Duration.zero);
  if (sl.isRegistered<ReadingDatabase>()) {
    await sl<ReadingDatabase>().close();
  }
  await sl.reset();
}
