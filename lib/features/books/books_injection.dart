import 'package:get_it/get_it.dart';
import '../../core/connectivity/connectivity_service.dart';
import '../../core/database/offline_cache_database.dart';
import '../../core/network/dio_client.dart';
import '../../core/offline/read_through.dart';
import '../authentication/domain/use_cases/auth_service.dart';
import '../downloads/domain/repositories/auto_download_preferences.dart';
import '../downloads/domain/repositories/download_service.dart';
import '../reading/domain/use_cases/reading_progress_coordinator.dart';
import '../settings/domain/use_cases/settings_service.dart';
import 'data/data_sources/books_local_data_source.dart';
import 'data/repositories/books_repository_impl.dart';
import 'data/repositories/books_view_preferences_repository_impl.dart';
import 'domain/repositories/books_repository.dart';
import 'domain/repositories/books_view_preferences_repository.dart';
import 'domain/value_objects/book_id.dart';
import 'presentation/view_models/book_downloads_view_model.dart';
import 'presentation/view_models/books_view_model.dart';
import 'presentation/view_models/book_details_view_model.dart';

Future<void> initBooksInjection(GetIt sl) async {
  // Data sources
  sl.registerLazySingleton<BooksLocalDataSource>(
    () => BooksLocalDataSource(sl<OfflineCacheDatabase>()),
  );

  // Repositories
  sl.registerLazySingleton<BooksRepository>(
    () => BooksRepositoryImpl(
      sl<DioClient>(),
      local: sl<BooksLocalDataSource>(),
      readThrough: sl<ReadThrough>(),
    ),
  );
  sl.registerLazySingleton<BooksViewPreferencesRepository>(
    BooksViewPreferencesRepositoryImpl.new,
  );
  // Read once so BooksViewModel can seed its state synchronously.
  await sl<BooksViewPreferencesRepository>().init();

  // View Models
  sl.registerFactory<BooksViewModel>(
    () => BooksViewModel(
      repository: sl<BooksRepository>(),
      settingsService: sl<SettingsService>(),
      viewPreferencesRepository: sl<BooksViewPreferencesRepository>(),
      connectivity: sl<ConnectivityService>(),
    ),
  );

  sl.registerFactoryParam<BookDetailsViewModel, String, void>(
    (bookId, _) => BookDetailsViewModel(
      repository: sl<BooksRepository>(),
      progressCoordinator: sl<ReadingProgressCoordinator>(),
      bookId: bookId,
    ),
  );

  // Resolves the downloads feature, registered after this one, on first use.
  sl.registerFactoryParam<BookDownloadsViewModel, String, void>(
    (bookId, _) => BookDownloadsViewModel(
      downloads: sl<DownloadService>(),
      autoDownload: sl<AutoDownloadPreferences>(),
      connectivity: sl<ConnectivityService>(),
      auth: sl<AuthService>(),
      bookId: BookId(bookId),
    ),
  );
}
