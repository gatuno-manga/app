import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

import '../logging/logger.dart';
import '../storage/background_readable_storage.dart';

/// Provides a stable, non-rotating per-device UUID for the `x-device-id` header.
///
/// Reads from [BackgroundReadableStorage] first so normal restarts and
/// background checks never touch platform channels. When storage is empty
/// (first launch, or Android after uninstall/clear data), queries the native
/// platform identifier (`ANDROID_ID` on Android, `IDFV` on iOS) and hashes it
/// with SHA-256 into a deterministic RFC 4122 UUID, falling back to a random
/// UUID v4 when unavailable.
class DeviceIdService {
  static const String _logTag = 'DeviceIdService';
  static const String _storageKey = 'device_id';
  static const MethodChannel _channel = MethodChannel(
    'com.gatuno.app/device_id',
  );

  final BackgroundReadableStorage _store;
  final Future<String?> Function() _getPlatformId;
  final Random _random;

  String? _cachedId;
  Future<String>? _inFlight;

  DeviceIdService({
    BackgroundReadableStorage? store,
    Future<String?> Function()? getPlatformId,
    Random? random,
  }) : _store =
           store ?? BackgroundReadableStorage(owns: (k) => k == _storageKey),
       _getPlatformId = getPlatformId ?? _defaultPlatformId,
       _random = random ?? Random.secure();

  static Future<String?> _defaultPlatformId() async {
    try {
      return await _channel.invokeMethod<String>('getDeviceId');
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e, stackTrace) {
      AppLogger.w(
        'Platform device ID lookup failed; falling back to random UUID: $e',
        _logTag,
      );
      AppLogger.d(stackTrace.toString(), _logTag);
      return null;
    }
  }

  /// Preloads the device ID into memory during app/background initialization.
  Future<void> init() async {
    await getDeviceId();
  }

  /// Returns the cached or persisted device UUID, creating it once if absent.
  Future<String> getDeviceId() {
    final cached = _cachedId;
    if (cached != null) return Future<String>.value(cached);
    return _inFlight ??= _loadOrCreate().whenComplete(() {
      _inFlight = null;
    });
  }

  Future<String> _loadOrCreate() async {
    try {
      await _store.migrate();
      final existing = await _store.storage.read(key: _storageKey);
      if (existing != null && existing.trim().isNotEmpty) {
        final normalized = existing.trim();
        _cachedId = normalized;
        return normalized;
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to read device ID from storage',
        e,
        stackTrace,
        _logTag,
      );
    }

    final platformId = await _safeGetPlatformId();
    final generated = (platformId != null && platformId.trim().isNotEmpty)
        ? deriveUuidFromPlatformId(platformId.trim())
        : generateRandomUuidV4(_random);

    _cachedId = generated;
    try {
      await _store.storage.write(key: _storageKey, value: generated);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to persist device ID', e, stackTrace, _logTag);
    }
    return generated;
  }

  Future<String?> _safeGetPlatformId() async {
    try {
      return await _getPlatformId();
    } catch (e, stackTrace) {
      AppLogger.e('Platform device ID provider threw', e, stackTrace, _logTag);
      return null;
    }
  }

  /// Derives a deterministic RFC 4122 UUID (version 5-shaped) from [platformId].
  static String deriveUuidFromPlatformId(String platformId) {
    final digest = sha256.convert(utf8.encode('gatuno:device:$platformId'));
    final bytes = List<int>.from(digest.bytes.take(16));
    bytes[6] = (bytes[6] & 0x0f) | 0x50;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    return _formatUuid(bytes);
  }

  /// Generates a random RFC 4122 version 4 UUID using [random].
  static String generateRandomUuidV4(Random random) {
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    return _formatUuid(bytes);
  }

  static String _formatUuid(List<int> bytes) {
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
