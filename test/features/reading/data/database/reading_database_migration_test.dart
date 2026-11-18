import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/reading/data/database/reading_database.dart';
import 'package:gatuno/features/reading/data/repositories/pending_read_marks_local_service.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('gatuno-reading-db');
    file = File('${dir.path}/reading.sqlite');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> writeV4Database() async {
    final old = ReadingDatabase(NativeDatabase(file));
    await old.customStatement('DROP TABLE pending_read_marks');
    await old.customStatement('PRAGMA user_version = 4');
    await old
        .into(old.readingProgress)
        .insert(
          ReadingProgressCompanion.insert(
            userId: 'user-1',
            chapterId: 'chapter-1',
            bookId: 'book-1',
            pageIndex: 3,
            timestamp: DateTime(2026, 11, 1),
          ),
        );
    await old.close();
  }

  Future<int> userVersion(ReadingDatabase db) => db
      .customSelect('PRAGMA user_version')
      .map((r) => r.read<int>('user_version'))
      .getSingle();

  test(
    'version 4 gains pending_read_marks and keeps reading_progress',
    () async {
      await writeV4Database();

      final db = ReadingDatabase(NativeDatabase(file));
      addTearDown(db.close);

      final progress = await db.select(db.readingProgress).getSingle();
      expect(progress.userId, 'user-1');
      expect(progress.chapterId, 'chapter-1');
      expect(progress.pageIndex, 3);
      expect(await db.select(db.pendingReadMarks).get(), isEmpty);
      expect(await userVersion(db), 5);

      final service = PendingReadMarksLocalService(db);
      const user = UserId('user-1');
      await service.enqueue(user, const ChapterId('chapter-2'));
      await service.enqueue(user, const ChapterId('chapter-3'));
      // Duplicate enqueue should be idempotent.
      await service.enqueue(user, const ChapterId('chapter-2'));

      expect(await service.getPendingChapterIds(user), [
        const ChapterId('chapter-2'),
        const ChapterId('chapter-3'),
      ]);

      await service.remove(user, const [ChapterId('chapter-2')]);
      expect(await service.getPendingChapterIds(user), [
        const ChapterId('chapter-3'),
      ]);
    },
  );
}
