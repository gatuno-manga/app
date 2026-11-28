import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';
import 'package:gatuno/shared/components/molecules/app_profile_action.dart';

import '../../../helpers/test_injection.dart';
import '../../../helpers/pump_app.dart';
import 'package:gatuno/core/di/injection.dart';

void main() {
  setUp(registerFailingImageStrategy);
  tearDown(sl.reset);

  Future<void> pump(
    WidgetTester tester, {
    bool isGuest = false,
    bool isLoading = false,
    String? imageUrl,
    VoidCallback? onPressed,
  }) => tester.pumpApp(
    Scaffold(
      appBar: AppBar(
        actions: [
          AppProfileAction(
            isGuest: isGuest,
            isLoading: isLoading,
            imageUrl: imageUrl,
            tooltip: 'Profile',
            onPressed: onPressed ?? () {},
          ),
        ],
      ),
    ),
  );

  testWidgets('is a 48 dp target with the tooltip as its label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    expect(tester.getSize(find.byType(AppProfileAction)), const Size(48, 48));
    expect(find.bySemanticsLabel('Profile'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('shows the photo for a signed-in user', (tester) async {
    await pump(tester, imageUrl: 'http://x/a.webp');

    final avatar = tester.widget<AppAvatar>(find.byType(AppAvatar));
    expect(avatar.guest, isFalse);
    expect(avatar.imageUrl, 'http://x/a.webp');
  });

  testWidgets('shows the guest icon for a guest', (tester) async {
    await pump(tester, isGuest: true);

    expect(tester.widget<AppAvatar>(find.byType(AppAvatar)).guest, isTrue);
  });

  testWidgets('keeps the loading circle while the profile loads', (
    tester,
  ) async {
    await pump(tester, isGuest: true, isLoading: true);

    final avatar = tester.widget<AppAvatar>(find.byType(AppAvatar));
    expect(avatar.isLoading, isTrue);
    expect(avatar.guest, isFalse);
  });

  testWidgets('taps call onPressed', (tester) async {
    var taps = 0;
    await pump(tester, onPressed: () => taps++);

    await tester.tap(find.byType(AppProfileAction));

    expect(taps, 1);
  });
}
