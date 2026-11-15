import '../../../reading/domain/entities/reading_chapter.dart';
import '../../../reading/domain/entities/reading_enums.dart';
import '../../exceptions/download_exceptions.dart';

/// One file of a chapter download, placed inside the chapter's directory.
class PlannedFile {
  /// Page order from 1; 0 for a document.
  final int position;

  /// As the server gave it, often relative to the server URL.
  final String url;

  /// Sub-directory of the chapter directory; empty for the chapter root.
  final String directory;
  final String filename;

  const PlannedFile({
    required this.position,
    required this.url,
    required this.directory,
    required this.filename,
  });

  String get relativePath =>
      directory.isEmpty ? filename : '$directory/$filename';
}

/// What a downloaded chapter holds besides its manifest: page images as
/// `pages/0001.<ext>` in page order, or `document.<pdf|epub>`; nothing for
/// text, whose content is inline in the manifest.
abstract final class ChapterFilePlan {
  static const String pagesDirectory = 'pages';

  /// Throws [ChapterUnavailableException] when the chapter has no content to
  /// download yet (still being scraped, for example).
  static List<PlannedFile> of(ReadingChapter chapter) {
    final id = chapter.id.value;
    switch (chapter.contentType) {
      case ContentType.image:
        final pages = [...chapter.pages]
          ..sort((a, b) => a.index.value.compareTo(b.index.value));
        if (pages.isEmpty) throw ChapterUnavailableException(id);
        return [
          for (final (i, page) in pages.indexed)
            PlannedFile(
              position: i + 1,
              url: page.url.value,
              directory: pagesDirectory,
              filename:
                  '${(i + 1).toString().padLeft(4, '0')}.'
                  '${extensionOf(page.url.value)}',
            ),
        ];
      case ContentType.document:
        final path = chapter.documentPath?.value;
        if (path == null || path.isEmpty) throw ChapterUnavailableException(id);
        return [
          PlannedFile(
            position: 0,
            url: path,
            directory: '',
            filename:
                'document.${chapter.documentFormat?.value ?? extensionOf(path)}',
          ),
        ];
      case ContentType.text:
        if (chapter.content == null) throw ChapterUnavailableException(id);
        return const [];
    }
  }

  /// The file extension of [url]'s path, or `img` when it has none usable.
  static String extensionOf(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot < path.lastIndexOf('/')) return 'img';
    final ext = path.substring(dot + 1).toLowerCase();
    return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(ext) ? ext : 'img';
  }
}
