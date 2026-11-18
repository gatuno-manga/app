import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/reading/data/database/reading_database.dart';
import 'package:gatuno/features/reading/data/repositories/pending_read_marks_local_service.dart';
import 'package:gatuno/features/reading/domain/entities/chapter_read_batch_result.dart';
import 'package:gatuno/features/reading/domain/repositories/reading_repository.dart';
import 'package:gatuno/features/reading/domain/use_cases/chapter_read_mark_coordinator.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_connectivity_service.dart';

class MockReadingRepository extends Mock implements ReadingRepository {}

class MockAuthService extends Mock implements AuthService {}

UserModel _signedInUser([String id = 'user-1']) => UserModel(
  id: UserId(id),
  email: const UserEmail('reader@example.com'),
  roles: const UserRoles(['user']),
  maxWeightSensitiveContent: const SensitiveContentWeight(0),
);

void main() {
  late ReadingDatabase db;
  late PendingReadMarksLocalService pendingLocal;
  late MockReadingRepository repository;
  late MockAuthService authService;
  late FakeConnectivityService connectivity;
  late ChapterReadMarkCoordinator coordinator;

  const chapter1 = ChapterId('chapter-1');
  const chapter2 = ChapterId('chapter-2');
  const chapter3 = ChapterId('chapter-3');

  setUpAll(() {
    registerFallbackValue(const ChapterId('dummy'));
  });

  setUp(() {
    db = ReadingDatabase(NativeDatabase.memory());
    pendingLocal = PendingReadMarksLocalService(db);
    repository = MockReadingRepository();
    authService = MockAuthService();
    connectivity = FakeConnectivityService();

    when(() => authService.authenticated).thenReturn(true);
    when(() => authService.currentUser).thenReturn(_signedInUser());
    when(() => repository.markChapterRead(any())).thenAnswer((_) async {});

    coordinator = ChapterReadMarkCoordinator(
      repository,
      pendingLocal,
      authService,
      connectivity,
    );
  });

  tearDown(() async {
    await db.close();
    await connectivity.close();
  });

  group('markRead', () {
    test('marks online when signed in without queueing', () async {
      await coordinator.markRead(chapter1);

      verify(() => repository.markChapterRead(chapter1)).called(1);
      expect(
        await pendingLocal.getPendingChapterIds(const UserId('user-1')),
        isEmpty,
      );
    });

    test('does nothing and queues nothing for guest users', () async {
      when(() => authService.authenticated).thenReturn(false);
      when(() => authService.currentUser).thenReturn(UserModel.guest);

      await coordinator.markRead(chapter1);
      connectivity.goOffline();
      await coordinator.markRead(chapter2);

      verifyNever(() => repository.markChapterRead(any()));
      expect(
        await pendingLocal.getPendingChapterIds(const UserId('guest')),
        isEmpty,
      );
    });

    test('queues when offline without calling repository', () async {
      connectivity.goOffline();

      await coordinator.markRead(chapter1);

      verifyNever(() => repository.markChapterRead(any()));
      expect(await pendingLocal.getPendingChapterIds(const UserId('user-1')), [
        chapter1,
      ]);
    });

    test('queues on NetworkException', () async {
      when(
        () => repository.markChapterRead(chapter1),
      ).thenThrow(NetworkException(message: 'Timeout'));

      await coordinator.markRead(chapter1);

      expect(await pendingLocal.getPendingChapterIds(const UserId('user-1')), [
        chapter1,
      ]);
    });

    test('queues on 5xx ServerException', () async {
      when(
        () => repository.markChapterRead(chapter1),
      ).thenThrow(ServerException(message: 'Unavailable', statusCode: 503));

      await coordinator.markRead(chapter1);

      expect(await pendingLocal.getPendingChapterIds(const UserId('user-1')), [
        chapter1,
      ]);
    });

    test('logs and drops 4xx errors without queueing', () async {
      when(
        () => repository.markChapterRead(chapter1),
      ).thenThrow(ServerException(message: 'Bad request', statusCode: 400));
      when(
        () => repository.markChapterRead(chapter2),
      ).thenThrow(AuthException('Forbidden'));

      await coordinator.markRead(chapter1);
      await coordinator.markRead(chapter2);

      expect(
        await pendingLocal.getPendingChapterIds(const UserId('user-1')),
        isEmpty,
      );
    });
  });

  group('flushPending', () {
    test(
      'clears succeeded and not-found items while keeping retryable failures',
      () async {
        const userId = UserId('user-1');
        await pendingLocal.enqueue(userId, chapter1);
        await pendingLocal.enqueue(userId, chapter2);
        await pendingLocal.enqueue(userId, chapter3);

        when(() => repository.markChaptersRead(any())).thenAnswer(
          (_) async => const [
            ChapterReadBatchResult(chapterId: chapter1, success: true),
            ChapterReadBatchResult(
              chapterId: chapter2,
              success: false,
              error: 'Chapter not found',
            ),
            ChapterReadBatchResult(
              chapterId: chapter3,
              success: false,
              error: 'Database timeout',
            ),
          ],
        );

        await coordinator.flushPending(userId);

        verify(
          () => repository.markChaptersRead([chapter1, chapter2, chapter3]),
        ).called(1);
        expect(await pendingLocal.getPendingChapterIds(userId), [chapter3]);
      },
    );

    test('keeps all queued items if batch request throws', () async {
      const userId = UserId('user-1');
      await pendingLocal.enqueue(userId, chapter1);
      when(
        () => repository.markChaptersRead(any()),
      ).thenThrow(NetworkException(message: 'Offline'));

      await coordinator.flushPending(userId);

      expect(await pendingLocal.getPendingChapterIds(userId), [chapter1]);
    });
  });
}
