import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/home/presentation/view_models/home_view_model.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/users/domain/use_cases/user_service.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_display_name.dart';
import 'package:gatuno/features/books/domain/repositories/books_repository.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';
import 'package:gatuno/features/reading/domain/use_cases/reading_progress_coordinator.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUserService extends Mock implements UserService {}

class MockBooksRepository extends Mock implements BooksRepository {}

class MockReadingProgressCoordinator extends Mock
    implements ReadingProgressCoordinator {}

/// Drives the status and reconnect streams by hand; [checkNow] lands on
/// [probeResult].
class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({
    ConnectivityStatus status = ConnectivityStatus.online,
  }) : _status = status;

  ConnectivityStatus _status;
  ConnectivityStatus probeResult = ConnectivityStatus.online;
  int checks = 0;
  final _statuses = StreamController<ConnectivityStatus>.broadcast();
  final _reconnected = StreamController<void>.broadcast();

  @override
  ConnectivityStatus get status => _status;

  @override
  Stream<ConnectivityStatus> get statusStream => _statuses.stream;

  @override
  Stream<void> get onReconnected => _reconnected.stream;

  void setStatus(ConnectivityStatus status) {
    _status = status;
    _statuses.add(status);
  }

  void reconnect() => _reconnected.add(null);

  bool get hasListeners => _statuses.hasListener || _reconnected.hasListener;

  @override
  Future<void> checkNow() async {
    checks++;
    setStatus(probeResult);
  }

  @override
  void reportReachable() {}

  @override
  void reportUnreachable() {}

  Future<void> close() async {
    await _statuses.close();
    await _reconnected.close();
  }
}

