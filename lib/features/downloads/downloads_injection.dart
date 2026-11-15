import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:rxdart/rxdart.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/connectivity/connectivity_service.dart';
import '../../core/covers/cover_store.dart';
import '../../core/network/dio_client.dart';
import '../../l10n/app_localizations.dart';
import '../../core/logging/logger.dart';
import '../authentication/domain/use_cases/auth_service.dart';
import '../books/domain/repositories/books_repository.dart';
import '../settings/domain/use_cases/settings_service.dart';
import 'data/data_sources/app_resumes.dart';
import 'data/data_sources/background_downloader_transfer_queue.dart';
import 'data/data_sources/download_network_rules_storage.dart';
import 'data/data_sources/download_records.dart';
import 'data/data_sources/download_remote_data_source.dart';
import 'data/data_sources/download_storage.dart';
import 'data/data_sources/new_chapter_check_handoff.dart';
import 'data/data_sources/transfer_queue.dart';
import 'data/data_sources/unmetered_network_monitor.dart';
import 'data/database/downloads_database.dart';
import 'data/repositories/auto_download_preferences_impl.dart';
import 'data/repositories/checking_auto_download_preferences.dart';
import 'data/repositories/download_manager.dart';
import 'data/repositories/downloaded_content_impl.dart';
import 'data/repositories/graphql_new_chapter_source.dart';
import 'data/repositories/records_new_chapter_ledger.dart';
import 'data/repositories/stored_download_network_rules.dart';
import 'domain/repositories/auto_download_preferences.dart';
import 'domain/repositories/download_network_policy.dart';
import 'domain/repositories/download_network_rules.dart';
import 'domain/repositories/download_service.dart';
import 'domain/repositories/downloaded_content.dart';
import 'domain/repositories/new_chapter_check_scheduler.dart';
import 'domain/repositories/new_chapter_ledger.dart';
import 'domain/repositories/new_chapter_source.dart';
import 'domain/use_cases/await_planned.dart';
import 'domain/use_cases/new_chapter_check.dart';
import 'domain/use_cases/new_chapter_check_triggers.dart';

/// Registers downloads. Needs DioClient, ConnectivityService, CoverStore,
/// BooksRepository, AuthService and SettingsService (resolved on first use),
/// and a [NewChapterCheckScheduler] registered by the caller. Start the engine with [startDownloads] once the Dio
/// interceptors are set up.
void initDownloadsInjection(GetIt sl) {
  sl.registerLazySingleton<DownloadsDatabase>(
    () => DownloadsDatabase(),
    dispose: (db) => db.close(),
  );
  sl.registerLazySingleton<DownloadRecords>(
    () => DownloadRecords(sl<DownloadsDatabase>()),
  );
  sl.registerLazySingleton<DownloadStorage>(
    () => DownloadStorage(getApplicationSupportDirectory),
  );
  sl.registerLazySingleton<DownloadRemoteDataSource>(
    () => DownloadRemoteDataSource(sl<DioClient>()),
  );
  sl.registerLazySingleton<UnmeteredNetworkMonitor>(
    UnmeteredNetworkMonitor.new,
    dispose: (monitor) => monitor.dispose(),
  );
  sl.registerLazySingleton<BackgroundDownloaderTransferQueue>(
    () => BackgroundDownloaderTransferQueue(texts: _notificationTexts),
    dispose: (queue) => queue.dispose(),
  );
  sl.registerLazySingleton<TransferQueue>(
    () => sl<BackgroundDownloaderTransferQueue>(),
  );
  sl.registerLazySingleton<DownloadNetworkRulesStorage>(
    DownloadNetworkRulesStorage.new,
  );
  sl.registerLazySingleton<StoredDownloadNetworkRules>(
    () => StoredDownloadNetworkRules(sl<DownloadNetworkRulesStorage>()),
    dispose: (rules) => rules.dispose(),
  );
  sl.registerLazySingleton<DownloadNetworkRules>(
    () => sl<StoredDownloadNetworkRules>(),
  );
  // The engine reads the same rules the settings screen edits.
  sl.registerLazySingleton<DownloadNetworkPolicy>(
    () => sl<DownloadNetworkRules>(),
  );
  sl.registerLazySingleton<DownloadManager>(
    () => DownloadManager(
      records: sl<DownloadRecords>(),
      storage: sl<DownloadStorage>(),
      transfers: sl<TransferQueue>(),
      remote: sl<DownloadRemoteDataSource>(),
      books: sl<BooksRepository>(),
      covers: sl<CoverStore>(),
      policy: sl<DownloadNetworkPolicy>(),
      connectivity: sl<ConnectivityService>(),
      unmetered: sl<UnmeteredNetworkMonitor>().stream,
    ),
    dispose: (manager) => manager.dispose(),
  );
  sl.registerLazySingleton<DownloadService>(() => sl<DownloadManager>());
  _initNewChapterCheck(sl);
  sl.registerLazySingleton<DownloadedContent>(
    () => DownloadedContentImpl(
      sl<DownloadRecords>(),
      sl<DownloadStorage>(),
      resolveUrl: sl<DownloadRemoteDataSource>().resolve,
    ),
  );
}

