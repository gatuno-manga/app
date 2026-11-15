import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/utils/format_bytes.dart';

void main() {
  group('formatBytes', () {
    test('bytes are whole numbers', () {
      expect(formatBytes(0, 'en'), '0\u00A0B');
      expect(formatBytes(512, 'en'), '512\u00A0B');
      expect(formatBytes(1023, 'en'), '1023\u00A0B');
    });

    test('kilobytes are whole numbers in base 1024', () {
      expect(formatBytes(1024, 'en'), '1\u00A0KB');
      expect(formatBytes(12 * 1024 + 400, 'en'), '12\u00A0KB');
    });

    test('megabytes and gigabytes keep one decimal', () {
      expect(formatBytes(1024 * 1024, 'en'), '1.0\u00A0MB');
      expect(formatBytes(340 * 1024 * 1024, 'en'), '340.0\u00A0MB');
      expect(formatBytes((1.5 * 1024 * 1024).round(), 'en'), '1.5\u00A0MB');
      expect(
        formatBytes((2.25 * 1024 * 1024 * 1024).round(), 'en'),
        '2.3\u00A0GB',
      );
    });

    test('terabytes are the largest unit', () {
      expect(formatBytes(2 * 1024 * 1024 * 1024 * 1024, 'en'), '2.0\u00A0TB');
      expect(
        formatBytes(2048 * 1024 * 1024 * 1024 * 1024, 'en'),
        '2048.0\u00A0TB',
      );
    });

    test('a value that rounds to 1024 moves up a unit', () {
      expect(formatBytes(1024 * 1024 - 1, 'en'), '1.0\u00A0MB');
      expect(formatBytes(1024 * 1024 * 1024 - 1, 'en'), '1.0\u00A0GB');
      expect(formatBytes(1023 * 1024 + 600, 'en'), '1.0\u00A0MB');
    });

    test('uses the locale decimal separator', () {
      expect(formatBytes((1.5 * 1024 * 1024).round(), 'pt'), '1,5\u00A0MB');
    });

    test('joins number and unit with a no-break space', () {
      expect(formatBytes(512, 'en'), contains('\u00A0'));
      expect(formatBytes(512, 'en'), isNot(contains(' ')));
    });

    test('rejects a negative size', () {
      expect(() => formatBytes(-1, 'en'), throwsArgumentError);
    });
  });
}
