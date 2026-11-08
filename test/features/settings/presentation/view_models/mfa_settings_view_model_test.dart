import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/authentication/domain/repositories/mfa_repository.dart';
import 'package:gatuno/features/authentication/domain/value_objects/mfa_models.dart';
import 'package:gatuno/features/authentication/presentation/view_models/mfa_error.dart';
import 'package:gatuno/features/settings/presentation/view_models/mfa_settings_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockMfaRepository extends Mock implements MfaRepository {}

void main() {
  late MockMfaRepository repo;
  late MfaSettingsViewModel vm;
  const off = MfaStatus(totpEnabled: false, backupCodesRemaining: 0);
  const on = MfaStatus(totpEnabled: true, backupCodesRemaining: 8);

  setUp(() {
    repo = MockMfaRepository();
    vm = MfaSettingsViewModel(repo);
  });
  tearDown(() => vm.dispose());

  test('load moves to status', () async {
    when(() => repo.status()).thenAnswer((_) async => off);
    await vm.load();
    expect(vm.state.phase, MfaPhase.status);
    expect(vm.state.status!.totpEnabled, false);
  });

  test('load failure moves to loadFailed with mapped error', () async {
    when(() => repo.status()).thenThrow(NetworkException());
    await vm.load();
    expect(vm.state.phase, MfaPhase.loadFailed);
    expect(vm.state.error, MfaError.network);
  });

  test(
    'enable flow: setup -> confirm -> backup codes -> acknowledge clears codes',
    () async {
      when(() => repo.status()).thenAnswer((_) async => off);
      when(() => repo.setupTotp()).thenAnswer(
        (_) async => const TotpSetup(secret: 'S', otpauthUri: 'otpauth://x'),
      );
      when(
        () => repo.verifyTotpSetup('123456'),
      ).thenAnswer((_) async => const BackupCodes(['A-1', 'B-2']));
      await vm.load();

      await vm.startSetup();
      expect(vm.state.phase, MfaPhase.setup);
      expect(vm.state.setup!.secret, 'S');

      await vm.confirmSetup(' 123456 ');
      expect(vm.state.phase, MfaPhase.backupCodes);
      expect(vm.state.backupCodes, ['A-1', 'B-2']);
      expect(vm.state.setup, isNull);

      when(() => repo.status()).thenAnswer((_) async => on);
      await vm.acknowledgeBackupCodes();
      expect(vm.state.phase, MfaPhase.status);
      expect(vm.state.backupCodes, isEmpty);
      expect(vm.state.status!.totpEnabled, true);
    },
  );

  test('confirmSetup ignores re-entry while busy', () async {
    when(() => repo.status()).thenAnswer((_) async => off);
    when(
      () => repo.setupTotp(),
    ).thenAnswer((_) async => const TotpSetup(secret: 'S', otpauthUri: 'u'));
    final completer = Completer<BackupCodes>();
    when(() => repo.verifyTotpSetup(any())).thenAnswer((_) => completer.future);
    await vm.load();
    await vm.startSetup();
    final first = vm.confirmSetup('123456');
    await vm.confirmSetup('123456');
    completer.complete(const BackupCodes(['A-1']));
    await first;
    verify(() => repo.verifyTotpSetup(any())).called(1);
    expect(vm.state.phase, MfaPhase.backupCodes);
  });

  test('wrong confirm code stays in setup with invalidCode', () async {
    when(() => repo.status()).thenAnswer((_) async => off);
    when(
      () => repo.setupTotp(),
    ).thenAnswer((_) async => const TotpSetup(secret: 'S', otpauthUri: 'u'));
    when(() => repo.verifyTotpSetup(any())).thenThrow(UnauthorizedException());
    await vm.load();
    await vm.startSetup();
    await vm.confirmSetup('000000');
    expect(vm.state.phase, MfaPhase.setup);
    expect(vm.state.error, MfaError.invalidCode);
    expect(vm.state.isBusy, false);
  });

  test('429 maps to tooManyAttempts', () async {
    when(() => repo.status()).thenAnswer((_) async => off);
    when(() => repo.setupTotp()).thenThrow(TooManyRequestsException());
    await vm.load();
    await vm.startSetup();
    expect(vm.state.error, MfaError.tooManyAttempts);
  });

  test('cancelSetup returns to status and drops the secret', () async {
    when(() => repo.status()).thenAnswer((_) async => off);
    when(
      () => repo.setupTotp(),
    ).thenAnswer((_) async => const TotpSetup(secret: 'S', otpauthUri: 'u'));
    await vm.load();
    await vm.startSetup();
    vm.cancelSetup();
    expect(vm.state.phase, MfaPhase.status);
    expect(vm.state.setup, isNull);
  });

  test('disable success reloads status', () async {
    when(() => repo.status()).thenAnswer((_) async => on);
    when(() => repo.disableTotp('123456')).thenAnswer((_) async {});
    await vm.load();
    when(() => repo.status()).thenAnswer((_) async => off);
    expect(await vm.disable('123456'), true);
    expect(vm.state.status!.totpEnabled, false);
  });

  test('disable failure keeps status and reports error', () async {
    when(() => repo.status()).thenAnswer((_) async => on);
    when(() => repo.disableTotp(any())).thenThrow(UnauthorizedException());
    await vm.load();
    expect(await vm.disable('x'), false);
    expect(vm.state.phase, MfaPhase.status);
    expect(vm.state.error, MfaError.invalidCode);
  });
}
