import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/background_injection.dart';
import 'package:gatuno/features/downloads/data/data_sources/new_chapter_check_handoff.dart';

/// Runs [runBackgroundCheck] with recording steps.
class Steps {
  final List<String> log = [];
  final BackgroundRun run = BackgroundRun();
  HandedOffRun? handedOff;
  bool reachable = true;
  void Function(String step)? onStep;

  /// Real steps do I/O, so a stop request (a port message) can arrive
  /// meanwhile; these yield to the event loop to let it.
  Future<void> _step(String name) async {
    log.add(name);
    onStep?.call(name);
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }

  Future<void> go() => runBackgroundCheck(
    run: run,
    handOff: () async {
      await _step('handOff');
      return handedOff;
    },
    init: () => _step('init'),
    serverReachable: () async {
      await _step('probe');
      return reachable;
    },
    check: (stopped) => _step('check'),
    teardown: () => _step('teardown'),
  );
}

void main() {
  tearDown(
    () => IsolateNameServer.removePortNameMapping(
      NewChapterCheckHandoff.backgroundPortName,
    ),
  );

  Future<void> askToStop() => NewChapterCheckHandoff.stopBackgroundRun(
    timeout: const Duration(seconds: 5),
  );

  test('runs every step in order, then finishes', () async {
    final steps = Steps();

    await steps.go();

    expect(steps.log, ['handOff', 'init', 'probe', 'check', 'teardown']);
    expect(
      IsolateNameServer.lookupPortByName(
        NewChapterCheckHandoff.backgroundPortName,
      ),
      isNull,
    );
  });

  test('handed to the app: no services, no check', () async {
    final steps = Steps();
    final done = Completer<void>();
    steps.handedOff = await _handedOff(done.future);
    done.complete();

    await steps.go();

    expect(steps.log, ['handOff', 'teardown']);
  });

  test('server unreachable: nothing is checked', () async {
    final steps = Steps()..reachable = false;

    await steps.go();

    expect(steps.log, ['handOff', 'init', 'probe', 'teardown']);
  });

  for (final after in ['handOff', 'init', 'probe']) {
    test('stops when the app asks during $after', () async {
      final steps = Steps();
      Future<void>? stop;
      steps.onStep = (step) {
        if (step == after) stop = askToStop();
      };

      await steps.go();
      await stop;

      expect(steps.log, isNot(contains('check')));
      expect(steps.log.last, 'teardown');
    });
  }

  test('a failing step still tears down and finishes', () async {
    final run = BackgroundRun();
    final log = <String>[];

    await runBackgroundCheck(
      run: run,
      handOff: () async => null,
      init: () async => throw StateError('boom'),
      serverReachable: () async => true,
      check: (_) async => log.add('check'),
      teardown: () async => log.add('teardown'),
    );

    expect(log, ['teardown']);
    // Finished: the app is answered at once.
    await askToStop();
  });
}

/// A [HandedOffRun] whose check is already done, through a real hand-over.
Future<HandedOffRun> _handedOff(Future<void> check) async {
  final app = NewChapterCheckHandoff()
    ..listen()
    ..serve((_) => check);
  addTearDown(app.close);
  final handed = await NewChapterCheckHandoff.handOff(
    acceptTimeout: const Duration(seconds: 1),
    deadline: DateTime.now().add(const Duration(minutes: 1)),
  );
  return handed!;
}
