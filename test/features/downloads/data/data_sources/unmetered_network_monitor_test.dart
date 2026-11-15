import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/unmetered_network_monitor.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity connectivity;
  late StreamController<List<ConnectivityResult>> changes;
  late UnmeteredNetworkMonitor monitor;

  setUp(() {
    connectivity = MockConnectivity();
    changes = StreamController<List<ConnectivityResult>>.broadcast();
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => changes.stream);
    monitor = UnmeteredNetworkMonitor();
  });

  tearDown(() async {
    await monitor.dispose();
    await changes.close();
  });

  test('only Wi-Fi counts, as DownloadNetwork.unmetered means', () async {
    when(
      () => connectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.ethernet]);
    final seen = <bool>[];
    final sub = monitor.stream.listen(seen.add);

    await monitor.start(connectivity: connectivity);
    changes.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);
    changes.add([ConnectivityResult.mobile]);
    await Future<void>.delayed(Duration.zero);

    expect(seen, [false, true, false]);
    await sub.cancel();
  });
}
