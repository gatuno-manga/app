import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/sync/data/data_sources/sync_local_data_source.dart';
import 'package:gatuno/features/sync/domain/entities/pull_sync_response.dart';
import 'package:gatuno/features/sync/domain/repositories/sync_repository.dart';
import 'package:gatuno/features/sync/domain/use_cases/app_sync_coordinator.dart';
import 'package:gatuno/features/sync/domain/use_cases/pending_read_marks_flusher.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/shared/domain/value_objects/timestamp.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncLocalDataSource extends Mock implements SyncLocalDataSource {}

class MockSyncRepository extends Mock implements SyncRepository {}

class MockAuthService extends Mock implements AuthService {}

class MockPendingReadMarksFlusher extends Mock
    implements PendingReadMarksFlusher {}

void main() {
  late MockSyncLocalDataSource syncLocal;
  late MockSyncRepository syncRepository;
  late MockAuthService authService;
  late MockPendingReadMarksFlusher flusher;
  late AppSyncCoordinator coordinator;

  final user = UserModel(
    id: const UserId('user-1'),
    email: const UserEmail('reader@example.com'),
    roles: const UserRoles(['user']),
    maxWeightSensitiveContent: const SensitiveContentWeight(0),
  );

  setUpAll(() {
    registerFallbackValue(const UserId('dummy'));
    registerFallbackValue(Timestamp(DateTime(2026)));
  });

  setUp(() {
    syncLocal = MockSyncLocalDataSource();
    syncRepository = MockSyncRepository();
    authService = MockAuthService();
    flusher = MockPendingReadMarksFlusher();
    coordinator = AppSyncCoordinator(
      syncLocal,
      syncRepository,
      authService,
      const [],
      pendingReadMarksFlusher: flusher,
    );

    when(() => syncLocal.getLastSyncAt(any())).thenAnswer((_) async => null);
    when(() => syncLocal.setLastSyncAt(any(), any())).thenAnswer((_) async {});
    when(
      () => syncRepository.pullData(lastSyncAt: any(named: 'lastSyncAt')),
    ).thenAnswer(
      (_) async => PullSyncResponse(
        syncedAt: Timestamp(DateTime(2026, 11, 1)),
        data: const {},
      ),
    );
    when(() => flusher.flushPending(any())).thenAnswer((_) async {});
  });

  test('flushes pending read marks during sync for signed-in user', () async {
    when(() => authService.currentUser).thenReturn(user);

    await coordinator.sync();

    verify(() => flusher.flushPending(user.id)).called(1);
  });

  test('skips sync and flush for guest user', () async {
    when(() => authService.currentUser).thenReturn(UserModel.guest);

    await coordinator.sync();

    verifyNever(() => flusher.flushPending(any()));
    verifyNever(
      () => syncRepository.pullData(lastSyncAt: any(named: 'lastSyncAt')),
    );
  });
}
