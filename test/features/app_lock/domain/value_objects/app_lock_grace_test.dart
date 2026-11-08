import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/domain/value_objects/app_lock_grace.dart';

void main() {
  group('AppLockGrace', () {
    test('offers the five decided options in ascending order', () {
      expect(AppLockGrace.values.map((g) => g.duration.inSeconds), [
        0,
        30,
        60,
        300,
        900,
      ]);
    });

    test('defaults to one minute', () {
      expect(AppLockGrace.defaultValue, AppLockGrace.oneMinute);
    });

    test('fromSeconds round-trips every option', () {
      for (final grace in AppLockGrace.values) {
        expect(AppLockGrace.fromSeconds(grace.duration.inSeconds), grace);
      }
    });

    test('fromSeconds falls back to the default for unknown or null', () {
      expect(AppLockGrace.fromSeconds(null), AppLockGrace.defaultValue);
      expect(AppLockGrace.fromSeconds(42), AppLockGrace.defaultValue);
    });
  });
}
