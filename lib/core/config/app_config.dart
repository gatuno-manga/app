/// Global configuration for the application.
///
/// This class centralizes all environment-based configuration values,
/// providing sensible defaults and allowing overrides via --dart-define.
class AppConfig {
  /// The default Referer header to be used in network requests.
  ///
  /// Can be overridden using `--dart-define=REFERER=your.domain.com`.
  static const String referer = String.fromEnvironment(
    'REFERER',
    defaultValue: 'https://gatuno.canto.internal/',
  );

  /// Private constructor to prevent instantiation.
  AppConfig._();
}
