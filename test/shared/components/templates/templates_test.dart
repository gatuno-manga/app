import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gatuno/features/users/presentation/components/templates/profile_template.dart';
import 'package:gatuno/shared/components/organisms/app_top_bar.dart';
import 'package:gatuno/features/home/presentation/components/templates/home_template.dart';

void main() {
  group('Templates', () {
    testWidgets('ProfileTemplate renders header and settings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileTemplate(
            title: 'Test Title',
            header: Text('HEADER'),
            settings: Text('SETTINGS'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('HEADER'), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);
    });

    testWidgets('HomeTemplate renders the top bar and sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeTemplate(
            topBar: const AppTopBar(title: 'APPBAR'),
            slivers: [SliverToBoxAdapter(child: Text('BODY'))],
          ),
        ),
      );

      expect(find.text('APPBAR'), findsOneWidget);
      expect(find.text('BODY'), findsOneWidget);
    });
  });
}
