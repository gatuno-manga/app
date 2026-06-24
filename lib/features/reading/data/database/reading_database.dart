import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'reading_database.g.dart';

@TableIndex(name: 'idx_reading_progress_recent', columns: {#userId, #timestamp})
class ReadingProgress extends Table {
  TextColumn get userId => text()();
  TextColumn get chapterId => text()();
  TextColumn get bookId => text()();
  IntColumn get pageIndex => integer()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(0))();
  IntColumn get totalPages => integer().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {userId, chapterId};
}

@DriftDatabase(tables: [ReadingProgress])
class ReadingDatabase extends _$ReadingDatabase {
  ReadingDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await transaction(() async {
            await customStatement(
              'ALTER TABLE reading_progress RENAME TO reading_progress_old;',
            );
            await m.createTable(readingProgress);
            await customStatement(
              'INSERT INTO reading_progress '
              '(user_id, chapter_id, book_id, page_index, timestamp, version, total_pages, completed) '
              'SELECT user_id, chapter_id, book_id, page_index, timestamp, version, total_pages, completed '
              'FROM reading_progress_old;',
            );
            await customStatement('DROP TABLE reading_progress_old;');
          });
        }
        if (from < 3) {
          await customStatement('CREATE INDEX idx_reading_progress_recent ON reading_progress(user_id, timestamp);');
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'reading_db');
  }
}
