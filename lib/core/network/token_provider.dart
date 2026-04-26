abstract class TokenProvider {
  /// Gets a valid token. If the current token is expired, it will wait for a refresh.
  /// If the token is near expiry, it will trigger a background refresh.
  /// Use [forceRefresh] to bypass expiration checks and force a refresh.
  Future<String?> getValidToken({bool forceRefresh = false});

  /// Explicitly trigger a token refresh.
  Future<void> performTokenRefresh();
}
