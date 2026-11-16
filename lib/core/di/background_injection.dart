import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/authentication/authentication_injection.dart';
import '../../features/books/books_injection.dart';
import '../../features/downloads/data/data_sources/new_chapter_check_handoff.dart';
import '../../features/downloads/data/data_sources/workmanager_check_scheduler.dart';
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
    final deadline = DateTime.now().add(WorkmanagerCheckScheduler.budget);
    WidgetsFlutterBinding.ensureInitialized();
    await runBackgroundCheck(
      // Visible to the app's engine from now on: one starting meanwhile
      // asks this run to stop before it touches the database or the
      // session.
      run: BackgroundRun(),
      handOff: () => NewChapterCheckHandoff.handOff(
        acceptTimeout: const Duration(seconds: 3),
        deadline: deadline,
      ),
      init: initBackgroundDI,
      serverReachable: () async {
        final connectivity = sl<ConnectivityService>();
        await connectivity.checkNow();
        return connectivity.status == ConnectivityStatus.online;
      },
      check: (stopped) async {
        launchDownloads(sl);
        await sl<NewChapterCheckRun>().run(
          deadline: deadline,
          stopped: stopped,
        );
      },
      // Closes the database and lets the engine's serial work finish before
      // the app's engine, possibly waiting, takes over.
      teardown: () =>
          sl.reset().timeout(const Duration(seconds: 3), onTimeout: () {}),
    );
    // Never a retry: the next periodic run checks again.
    return true;
  });
}

/// The steps of a background run, in order. Each one that could clash with
/// the app's engine comes after a look at whether the app asked [run] to
/// stop:
/// 1. hand the check to the app's engine if it runs ([handOff]);
/// 2. [init] the services;
/// 3. skip unless the server answers: a token refresh that cannot reach it
///    signs the user out, and a self-hosted server is often reachable only
///    at home ([serverReachable]);
/// 4. start the download engine and [check];
/// 5. [teardown], then [BackgroundRun.finish] (also on a failure).
Future<void> runBackgroundCheck({
  required BackgroundRun run,
  required Future<HandedOffRun?> Function() handOff,
  required Future<void> Function() init,
  required Future<bool> Function() serverReachable,
  required Future<void> Function(Future<void> stopped) check,
  required Future<void> Function() teardown,
}) async {
  try {
    final handedOff = await handOff();
    if (handedOff != null) {
      // Nothing runs here: the app need not wait for this run.
      run.finish();
      await handedOff.done;
      return;
    }
    if (run.stopRequested) return;
    await init();
    if (run.stopRequested) return;
    if (!await serverReachable()) {
      AppLogger.i('Skipped: server unreachable', _logTag);
      return;
    }
    if (run.stopRequested) return;
    await check(run.stopped);
  } catch (e, stackTrace) {
    AppLogger.e('Background check failed', e, stackTrace, _logTag);
  } finally {
    try {
      await teardown();
    } catch (e, stackTrace) {
      AppLogger.e('Background teardown failed', e, stackTrace, _logTag);
    }
    run.finish();
  }
}

/// The slice of `initDI` the background check needs: settings, the session,
/// books (for the engine's book type lookup) and downloads, not started. No
/// UI services, MQTT, sync or reading, and no connectivity triggers.
Future<void> initBackgroundDI() async {
  await initCoreDI();
  initAuthenticationInjection(sl);
  await initBooksInjection(sl);
  initDownloadsInjection(sl, backgroundDispatcher: newChapterCheckDispatcher);
  await setupInterceptors();
}
