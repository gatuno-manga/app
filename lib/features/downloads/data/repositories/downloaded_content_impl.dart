import 'dart:io';

import 'package:drift/drift.dart';

import '../../../../core/logging/logger.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../../../reading/data/models/reading_chapter_model.dart';
import '../../domain/entities/download_state.dart';
import '../../domain/entities/downloaded_chapter.dart';
import '../../domain/repositories/downloaded_content.dart';
import '../data_sources/download_storage.dart';
import '../database/downloads_database.dart';

/// [DownloadedContent] read from the downloads database and storage.
class DownloadedContentImpl implements DownloadedContent {
  final DownloadsDatabase _db;
  final DownloadStorage _storage;

  static const String _logTag = 'DownloadedContent';

  DownloadedContentImpl(this._db, this._storage);

  @override
  Future<DownloadedChapter?> chapter(ChapterId chapterId) async {
    final row =
        await (_db.select(_db.downloadChapters)..where(
              (c) =>
                  c.chapterId.equals(chapterId.value) &
                  c.state.equalsValue(DownloadState.done),
            ))
            .getSingleOrNull();
    if (row == null) return null;

    final manifest = await _storage.readManifest(row.bookId, row.chapterId);
    if (manifest == null) return null;

    final files =
        await (_db.select(_db.downloadFiles)
              ..where((f) => f.chapterId.equals(row.chapterId))
              ..orderBy([(f) => OrderingTerm.asc(f.position)]))
            .get();
    final pages = <File>[];
    File? document;
    for (final file in files) {
      final local = await _storage.file(
        row.bookId,
        row.chapterId,
        file.relativePath,
      );
      // Deleted behind the app's back: the reader goes online instead.
      if (!await local.exists()) {
        AppLogger.w('A downloaded file is missing', _logTag);
        return null;
      }
      if (file.relativePath.startsWith('pages/')) {
        pages.add(local);
      } else {
        document = local;
      }
    }

    try {
      return DownloadedChapter(
        chapter: ReadingChapterModel.fromJson(manifest),
        pages: pages,
        document: document,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Unreadable chapter manifest', e, stackTrace, _logTag);
      return null;
    }
  }
}
