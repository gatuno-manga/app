import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/users/presentation/components/molecules/user_profile_header.dart';
import 'package:gatuno/shared/components/atoms/app_skeleton.dart';

import '../../../../../helpers/test_injection.dart';

void main() {
  setUp(registerFailingImageStrategy);
  tearDown(sl.reset);

  testWidgets('tapping the avatar edit badge below the banner triggers edit', (
    tester,
  ) async {
    var avatarTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserProfileHeader(
            displayName: 'Maria',
            email: 'm@x.y',
            onEditAvatar: () => avatarTaps++,
          ),
        ),
      ),
    );

    // The badge sits at the bottom-right of the avatar, below the banner.
    await tester.tap(find.byIcon(Icons.edit));
    expect(avatarTaps, 1);

    // Bottom edge of the avatar must be hittable too.
    final avatar = tester.getRect(find.byType(CircleAvatar).first);
    await tester.tapAt(Offset(avatar.center.dx, avatar.bottom - 4));
    expect(avatarTaps, 2);
  });

  testWidgets('banner edit is independent of avatar edit', (tester) async {
    var bannerTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserProfileHeader(
            displayName: 'Maria',
            editBannerLabel: 'Change banner',
            onEditBanner: () => bannerTaps++,
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Change banner'));
    expect(bannerTaps, 1);
  });

  Future<void> pumpHeader(
    WidgetTester tester, {
    String? displayName,
    String? email,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: UserProfileHeader(displayName: displayName, email: email),
      ),
    ),
  );

  testWidgets('shows name and email without placeholders once loaded', (
    tester,
  ) async {
    await pumpHeader(tester, displayName: 'Maria', email: 'm@x.y');

    expect(find.text('Maria'), findsOneWidget);
    expect(find.text('m@x.y'), findsOneWidget);
    expect(find.byType(AppSkeleton), findsNothing);
  });

  testWidgets('shows a text line placeholder for a missing name and email', (
    tester,
  ) async {
    await pumpHeader(tester);

    expect(find.byType(AppSkeleton), findsNWidgets(2));
    expect(tester.getSize(find.byType(AppSkeleton).first).height, 24 + 8);
    expect(tester.getSize(find.byType(AppSkeleton).last).height, 16 + 8);
  });

  testWidgets('treats a blank name and email as missing', (tester) async {
    await pumpHeader(tester, displayName: '  ', email: '');

    expect(find.byType(AppSkeleton), findsNWidgets(2));
  });
}
