import 'reading_chapter.dart';

/// A chapter ready for a reader, and where it came from.
class OpenedChapter {
  final ReadingChapter chapter;

  /// Read from the device's downloads rather than the server.
  final bool isDownloaded;

  const OpenedChapter({required this.chapter, required this.isDownloaded});
}
