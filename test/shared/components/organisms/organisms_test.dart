import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gatuno/features/settings/presentation/components/organisms/me_settings_list.dart';
import 'package:gatuno/core/di/injection.dart';

import '../../../helpers/test_injection.dart';

void main() {
  group('Organisms', () {
    setUp(registerFailingImageStrategy);
    tearDown(sl.reset);

    testWidgets('MeSettingsList renders logout button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MeSettingsList(logoutButton: Text('LOGOUT_BTN')),
          ),
        ),
      );

      expect(find.text('LOGOUT_BTN'), findsOneWidget);
    });
  });
}
