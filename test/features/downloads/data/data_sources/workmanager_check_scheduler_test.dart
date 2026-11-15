import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/workmanager_check_scheduler.dart';
import 'package:mocktail/mocktail.dart';
import 'package:workmanager/workmanager.dart';

class MockWorkmanager extends Mock implements Workmanager {}

void _dispatcher() {}

void main() {
  late MockWorkmanager workmanager;
  late WorkmanagerCheckScheduler scheduler;

  setUpAll(() {
    registerFallbackValue(Constraints());
    registerFallbackValue(ExistingPeriodicWorkPolicy.update);
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    workmanager = MockWorkmanager();
    when(() => workmanager.initialize(any())).thenAnswer((_) async {});
    when(
      () => workmanager.registerPeriodicTask(
        any(),
        any(),
        frequency: any(named: 'frequency'),
        initialDelay: any(named: 'initialDelay'),
        constraints: any(named: 'constraints'),
        existingWorkPolicy: any(named: 'existingWorkPolicy'),
      ),
    ).thenAnswer((_) async {});
    when(() => workmanager.cancelByUniqueName(any())).thenAnswer((_) async {});
    scheduler = WorkmanagerCheckScheduler(
      _dispatcher,
      workmanager: workmanager,
    );
  });

  test('registers one periodic task on a connected network', () async {
    const interval = Duration(hours: 6);

    await scheduler.schedule(interval);
    await scheduler.schedule(interval);

    verify(() => workmanager.initialize(_dispatcher)).called(1);
    final captured = verify(
      () => workmanager.registerPeriodicTask(
        WorkmanagerCheckScheduler.taskId,
        WorkmanagerCheckScheduler.taskId,
        frequency: interval,
        initialDelay: interval,
        constraints: captureAny(named: 'constraints'),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      ),
    ).captured;
    expect(captured, hasLength(2));
    expect((captured.first as Constraints).networkType, NetworkType.connected);
  });

  test('cancels the task by its name', () async {
    await scheduler.cancel();

    verify(
      () => workmanager.cancelByUniqueName(WorkmanagerCheckScheduler.taskId),
    ).called(1);
  });
}
