import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:gatuno/features/app_lock/domain/use_cases/app_lock_service.dart';
import 'package:gatuno/features/app_lock/presentation/components/organisms/app_lock_gate.dart';
import 'package:gatuno/features/app_lock/presentation/views/app_lock_screen.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/app_lock_mocks.dart';

void main() {
  late FakeAppLockService fake;

  setUp(() => fake = FakeAppLockService());
  tearDown(() => fake.close());

  Future<void> pumpGate(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Column(
              children: [
                TextButton(
                  onPressed: () => context.push('/second'),
                  child: const Text('go second'),
                ),
                const TextField(key: Key('field')),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/second',
          builder: (_, _) => const Scaffold(body: Text('second page')),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        builder: (context, child) =>
            AppLockGate(service: fake.mock, child: child!),
      ),
    );
  }

  const locked = AppLockState(enabled: true, locked: true, isInitialized: true);
  const unlocked = AppLockState(enabled: true, isInitialized: true);

  testWidgets('shows only the child while unlocked', (tester) async {
    fake.emit(unlocked);
    await pumpGate(tester);

    expect(find.text('go second'), findsOneWidget);
    expect(find.byType(AppLockScreen), findsNothing);
    verifyNever(() => fake.mock.unlock(reason: any(named: 'reason')));
  });

  testWidgets('covers the child and prompts once when locked at start', (
    tester,
  ) async {
    fake.emit(locked);
    await pumpGate(tester);
    await tester.pump();

    expect(find.byType(AppLockScreen), findsOneWidget);
    expect(find.text('go second'), findsNothing);
    verify(() => fake.mock.unlock(reason: 'Unlock Gatuno')).called(1);
  });

  testWidgets('prompts again each time the lock engages', (tester) async {
    fake.emit(unlocked);
    await pumpGate(tester);

    fake.emit(locked);
    await tester.pump();
    fake.emit(locked.copyWith(isAuthenticating: true));
    await tester.pump();
    fake.emit(unlocked);
    await tester.pump();
    fake.emit(locked);
    await tester.pump();

    verify(() => fake.mock.unlock(reason: 'Unlock Gatuno')).called(2);
  });

  testWidgets('the Unlock button prompts again after a failure', (
    tester,
  ) async {
    fake.emit(locked.copyWith(lastOutcome: () => DeviceAuthOutcome.cancelled));
    await pumpGate(tester);
    await tester.pump();

    await tester.tap(find.text('Try again'));
    verify(() => fake.mock.unlock(reason: 'Unlock Gatuno')).called(2);
  });

  testWidgets('forwards background and foreground to the service', (
    tester,
  ) async {
    fake.emit(unlocked);
    await pumpGate(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    verify(() => fake.mock.onBackgrounded()).called(1);
    verifyNever(() => fake.mock.onForegrounded());

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    verify(() => fake.mock.onForegrounded()).called(1);
  });

  testWidgets('drops keyboard focus from the covered UI', (tester) async {
    fake.emit(unlocked);
    await pumpGate(tester);
    await tester.tap(find.byKey(const Key('field')));
    await tester.pump();
    final field = tester.state<EditableTextState>(find.byType(EditableText));
    expect(field.widget.focusNode.hasFocus, isTrue);

    fake.emit(locked);
    await tester.pump();

    expect(field.widget.focusNode.hasFocus, isFalse);
    expect(
      tester.binding.focusManager.primaryFocus?.context?.widget,
      isNot(isA<EditableText>()),
    );
  });

  testWidgets('prompts again on resume while still locked', (tester) async {
    fake.emit(locked.copyWith(lastOutcome: () => DeviceAuthOutcome.cancelled));
    await pumpGate(tester);
    await tester.pump();
    verify(() => fake.mock.unlock(reason: 'Unlock Gatuno')).called(1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    verify(() => fake.mock.unlock(reason: 'Unlock Gatuno')).called(1);
  });

  testWidgets('does not prompt on resume while a prompt is open', (
    tester,
  ) async {
    fake.emit(locked.copyWith(isAuthenticating: true));
    await pumpGate(tester);
    await tester.pump();
    clearInteractions(fake.mock);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    verifyNever(() => fake.mock.unlock(reason: any(named: 'reason')));
  });

  testWidgets('swallows the back button while locked', (tester) async {
    fake.emit(unlocked);
    await pumpGate(tester);
    await tester.tap(find.text('go second'));
    await tester.pumpAndSettle();
    expect(find.text('second page'), findsOneWidget);

    fake.emit(locked);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    fake.emit(unlocked);
    await tester.pumpAndSettle();
    expect(find.text('second page'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('second page'), findsNothing);
  });
}
