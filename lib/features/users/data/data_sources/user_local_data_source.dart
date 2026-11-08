import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../core/logging/logger.dart';

/// Persists the last `/me` profile JSON so avatar and banner show instantly
/// on a cold start. The remote profile stays the source of truth.
class UserStorage {
  static const String _logTag = 'UserStorage';
  static const String _fileName = 'user_profile.json';

  final Future<Directory> Function() _directoryProvider;

  UserStorage({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  Future<File> _file() async =>
      File('${(await _directoryProvider()).path}/$_fileName');

  Future<Map<String, dynamic>?> readProfile() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      AppLogger.w('Could not read cached profile: $e', _logTag);
      return null;
    }
  }

  Future<void> writeProfile(Map<String, dynamic> profile) async {
    try {
      await (await _file()).writeAsString(jsonEncode(profile));
    } catch (e) {
      AppLogger.w('Could not cache profile: $e', _logTag);
    }
  }

  Future<void> clear() async {
    try {
      final file = await _file();
      if (await file.exists()) await file.delete();
    } catch (e) {
      AppLogger.w('Could not clear cached profile: $e', _logTag);
    }
  }
}
