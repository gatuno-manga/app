import 'package:get_it/get_it.dart';
import '../authentication/domain/use_cases/auth_service.dart';
import '../../core/network/dio_client.dart';
import 'data/data_sources/user_local_data_source.dart';
import 'data/data_sources/user_remote_data_source.dart';
import 'domain/use_cases/user_service.dart';
import 'presentation/view_models/me_view_model.dart';
import '../../shared/presentation/view_models/navigation_view_model.dart';

void initUsersInjection(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<UserStorage>(() => UserStorage());
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(sl<DioClient>().dio),
  );

  // Use Cases
  sl.registerLazySingleton<UserService>(
    () => UserService(
      sl<AuthService>(),
      remote: sl<UserRemoteDataSource>(),
      storage: sl<UserStorage>(),
    ),
  );

  // View Models
  sl.registerFactory<MeViewModel>(() => MeViewModel(sl<UserService>()));
  sl.registerFactory<NavigationViewModel>(
    () => NavigationViewModel(sl<UserService>(), sl<AuthService>()),
  );
}
