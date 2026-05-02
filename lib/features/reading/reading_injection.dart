import 'package:get_it/get_it.dart';
import 'data/database/reading_database.dart';
import 'data/repositories/reading_progress_local_service.dart';
import 'data/repositories/reading_progress_remote_service.dart';
import 'data/repositories/reading_repository_impl.dart';
import 'domain/repositories/reading_repository.dart';
import 'domain/use_cases/reading_progress_coordinator.dart';
import 'presentation/view_models/reading_view_model.dart';

void initReadingDI(GetIt sl) {
  // Database
  sl.registerLazySingleton<ReadingDatabase>(() => ReadingDatabase());

  // Services
  sl.registerLazySingleton<ReadingProgressLocalService>(
    () => ReadingProgressLocalService(sl()),
  );
  sl.registerLazySingleton<ReadingProgressRemoteService>(
    () => ReadingProgressRemoteService(sl(), sl()),
  );

  // Coordinator
  sl.registerLazySingleton<ReadingProgressCoordinator>(
    () => ReadingProgressCoordinator(sl(), sl(), sl(), sl()),
  );

  // Repositories
  sl.registerLazySingleton<ReadingRepository>(
    () => ReadingRepositoryImpl(sl()),
  );

  // ViewModels
  sl.registerFactory(() => ReadingViewModel(sl(), sl()));
}
