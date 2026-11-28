import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/users/presentation/components/molecules/user_profile_header.dart';
import 'package:gatuno/core/di/injection.dart';

import '../../../helpers/test_injection.dart';

void main() {
  group('Molecules', () {
    setUp(registerFailingImageStrategy);
    tearDown(sl.reset);

    testWidgets('UserProfileHeader renders name and email', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserProfileHeader(
              displayName: 'John Doe',
              email: 'john@example.com',
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });
  });
}
