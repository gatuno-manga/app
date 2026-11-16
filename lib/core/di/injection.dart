import 'dart:async';

import '../connectivity/connectivity_triggers.dart';
import '../connectivity/server_connectivity_service.dart';
import '../offline/offline_cache_maintenance.dart';
import '../../features/authentication/authentication_injection.dart';
import '../../features/users/domain/use_cases/user_service.dart';
import '../../features/users/users_injection.dart';
import '../../features/home/home_injection.dart';
import '../../features/books/books_injection.dart';
import '../../features/downloads/domain/repositories/download_network_rules.dart';
import '../../features/downloads/downloads_injection.dart';
import '../../features/book_requests/book_requests_injection.dart';
import '../../features/reading/reading_injection.dart';
import '../../features/reading/domain/use_cases/reader_preferences_service.dart';
import '../../features/sync/domain/use_cases/reconnect_sync_trigger.dart';
import '../../features/sync/sync_injection.dart';
import '../../features/settings/presentation/view_models/download_settings_view_model.dart';
import '../../features/app_lock/app_lock_injection.dart';
import '../../features/app_lock/domain/use_cases/app_lock_service.dart';
import '../network/app_mqtt_service.dart';
import 'background_injection.dart';
import 'core_injection.dart';
import '../../features/downloads/data/data_sources/new_chapter_check_handoff.dart';

export 'core_injection.dart' show sl;

Future<void> initDI() async {
  // First, before anything writes the downloads or reads the session: a
  // background new-chapter run hands over to this engine from now on, and
  // one already running is asked to stop and waited for (bounded).
  final handoff = NewChapterCheckHandoff()..listen();
  try {
    sl.registerSingleton<NewChapterCheckHandoff>(
      handoff,
      dispose: (handoff) => handoff.close(),
    );
    await NewChapterCheckHandoff.stopBackgroundRun(
      timeout: const Duration(seconds: 10),
    );
    await _initAppServices(handoff);
  } catch (_) {
    // Hand-overs accepted meanwhile would wait for a check that never comes.
    handoff.close();
    rethrow;
  }
}

/// Everything after the hand-over set-up; [handoff] is served at the end.
Future<void> _initAppServices(NewChapterCheckHandoff handoff) async {
  await initCoreDI();

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
  // Needs books (book type, chapter list) and the cover store.
  initDownloadsInjection(sl, backgroundDispatcher: newChapterCheckDispatcher);
  sl.registerFactory<DownloadSettingsViewModel>(
    () => DownloadSettingsViewModel(rules: sl<DownloadNetworkRules>()),
  );

  await setupInterceptors();

  // Needs the interceptors: probes go through DioClient. Not awaited, so a
  // slow server does not hold the first frame.
  sl<ConnectivityTriggers>().start();
  unawaited(sl<ServerConnectivityService>().start());
  sl<ReconnectSyncTrigger>().start();
  unawaited(sl<OfflineCacheMaintenance>().evictStale());
  // Plans chapters through DioClient, so after the interceptors.
  launchDownloads(sl);
  // Queues through the engine, whose start runs first.
  startNewChapterChecks(sl, handoff);

  // Last: refreshes the profile on sign-in, so it needs the interceptors
  // above and must be listening before any screen appears.
  sl<UserService>().init();
}
