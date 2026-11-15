import 'dart:io';

import '../../../reading/domain/entities/reading_chapter.dart';

/// A chapter whose download is done, read back from local storage.
class DownloadedChapter {
  /// Rebuilt from the stored manifest: titles, previous and next, text
  /// content and page metadata.
  final ReadingChapter chapter;

  /// Image chapters: one file per page, in page order. Empty otherwise.
  final List<File> pages;

  /// Document chapters: the PDF or EPUB file.
  final File? document;

  const DownloadedChapter({
    required this.chapter,
    this.pages = const [],
    this.document,
  });
}
