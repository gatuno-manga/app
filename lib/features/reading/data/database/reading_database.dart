import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'reading_database.g.dart';

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
  int get schemaVersion => 2;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'reading_db');
  }
}
