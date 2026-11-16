import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/workmanager_check_scheduler.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    SharedPreferences.setMockInitialValues({});
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

  List<dynamic> registrations(Duration interval) => verify(
    () => workmanager.registerPeriodicTask(
      WorkmanagerCheckScheduler.taskId,
      WorkmanagerCheckScheduler.taskId,
      frequency: interval,
      initialDelay: interval,
      constraints: captureAny(named: 'constraints'),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    ),
  ).captured;

  test('registers one periodic task on a connected network', () async {
    const interval = Duration(hours: 6);

    await scheduler.schedule(interval);

    verify(() => workmanager.initialize(_dispatcher)).called(1);
    final captured = registrations(interval);
    expect(captured, hasLength(1));
    expect((captured.single as Constraints).networkType, NetworkType.connected);
  });

  test('does not register again for the same interval', () async {
    const interval = Duration(hours: 6);

    await scheduler.schedule(interval);
    await WorkmanagerCheckScheduler(
      _dispatcher,
      workmanager: workmanager,
    ).schedule(interval);

    expect(registrations(interval), hasLength(1));
  });

  test('registers again for a new interval or after a cancel', () async {
    await scheduler.schedule(const Duration(hours: 6));
    await scheduler.schedule(const Duration(hours: 3));
    await scheduler.cancel();
    await scheduler.schedule(const Duration(hours: 3));

    expect(registrations(const Duration(hours: 6)), hasLength(1));
    expect(registrations(const Duration(hours: 3)), hasLength(2));
  });

  test('cancels the task by its name', () async {
    await scheduler.cancel();

    verify(
      () => workmanager.cancelByUniqueName(WorkmanagerCheckScheduler.taskId),
    ).called(1);
  });
}
