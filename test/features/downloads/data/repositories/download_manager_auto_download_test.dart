/// DownloadManager with automatic download turned on for a book.
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/data/data_sources/download_records.dart';
import 'package:gatuno/features/downloads/data/repositories/auto_download_preferences_impl.dart';
import 'package:gatuno/features/downloads/data/repositories/download_manager.dart';
import 'package:gatuno/features/downloads/domain/entities/download_scope.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/download_test_doubles.dart';
import '../../helpers/download_manager_harness.dart';

void main() {
  setUpDownloadManager();

  late AutoDownloadPreferencesImpl prefs;

  setUp(() => prefs = AutoDownloadPreferencesImpl(DownloadRecords(db)));

  test(
    'deleting the last chapter keeps the setting, but frees the book',
    () async {
      manifest('t1', textManifest('t1'));
      await prefs.enable(testBook);
      await manager.enqueueChapters(testBook, const [ChapterId('t1')]);
      await untilState('t1', DownloadState.done);

      await manager.delete(const DownloadScope.book(testBook));

      expect(await manager.watchBook(testBook).first, isNull);
      expect(Directory('${dir.path}/downloads/book-1').existsSync(), isFalse);
      verify(
        () => covers.unpin('book-1', DownloadManager.coverPinOwner),
      ).called(1);
      expect(await prefs.watch(testBook).first, isNotNull);
    },
  );

  test('a book with only the setting is not a download', () async {
    await prefs.enable(testBook);

    expect(await manager.watchBook(testBook).first, isNull);
    expect(await manager.watchAll().first, isEmpty);
    expect((await manager.totals()).chapters, 0);
  });

  test('a server change clears the setting', () async {
    await prefs.enable(testBook);

    await manager.clearAll();

    expect(await prefs.enabledBooks(), isEmpty);
  });
}
