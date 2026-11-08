import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/domain/device_authenticator.dart';
import 'package:gatuno/features/app_lock/presentation/app_lock_texts.dart';
import 'package:gatuno/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('success and null have no message', () {
    expect(appLockOutcomeText(l10n, null), isNull);
    expect(appLockOutcomeText(l10n, DeviceAuthOutcome.success), isNull);
  });

  test('every failure outcome has a distinct message', () {
    final failures = DeviceAuthOutcome.values
        .where((o) => o != DeviceAuthOutcome.success)
        .map((o) => appLockOutcomeText(l10n, o))
        .toList();
    expect(failures, everyElement(isNotNull));
    expect(failures.toSet().length, failures.length);
  });

  test('maps the lockout to its dedicated message', () {
    expect(
      appLockOutcomeText(l10n, DeviceAuthOutcome.lockedOut),
      l10n.appLockErrorLockedOut,
    );
  });
}
