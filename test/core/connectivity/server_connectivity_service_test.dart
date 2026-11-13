import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/core/connectivity/server_connectivity_service.dart';

void main() {
  late List<bool?> probeResults;
  late int probes;
  late StreamController<void> triggers;

  ServerConnectivityService build() {
    return ServerConnectivityService(
      probe: () async {
        probes++;
        return probeResults.isEmpty ? true : probeResults.removeAt(0);
      },
      triggers: triggers.stream,
    );
  }

  setUp(() {
    probeResults = [];
    probes = 0;
    triggers = StreamController<void>.broadcast();
  });

  tearDown(() => triggers.close());

  test('starts online until a probe says otherwise', () {
    fakeAsync((async) {
      final service = build();
      expect(service.status, ConnectivityStatus.online);

      probeResults = [false];
      service.start();
      async.flushMicrotasks();

      expect(service.status, ConnectivityStatus.offline);
      expect(service.isOffline, isTrue);
      service.dispose();
    });
  });

  test('a null probe result (no server configured) keeps the status', () {
    fakeAsync((async) {
      final service = build();
      probeResults = [false, null];
      service.reportUnreachable();
      async.flushMicrotasks();
      service.checkNow();
      async.flushMicrotasks();

      expect(service.status, ConnectivityStatus.offline);
      service.dispose();
    });
  });

  test('a throwing probe counts as unreachable', () {
    fakeAsync((async) {
      final service = ServerConnectivityService(
        probe: () async => throw StateError('boom'),
      );
      service.checkNow();
      async.flushMicrotasks();

      expect(service.status, ConnectivityStatus.offline);
      service.dispose();
    });
  });

  test('request outcomes flip the status at once', () {
    fakeAsync((async) {
      final service = build();
      final statuses = <ConnectivityStatus>[];
      service.statusStream.listen(statuses.add);
      probeResults = [true];

      service.reportUnreachable();
      service.reportUnreachable();
      service.reportReachable();
      async.flushMicrotasks();

      expect(statuses, [
        ConnectivityStatus.online,
        ConnectivityStatus.offline,
        ConnectivityStatus.online,
      ]);
      service.dispose();
    });
  });

  test('a failed request re-probes at once to confirm', () {
    fakeAsync((async) {
      final service = build();
      probeResults = [true];
      service.reportUnreachable();
      expect(service.status, ConnectivityStatus.offline);

      async.flushMicrotasks();
      expect(probes, 1);
      expect(service.status, ConnectivityStatus.online);
      service.dispose();
    });
  });

  test('polls every 30 s while offline and stops once online', () {
    fakeAsync((async) {
      final service = build();
      probeResults = [false, false, false, true];
      service.reportUnreachable();
      async.flushMicrotasks();
      expect(probes, 1);

      async.elapse(const Duration(seconds: 29));
      expect(probes, 1);
      async.elapse(const Duration(seconds: 1));
      expect(probes, 2);
      expect(service.status, ConnectivityStatus.offline);

      async.elapse(const Duration(seconds: 60));
      expect(probes, 4);
      expect(service.status, ConnectivityStatus.online);

      async.elapse(const Duration(minutes: 5));
      expect(probes, 4);
      service.dispose();
    });
  });

  test('triggers (network change, resume) probe again', () {
    fakeAsync((async) {
      final service = build();
      service.start();
      async.flushMicrotasks();
      expect(probes, 1);

      probeResults = [false];
      triggers.add(null);
      async.flushMicrotasks();

      expect(probes, 2);
      expect(service.status, ConnectivityStatus.offline);
      service.dispose();
    });
  });

  test('concurrent checks share one probe', () {
    fakeAsync((async) {
      final service = build();
      service.checkNow();
      service.checkNow();
      async.flushMicrotasks();

      expect(probes, 1);
      service.dispose();
    });
  });

  test('onReconnected fires once, after the debounce', () {
    fakeAsync((async) {
      final service = build();
      var reconnects = 0;
      service.onReconnected.listen((_) => reconnects++);
      probeResults = [false];

      service.reportUnreachable();
      async.flushMicrotasks();
      service.reportReachable();
      async.elapse(const Duration(seconds: 1));
      expect(reconnects, 0);

      async.elapse(const Duration(seconds: 1));
      expect(reconnects, 1);

      async.elapse(const Duration(minutes: 1));
      expect(reconnects, 1);
      service.dispose();
    });
  });

  test('a flapping link does not fire onReconnected', () {
    fakeAsync((async) {
      final service = build();
      var reconnects = 0;
      service.onReconnected.listen((_) => reconnects++);
      probeResults = [false, false];

      service.reportUnreachable();
      async.flushMicrotasks();
      service.reportReachable();
      async.elapse(const Duration(milliseconds: 500));
      service.reportUnreachable();
      async.elapse(const Duration(seconds: 5));

      expect(reconnects, 0);
      service.dispose();
    });
  });

  test('onReconnected does not fire without an offline period', () {
    fakeAsync((async) {
      final service = build();
      var reconnects = 0;
      service.onReconnected.listen((_) => reconnects++);

      service.reportReachable();
      async.elapse(const Duration(seconds: 5));

      expect(reconnects, 0);
      service.dispose();
    });
  });
}
