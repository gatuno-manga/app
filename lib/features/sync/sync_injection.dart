import 'package:get_it/get_it.dart';
import 'data/data_sources/sync_local_data_source.dart';
import 'data/repositories/sync_repository_impl.dart';
import 'domain/repositories/sync_repository.dart';
import 'domain/use_cases/app_sync_coordinator.dart';
import 'domain/use_cases/local_sync_feature_provider.dart';
import '../reading/domain/entities/reading_progress.dart';

void initSyncDI(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<SyncLocalDataSource>(
    () => SyncLocalDataSource(),
  );

  // Services
  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepositoryImpl(sl()),
  );

  // Coordinator
  sl.registerLazySingleton<AppSyncCoordinator>(
    () => AppSyncCoordinator(
      sl(),
      sl(),
      sl(),
      [
        sl<LocalSyncFeatureProvider<ReadingProgress>>(),
      ],
    ),
  );
}
