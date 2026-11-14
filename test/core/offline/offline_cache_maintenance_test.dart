import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/covers/cover_store.dart';
import 'package:gatuno/core/database/offline_cache_database.dart';
import 'package:gatuno/core/offline/cache_epoch.dart';
import 'package:gatuno/core/offline/offline_cache_maintenance.dart';
import 'package:mocktail/mocktail.dart';

class MockCoverStore extends Mock implements CoverStore {}

void main() {
  late OfflineCacheDatabase db;
  late MockCoverStore covers;
  late OfflineCacheMaintenance maintenance;
  late CacheEpoch epoch;
  final now = DateTime(2026, 11, 13);

  Future<void> insertBook(String id, DateTime lastAccessedAt) => db
      .into(db.cachedBooks)
      .insert(
        CachedBooksCompanion.insert(
          id: id,
          title: id,
          cachedAt: lastAccessedAt,
          lastAccessedAt: lastAccessedAt,
        ),
      );

  setUp(() {
    db = OfflineCacheDatabase(NativeDatabase.memory());
    covers = MockCoverStore();
    when(() => covers.remove(any())).thenAnswer((_) async {});
    when(() => covers.enforceBudget()).thenAnswer((_) async {});
    when(() => covers.clear()).thenAnswer((_) async {});
    epoch = CacheEpoch();
    maintenance = OfflineCacheMaintenance(db, covers, epoch, now: () => now);
  });

  tearDown(() => db.close());

  test('evicts books untouched for 90 days, except pinned ones', () async {
    final old = now.subtract(const Duration(days: 91));
    await insertBook('old', old);
    await insertBook('pinned', old);
    await insertBook('recent', now.subtract(const Duration(days: 10)));
    await db
        .into(db.cachedChapters)
        .insert(
          CachedChaptersCompanion.insert(
            id: 'c1',
            bookId: 'old',
            chapterIndex: 1,
            cachedAt: old,
          ),
        );
    await db
        .into(db.coverPins)
        .insert(CoverPinsCompanion.insert(bookId: 'pinned', owner: 'download'));

    await maintenance.evictStale();

    final left = await db.select(db.cachedBooks).map((b) => b.id).get();
    expect(left, unorderedEquals(['pinned', 'recent']));
    expect(await db.select(db.cachedChapters).get(), isEmpty);
    verify(() => covers.remove(['old'])).called(1);
    verify(() => covers.enforceBudget()).called(1);
  });

  test('a book refreshed while eviction runs is kept', () async {
    final old = now.subtract(const Duration(days: 91));
    await insertBook('x', old);

    // The refresh is queued while the eviction transaction holds the
    // database, so eviction decides on the old stamp and the refresh then
    // writes the book back; or the refresh lands first and eviction skips it.
    // Either way the book exists afterwards.
    await Future.wait([
      maintenance.evictStale(),
      db
          .into(db.cachedBooks)
          .insertOnConflictUpdate(
            CachedBooksCompanion.insert(
              id: 'x',
              title: 'x',
              cachedAt: now,
              lastAccessedAt: now,
            ),
          ),
    ]);

    expect(await db.select(db.cachedBooks).map((b) => b.id).get(), ['x']);
  });

  test('eviction never throws', () async {
    when(() => covers.enforceBudget()).thenThrow(StateError('disk'));

    await expectLater(maintenance.evictStale(), completes);
  });

  test('clearAll wipes every table and the cover store', () async {
    await insertBook('1', now);

    await maintenance.clearAll();

    expect(await db.select(db.cachedBooks).get(), isEmpty);
    expect(epoch.value, 1);
    verify(() => covers.clear()).called(1);
  });
}
