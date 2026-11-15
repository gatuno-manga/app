import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_records.dart';
import 'package:gatuno/features/downloads/data/database/downloads_database.dart';
import 'package:gatuno/features/downloads/domain/use_cases/chapter_file_plan.dart';

void main() {
  late DownloadsDatabase db;
  late DownloadRecords records;

  setUp(() {
    db = DownloadsDatabase(NativeDatabase.memory());
    records = DownloadRecords(db);
  });

  tearDown(() => db.close());

  test('id sets past SQLite\'s variable limit are handled', () async {
    const count = 40000;
    await records.insertChapter('c1', 'b1', DateTime(2026));
    await records.recordPlan('c1', 0, [
      for (var i = 1; i <= count; i++)
        PlannedFile(
          position: i,
          url: 'https://srv/$i',
          directory: 'pages',
          filename: '$i.jpg',
        ),
    ]);
    final ids = {for (var i = 1; i <= count; i++) 't$i'};
    await records.assignTasks({
      for (var i = 1; i <= count; i++) 'c1/$i': 't$i',
    }, queuedOnWifi: false);

    expect(await records.boundTaskIdsAmong(ids), hasLength(count));

    await records.releaseTaskIds(ids);

    expect(await records.boundTaskIdsAmong(ids), isEmpty);
  });
}
