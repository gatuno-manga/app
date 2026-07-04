import 'package:get_it/get_it.dart';
import 'data/database/reading_database.dart' hide ReadingProgress;
import 'data/repositories/reading_progress_local_service.dart';
import 'data/repositories/reading_repository_impl.dart';
import 'domain/repositories/reading_repository.dart';
import 'domain/use_cases/reading_progress_coordinator.dart';
import 'presentation/view_models/reading_view_model.dart';
import '../sync/domain/use_cases/local_sync_feature_provider.dart';
import 'domain/entities/reading_progress.dart';
import 'data/repositories/reading_progress_sync_provider_impl.dart';
import 'data/repositories/reading_progress_mqtt_handler.dart';

void initReadingDI(GetIt sl) {
  // Database
  sl.registerLazySingleton<ReadingDatabase>(() => ReadingDatabase());

  // Services
  sl.registerLazySingleton<ReadingProgressLocalService>(
    () => ReadingProgressLocalService(sl()),
  );

  sl.registerLazySingleton<LocalSyncFeatureProvider<ReadingProgress>>(
    () => ReadingProgressSyncProviderImpl(sl()),
  );

  // Eagerly register MQTT handler so it starts listening
  sl.registerSingleton<ReadingProgressMqttHandler>(
    ReadingProgressMqttHandler(sl(), sl(), sl()),
  );

  // Coordinator
  sl.registerLazySingleton<ReadingProgressCoordinator>(
    () => ReadingProgressCoordinator(sl(), sl(), sl()),
  );

  // Repositories
  sl.registerLazySingleton<ReadingRepository>(
    () => ReadingRepositoryImpl(sl()),
  );

  // ViewModels
  sl.registerFactory(() => ReadingViewModel(sl(), sl()));
}
