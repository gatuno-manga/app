import 'dart:io';

import '../../../../core/logging/logger.dart';
import '../../../downloads/domain/repositories/downloaded_content.dart';
import '../entities/reading_chapter.dart';
import '../entities/reading_enums.dart';

/// Where a document reader reads a chapter's PDF or EPUB from.
class DocumentSource {
  final DownloadedContent _downloads;

  static const String _logTag = 'DocumentSource';

  DocumentSource(this._downloads);

  /// The downloaded document of [chapter], or `null` to read it from its
  /// `documentPath` on the server.
  Future<File?> resolve(ReadingChapter chapter) async {
    if (chapter.contentType != ContentType.document) return null;
    final path = chapter.documentPath?.value;
    if (path == null || path.isEmpty) return null;
    try {
      return await _downloads.localFile(path);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Could not look up a downloaded document',
        e,
        stackTrace,
        _logTag,
      );
      return null;
    }
  }
}