void main() {
  late HomeViewModel viewModel;
  late MockAuthService mockAuthService;
  late MockUserService mockUserService;
  late MockBooksRepository mockBooksRepository;
  late MockReadingProgressCoordinator mockReadingCoordinator;
  late FakeConnectivityService connectivity;

  setUpAll(() {
    registerFallbackValue(const BookPageOptions());
    registerFallbackValue(const BookId('fallback'));
  });

  UserModel user({String? name, String? imageUrl}) => UserModel(
    id: const UserId('1'),
    email: const UserEmail('test@example.com'),
    roles: const UserRoles(['user']),
    maxWeightSensitiveContent: const SensitiveContentWeight(5),
    name: name == null ? null : UserDisplayName(name),
    profilePictureUrl: imageUrl,
  );

  HomeViewModel buildViewModel() {
    final vm = HomeViewModel(
      mockAuthService,
      mockUserService,
      mockBooksRepository,
      mockReadingCoordinator,
      connectivity,
    );
    addTearDown(vm.dispose);
    return vm;
  }

  setUp(() {
    mockAuthService = MockAuthService();
    mockUserService = MockUserService();
    mockBooksRepository = MockBooksRepository();
    mockReadingCoordinator = MockReadingProgressCoordinator();
    connectivity = FakeConnectivityService();
    addTearDown(connectivity.close);

    when(
      () => mockAuthService.authStateStream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthService.authenticated).thenReturn(false);
    when(() => mockAuthService.isInitialized).thenReturn(true);
    when(
      () => mockUserService.profileStream,
    ).thenAnswer((_) => Stream.value(UserModel.guest));

    when(() => mockBooksRepository.getBooks(any())).thenAnswer(
      (_) async => const BookList(
        data: [],
        total: PositiveInt(0),
        page: PositiveInt(1),
        limit: PositiveInt(12),
        totalPages: PositiveInt(1),
      ),
    );
    when(
      () => mockReadingCoordinator.getContinueReadingBooks(
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => []);

    viewModel = buildViewModel();
  });

  group('HomeViewModel', () {
    test('should reflect auth status from service', () {
      expect(viewModel.state.isAuthenticated, isFalse);
      expect(viewModel.state.isInitialized, isTrue);
    });

    test('starts with the guest user', () {
      expect(viewModel.state.user, same(UserModel.guest));
    });

    test('takes the user from the profile stream', () async {
      when(() => mockAuthService.authenticated).thenReturn(true);
      when(() => mockUserService.profileStream).thenAnswer(
        (_) => Stream.value(user(name: 'Test', imageUrl: 'http://x/1.webp')),
      );

      viewModel = buildViewModel();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.isAuthenticated, isTrue);
      expect(viewModel.state.user.displayName, 'Test');
      expect(viewModel.state.user.profilePictureUrl, 'http://x/1.webp');
    });

    test('follows later profile changes', () async {
      final profiles = StreamController<UserModel>();
      addTearDown(profiles.close);
      when(
        () => mockUserService.profileStream,
      ).thenAnswer((_) => profiles.stream);
      viewModel = buildViewModel();

      profiles.add(user(name: 'Fresh', imageUrl: 'http://x/new.webp'));
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.user.profilePictureUrl, 'http://x/new.webp');

      profiles.add(UserModel.guest);
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.user, same(UserModel.guest));
    });
  });

  group('HomeViewModel offline', () {
    Book book(String id) => Book(id: BookId(id), title: BookTitle('Book $id'));

    BookList listOf(List<Book> books) => BookList(
      data: books,
      total: PositiveInt(books.isEmpty ? 0 : books.length),
      page: const PositiveInt(1),
      limit: const PositiveInt(12),
      totalPages: const PositiveInt(1),
    );

    void stubList(String orderBy, Future<BookList> Function() answer) {
      when(
        () => mockBooksRepository.getBooks(
          any(
            that: isA<BookPageOptions>().having(
              (o) => o.orderBy,
              'orderBy',
              orderBy,
            ),
          ),
        ),
      ).thenAnswer((_) => answer());
    }

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('shows the offline empty view when neither list is saved', () async {
      connectivity = FakeConnectivityService(
        status: ConnectivityStatus.offline,
      );
      addTearDown(connectivity.close);
      when(
        () => mockBooksRepository.getBooks(any()),
      ).thenThrow(OfflineException());

      viewModel = buildViewModel();
      await settle();

      expect(viewModel.state.isOffline, isTrue);
      expect(viewModel.state.showOfflineEmpty, isTrue);
      expect(viewModel.state.latestUpdated.isLoading, isFalse);
      expect(viewModel.state.recentlyAdded.isLoading, isFalse);
    });

    test('shows the saved list when only the other one misses', () async {
      connectivity = FakeConnectivityService(
        status: ConnectivityStatus.offline,
      );
      addTearDown(connectivity.close);
      stubList('updatedAt', () async => listOf([book('a'), book('b')]));
      stubList('createdAt', () async => throw OfflineException());

      viewModel = buildViewModel();
      await settle();

      expect(viewModel.state.showOfflineEmpty, isFalse);
      expect(viewModel.state.latestUpdated.books, hasLength(2));
      expect(viewModel.state.featuredBooks, hasLength(2));
      expect(viewModel.state.recentlyAdded.books, isEmpty);
    });

    test('a server error is not the offline empty view', () async {
      when(
        () => mockBooksRepository.getBooks(any()),
      ).thenThrow(ServerException());

      viewModel = buildViewModel();
      await settle();

      expect(viewModel.state.showOfflineEmpty, isFalse);
    });

    test('continue reading skips books that fail and keeps order', () async {
      when(() => mockAuthService.authenticated).thenReturn(true);
      when(
        () => mockReadingCoordinator.getContinueReadingBooks(
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const [BookId('1'), BookId('2'), BookId('3'), BookId('4')],
      );
      when(
        () => mockBooksRepository.getBook(const BookId('1')),
      ).thenAnswer((_) async => book('1'));
      when(
        () => mockBooksRepository.getBook(const BookId('2')),
      ).thenThrow(OfflineException());
      when(
        () => mockBooksRepository.getBook(const BookId('3')),
      ).thenThrow(ServerException());
      when(
        () => mockBooksRepository.getBook(const BookId('4')),
      ).thenAnswer((_) async => book('4'));

      viewModel = buildViewModel();
      await settle();

      expect(viewModel.state.continueReadingBooks.map((b) => b.id.value), [
        '1',
        '4',
      ]);
      expect(viewModel.state.isLoadingContinueReading, isFalse);
    });

    test('follows the connectivity status', () async {
      viewModel = buildViewModel();
      expect(viewModel.state.isOffline, isFalse);

      connectivity.setStatus(ConnectivityStatus.offline);
      await settle();
      expect(viewModel.state.isOffline, isTrue);

      connectivity.setStatus(ConnectivityStatus.online);
      await settle();
      expect(viewModel.state.isOffline, isFalse);
    });

    test('reloads silently on reconnect, keeping what is shown', () async {
      stubList('updatedAt', () async => listOf([book('old')]));
      viewModel = buildViewModel();
      await settle();
      connectivity.setStatus(ConnectivityStatus.offline);
      await settle();

      final fresh = Completer<BookList>();
      stubList('updatedAt', () => fresh.future);
      final loadingStates = <bool>[];
      final sub = viewModel.stateStream.listen(
        (s) => loadingStates.add(s.latestUpdated.isLoading),
      );
      addTearDown(sub.cancel);

      connectivity.setStatus(ConnectivityStatus.online);
      connectivity.reconnect();
      await settle();

      expect(viewModel.state.latestUpdated.books.single.id.value, 'old');
      expect(loadingStates, everyElement(isFalse));

      fresh.complete(listOf([book('new')]));
      await settle();
      expect(viewModel.state.latestUpdated.books.single.id.value, 'new');
    });

    test('a failed refresh keeps the old content', () async {
      stubList('updatedAt', () async => listOf([book('old')]));
      viewModel = buildViewModel();
      await settle();

      stubList('updatedAt', () async => throw ServerException());
      await viewModel.reload();

      expect(viewModel.state.latestUpdated.books.single.id.value, 'old');
    });

    test('a reconnect after everything missed shows skeletons', () async {
      connectivity = FakeConnectivityService(
        status: ConnectivityStatus.offline,
      );
      addTearDown(connectivity.close);
      when(
        () => mockBooksRepository.getBooks(any()),
      ).thenThrow(OfflineException());
      viewModel = buildViewModel();
      await settle();

      final fresh = Completer<BookList>();
      when(
        () => mockBooksRepository.getBooks(any()),
      ).thenAnswer((_) => fresh.future);
      connectivity.setStatus(ConnectivityStatus.online);
      connectivity.reconnect();
      await settle();

      expect(viewModel.state.latestUpdated.isLoading, isTrue);
      expect(viewModel.state.showOfflineEmpty, isFalse);
      fresh.complete(listOf([book('a')]));
      await settle();
      expect(viewModel.state.showOfflineEmpty, isFalse);
      expect(viewModel.state.latestUpdated.books, hasLength(1));
    });

    test('a server error after reconnecting leaves the offline view', () async {
      connectivity = FakeConnectivityService(
        status: ConnectivityStatus.offline,
      );
      addTearDown(connectivity.close);
      when(
        () => mockBooksRepository.getBooks(any()),
      ).thenThrow(OfflineException());
      viewModel = buildViewModel();
      await settle();
      expect(viewModel.state.showOfflineEmpty, isTrue);

      when(
        () => mockBooksRepository.getBooks(any()),
      ).thenThrow(ServerException());
      connectivity.setStatus(ConnectivityStatus.online);
      connectivity.reconnect();
      await settle();

      expect(viewModel.state.showOfflineEmpty, isFalse);
    });

    group('retry', () {
      setUp(() {
        connectivity = FakeConnectivityService(
          status: ConnectivityStatus.offline,
        );
        addTearDown(connectivity.close);
        when(
          () => mockBooksRepository.getBooks(any()),
        ).thenThrow(OfflineException());
        viewModel = buildViewModel();
      });

      test('stays on the empty view while still offline', () async {
        await settle();
        clearInteractions(mockBooksRepository);
        connectivity.probeResult = ConnectivityStatus.offline;

        await viewModel.retry();

        expect(connectivity.checks, 1);
        verifyNever(() => mockBooksRepository.getBooks(any()));
        expect(viewModel.state.showOfflineEmpty, isTrue);
        expect(viewModel.state.isRetrying, isFalse);
      });

      test('reloads once the server answers', () async {
        await settle();
        clearInteractions(mockBooksRepository);
        when(
          () => mockBooksRepository.getBooks(any()),
        ).thenAnswer((_) async => listOf([book('a')]));

        final retrying = viewModel.retry();
        expect(viewModel.state.isRetrying, isTrue);
        await retrying;

        verify(() => mockBooksRepository.getBooks(any())).called(2);
        expect(viewModel.state.showOfflineEmpty, isFalse);
        expect(viewModel.state.isRetrying, isFalse);
      });

      test('the reconnect that follows does not fetch again', () async {
        await settle();
        when(
          () => mockBooksRepository.getBooks(any()),
        ).thenAnswer((_) async => listOf([book('a')]));
        await viewModel.retry();
        clearInteractions(mockBooksRepository);

        connectivity.reconnect();
        await settle();

        verifyNever(() => mockBooksRepository.getBooks(any()));
      });
    });

    test('a reload requested while one runs joins it', () async {
      final pending = Completer<BookList>();
      when(
        () => mockBooksRepository.getBooks(any()),
      ).thenAnswer((_) => pending.future);
      viewModel = buildViewModel();
      clearInteractions(mockBooksRepository);

      final again = viewModel.reload();
      pending.complete(listOf(const []));
      await again;

      verifyNever(() => mockBooksRepository.getBooks(any()));
    });

    test('dispose cancels the connectivity subscriptions', () {
      expect(connectivity.hasListeners, isTrue);

      viewModel.dispose();

      expect(connectivity.hasListeners, isFalse);
    });
  });
}
