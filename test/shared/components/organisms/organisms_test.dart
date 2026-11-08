import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gatuno/features/settings/presentation/components/organisms/me_settings_list.dart';
import 'package:gatuno/features/home/presentation/components/organisms/home_app_bar.dart';
import 'package:gatuno/features/home/presentation/components/molecules/user_profile_icon.dart';
import 'package:gatuno/features/home/presentation/components/molecules/login_icon.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';

import '../../../helpers/test_injection.dart';

void main() {
  group('Organisms', () {
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

    testWidgets('HomeAppBar renders correct icon based on auth', (
      tester,
    ) async {
      // Authenticated
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeAppBar(
              title: 'Title',
              isAuthenticated: true,
              isLoading: false,
              displayName: 'User',
              onProfilePressed: () {},
              onSignInPressed: () {},
              profileTooltip: 'Profile',
              signInTooltip: 'Sign In',
            ),
          ),
        ),
      );
      expect(find.byType(UserProfileIcon), findsOneWidget);
      expect(find.byType(LoginIcon), findsNothing);

      // Guest
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeAppBar(
              title: 'Title',
              isAuthenticated: false,
              isLoading: false,
              displayName: '',
              onProfilePressed: () {},
              onSignInPressed: () {},
              profileTooltip: 'Profile',
              signInTooltip: 'Sign In',
            ),
          ),
        ),
      );
      expect(find.byType(LoginIcon), findsOneWidget);
      expect(find.byType(UserProfileIcon), findsNothing);
    });

    testWidgets('HomeAppBar passes the profile image to the avatar', (
      tester,
    ) async {
      await registerFailingImageStrategy();
      addTearDown(sl.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeAppBar(
              title: 'Title',
              isAuthenticated: true,
              isLoading: false,
              displayName: 'User',
              imageUrl: 'http://x/a.webp',
              onProfilePressed: () {},
              onSignInPressed: () {},
              profileTooltip: 'Profile',
              signInTooltip: 'Sign In',
            ),
          ),
        ),
      );

      expect(
        tester.widget<AppAvatar>(find.byType(AppAvatar)).imageUrl,
        'http://x/a.webp',
      );
    });
  });
}
