import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/data/data_sources/user_local_data_source.dart';
import 'package:gatuno/features/users/data/data_sources/user_remote_data_source.dart';
import 'package:gatuno/features/users/domain/value_objects/profile_image_failure.dart';
import 'package:gatuno/features/users/domain/value_objects/profile_image_kind.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUserStorage extends Mock implements UserStorage {}

class MockRemote extends Mock implements UserRemoteDataSource {}

/// A `/me` payload for account [id] with an avatar and no banner.
Map<String, dynamic> profile(String id) => {
  'id': id,
  'email': 'a@b.c',
  'roles': ['user'],
  'profileImageUrl': 'http://x/$id.webp',
  'profileBannerUrl': '',
};

void main() {
  setUpAll(() {
    registerFallbackValue(ProfileImageKind.avatar);
    registerFallbackValue(Uint8List(0));
  });

  late UserService userService;
  late MockAuthService mockAuthService;
  late MockUserStorage mockStorage;

  setUp(() {
    mockAuthService = MockAuthService();
    mockStorage = MockUserStorage();
    when(() => mockStorage.readProfile()).thenAnswer((_) async => null);
    when(() => mockStorage.clear()).thenAnswer((_) async {});
    when(
      () => mockAuthService.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    userService = UserService(
      mockAuthService,
      remote: MockRemote(),
      storage: mockStorage,
    );
  });

  String createMockToken(Map<String, dynamic> payload) {
    const header = '{"alg":"HS256","typ":"JWT"}';
    final headerEncoded = base64Url
        .encode(utf8.encode(header))
        .replaceAll('=', '');
    final payloadEncoded = base64Url
        .encode(utf8.encode(json.encode(payload)))
        .replaceAll('=', '');
    return '$headerEncoded.$payloadEncoded.signature';
  }

  group('UserService', () {
    test('getCurrentUser should return UserModel for valid token', () async {
      final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      final payload = {
        'sub': '123',
        'email': 'test@example.com',
        'roles': ['user'],
        'exp': exp,
      };
      final token = createMockToken(payload);

      when(() => mockAuthService.getToken()).thenAnswer((_) async => token);

      final user = await userService.getCurrentUser();

      expect(user.isGuest, isFalse);
      expect(user.id, equals(const UserId('123')));
      expect(user.email, equals(const UserEmail('test@example.com')));
    });

    test(
      'getCurrentUser should return UserModel.guest for expired token',
      () async {
        final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600;
        final payload = {
          'sub': '123',
          'email': 'test@example.com',
          'roles': ['user'],
          'exp': exp,
        };
        final token = createMockToken(payload);

        when(() => mockAuthService.getToken()).thenAnswer((_) async => token);

        final user = await userService.getCurrentUser();

        expect(user, equals(UserModel.guest));
      },
    );

    test(
      'getCurrentUser should return UserModel.guest for null token',
      () async {
        when(() => mockAuthService.getToken()).thenAnswer((_) async => null);

        final user = await userService.getCurrentUser();

        expect(user, equals(UserModel.guest));
        verify(() => mockStorage.clear()).called(1);
      },
    );

    test('logout should call authService.logout', () async {
      when(() => mockAuthService.logout()).thenAnswer((_) async {});

      await userService.logout();

      verify(() => mockAuthService.logout()).called(1);
    });
  });
  group('profile images', () {
    late MockUserStorage storage;
    late MockRemote remote;
    late UserService service;

    String validToken(String sub) => createMockToken({
      'sub': sub,
      'email': 'a@b.c',
      'roles': ['user'],
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
    });

    setUp(() {
      storage = MockUserStorage();
      remote = MockRemote();
      service = UserService(mockAuthService, remote: remote, storage: storage);
      when(() => storage.writeProfile(any())).thenAnswer((_) async {});
      when(() => storage.clear()).thenAnswer((_) async {});
    });

    test(
      'getCurrentUser uses the cached profile of the same account',
      () async {
        when(
          () => mockAuthService.getToken(),
        ).thenAnswer((_) async => validToken('1'));
        when(() => storage.readProfile()).thenAnswer((_) async => profile('1'));

        final user = await service.getCurrentUser();

        expect(user.profilePictureUrl, 'http://x/1.webp');
        expect(user.profileBannerUrl, isNull);
      },
    );

    test('getCurrentUser ignores a cache from another account', () async {
      when(
        () => mockAuthService.getToken(),
      ).thenAnswer((_) async => validToken('1'));
      when(() => storage.readProfile()).thenAnswer((_) async => profile('2'));

      final user = await service.getCurrentUser();

      expect(user.id, const UserId('1'));
      expect(user.profilePictureUrl, isNull);
    });

    test('refreshProfile caches and returns /me', () async {
      when(() => remote.fetchMe()).thenAnswer((_) async => profile('1'));

      final user = await service.refreshProfile();

      expect(user?.profilePictureUrl, 'http://x/1.webp');
      verify(() => storage.writeProfile(profile('1'))).called(1);
    });

    test('refreshProfile returns null when the request fails', () async {
      when(() => remote.fetchMe()).thenThrow(Exception('offline'));
      expect(await service.refreshProfile(), isNull);
      verifyNever(() => storage.writeProfile(any()));
    });

    test(
      'uploadProfileImage rejects invalid files without calling the API',
      () async {
        await expectLater(
          service.uploadProfileImage(
            kind: ProfileImageKind.avatar,
            fileName: 'a.gif',
            bytes: Uint8List(1),
          ),
          throwsA(isA<ProfileImageFailure>()),
        );
        verifyNever(
          () => remote.uploadImage(
            kind: any(named: 'kind'),
            bytes: any(named: 'bytes'),
            fileName: any(named: 'fileName'),
          ),
        );
      },
    );

    test('uploadProfileImage caches and returns the updated user', () async {
      when(
        () => remote.uploadImage(
          kind: any(named: 'kind'),
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
        ),
      ).thenAnswer((_) async => profile('1'));

      final user = await service.uploadProfileImage(
        kind: ProfileImageKind.avatar,
        fileName: 'a.png',
        bytes: Uint8List(1),
      );

      expect(user.profilePictureUrl, 'http://x/1.webp');
      verify(() => storage.writeProfile(profile('1'))).called(1);
    });

    test('logout clears the cached profile', () async {
      when(() => mockAuthService.logout()).thenAnswer((_) async {});
      await service.logout();
      verify(() => storage.clear()).called(1);
      verify(() => mockAuthService.logout()).called(1);
    });
  });

  group('profile stream', () {
    late MockUserStorage storage;
    late MockRemote remote;
    late UserService service;

    setUp(() {
      storage = MockUserStorage();
      remote = MockRemote();
      when(() => storage.writeProfile(any())).thenAnswer((_) async {});
      when(() => storage.clear()).thenAnswer((_) async {});
      service = UserService(mockAuthService, remote: remote, storage: storage);
    });

    tearDown(() => service.dispose());

    test('starts as guest', () async {
      expect(await service.profileStream.first, same(UserModel.guest));
    });

    test('emits the profile stored by refreshProfile', () async {
      when(() => remote.fetchMe()).thenAnswer((_) async => profile('1'));
      final next = service.profileStream.skip(1).first;

      await service.refreshProfile();

      expect((await next).profilePictureUrl, 'http://x/1.webp');
    });

    test('emits the profile stored by uploadProfileImage', () async {
      when(
        () => remote.uploadImage(
          kind: any(named: 'kind'),
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
        ),
      ).thenAnswer((_) async => profile('1'));
      final next = service.profileStream.skip(1).first;

      await service.uploadProfileImage(
        kind: ProfileImageKind.avatar,
        fileName: 'a.png',
        bytes: Uint8List(1),
      );

      expect((await next).id, const UserId('1'));
    });

    test('emits guest before the backend logout round-trip', () async {
      final backendLogout = Completer<void>();
      when(
        () => mockAuthService.logout(),
      ).thenAnswer((_) => backendLogout.future);
      final next = service.profileStream.skip(1).first;

      final logout = service.logout();

      expect(await next, same(UserModel.guest));
      backendLogout.complete();
      await logout;
    });

    test('does not emit when the refresh fails', () async {
      when(() => remote.fetchMe()).thenThrow(Exception('offline'));
      final events = <UserModel>[];
      final sub = service.profileStream.skip(1).listen(events.add);

      await service.refreshProfile();
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
      await sub.cancel();
    });
  });

  group('auth-driven refresh', () {
    late MockUserStorage storage;
    late MockRemote remote;
    late StreamController<AuthState> auth;
    late UserService service;

    String validToken(String sub) => createMockToken({
      'sub': sub,
      'email': 'a@b.c',
      'roles': ['user'],
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
    });

    setUp(() {
      storage = MockUserStorage();
      remote = MockRemote();
      auth = StreamController<AuthState>.broadcast();
      when(
        () => mockAuthService.authStateStream,
      ).thenAnswer((_) => auth.stream);
      when(
        () => mockAuthService.getToken(),
      ).thenAnswer((_) async => validToken('1'));
      when(() => storage.readProfile()).thenAnswer((_) async => null);
      when(() => storage.writeProfile(any())).thenAnswer((_) async {});
      when(() => remote.fetchMe()).thenAnswer((_) async => profile('1'));
      service = UserService(mockAuthService, remote: remote, storage: storage);
    });

    tearDown(() async {
      service.dispose();
      await auth.close();
    });

    test('does not listen to auth state until init', () {
      verifyNever(() => mockAuthService.authStateStream);

      service.init();

      verify(() => mockAuthService.authStateStream).called(1);
    });

    test('emits the cached user, then the refreshed one, on sign-in', () async {
      final fetched = Completer<Map<String, dynamic>>();
      when(() => remote.fetchMe()).thenAnswer((_) => fetched.future);
      final events = <UserModel>[];
      final sub = service.profileStream.skip(1).listen(events.add);
      service.init();

      auth.add(AuthState.authenticated);
      await Future<void>.delayed(Duration.zero);

      expect(events.map((u) => u.profilePictureUrl), [null]);
      expect(events.single.id, const UserId('1'));

      fetched.complete(profile('1'));
      await Future<void>.delayed(Duration.zero);

      expect(events.last.profilePictureUrl, 'http://x/1.webp');
      await sub.cancel();
    });

    test('fetches /me once even when authenticated is re-emitted', () async {
      service.init();

      auth.add(AuthState.authenticated);
      auth.add(AuthState.authenticated);
      await Future<void>.delayed(Duration.zero);

      verify(() => remote.fetchMe()).called(1);
    });

    test(
      'emits guest without fetching when auth becomes unauthenticated',
      () async {
        final next = service.profileStream.skip(1).first;
        service.init();

        auth.add(AuthState.unauthenticated);

        expect(await next, same(UserModel.guest));
        verifyNever(() => remote.fetchMe());
      },
    );

    test('drops a /me that resolves after sign-out', () async {
      final fetched = Completer<Map<String, dynamic>>();
      when(() => remote.fetchMe()).thenAnswer((_) => fetched.future);
      final events = <UserModel>[];
      final sub = service.profileStream.skip(1).listen(events.add);
      service.init();

      auth.add(AuthState.authenticated);
      await Future<void>.delayed(Duration.zero);
      auth.add(AuthState.unauthenticated);
      await Future<void>.delayed(Duration.zero);
      fetched.complete(profile('1'));
      await Future<void>.delayed(Duration.zero);

      expect(events.last, same(UserModel.guest));
      verifyNever(() => storage.writeProfile(any()));
      await sub.cancel();
    });

    test('drops a /me that resolves during the logout round-trip', () async {
      final fetched = Completer<Map<String, dynamic>>();
      final backendLogout = Completer<void>();
      when(() => remote.fetchMe()).thenAnswer((_) => fetched.future);
      when(
        () => mockAuthService.logout(),
      ).thenAnswer((_) => backendLogout.future);
      when(() => storage.clear()).thenAnswer((_) async {});
      final events = <UserModel>[];
      final sub = service.profileStream.skip(1).listen(events.add);
      service.init();

      auth.add(AuthState.authenticated);
      await Future<void>.delayed(Duration.zero);
      final logout = service.logout();
      await Future<void>.delayed(Duration.zero);
      // AuthService still reports authenticated here.
      fetched.complete(profile('1'));
      await Future<void>.delayed(Duration.zero);

      expect(events.last, same(UserModel.guest));
      verifyNever(() => storage.writeProfile(any()));
      backendLogout.complete();
      await logout;
      await sub.cancel();
    });

    test(
      'drops an upload that resolves during the logout round-trip',
      () async {
        final uploaded = Completer<Map<String, dynamic>>();
        final backendLogout = Completer<void>();
        // Keep the sign-in /me pending so only the upload writes could reach
        // the cache.
        when(
          () => remote.fetchMe(),
        ).thenAnswer((_) => Completer<Map<String, dynamic>>().future);
        when(
          () => remote.uploadImage(
            kind: any(named: 'kind'),
            bytes: any(named: 'bytes'),
            fileName: any(named: 'fileName'),
          ),
        ).thenAnswer((_) => uploaded.future);
        when(
          () => mockAuthService.logout(),
        ).thenAnswer((_) => backendLogout.future);
        when(() => storage.clear()).thenAnswer((_) async {});
        final events = <UserModel>[];
        final sub = service.profileStream.skip(1).listen(events.add);
        service.init();
        auth.add(AuthState.authenticated);
        await Future<void>.delayed(Duration.zero);

        final upload = service.uploadProfileImage(
          kind: ProfileImageKind.avatar,
          fileName: 'a.png',
          bytes: Uint8List(1),
        );
        final logout = service.logout();
        await Future<void>.delayed(Duration.zero);
        uploaded.complete(profile('1'));
        await expectLater(upload, throwsA(isA<ProfileImageFailure>()));

        expect(events.last, same(UserModel.guest));
        verifyNever(() => storage.writeProfile(any()));
        backendLogout.complete();
        await logout;
        await sub.cancel();
      },
    );

    test(
      'drops a stale /me from the previous account after re-sign-in',
      () async {
        final fetchedA = Completer<Map<String, dynamic>>();
        var fetches = 0;
        when(() => remote.fetchMe()).thenAnswer(
          (_) => ++fetches == 1 ? fetchedA.future : Future.value(profile('2')),
        );
        final events = <UserModel>[];
        final sub = service.profileStream.skip(1).listen(events.add);
        service.init();

        auth.add(AuthState.authenticated); // A, /me pending
        await Future<void>.delayed(Duration.zero);
        auth.add(AuthState.unauthenticated);
        when(
          () => mockAuthService.getToken(),
        ).thenAnswer((_) async => validToken('2'));
        auth.add(AuthState.authenticated); // B
        await Future<void>.delayed(Duration.zero);
        fetchedA.complete(profile('1'));
        await Future<void>.delayed(Duration.zero);

        expect(events.last.id, const UserId('2'));
        verifyNever(() => storage.writeProfile(profile('1')));
        await sub.cancel();
      },
    );

    test('ignores the uninitialized state', () async {
      service.init();

      auth.add(AuthState.uninitialized);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => remote.fetchMe());
    });

    test('stops listening after dispose', () async {
      service.init();
      service.dispose();

      auth.add(AuthState.authenticated);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => remote.fetchMe());
    });
  });
}
