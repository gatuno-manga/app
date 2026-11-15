import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/authentication/authentication_injection.dart';
import '../../features/books/books_injection.dart';
import '../../features/downloads/data/data_sources/new_chapter_check_handoff.dart';
import '../../features/downloads/downloads_injection.dart';
import '../connectivity/connectivity_service.dart';
import '../logging/logger.dart';
import 'injection.dart';

const String _logTag = 'BackgroundCheck';

/// Entry point of the background engine the platform scheduler starts for
/// the new-chapter check (Android WorkManager, iOS BGAppRefreshTask).
@pragma('vm:entry-point')
void newChapterCheckDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    final deadline = DateTime.now().add(newChapterCheckBudget);
    try {
      // The app is running: its engine owns the database and the session.
      final handedOff = await NewChapterCheckHandoff.handOff(
        acceptTimeout: const Duration(seconds: 3),
        deadline: deadline,
      );
      if (handedOff) return true;
      await initBackgroundDI();
      // Before the session is read: a token refresh that cannot reach the
      // server signs the user out, and a self-hosted server is often
      // reachable only at home.
      final connectivity = sl<ConnectivityService>();
      await connectivity.checkNow();
      if (connectivity.status != ConnectivityStatus.online) {
        AppLogger.i('Skipped: server unreachable', _logTag);
        return true;
      }
      await runNewChapterCheck(sl, deadline: deadline);
    } catch (e, stackTrace) {
      AppLogger.e('Background check failed', e, stackTrace, _logTag);
    }
    // Never a retry: the next periodic run checks again.
    return true;
  });
}

/// The slice of [initDI] the background check needs: settings, the session,
/// books (for the engine's book type lookup) and downloads. No UI services,
/// MQTT, sync or reading, and no connectivity triggers. Nothing here turns
/// automatic download on or off, so no scheduler is registered.
Future<void> initBackgroundDI() async {
  await initCoreDI();
  initAuthenticationInjection(sl);
  await initBooksInjection(sl);
  initDownloadsInjection(sl);
  await setupInterceptors();
  // Not awaited: the engine queues its start first, so the check's enqueue
  // runs after it anyway, and the run's deadline bounds the wait.
  unawaited(
    startDownloads(sl).catchError(
      (Object e, StackTrace stackTrace) =>
          AppLogger.e('Downloads did not start', e, stackTrace, _logTag),
    ),
  );
}