/// Starts watching the network type and the native queue, and applies what
/// finished while the app was closed. Needs the Dio interceptors: planning
/// goes through DioClient.
Future<void> startDownloads(GetIt sl) async {
  // The manager first: its start must be its first serial operation, before
  // any command.
  final started = sl<DownloadManager>().start();
  await sl<UnmeteredNetworkMonitor>().start();
  await started;
}

/// Automatic download of new chapters (#94): the setting, the check and its
/// in-app triggers.
void _initNewChapterCheck(GetIt sl) {
  sl.registerLazySingleton<NewChapterLedger>(
    () => RecordsNewChapterLedger(sl<DownloadRecords>()),
  );
  sl.registerLazySingleton<NewChapterSource>(
    () => GraphqlNewChapterSource(sl<DioClient>()),
  );
  sl.registerLazySingleton<NewChapterCheck>(
    () => NewChapterCheck(
      ledger: sl<NewChapterLedger>(),
      source: sl<NewChapterSource>(),
      downloads: sl<DownloadService>(),
      signedIn: () => _signedIn(sl<AuthService>()),
      server: () => sl<SettingsService>().apiUrl,
    ),
  );
  sl.registerLazySingleton<CheckingAutoDownloadPreferences>(
    () => CheckingAutoDownloadPreferences(
      AutoDownloadPreferencesImpl(sl<DownloadRecords>()),
      sl<NewChapterCheck>(),
      sl<NewChapterCheckScheduler>(),
    ),
  );
  sl.registerLazySingleton<AutoDownloadPreferences>(
    () => sl<CheckingAutoDownloadPreferences>(),
  );
  sl.registerLazySingleton<AppResumes>(
    AppResumes.new,
    dispose: (resumes) => resumes.dispose(),
  );
  sl.registerLazySingleton<NewChapterCheckTriggers>(
    () => NewChapterCheckTriggers(
      sl<NewChapterCheck>(),
      triggers: Rx.merge<void>([
        sl<AppResumes>().stream,
        sl<ConnectivityService>().onReconnected,
      ]),
    ),
    dispose: (triggers) => triggers.dispose(),
  );
  sl.registerLazySingleton<NewChapterCheckHandoff>(
    NewChapterCheckHandoff.new,
    dispose: (handoff) => handoff.close(),
  );
}

/// Whether someone is signed in, once the stored session was read.
Future<bool> _signedIn(AuthService auth) async {
  if (!auth.isInitialized) {
    await auth.authStateStream.firstWhere(
      (state) => state != AuthState.uninitialized,
    );
  }
  return auth.authenticated;
}

/// How long a background run may take: iOS gives a `BGAppRefreshTask` about
/// 30 s, Android WorkManager 10 min.
Duration get newChapterCheckBudget =>
    Platform.isIOS ? const Duration(seconds: 25) : const Duration(minutes: 8);

/// Checks for new chapters in the app: now, on resume and on reconnect (at
/// most hourly), and for background runs handed over to this isolate. Keeps
/// the background schedule in step with the setting.
void startNewChapterChecks(GetIt sl) {
  sl<NewChapterCheckTriggers>().start();
  sl<NewChapterCheckHandoff>().listen(
    () => runNewChapterCheck(
      sl,
      deadline: DateTime.now().add(newChapterCheckBudget),
    ),
  );
  unawaited(sl<CheckingAutoDownloadPreferences>().syncSchedule());
}

/// One background run: checks every book, then waits until the chapters it
/// queued are planned, so their files are with the native queue before the
/// run ends.
Future<void> runNewChapterCheck(GetIt sl, {required DateTime deadline}) async {
  try {
    // The deadline bounds the whole run, also a native call that never
    // answers: the platform would kill a task that overstays.
    final result = await sl<NewChapterCheck>()
        .run(deadline: deadline)
        .timeout(deadline.difference(DateTime.now()));
    await awaitPlanned(
      sl<DownloadService>(),
      result.queued,
      deadline: deadline,
    );
  } on TimeoutException {
    AppLogger.w('New-chapter check ran out of time', 'downloads');
  } catch (e, stackTrace) {
    AppLogger.e('New-chapter check failed', e, stackTrace, 'downloads');
  }
}

/// Deletes every download, for a server change: they belong to the old
/// server.
Future<void> clearDownloads(GetIt sl) => sl<DownloadManager>().clearAll();

/// Notification texts in the device language: notifications show outside
/// any widget tree.
DownloadNotificationTexts _notificationTexts() {
  final l10n = lookupAppLocalizations(_supportedLocale());
  return DownloadNotificationTexts(
    runningTitle: l10n.downloadsNotificationRunningTitle,
    runningBody: l10n.downloadsNotificationRunningBody(
      '{numFinished}',
      '{numTotal}',
    ),
    completeTitle: l10n.downloadsNotificationCompleteTitle,
    completeBody: l10n.downloadsNotificationCompleteBody('{numTotal}'),
    errorTitle: l10n.downloadsNotificationErrorTitle,
    errorBody: l10n.downloadsNotificationErrorBody('{numFailed}', '{numTotal}'),
    cancel: l10n.commonCancel,
  );
}

Locale _supportedLocale() {
  final device = PlatformDispatcher.instance.locale;
  for (final locale in AppLocalizations.supportedLocales) {
    if (locale.languageCode == device.languageCode) return locale;
  }
  return const Locale('en');
}
