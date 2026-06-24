import 'package:get_it/get_it.dart';
import 'data/data_sources/sync_local_data_source.dart';
import 'data/repositories/sync_remote_service.dart';
import 'domain/use_cases/app_sync_coordinator.dart';

void initSyncDI(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<SyncLocalDataSource>(
    () => SyncLocalDataSource(),
  );

  // Services
  sl.registerLazySingleton<SyncRemoteService>(
    () => SyncRemoteService(sl()),
  );

  // Coordinator
  sl.registerLazySingleton<AppSyncCoordinator>(
    () => AppSyncCoordinator(sl(), sl(), sl(), sl()),
  );
}
