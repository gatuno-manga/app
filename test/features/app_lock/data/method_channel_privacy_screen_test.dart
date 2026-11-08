import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/app_lock/data/method_channel_privacy_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.gatuno.app/privacy_screen');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('setEnabled sends the flag over the platform channel', () async {
    final screen = MethodChannelPrivacyScreen();

    await screen.setEnabled(true);
    await screen.setEnabled(false);

    expect(calls.map((c) => c.method), ['setEnabled', 'setEnabled']);
    expect(calls.map((c) => c.arguments), [
      {'enabled': true},
      {'enabled': false},
    ]);
  });

  test('setEnabled swallows a missing platform implementation', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);

    await expectLater(MethodChannelPrivacyScreen().setEnabled(true), completes);
  });
}
