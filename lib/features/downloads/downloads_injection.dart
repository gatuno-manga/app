import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/connectivity/connectivity_service.dart';
import '../../core/covers/cover_store.dart';
import '../../core/network/dio_client.dart';
import '../../l10n/app_localizations.dart';
import '../books/domain/repositories/books_repository.dart';
import 'data/data_sources/background_downloader_transfer_queue.dart';
import 'data/data_sources/download_network_rules_storage.dart';
import 'data/data_sources/download_records.dart';
import 'data/data_sources/download_remote_data_source.dart';
import 'data/data_sources/download_storage.dart';
import 'data/data_sources/transfer_queue.dart';
import 'data/data_sources/unmetered_network_monitor.dart';
import 'data/database/downloads_database.dart';
import 'data/repositories/auto_download_preferences_impl.dart';
import 'data/repositories/download_manager.dart';
import 'data/repositories/downloaded_content_impl.dart';
import 'data/repositories/stored_download_network_rules.dart';
import 'domain/repositories/auto_download_preferences.dart';
import 'domain/repositories/download_network_policy.dart';
import 'domain/repositories/download_network_rules.dart';
import 'domain/repositories/download_service.dart';
import 'domain/repositories/downloaded_content.dart';

/// Registers downloads. Needs DioClient, ConnectivityService, CoverStore and
/// BooksRepository. Start the engine with [startDownloads] once the Dio
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
  sl.registerLazySingleton<AutoDownloadPreferences>(
    () => AutoDownloadPreferencesImpl(sl<DownloadRecords>()),
  );
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
