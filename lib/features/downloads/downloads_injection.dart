import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/connectivity/connectivity_service.dart';
import '../../core/covers/cover_store.dart';
import '../../core/network/dio_client.dart';
import '../../l10n/app_localizations.dart';
import '../books/domain/repositories/books_repository.dart';
import 'data/data_sources/background_downloader_transfer_queue.dart';
import 'data/data_sources/download_remote_data_source.dart';
import 'data/data_sources/download_storage.dart';
import 'data/data_sources/transfer_queue.dart';
import 'data/data_sources/unmetered_network_monitor.dart';
import 'data/database/downloads_database.dart';
import 'data/repositories/download_manager.dart';
import 'data/repositories/downloaded_content_impl.dart';
import 'domain/repositories/download_network_policy.dart';
import 'domain/repositories/download_service.dart';
import 'domain/repositories/downloaded_content.dart';
import 'domain/use_cases/any_network_policy.dart';

/// Registers downloads. Needs DioClient, ConnectivityService, CoverStore and
/// BooksRepository. Start the engine with [startDownloads] once the Dio
/// interceptors are set up.
void initDownloadsInjection(GetIt sl) {
  sl.registerLazySingleton<DownloadsDatabase>(
    () => DownloadsDatabase(),
    dispose: (db) => db.close(),
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
  // Replaced by the user's per-type setting.
  sl.registerLazySingleton<DownloadNetworkPolicy>(
    () => const AnyNetworkPolicy(),
  );
  sl.registerLazySingleton<DownloadManager>(
    () => DownloadManager(
      db: sl<DownloadsDatabase>(),
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
  sl.registerLazySingleton<DownloadedContent>(
    () => DownloadedContentImpl(sl<DownloadsDatabase>(), sl<DownloadStorage>()),
  );
}

/// Starts watching the network type and the native queue, and applies what
/// finished while the app was closed. Needs the Dio interceptors: planning
/// goes through DioClient.
Future<void> startDownloads(GetIt sl) async {
  await sl<UnmeteredNetworkMonitor>().start();
  await sl<DownloadManager>().start();
}

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
