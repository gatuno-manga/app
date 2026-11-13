import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

/// Answers every `path_provider` call with [dir], so code under test (the
/// HTTP cache store, drift databases) never writes into the working
/// directory. Call [clearPathProviderMock] in `tearDown`.
void mockPathProvider(Directory dir) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_pathProviderChannel, (call) async {
        return call.method.startsWith('get') ? dir.path : null;
      });
}

void clearPathProviderMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_pathProviderChannel, null);
}
