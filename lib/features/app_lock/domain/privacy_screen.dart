/// Port over the platform's app-switcher cover (Android FLAG_SECURE, iOS
/// snapshot cover view).
abstract class PrivacyScreen {
  Future<void> setEnabled(bool enabled);
}
