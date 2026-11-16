import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/authentication/authentication_injection.dart';
import '../../features/books/books_injection.dart';
import '../../features/downloads/data/data_sources/new_chapter_check_handoff.dart';
import '../../features/downloads/domain/use_cases/new_chapter_check_run.dart';
import '../../features/downloads/downloads_injection.dart';
import '../connectivity/connectivity_service.dart';
import '../logging/logger.dart';
import 'core_injection.dart';

const String _logTag = 'BackgroundCheck';

/// Entry point of the background engine the platform scheduler starts for
/// the new-chapter check (Android WorkManager, iOS BGAppRefreshTask).
@pragma('vm:entry-point')
void newChapterCheckDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final deadline = DateTime.now().add(NewChapterCheckRun.budget);
    WidgetsFlutterBinding.ensureInitialized();
    // Visible to the app's engine from now on: one starting meanwhile asks
    // this run to stop before it touches the database or the session.
    final run = BackgroundRun();
    try {
      // The app is running: its engine owns the database and the session.
      final handedOff = await NewChapterCheckHandoff.handOff(
        acceptTimeout: const Duration(seconds: 3),
        deadline: deadline,
      );
      if (handedOff != null) {
        // Nothing runs here: the app need not wait for this run.
        run.finish();
        await handedOff.done;
        return true;
      }
      if (run.stopRequested) return true;
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
      if (run.stopRequested) return true;
      await sl<NewChapterCheckRun>().run(
        deadline: deadline,
        stopped: run.stopped,
      );
    } catch (e, stackTrace) {
      AppLogger.e('Background check failed', e, stackTrace, _logTag);
    } finally {
      // Closes the database and lets the engine's serial work finish before
      // the app's engine, possibly waiting, takes over.
      await sl
          .reset()
          .timeout(const Duration(seconds: 3), onTimeout: () {})
          .catchError((Object e, StackTrace stackTrace) {
            AppLogger.e('Background teardown failed', e, stackTrace, _logTag);
          });
      run.finish();
    }
    // Never a retry: the next periodic run checks again.
    return true;
  });
}

/// The slice of `initDI` the background check needs: settings, the session,
/// books (for the engine's book type lookup) and downloads. No UI services,
/// MQTT, sync or reading, and no connectivity triggers.
Future<void> initBackgroundDI() async {
  await initCoreDI();
  initAuthenticationInjection(sl);
  await initBooksInjection(sl);
  initDownloadsInjection(sl, backgroundDispatcher: newChapterCheckDispatcher);
  await setupInterceptors();
  launchDownloads(sl);
}
