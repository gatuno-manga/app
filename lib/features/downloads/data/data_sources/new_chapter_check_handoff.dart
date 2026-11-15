import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

/// Hands a background new-chapter check to the app's UI isolate when it is
/// alive, so two engines never write the downloads database or refresh the
/// session at the same time.
///
/// The UI isolate [listen]s under [portName]. A background run sends it a
/// reply port; the UI isolate answers [accepted] at once, runs the check,
/// then answers [finished]. The background run keeps its task open until
/// then, so the system does not suspend the app mid-check.
class NewChapterCheckHandoff {
  static const String portName = 'gatuno.new_chapter_check';
  static const String accepted = 'accepted';
  static const String finished = 'finished';

  ReceivePort? _port;

  /// UI isolate: runs [check] for every background request.
  void listen(Future<void> Function() check) {
    if (_port != null) return;
    final port = _port = ReceivePort();
    // A mapping left by an earlier UI isolate of this process is stale.
    IsolateNameServer.removePortNameMapping(portName);
    IsolateNameServer.registerPortWithName(port.sendPort, portName);
    port.listen((message) {
      if (message is! SendPort) return;
      message.send(accepted);
      unawaited(check().whenComplete(() => message.send(finished)));
    });
  }

  void close() {
    final port = _port;
    if (port == null) return;
    if (IsolateNameServer.lookupPortByName(portName) == port.sendPort) {
      IsolateNameServer.removePortNameMapping(portName);
    }
    port.close();
    _port = null;
  }

  /// Background: whether a live UI isolate ran the check. `false` when none
  /// answered within [acceptTimeout] (no UI isolate, or a dead one). Waits
  /// for it to finish until [deadline].
  static Future<bool> handOff({
    required Duration acceptTimeout,
    required DateTime deadline,
  }) async {
    final ui = IsolateNameServer.lookupPortByName(portName);
    if (ui == null) return false;
    final reply = ReceivePort();
    final messages = StreamIterator<Object?>(reply);
    try {
      ui.send(reply.sendPort);
      final got = await messages.moveNext().timeout(
        acceptTimeout,
        onTimeout: () => false,
      );
      if (!got || messages.current != accepted) return false;
      final left = deadline.difference(DateTime.now());
      if (left > Duration.zero) {
        await messages.moveNext().timeout(left, onTimeout: () => false);
      }
      return true;
    } finally {
      await messages.cancel();
      reply.close();
    }
  }
}
