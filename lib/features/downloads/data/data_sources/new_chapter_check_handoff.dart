import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

/// Keeps the app's engine and a background new-chapter run from working at
/// the same time: both would write the downloads database, plan chapters
/// and refresh the session.
///
/// Two names in [IsolateNameServer], one per side:
/// - The app registers [uiPortName] first thing on start ([listen]). A
///   background run that finds it hands its check over ([handOff]) instead
///   of starting its own engine work; the app runs it once its services are
///   ready ([serve]) and answers [finished], so the background task stays
///   open (and the app awake) until then.
/// - A background run registers [backgroundPortName] for its whole length
///   ([BackgroundRun]). The app, starting while one runs, asks it to stop at
///   the next book and waits for it ([stopBackgroundRun]) before its own
///   downloads and session start.
///
/// Registering before looking the other side up means that of two engines
/// starting together, at least one sees the other.
class NewChapterCheckHandoff {
  static const String uiPortName = 'gatuno.new_chapter_check.ui';
  static const String backgroundPortName = 'gatuno.new_chapter_check.bg';
  static const String accepted = 'accepted';
  static const String finished = 'finished';

  ReceivePort? _port;
  Future<void> Function(DateTime deadline)? _check;
  final List<_Request> _waiting = [];

  /// App side: takes background runs from now on; they wait for [serve].
  void listen() {
    if (_port != null) return;
    final port = _port = ReceivePort();
    _register(port.sendPort, uiPortName);
    port.listen((message) {
      final request = _Request.decode(message);
      if (request == null) return;
      request.reply.send(accepted);
      final check = _check;
      if (check == null) {
        _waiting.add(request);
      } else {
        _run(check, request);
      }
    });
  }

  /// App side: runs [check] for every background run handed over, also the
  /// ones that came before, with the background task's deadline: the
  /// platform may suspend the app once that task ends.
  void serve(Future<void> Function(DateTime deadline) check) {
    _check = check;
    for (final request in _waiting) {
      _run(check, request);
    }
    _waiting.clear();
  }

  void _run(Future<void> Function(DateTime deadline) check, _Request request) =>
      unawaited(
        check(
          request.deadline,
        ).whenComplete(() => request.reply.send(finished)),
      );

  void close() {
    final port = _port;
    if (port == null) return;
    _unregister(port.sendPort, uiPortName);
    port.close();
    _port = null;
    for (final request in _waiting) {
      request.reply.send(finished);
    }
    _waiting.clear();
  }

  /// App side: asks a background run in progress to stop and waits until it
  /// ended, at most [timeout]. Returns at once when none runs; a dead run's
  /// stale name costs [ackTimeout].
  static Future<void> stopBackgroundRun({
    required Duration timeout,
    Duration ackTimeout = const Duration(seconds: 1),
  }) async {
    final run = IsolateNameServer.lookupPortByName(backgroundPortName);
    if (run == null) return;
    final reply = ReceivePort();
    final messages = StreamIterator<Object?>(reply);
    try {
      run.send(reply.sendPort);
      final alive = await messages.moveNext().timeout(
        ackTimeout,
        onTimeout: () => false,
      );
      if (!alive) {
        _unregister(run, backgroundPortName);
        return;
      }
      if (messages.current == finished) return;
      await messages.moveNext().timeout(timeout, onTimeout: () => false);
    } finally {
      await messages.cancel();
      reply.close();
    }
  }

  /// Background side: hands the check to the app's engine. `null` when no
  /// app engine answered within [acceptTimeout] (none, or a dead one).
  static Future<HandedOffRun?> handOff({
    required Duration acceptTimeout,
    required DateTime deadline,
  }) async {
    final ui = IsolateNameServer.lookupPortByName(uiPortName);
    if (ui == null) return null;
    final reply = ReceivePort();
    final messages = StreamIterator<Object?>(reply);
    Future<void> close() async {
      await messages.cancel();
      reply.close();
    }

    ui.send(_Request(reply.sendPort, deadline).encode());
    final got = await messages.moveNext().timeout(
      acceptTimeout,
      onTimeout: () => false,
    );
    if (!got || messages.current != accepted) {
      await close();
      return null;
    }
    Future<void> finish() async {
      try {
        final left = deadline.difference(DateTime.now());
        if (left > Duration.zero) {
          await messages.moveNext().timeout(left, onTimeout: () => false);
        }
      } finally {
        await close();
      }
    }

    return HandedOffRun._(finish());
  }

  static void _register(SendPort port, String name) {
    // A mapping left by an engine of this process that died is stale.
    IsolateNameServer.removePortNameMapping(name);
    IsolateNameServer.registerPortWithName(port, name);
  }

  static void _unregister(SendPort port, String name) {
    if (IsolateNameServer.lookupPortByName(name) == port) {
      IsolateNameServer.removePortNameMapping(name);
    }
  }
}

/// A check the app's engine took over from a background run.
class HandedOffRun {
  /// Completes when the app finished the check, or at the deadline (if the
  /// app dies meanwhile the time is up anyway).
  final Future<void> done;

  HandedOffRun._(this.done);
}

/// A hand-over request: where to answer, and the background task's
/// deadline. Sent as a list of plain values.
class _Request {
  final SendPort reply;
  final DateTime deadline;

  const _Request(this.reply, this.deadline);

  List<Object> encode() => [reply, deadline.millisecondsSinceEpoch];

  static _Request? decode(Object? message) => switch (message) {
    [final SendPort reply, final int deadline] => _Request(
      reply,
      DateTime.fromMillisecondsSinceEpoch(deadline),
    ),
    _ => null,
  };
}

/// A background run in progress, visible to the app's engine, which can ask
/// it to stop. [finish] it when the run ends.
class BackgroundRun {
  final ReceivePort _port = ReceivePort();
  final Completer<void> _stop = Completer<void>();
  final List<SendPort> _waiting = [];
  bool _finished = false;

  BackgroundRun() {
    NewChapterCheckHandoff._register(
      _port.sendPort,
      NewChapterCheckHandoff.backgroundPortName,
    );
    _port.listen((message) {
      if (message is! SendPort) return;
      if (_finished) {
        message.send(NewChapterCheckHandoff.finished);
        return;
      }
      message.send(NewChapterCheckHandoff.accepted);
      _waiting.add(message);
      if (!_stop.isCompleted) _stop.complete();
    });
  }

  /// Whether the app asked this run to stop.
  bool get stopRequested => _stop.isCompleted;

  /// Completes when the app asks this run to stop.
  Future<void> get stopped => _stop.future;

  void finish() {
    if (_finished) return;
    _finished = true;
    NewChapterCheckHandoff._unregister(
      _port.sendPort,
      NewChapterCheckHandoff.backgroundPortName,
    );
    for (final reply in _waiting) {
      reply.send(NewChapterCheckHandoff.finished);
    }
    _waiting.clear();
    _port.close();
  }
}
