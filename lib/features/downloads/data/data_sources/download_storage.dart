import 'dart:convert';
import 'dart:io';

import '../../../../core/logging/logger.dart';

/// Files of downloaded chapters, under `downloads/` in the application
/// support directory (app-controlled storage the OS never clears):
///
/// ```text
/// downloads/<bookId>/<chapterId>/chapter.json
/// downloads/<bookId>/<chapterId>/pages/0001.jpg ...
/// downloads/<bookId>/<chapterId>/document.pdf
/// ```
class DownloadStorage {
  /// The directory under the application support directory that holds
  /// every download.
  static const String rootName = 'downloads';
  static const String manifestName = 'chapter.json';

  final Future<Directory> Function() _supportDirectory;

  static const String _logTag = 'DownloadStorage';

  DownloadStorage(Future<Directory> Function() supportDirectory)
    : _supportDirectory = _once(supportDirectory);

  /// The support directory never moves: ask the platform once, not per file.
  static Future<Directory> Function() _once(
    Future<Directory> Function() resolve,
  ) {
    Future<Directory>? cached;
    return () => cached ??= resolve();
  }

  /// The chapter directory relative to the application support directory,
  /// as the native downloader wants it.
  static String chapterPath(String bookId, String chapterId) =>
      '$rootName/${_safe(bookId)}/${_safe(chapterId)}';

  /// Where the native downloader puts [relativePath] of a chapter: a
  /// directory relative to the application support directory, and a file
  /// name.
  static ({String directory, String filename}) transferTarget(
    String bookId,
    String chapterId,
    String relativePath,
  ) {
    final slash = relativePath.lastIndexOf('/');
    final chapter = chapterPath(bookId, chapterId);
    return (
      directory: slash == -1
          ? chapter
          : '$chapter/${relativePath.substring(0, slash)}',
      filename: relativePath.substring(slash + 1),
    );
  }

  Future<Directory> root() async =>
      Directory('${(await _supportDirectory()).path}/$rootName');

  Future<File> file(
    String bookId,
    String chapterId,
    String relativePath,
  ) async => File(
    '${(await _supportDirectory()).path}/'
    '${chapterPath(bookId, chapterId)}/$relativePath',
  );

  /// Writes the manifest atomically and returns its size in bytes.
  Future<int> writeManifest(
    String bookId,
    String chapterId,
    Map<String, dynamic> manifest,
  ) async {
    final target = await file(bookId, chapterId, manifestName);
    await target.parent.create(recursive: true);
    final bytes = utf8.encode(jsonEncode(manifest));
    final temp = File('${target.path}.part');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(target.path);
    return bytes.length;
  }

  /// The stored manifest, or `null` when it is missing or unreadable.
  Future<Map<String, dynamic>?> readManifest(
    String bookId,
    String chapterId,
  ) async {
    final source = await file(bookId, chapterId, manifestName);
    try {
      if (!await source.exists()) return null;
      final decoded = jsonDecode(await source.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e, stackTrace) {
      AppLogger.e('Unreadable chapter manifest', e, stackTrace, _logTag);
      return null;
    }
  }

  /// Size of a stored file, or `null` when it is not on disk.
  Future<int?> sizeOf(
    String bookId,
    String chapterId,
    String relativePath,
  ) async {
    final target = await file(bookId, chapterId, relativePath);
    return await target.exists() ? target.length() : null;
  }

  Future<void> deleteChapter(String bookId, String chapterId) async {
    final manifest = await file(bookId, chapterId, manifestName);
    await _delete(manifest.parent);
  }

  Future<void> deleteBook(String bookId) async {
    await _delete(Directory('${(await root()).path}/${_safe(bookId)}'));
  }

  Future<void> deleteAll() async => _delete(await root());

  /// Deletes chapter directories, and book directories, that no download
  /// in [keep] (`(bookId, chapterId)`) owns.
  Future<void> sweep(Set<(String, String)> keep) async {
    final rootDir = await root();
    if (!await rootDir.exists()) return;
    final owned = {for (final (b, c) in keep) chapterPath(b, c)};
    final ownedBooks = {for (final path in owned) path.split('/')[1]};
    await for (final book in rootDir.list()) {
      if (book is! Directory) continue;
      final bookName = book.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
      if (!ownedBooks.contains(bookName)) {
        await _delete(book);
        continue;
      }
      await for (final chapter in book.list()) {
        if (chapter is! Directory) continue;
        final name = chapter.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
        if (!owned.contains('$rootName/$bookName/$name')) {
          await _delete(chapter);
        }
      }
    }
  }

  Future<void> _delete(Directory dir) async {
    try {
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (e, stackTrace) {
      AppLogger.e('Could not delete downloads', e, stackTrace, _logTag);
    }
  }

  /// Ids come from the server; keep them from escaping their directory.
  static String _safe(String id) =>
      id.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
}
