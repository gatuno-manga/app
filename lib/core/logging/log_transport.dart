import 'dart:developer' as dev;
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Base interface for all log transports.
abstract class LogTransport {
  void log(String level, String message, Object? error, StackTrace? stackTrace, String? name);
}

/// Standard Dart/Flutter developer log transport.
class DevLogTransport implements LogTransport {
  @override
  void log(String level, String message, Object? error, StackTrace? stackTrace, String? name) {
    dev.log(message, name: name ?? level, error: error, stackTrace: stackTrace);
  }
}

/// Console transport that uses [debugPrint] in debug mode only.
class ConsoleTransport implements LogTransport {
  @override
  void log(String level, String message, Object? error, StackTrace? stackTrace, String? name) {
    if (kDebugMode) {
      final formattedMessage = '[${name ?? 'APP'}] $message';
      final consoleMsg = '$level: $formattedMessage${error != null ? '\nError: $error' : ''}';
      debugPrint(consoleMsg);
    }
  }
}

/// Internal data container for messages passed to the logging isolate.
class _LogMessage {
  final String level;
  final String message;
  final String? error;
  final String? stackTrace;
  final String? name;
  final DateTime timestamp;

  _LogMessage({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    this.name,
    required this.timestamp,
  });
}

/// A transport that writes logs to a local file using a background Isolate.
/// 
/// This ensures that file I/O, string formatting, and rotation logic 
/// do not burden the main UI thread.
class FileTransport implements LogTransport {
  final int maxFileSize;
  SendPort? _sendPort;
  Isolate? _isolate;

  FileTransport({this.maxFileSize = 5 * 1024 * 1024}); // Default 5MB

  /// Returns the absolute path to the log file.
  static Future<String> getLogFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/app_logs.txt';
  }

  /// Spawns the background isolate and sets up communication.
  Future<void> init() async {
    try {
      final logFilePath = await getLogFilePath();
      
      final receivePort = ReceivePort();
      _isolate = await Isolate.spawn(
        _loggingIsolate,
        _IsolateConfig(
          sendPort: receivePort.sendPort,
          logFilePath: logFilePath,
          maxFileSize: maxFileSize,
        ),
      );

      _sendPort = await receivePort.first as SendPort;
    } catch (e) {
      debugPrint('Failed to initialize FileTransport background isolate: $e');
    }
  }

  @override
  void log(String level, String message, Object? error, StackTrace? stackTrace, String? name) {
    // Objects must be converted to primitives (String) to cross isolate boundaries safely.
    _sendPort?.send(_LogMessage(
      level: level,
      message: message,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
      name: name,
      timestamp: DateTime.now(),
    ));
  }

  /// Kills the background isolate.
  void dispose() {
    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
  }

  /// The entry point for the background isolate.
  static void _loggingIsolate(_IsolateConfig config) async {
    final receivePort = ReceivePort();
    config.sendPort.send(receivePort.sendPort);

    final logFile = File(config.logFilePath);
    
    await for (final dynamic msg in receivePort) {
      if (msg is _LogMessage) {
        await _handleLog(msg, logFile, config.maxFileSize);
      }
    }
  }

  /// Formats and writes the message to the log file.
  static Future<void> _handleLog(_LogMessage msg, File file, int maxSize) async {
    try {
      await _rotateIfNecessary(file, maxSize);
      
      final formattedMessage = '[${msg.name ?? 'APP'}] ${msg.message}';
      var fileMsg = '${msg.timestamp.toIso8601String()} | ${msg.level} | $formattedMessage\n';
      if (msg.error != null) fileMsg += 'Error: ${msg.error}\n';
      if (msg.stackTrace != null) fileMsg += 'Stack:\n${msg.stackTrace}\n';

      await file.writeAsString(fileMsg, mode: FileMode.append, flush: true);
    } catch (_) {
      // Background isolate, silent failure to avoid recursively causing issues.
    }
  }

  /// Rotates logs if the current file exceeds [maxSize].
  static Future<void> _rotateIfNecessary(File file, int maxSize) async {
    if (await file.exists() && await file.length() > maxSize) {
      try {
        final oldFile = File('${file.path}.old');
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
        await file.rename(oldFile.path);
        await file.create();
      } catch (_) {}
    }
  }
}

/// Configuration passed to the Isolate during spawning.
class _IsolateConfig {
  final SendPort sendPort;
  final String logFilePath;
  final int maxFileSize;

  _IsolateConfig({
    required this.sendPort,
    required this.logFilePath,
    required this.maxFileSize,
  });
}
