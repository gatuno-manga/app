import 'dart:async';
import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import '../connectivity/connectivity_service.dart';
import '../connectivity/connectivity_triggers.dart';
import '../connectivity/dio_server_probe.dart';
import '../connectivity/server_connectivity_service.dart';
import '../covers/cover_image_loading_strategy.dart';
import '../covers/cover_store.dart';
import '../covers/dio_cover_downloader.dart';
import '../covers/file_cover_store.dart';
import '../database/offline_cache_database.dart';
import '../offline/cache_epoch.dart';
import '../offline/offline_cache_maintenance.dart';
import '../offline/read_through.dart';
import '../logging/logger.dart';
import '../network/dio_client.dart';
import '../network/token_provider.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/cache_interceptor.dart';
import '../network/interceptors/cookie_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../network/interceptors/bad_certificate_interceptor.dart';
import '../network/interceptors/connectivity_interceptor.dart';
import '../../features/authentication/authentication_injection.dart';
import '../../features/users/domain/use_cases/user_service.dart';
import '../../features/users/users_injection.dart';
import '../../features/home/home_injection.dart';
import '../../features/books/books_injection.dart';
import '../../features/book_requests/book_requests_injection.dart';
import '../../features/reading/reading_injection.dart';
import '../../features/reading/domain/use_cases/reader_preferences_service.dart';
import '../../features/sync/domain/use_cases/reconnect_sync_trigger.dart';
import '../../features/sync/sync_injection.dart';
import '../../features/settings/data/data_sources/settings_local_data_source.dart';
import '../../features/settings/data/data_sources/settings_migration.dart';
import '../../features/settings/domain/use_cases/settings_service.dart';
import '../../features/certificates/certificates_injection.dart';
import '../../features/certificates/domain/use_cases/certificates_service.dart';
import '../../features/app_lock/app_lock_injection.dart';
import '../../features/app_lock/domain/use_cases/app_lock_service.dart';
import '../image/image_loading_strategy.dart';
import '../image/dio_image_loading_strategy.dart';
import '../network/app_mqtt_service.dart';

final GetIt sl = GetIt.instance;

Future<void> initDI() async {
  // Logger
  await AppLogger.init();

  // Before any storage reads: moves non-sensitive values out of secure storage.
  await SettingsMigration().run();

  // Core
  initCertificatesInjection(sl);
  await sl<CertificatesService>().init();

  sl.registerLazySingleton<DioClient>(
    () => DioClient(certificatesService: sl<CertificatesService>()),
  );
  // Offline: connectivity, the local cache and the cover store.
  sl.registerLazySingleton<ConnectivityTriggers>(
    ConnectivityTriggers.new,
    dispose: (triggers) => triggers.dispose(),
  );
  sl.registerLazySingleton<ServerConnectivityService>(
    () => ServerConnectivityService(
      probe: dioServerProbe(sl<DioClient>()),
      triggers: sl<ConnectivityTriggers>().stream,
    ),
    dispose: (service) => service.dispose(),
  );
  sl.registerLazySingleton<ConnectivityService>(
    () => sl<ServerConnectivityService>(),
  );
  sl.registerLazySingleton<CacheEpoch>(CacheEpoch.new);
  sl.registerLazySingleton<ReadThrough>(
    () => ReadThrough(sl<ConnectivityService>(), sl<CacheEpoch>()),
  );
  sl.registerLazySingleton<OfflineCacheDatabase>(
    () => OfflineCacheDatabase(),
    dispose: (db) => db.close(),
  );
  sl.registerLazySingleton<CoverStore>(
    () => FileCoverStore(
      db: sl<OfflineCacheDatabase>(),
      directory: () async =>
          Directory('${(await getApplicationSupportDirectory()).path}/covers'),
      download: dioCoverDownloader(sl<DioClient>()),
      isOffline: () => sl<ConnectivityService>().isOffline,
      epoch: sl<CacheEpoch>(),
    ),
  );
  // Every AppImage checks the cover store first; URLs that are not a cached
  // book's cover go straight to the network.
  sl.registerLazySingleton<ImageLoadingStrategy>(
    () => CoverImageLoadingStrategy(
      sl<CoverStore>(),
      DioImageLoadingStrategy(sl<DioClient>()),
    ),
  );
  sl.registerLazySingleton<OfflineCacheMaintenance>(
    () => OfflineCacheMaintenance(
      sl<OfflineCacheDatabase>(),
      sl<CoverStore>(),
      sl<CacheEpoch>(),
    ),
  );

  sl.registerLazySingleton<SettingsStorage>(() => SettingsStorage());
  sl.registerLazySingleton<SettingsService>(
    () => SettingsService(
      sl<SettingsStorage>(),
      sl<DioClient>(),
      onServerChanged: () async {
        try {
          await sl<OfflineCacheMaintenance>().clearAll();
        } finally {
          // The status still describes the old server: probe the new one
          // even if the wipe failed.
          unawaited(sl<ConnectivityService>().checkNow());
        }
      },
    ),
  );

  // Initialize settings (including base URL)
  await sl<SettingsService>().init();

  initAppLockInjection(sl);
  await sl<AppLockService>().init();

  // Features
  initAuthenticationInjection(sl);
  sl.registerLazySingleton<AppMqttService>(() => AppMqttService(sl(), sl()));
  initUsersInjection(sl);
  initHomeInjection(sl);
  await initBooksInjection(sl);
  initSyncDI(
    sl,
  ); // Must be before reading since reading depends on sync coordinator
  initReadingDI(sl);
  await sl<ReaderPreferencesService>().init();
  initBookRequestsInjection(sl);

  // Set up interceptors (AuthService is registered in initAuthenticationInjection)
  setupCookieInterceptor(sl<DioClient>());
  await setupCacheInterceptor(sl<DioClient>());
  setupAuthInterceptor(sl<DioClient>(), sl<TokenProvider>());
  setupLoggingInterceptor(sl<DioClient>());
  setupBadCertificateInterceptor(sl<DioClient>(), sl<CertificatesService>());
  // First in the chain. HTTP cache hits still reach it (the cache resolves
  // them with callFollowingResponseInterceptor); it filters them itself.
  setupConnectivityInterceptor(sl<DioClient>(), sl<ConnectivityService>());

  // Needs the interceptors: probes go through DioClient. Not awaited, so a
  // slow server does not hold the first frame.
  sl<ConnectivityTriggers>().start();
  unawaited(sl<ServerConnectivityService>().start());
  sl<ReconnectSyncTrigger>().start();
  unawaited(sl<OfflineCacheMaintenance>().evictStale());

  // Last: refreshes the profile on sign-in, so it needs the interceptors
  // above and must be listening before any screen appears.
  sl<UserService>().init();
}
