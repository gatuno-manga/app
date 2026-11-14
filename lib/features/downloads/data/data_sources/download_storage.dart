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
  /// The directory under the application support directory, which is also
  /// the native downloader's `BaseDirectory.applicationSupport`.
  static const String rootName = 'downloads';
  static const String manifestName = 'chapter.json';

  final Future<Directory> Function() _supportDirectory;

  static const String _logTag = 'DownloadStorage';

  DownloadStorage(this._supportDirectory);

  /// The chapter directory relative to the application support directory,
  /// as the native downloader wants it.
  static String chapterPath(String bookId, String chapterId) =>
      '$rootName/${_safe(bookId)}/${_safe(chapterId)}';

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
