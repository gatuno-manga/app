import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/new_chapter_check_handoff.dart';

void main() {
  late NewChapterCheckHandoff handoff;

  setUp(() => handoff = NewChapterCheckHandoff());
  tearDown(() {
    handoff.close();
    IsolateNameServer.removePortNameMapping(NewChapterCheckHandoff.uiPortName);
    IsolateNameServer.removePortNameMapping(
      NewChapterCheckHandoff.backgroundPortName,
    );
  });

  final deadline = DateTime.fromMillisecondsSinceEpoch(
    DateTime.now().add(const Duration(minutes: 1)).millisecondsSinceEpoch,
  );

  Future<HandedOffRun?> handOff() => NewChapterCheckHandoff.handOff(
    acceptTimeout: const Duration(milliseconds: 100),
    deadline: deadline,
  );

  group('background run handed to the app', () {
    test('no app engine: the background run keeps it', () async {
      expect(await handOff(), isNull);
    });

    test('a dead app engine is not waited for', () async {
      final dead = ReceivePort();
      IsolateNameServer.registerPortWithName(
        dead.sendPort,
        NewChapterCheckHandoff.uiPortName,
      );
      dead.close();

      expect(await handOff(), isNull);
    });

    test('the app runs it once served, and the run waits for it', () async {
      final check = Completer<void>();
      var ran = false;
      handoff.listen();

      final handedOff = await handOff();
      expect(handedOff, isNotNull);
      var done = false;
      unawaited(handedOff!.done.then((_) => done = true));

      // Requests before the app's services are ready wait for serve.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(ran, isFalse);
      DateTime? servedDeadline;
      handoff.serve((deadline) {
        ran = true;
        servedDeadline = deadline;
        return check.future;
      });
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(ran, isTrue);
      // The app works to the background task's deadline, not its own.
      expect(servedDeadline, deadline);
      expect(done, isFalse);

      check.complete();
      await handedOff.done;
      expect(done, isTrue);
    });

    test('a closed app engine no longer takes runs', () async {
      handoff
        ..listen()
        ..close();

      expect(await handOff(), isNull);
    });
  });

  group('app stopping a background run', () {
    test('returns at once when none runs', () async {
      await NewChapterCheckHandoff.stopBackgroundRun(
        timeout: const Duration(seconds: 5),
      );
    });

    test('asks the run to stop and waits until it finished', () async {
      final run = BackgroundRun();
      var stopped = false;
      final stop = NewChapterCheckHandoff.stopBackgroundRun(
        timeout: const Duration(seconds: 5),
      ).then((_) => stopped = true);

      await run.stopped;
      expect(run.stopRequested, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(stopped, isFalse);

      run.finish();
      await stop;
      expect(stopped, isTrue);
    });

    test('a finished run is not waited for', () async {
      BackgroundRun().finish();

      await NewChapterCheckHandoff.stopBackgroundRun(
        timeout: const Duration(seconds: 5),
      );
    });

    test('a dead run costs only the acknowledgement timeout', () async {
      final dead = ReceivePort();
      IsolateNameServer.registerPortWithName(
        dead.sendPort,
        NewChapterCheckHandoff.backgroundPortName,
      );
      dead.close();

      await NewChapterCheckHandoff.stopBackgroundRun(
        timeout: const Duration(minutes: 1),
        ackTimeout: const Duration(milliseconds: 50),
      );
      expect(
        IsolateNameServer.lookupPortByName(
          NewChapterCheckHandoff.backgroundPortName,
        ),
        isNull,
      );
    });

    test('gives up after the timeout', () async {
      final run = BackgroundRun();
      addTearDown(run.finish);

      await NewChapterCheckHandoff.stopBackgroundRun(
        timeout: const Duration(milliseconds: 50),
      );
      expect(run.stopRequested, isTrue);
    });
  });
}
