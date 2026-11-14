import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/connectivity/connectivity_service.dart';
import 'package:gatuno/features/sync/domain/use_cases/app_sync_coordinator.dart';
import 'package:gatuno/features/sync/domain/use_cases/reconnect_sync_trigger.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockAppSyncCoordinator extends Mock implements AppSyncCoordinator {}

void main() {
  test('syncs on every reconnect until disposed', () async {
    final connectivity = MockConnectivityService();
    final coordinator = MockAppSyncCoordinator();
    final reconnects = StreamController<void>.broadcast();
    when(() => connectivity.onReconnected).thenAnswer((_) => reconnects.stream);
    when(() => coordinator.sync()).thenAnswer((_) async {});

    final trigger = ReconnectSyncTrigger(connectivity, coordinator)..start();
    reconnects.add(null);
    await Future<void>.delayed(Duration.zero);
    verify(() => coordinator.sync()).called(1);

    await trigger.dispose();
    reconnects.add(null);
    await Future<void>.delayed(Duration.zero);
    verifyNever(() => coordinator.sync());
    await reconnects.close();
  });
}
