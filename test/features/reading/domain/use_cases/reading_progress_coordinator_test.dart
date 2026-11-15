import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/reading/data/database/reading_database.dart';
import 'package:gatuno/features/reading/data/repositories/reading_progress_local_service.dart';
import 'package:gatuno/features/reading/domain/use_cases/reading_progress_coordinator.dart';
import 'package:gatuno/features/sync/domain/use_cases/app_sync_coordinator.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_connectivity_service.dart';

class MockLocalService extends Mock implements ReadingProgressLocalService {}

class MockSyncCoordinator extends Mock implements AppSyncCoordinator {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockLocalService local;
  late MockSyncCoordinator sync;
  late MockAuthService auth;
  late FakeConnectivityService connectivity;
  late ReadingProgressCoordinator coordinator;

  final user = UserModel(
    id: const UserId('1'),
    email: const UserEmail('test@example.com'),
    roles: const UserRoles(['user']),
    maxWeightSensitiveContent: const SensitiveContentWeight(5),
  );

  setUpAll(() {
    registerFallbackValue(const ReadingProgressCompanion());
    registerFallbackValue(const UserId('x'));
    registerFallbackValue(const ChapterId('x'));
  });

  setUp(() {
    local = MockLocalService();
    sync = MockSyncCoordinator();
    auth = MockAuthService();
    connectivity = FakeConnectivityService();
    when(
      () => auth.authStateStream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    // Not signed in at start: no initial sync to account for.
    when(() => auth.authenticated).thenReturn(false);
    when(() => auth.currentUser).thenReturn(user);
    when(() => local.getProgress(any(), any())).thenAnswer((_) async => null);
    when(() => local.saveProgress(any())).thenAnswer((_) async {});
    when(() => sync.sync()).thenAnswer((_) async {});
    coordinator = ReadingProgressCoordinator(local, sync, auth, connectivity);
  });

  tearDown(() async {
    coordinator.dispose();
    await connectivity.close();
  });

  Future<void> save() => coordinator.saveProgress(
    chapterId: const ChapterId('c1'),
    bookId: const BookId('b1'),
    pageIndex: const PositiveInt(4),
    totalPages: const PositiveInt(10),
  );

  test('online, saving progress syncs it', () async {
    await save();

    verify(() => local.saveProgress(any())).called(1);
    verify(() => sync.sync()).called(1);
  });

  test('offline, progress is saved locally without a sync', () async {
    connectivity.goOffline();

    await save();

    final saved =
        verify(() => local.saveProgress(captureAny())).captured.single
            as ReadingProgressCompanion;
    expect(saved.pageIndex, const Value(4));
    expect(saved.chapterId, const Value('c1'));
    verifyNever(() => sync.sync());
  });

  test('a guest never syncs', () async {
    when(() => auth.currentUser).thenReturn(UserModel.guest);

    await save();

    verifyNever(() => sync.sync());
  });
}
