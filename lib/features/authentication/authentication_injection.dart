import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/token_provider.dart';
import 'data/data_sources/auth_local_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/use_cases/auth_service.dart';
import 'domain/use_cases/token_manager.dart';

void initAuthenticationInjection(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<AuthStorage>(() => AuthStorage());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<DioClient>().dio),
  );

  // Token Management
  sl.registerLazySingleton<TokenManager>(
    () => TokenManager(sl<AuthRepository>(), sl<AuthStorage>()),
  );
  sl.registerLazySingleton<TokenProvider>(() => sl<TokenManager>());

  // Use Cases / Services
  sl.registerLazySingleton<AuthService>(
    () => AuthService(sl<AuthRepository>(), sl<TokenManager>()),
  );
}
