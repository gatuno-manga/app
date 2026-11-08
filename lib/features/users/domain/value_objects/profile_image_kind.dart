/// Which profile image slot an upload targets.
enum ProfileImageKind {
  avatar(path: '/users/me/avatar', maxBytes: 5 * 1024 * 1024),
  banner(path: '/users/me/banner', maxBytes: 10 * 1024 * 1024);

  const ProfileImageKind({required this.path, required this.maxBytes});

  /// API route (relative to the base URL) that accepts the upload.
  final String path;

  /// Maximum accepted file size, enforced by the API and checked client-side.
  final int maxBytes;

  int get maxMegabytes => maxBytes ~/ (1024 * 1024);
}
