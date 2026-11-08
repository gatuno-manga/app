import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/users/domain/value_objects/profile_image_failure.dart';
import 'package:gatuno/features/users/domain/value_objects/profile_image_kind.dart';

void main() {
  group('validateProfileImage', () {
    test('accepts png, jpg, jpeg and webp case-insensitively', () {
      for (final name in ['a.png', 'a.JPG', 'a.jpeg', 'a.WebP']) {
        expect(
          validateProfileImage(
            kind: ProfileImageKind.avatar,
            fileName: name,
            sizeBytes: 100,
          ),
          isNull,
          reason: name,
        );
      }
    });

    test('rejects other types and extensionless names', () {
      for (final name in ['a.gif', 'a.pdf', 'avatar']) {
        expect(
          validateProfileImage(
            kind: ProfileImageKind.avatar,
            fileName: name,
            sizeBytes: 100,
          )?.reason,
          ProfileImageFailureReason.unsupportedType,
          reason: name,
        );
      }
    });

    test('enforces 5 MB for avatar and 10 MB for banner', () {
      const six = 6 * 1024 * 1024;
      expect(
        validateProfileImage(
          kind: ProfileImageKind.avatar,
          fileName: 'a.png',
          sizeBytes: six,
        )?.reason,
        ProfileImageFailureReason.tooLarge,
      );
      expect(
        validateProfileImage(
          kind: ProfileImageKind.banner,
          fileName: 'a.png',
          sizeBytes: six,
        ),
        isNull,
      );
      expect(
        validateProfileImage(
          kind: ProfileImageKind.banner,
          fileName: 'a.png',
          sizeBytes: 10 * 1024 * 1024 + 1,
        )?.reason,
        ProfileImageFailureReason.tooLarge,
      );
    });
  });
}
