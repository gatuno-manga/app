import 'package:flutter/foundation.dart';
import 'log_transport.dart';

class AppLogger {
  static final List<LogTransport> _transports = [];

  /// Initializes the logger with default or custom transports.
  /// 
  /// In typical usage, this should be called once at app startup.
  static Future<void> init({List<LogTransport>? transports}) async {
    _transports.clear();
    if (transports != null) {
      _transports.addAll(transports);
    } else {
      // Default setup: DevTools + Console + background File Isolate
      _transports.add(DevLogTransport());
      _transports.add(ConsoleTransport());
      
      final fileTransport = FileTransport();
      await fileTransport.init();
      _transports.add(fileTransport);
    }
  }

  /// Returns the absolute path to the log file.
  static Future<String> getLogFilePath() => FileTransport.getLogFilePath();

  static void d(String message, [String? name]) {
    _broadcast('DEBUG', message, null, null, name);
  }

  static void i(String message, [String? name]) {
    _broadcast('INFO', message, null, null, name);
  }

  static void w(String message, [String? name]) {
    _broadcast('WARNING', message, null, null, name);
  }

  static void e(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    String? name,
  ]) {
    _broadcast('ERROR', message, error, stackTrace, name);
  }

  static void _broadcast(
    String level,
    String message,
    Object? error,
    StackTrace? stackTrace,
    String? name,
  ) {
    for (final transport in _transports) {
      try {
        transport.log(level, message, error, stackTrace, name);
      } catch (e) {
        // Fallback print if a transport fails
        debugPrint('Logger transport failed: $e');
      }
    }
  }

  /// Redacts an email address if not in debug mode.
  /// user@example.com -> u***@example.com
  static String redactEmail(String email) {
    if (kDebugMode) return email;
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final user = parts[0];
    final domain = parts[1];
    if (user.length <= 1) return '*@$domain';
    return '${user[0]}***@$domain';
  }
}
