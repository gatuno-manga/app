class ApiConstants {
  // Health: URL validation and the connectivity probe
  static const String healthLiveness = '/health/liveness';

  // Auth Routes
  static const String signIn = '/auth/signin';
  static const String signUp = '/auth/signup';
  static const String authRefresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // MFA Routes
  static const String mfaVerifyLogin = '/auth/mfa/verify-login';
  static const String mfaStatus = '/auth/mfa/status';
  static const String mfaTotpSetup = '/auth/mfa/totp/setup';
  static const String mfaTotpVerifySetup = '/auth/mfa/totp/verify-setup';
  static const String mfaTotpDisable = '/auth/mfa/totp/disable';

  // Books Routes
  static const String books = '/books';

  // Books filter lookups
  static const String tags = '/tags';
  static const String authors = '/authors';

  // Chapters Routes
  static const String chapters = '/chapters';

  // Reading Progress Routes
  static const String readingProgress = '/users/me/reading-progress';
  static const String readingProgressSync = '/users/me/reading-progress/sync';

  // Sync Route
  static const String syncUnified = '/sync';

  // Object Storage
  static const String s3Prefix = '/s3/';
}
