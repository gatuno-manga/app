import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/utils/format_bytes.dart';

void main() {
  group('formatBytes', () {
    test('bytes are whole numbers', () {
      expect(formatBytes(0, 'en'), '0 B');
      expect(formatBytes(512, 'en'), '512 B');
      expect(formatBytes(1023, 'en'), '1023 B');
    });

    test('kilobytes are whole numbers in base 1024', () {
      expect(formatBytes(1024, 'en'), '1 KB');
      expect(formatBytes(12 * 1024 + 400, 'en'), '12 KB');
    });

    test('megabytes and gigabytes keep one decimal', () {
      expect(formatBytes(1024 * 1024, 'en'), '1.0 MB');
      expect(formatBytes(340 * 1024 * 1024, 'en'), '340.0 MB');
      expect(formatBytes((1.5 * 1024 * 1024).round(), 'en'), '1.5 MB');
      expect(formatBytes((2.25 * 1024 * 1024 * 1024).round(), 'en'), '2.3 GB');
    });

    test('gigabytes are the largest unit', () {
      expect(formatBytes(2048 * 1024 * 1024 * 1024, 'en'), '2048.0 GB');
    });

    test('a value that rounds to 1024 moves up a unit', () {
      expect(formatBytes(1024 * 1024 - 1, 'en'), '1.0 MB');
      expect(formatBytes(1024 * 1024 * 1024 - 1, 'en'), '1.0 GB');
      expect(formatBytes(1023 * 1024 + 600, 'en'), '1.0 MB');
    });

    test('uses the locale decimal separator', () {
      expect(formatBytes((1.5 * 1024 * 1024).round(), 'pt'), '1,5 MB');
    });

    test('rejects a negative size', () {
      expect(() => formatBytes(-1, 'en'), throwsArgumentError);
    });
  });
}
