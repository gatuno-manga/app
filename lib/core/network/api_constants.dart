class ApiConstants {
  // Auth Routes
  static const String signIn = '/auth/signin';
  static const String signUp = '/auth/signup';
  static const String authRefresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Books Routes
  static const String books = '/books';

  // Chapters Routes
  static const String chapters = '/chapters';

  // Reading Progress Routes
  static const String readingProgress = '/users/me/reading-progress';
  static const String readingProgressSync = '/users/me/reading-progress/sync';
}
