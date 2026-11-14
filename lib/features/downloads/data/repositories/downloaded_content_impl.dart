import 'dart:io';

import '../../../../core/logging/logger.dart';
import '../../../books/domain/value_objects/chapter_id.dart';
import '../../../reading/data/models/reading_chapter_model.dart';
import '../../domain/entities/downloaded_chapter.dart';
import '../../domain/repositories/downloaded_content.dart';
import '../data_sources/download_storage.dart';
import '../../domain/use_cases/chapter_file_plan.dart';
import '../data_sources/download_records.dart';

/// [DownloadedContent] read from the download records and storage.
class DownloadedContentImpl implements DownloadedContent {
  final DownloadRecords _records;
  final DownloadStorage _storage;

  static const String _logTag = 'DownloadedContent';

  DownloadedContentImpl(this._records, this._storage);

  @override
  Future<DownloadedChapter?> chapter(ChapterId chapterId) async {
    final row = await _records.doneChapter(chapterId.value);
    if (row == null) return null;

    final manifest = await _storage.readManifest(row.bookId, row.chapterId);
    if (manifest == null) return null;

    final files = await _records.files(row.chapterId);
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
      if (file.relativePath.startsWith('${ChapterFilePlan.pagesDirectory}/')) {
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
