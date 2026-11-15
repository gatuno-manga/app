import 'dart:io';

import '../../../books/domain/value_objects/chapter_id.dart';
import '../entities/downloaded_chapter.dart';

/// Read side of downloads, for the readers.
abstract class DownloadedContent {
  /// The stored chapter, or `null` unless its download is done.
  Future<DownloadedChapter?> chapter(ChapterId chapterId);

  /// The stored copy of a page image or document, by the URL the chapter
  /// gives for it (relative to the server or absolute). `null` unless its
  /// chapter is done and the file is on disk.
  Future<File?> localFile(String url);
}
