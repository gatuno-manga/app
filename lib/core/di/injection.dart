import 'package:get_it/get_it.dart';
import '../logging/logger.dart';
import '../network/dio_client.dart';
import '../network/token_provider.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/cache_interceptor.dart';
import '../network/interceptors/cookie_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../network/interceptors/bad_certificate_interceptor.dart';
import '../../features/authentication/authentication_injection.dart';
import '../../features/users/domain/use_cases/user_service.dart';
import '../../features/users/users_injection.dart';
import '../../features/home/home_injection.dart';
import '../../features/books/books_injection.dart';
import '../../features/book_requests/book_requests_injection.dart';
import '../../features/reading/reading_injection.dart';
import '../../features/reading/domain/use_cases/reader_preferences_service.dart';
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
  sl.registerLazySingleton<ImageLoadingStrategy>(
    () => DioImageLoadingStrategy(sl<DioClient>()),
  );
  sl.registerLazySingleton<SettingsStorage>(() => SettingsStorage());
  sl.registerLazySingleton<SettingsService>(
    () => SettingsService(sl<SettingsStorage>(), sl<DioClient>()),
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

  // Last: refreshes the profile on sign-in, so it needs the interceptors
  // above and must be listening before any screen appears.
  sl<UserService>().init();
}
