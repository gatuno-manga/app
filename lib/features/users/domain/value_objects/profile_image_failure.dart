import 'profile_image_kind.dart';

enum ProfileImageFailureReason {
  unsupportedType,
  tooLarge,
  forbidden,
  network,
  unknown,
}

/// Why a profile image upload was rejected, before or after reaching the API.
class ProfileImageFailure implements Exception {
  final ProfileImageFailureReason reason;
  final ProfileImageKind kind;

  const ProfileImageFailure(this.reason, this.kind);

  @override
  String toString() => 'ProfileImageFailure($reason, $kind)';
}

const _allowedExtensions = {
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'webp': 'image/webp',
};

/// Mime type for [fileName] when it is an allowed image type, else null.
String? profileImageMimeType(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot < 0) return null;
  return _allowedExtensions[fileName.substring(dot + 1).toLowerCase()];
}

/// Client-side check mirroring the API limits (png/jpeg/webp, per-kind size).
ProfileImageFailure? validateProfileImage({
  required ProfileImageKind kind,
  required String fileName,
  required int sizeBytes,
}) {
  if (profileImageMimeType(fileName) == null) {
    return ProfileImageFailure(ProfileImageFailureReason.unsupportedType, kind);
  }
  if (sizeBytes > kind.maxBytes) {
    return ProfileImageFailure(ProfileImageFailureReason.tooLarge, kind);
  }
  return null;
}
