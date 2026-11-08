import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/authentication/domain/repositories/mfa_repository.dart';
import 'package:gatuno/features/authentication/domain/value_objects/mfa_models.dart';
import 'package:gatuno/features/settings/presentation/view_models/mfa_settings_view_model.dart';
import 'package:gatuno/features/settings/presentation/views/mfa_settings_screen.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/pump_app.dart';

class MockMfaRepository extends Mock implements MfaRepository {}

void main() {
  late MockMfaRepository repo;
  setUp(() => repo = MockMfaRepository());

  testWidgets('backup codes screen gates Done behind the confirm checkbox', (
    tester,
  ) async {
    when(() => repo.status()).thenAnswer(
      (_) async => const MfaStatus(totpEnabled: false, backupCodesRemaining: 0),
    );
    when(() => repo.setupTotp()).thenAnswer(
      (_) async =>
          const TotpSetup(secret: 'SECRET123', otpauthUri: 'otpauth://x'),
    );
    when(() => repo.verifyTotpSetup('123456')).thenAnswer(
      (_) async => const BackupCodes(['AAAAA-11111', 'BBBBB-22222']),
    );

    await tester.pumpApp(
      MfaSettingsPage(viewModel: MfaSettingsViewModel(repo)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Enable'));
    await tester.pumpAndSettle();
    expect(find.text('SECRET123'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('AAAAA-11111'), findsOneWidget);
    ElevatedButton done() =>
        tester.widget(find.widgetWithText(ElevatedButton, 'Done'));
    expect(done().onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(done().onPressed, isNotNull);
  });

  testWidgets('reconfigure asks for confirmation first', (tester) async {
    when(() => repo.status()).thenAnswer(
      (_) async => const MfaStatus(totpEnabled: true, backupCodesRemaining: 5),
    );
    await tester.pumpApp(
      MfaSettingsPage(viewModel: MfaSettingsViewModel(repo)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Reconfigure'));
    await tester.pumpAndSettle();
    expect(find.textContaining('will stop working'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    verifyNever(() => repo.setupTotp());
  });
}
