import 'package:dio/dio.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/core/network/token_provider.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/authentication/domain/use_cases/token_manager.dart';
import 'package:gatuno/features/authentication/data/data_sources/auth_local_data_source.dart';
import 'package:gatuno/features/users/data/data_sources/user_local_data_source.dart';
import 'package:gatuno/features/home/presentation/view_models/home_view_model.dart';
import 'package:gatuno/features/users/presentation/view_models/me_view_model.dart';
import 'package:gatuno/shared/presentation/view_models/navigation_view_model.dart';
import 'package:gatuno/features/settings/domain/use_cases/settings_service.dart';
import 'package:gatuno/features/settings/data/data_sources/settings_local_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockTokenManager extends Mock implements TokenManager {}

class MockAuthStorage extends Mock implements AuthStorage {}

class MockUserStorage extends Mock implements UserStorage {}

class MockSettingsService extends Mock implements SettingsService {}

class MockSettingsStorage extends Mock implements SettingsStorage {}

class MockHomeViewModel extends Mock implements HomeViewModel {}

class MockNavigationViewModel extends Mock implements NavigationViewModel {}

class MockDio extends Mock implements Dio {
  MockDio() {
    when(() => interceptors).thenReturn(Interceptors());
    // Default stub for get to return a Future, avoiding: type 'Null' is not a subtype of type 'Future<Response<List<int>>>'
    when(
      () => get<List<int>>(any(), options: any(named: 'options')),
    ).thenAnswer(
      (_) async => Response<List<int>>(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      ),
    );
  }
}

class MockDioClient extends Mock implements DioClient {
  @override
  final Dio dio = MockDio();
}

Future<void> initTestDI({
  AuthService? authService,
  TokenManager? tokenManager,
  AuthStorage? authStorage,
  UserStorage? userStorage,
  SettingsService? settingsService,
  SettingsStorage? settingsStorage,
  HomeViewModel? homeViewModel,
  MeViewModel? meViewModel,
  NavigationViewModel? navigationViewModel,
  DioClient? dioClient,
}) async {
  await sl.reset();

  final dc = dioClient ?? MockDioClient();
  sl.registerLazySingleton<DioClient>(() => dc);

  final storage = authStorage ?? MockAuthStorage();
  if (authStorage == null) {
    when(() => storage.getToken()).thenAnswer((_) async => null);
  }
  sl.registerLazySingleton<AuthStorage>(() => storage);

  sl.registerLazySingleton<UserStorage>(() => userStorage ?? MockUserStorage());

  final sStorage = settingsStorage ?? MockSettingsStorage();
  sl.registerLazySingleton<SettingsStorage>(() => sStorage);

  final sService = settingsService ?? MockSettingsService();
  if (settingsService == null) {
    when(() => sService.sensitiveContentEnabled).thenReturn(false);
    when(() => sService.apiUrl).thenReturn(null);
    when(() => sService.allowedBadCertificateUrls).thenReturn([]);
  }
  sl.registerLazySingleton<SettingsService>(() => sService);

  final tm = tokenManager ?? MockTokenManager();
  if (tokenManager == null) {
    when(() => tm.initialize()).thenAnswer((_) async {});
    when(() => tm.getToken()).thenAnswer((_) async => null);
    when(
      () => tm.getValidToken(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => null);
    when(() => tm.currentToken).thenReturn(null);
  }
  sl.registerLazySingleton<TokenManager>(() => tm);
  sl.registerLazySingleton<TokenProvider>(() => tm);

  sl.registerLazySingleton<AuthService>(() => authService ?? MockAuthService());

  if (homeViewModel != null) {
    sl.registerLazySingleton<HomeViewModel>(() => homeViewModel);
  }

  if (meViewModel != null) {
    sl.registerLazySingleton<MeViewModel>(() => meViewModel);
  }

  final navVM = navigationViewModel ?? MockNavigationViewModel();
  if (navigationViewModel == null) {
    when(() => navVM.isAuthenticated).thenReturn(false);
    when(() => navVM.user).thenReturn(null);
  }
  sl.registerFactory<NavigationViewModel>(() => navVM);
}
