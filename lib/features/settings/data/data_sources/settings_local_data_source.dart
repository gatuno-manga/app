import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme_choice.dart';

/// Every value here is non-sensitive, so it lives in shared_preferences.
class SettingsStorage {
  static const String _apiUrlKey = 'api_base_url';
  static const String _themeKey = 'theme_choice';
  static const String _sensitiveContentKey = 'sensitive_content_enabled';

  Future<void> setApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, url);
  }

  Future<String?> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiUrlKey);
  }

  Future<void> setSensitiveContentEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sensitiveContentKey, enabled);
  }

  Future<bool> isSensitiveContentEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sensitiveContentKey) ?? false;
  }

  Future<void> setThemeChoice(AppThemeChoice choice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, choice.name);
  }

  Future<AppThemeChoice> getThemeChoice() async {
    final prefs = await SharedPreferences.getInstance();
    return AppThemeChoice.fromName(prefs.getString(_themeKey));
  }
}
