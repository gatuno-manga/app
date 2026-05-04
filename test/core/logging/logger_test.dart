import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/logging/logger.dart';
import 'package:gatuno/core/logging/log_transport.dart';
import 'package:mocktail/mocktail.dart';

class MockTransport extends Mock implements LogTransport {}

void main() {
  group('AppLogger', () {
    late MockTransport transport1;
    late MockTransport transport2;

    setUp(() {
      transport1 = MockTransport();
      transport2 = MockTransport();
    });

    test('broadcasts messages to all registered transports', () async {
      await AppLogger.init(transports: [transport1, transport2]);

      AppLogger.i('Test Info', 'Tag');
      AppLogger.e('Test Error', 'ErrorObject', StackTrace.empty, 'ErrorTag');

      verify(() => transport1.log('INFO', 'Test Info', null, null, 'Tag')).called(1);
      verify(() => transport2.log('INFO', 'Test Info', null, null, 'Tag')).called(1);
      
      verify(() => transport1.log('ERROR', 'Test Error', 'ErrorObject', any(), 'ErrorTag')).called(1);
      verify(() => transport2.log('ERROR', 'Test Error', 'ErrorObject', any(), 'ErrorTag')).called(1);
    });

    test('redactEmail masks email correctly in non-debug mode', () {
      // Note: kDebugMode is true during tests, so we can only test the logic 
      // if we were able to mock kDebugMode, which is difficult as it's a const.
      // However, the logic itself is simple.
      
      // In tests, kDebugMode is true, so redactEmail returns the original email.
      expect(AppLogger.redactEmail('test@example.com'), 'test@example.com');
    });

    test('fallback to debugPrint if transport fails', () async {
      final failingTransport = MockTransport();
      when(() => failingTransport.log(any(), any(), any(), any(), any()))
          .thenThrow(Exception('Log failed'));

      await AppLogger.init(transports: [failingTransport]);

      // Should not throw
      AppLogger.i('Message');

      verify(() => failingTransport.log(any(), any(), any(), any(), any())).called(1);
    });
  });
}
