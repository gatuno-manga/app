import '../../../../core/theme/app_theme_choice.dart';
import '../../data/data_sources/settings_local_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/logging/logger.dart';

import 'package:rxdart/rxdart.dart';

class SettingsState {
  final String? apiUrl;
  final bool sensitiveContentEnabled;
  final AppThemeChoice themeChoice;
  final bool isInitialized;

  SettingsState({
    this.apiUrl,
    this.sensitiveContentEnabled = false,
    this.themeChoice = AppThemeChoice.system,
    this.isInitialized = false,
  });

  SettingsState copyWith({
    String? apiUrl,
    bool? sensitiveContentEnabled,
    AppThemeChoice? themeChoice,
    bool? isInitialized,
  }) {
    return SettingsState(
      apiUrl: apiUrl ?? this.apiUrl,
      sensitiveContentEnabled:
          sensitiveContentEnabled ?? this.sensitiveContentEnabled,
      themeChoice: themeChoice ?? this.themeChoice,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class SettingsService {
  final SettingsStorage _storage;
  final DioClient _dioClient;
  static const String _logTag = 'SETTINGS_SERVICE';

  final _stateSubject = BehaviorSubject<SettingsState>.seeded(SettingsState());
  Stream<SettingsState> get settingsStream => _stateSubject.stream;
  SettingsState get state => _stateSubject.value;

  SettingsService(this._storage, this._dioClient);

  String? get apiUrl => state.apiUrl;
  bool get sensitiveContentEnabled => state.sensitiveContentEnabled;
  AppThemeChoice get themeChoice => state.themeChoice;
  bool get isInitialized => state.isInitialized;

  void dispose() {
    _stateSubject.close();
  }

  Future<void> init() async {
    if (isInitialized) return;

    try {
      final apiUrl = await _storage.getApiUrl();
      final sensitiveContentEnabled = await _storage
          .isSensitiveContentEnabled();
      final themeChoice = await _storage.getThemeChoice();

      if (apiUrl != null) {
        _dioClient.updateBaseUrl(apiUrl);
      }

      _stateSubject.add(
        state.copyWith(
          apiUrl: apiUrl,
          sensitiveContentEnabled: sensitiveContentEnabled,
          themeChoice: themeChoice,
          isInitialized: true,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error initializing SettingsService', e, stackTrace, _logTag);
    }
  }

  Future<void> setApiUrl(String url) async {
    try {
      await _storage.setApiUrl(url);
      _dioClient.updateBaseUrl(url);
      _stateSubject.add(state.copyWith(apiUrl: url));
    } catch (e, stackTrace) {
      AppLogger.e('Error setting API URL', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<void> setSensitiveContentEnabled(bool enabled) async {
    try {
      await _storage.setSensitiveContentEnabled(enabled);
      _stateSubject.add(state.copyWith(sensitiveContentEnabled: enabled));
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error setting sensitive content enabled',
        e,
        stackTrace,
        _logTag,
      );
      rethrow;
    }
  }

  Future<void> setThemeChoice(AppThemeChoice choice) async {
    try {
      await _storage.setThemeChoice(choice);
      _stateSubject.add(state.copyWith(themeChoice: choice));
    } catch (e, stackTrace) {
      AppLogger.e('Error setting theme choice', e, stackTrace, _logTag);
      rethrow;
    }
  }

  Future<bool> validateApiUrl(String url) async {
    if (url.isEmpty) return false;

    try {
      // Ensure the URL doesn't have a trailing slash for consistency
      final formattedUrl = url.endsWith('/')
          ? url.substring(0, url.length - 1)
          : url;
      final uri = Uri.tryParse(formattedUrl);
      if (uri == null) return false;

      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        '$formattedUrl/health/liveness',
      );
      return response.statusCode == 200;
    } catch (e, stackTrace) {
      AppLogger.e('Error validating API URL', e, stackTrace, _logTag);
      return false;
    }
  }
}
