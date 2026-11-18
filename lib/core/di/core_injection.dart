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
import '../device/device_id_service.dart';
import '../offline/cache_epoch.dart';
import '../offline/offline_cache_maintenance.dart';
import '../offline/read_through.dart';
import '../logging/logger.dart';
import '../network/dio_client.dart';
import '../network/token_provider.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/cache_interceptor.dart';
import '../network/interceptors/cookie_interceptor.dart';
import '../network/interceptors/device_id_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../network/interceptors/bad_certificate_interceptor.dart';
import '../network/interceptors/connectivity_interceptor.dart';
import '../../features/downloads/downloads_injection.dart';
import '../../features/downloads/data/data_sources/downloaded_file_image_loading_strategy.dart';
import '../../features/downloads/domain/repositories/downloaded_content.dart';
import '../../features/settings/data/data_sources/settings_local_data_source.dart';
import '../../features/settings/data/data_sources/settings_migration.dart';
import '../../features/settings/domain/use_cases/settings_service.dart';
import '../../features/certificates/certificates_injection.dart';
import '../../features/certificates/domain/use_cases/certificates_service.dart';
import '../image/image_loading_strategy.dart';
import '../image/dio_image_loading_strategy.dart';

final GetIt sl = GetIt.instance;

/// What every engine needs, the app's and the background check's: logging,
/// certificates, Dio, connectivity, the offline cache, covers and settings
/// (which sets the server URL).
Future<void> initCoreDI() async {
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
  // Every AppImage checks the downloaded chapters first, then the cover
  // store; anything else goes to the network. Downloads are registered later
  // (lazily resolved here).
  sl.registerLazySingleton<ImageLoadingStrategy>(
    () => DownloadedFileImageLoadingStrategy(
      sl<DownloadedContent>(),
      CoverImageLoadingStrategy(
        sl<CoverStore>(),
        DioImageLoadingStrategy(sl<DioClient>()),
      ),
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
          // Downloads belong to the old server too. A failure here must not
          // keep the cache of the old library.
          await clearDownloads(sl).catchError(
            (Object e, StackTrace stackTrace) => AppLogger.e(
              'Could not delete downloads on a server change',
              e,
              stackTrace,
              'initDI',
            ),
          );
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

  sl.registerLazySingleton<DeviceIdService>(DeviceIdService.new);
  await sl<DeviceIdService>().init();
}

/// Dio interceptors, once AuthService (initAuthenticationInjection) and
/// ConnectivityService are registered.
Future<void> setupInterceptors() async {
  setupCookieInterceptor(sl<DioClient>());
  await setupCacheInterceptor(sl<DioClient>());
  setupDeviceIdInterceptor(sl<DioClient>(), sl<DeviceIdService>());
  setupAuthInterceptor(sl<DioClient>(), sl<TokenProvider>());
  setupLoggingInterceptor(sl<DioClient>());
  setupBadCertificateInterceptor(sl<DioClient>(), sl<CertificatesService>());
  // First in the chain. HTTP cache hits still reach it (the cache resolves
  // them with callFollowingResponseInterceptor); it filters them itself.
  setupConnectivityInterceptor(sl<DioClient>(), sl<ConnectivityService>());
}
