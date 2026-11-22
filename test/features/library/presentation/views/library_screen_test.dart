import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/library/presentation/views/library_screen.dart';
import 'package:gatuno/features/users/data/models/user_model.dart';
import 'package:gatuno/features/users/domain/value_objects/sensitive_content_weight.dart';
import 'package:gatuno/features/users/domain/value_objects/user_email.dart';
import 'package:gatuno/features/users/domain/value_objects/user_id.dart';
import 'package:gatuno/features/users/domain/value_objects/user_roles.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';
import 'package:gatuno/shared/presentation/view_models/navigation_view_model.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_injection.dart';

void main() {
  late MockNavigationViewModel navigation;

  final maria = UserModel(
    id: const UserId('1'),
    email: const UserEmail('maria@example.com'),
    roles: const UserRoles(['user']),
    maxWeightSensitiveContent: const SensitiveContentWeight(0),
    profilePictureUrl: 'http://x/a.webp',
  );

  Future<void> pumpLibrary(
    WidgetTester tester, {
    UserModel? user,
    Locale? locale,
  }) async {
    navigation = MockNavigationViewModel();
    await initTestDI(navigationViewModel: navigation);
    // initTestDI stubs the mock with a guest; stub the wanted user after it.
    when(() => navigation.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => navigation.state).thenReturn(
      NavigationState(
        user: user ?? UserModel.guest,
        isAuthenticated: user != null,
      ),
    );
    await tester.pumpApp(const LibraryPage(), locale: locale);
  }

  for (final signedIn in [false, true]) {
    testWidgets(
      'shows the coming-soon placeholder for ${signedIn ? 'signed-in users' : 'guests'}',
      (tester) async {
        await pumpLibrary(tester, user: signedIn ? maria : null);

        expect(find.text('Library'), findsOneWidget);
        expect(find.text('Coming soon'), findsOneWidget);
        expect(find.text('Your library is coming soon.'), findsOneWidget);
      },
    );
  }

  testWidgets('shows the same placeholder in Portuguese', (tester) async {
    await pumpLibrary(tester, locale: const Locale('pt'));

    expect(find.text('Em breve'), findsOneWidget);
    expect(find.text('A sua biblioteca chega em breve.'), findsOneWidget);
  });

  testWidgets('the avatar action shows the guest icon for a guest', (
    tester,
  ) async {
    await pumpLibrary(tester);

    expect(tester.widget<AppAvatar>(find.byType(AppAvatar)).guest, isTrue);
  });

  testWidgets('the avatar action shows the profile image when signed in', (
    tester,
  ) async {
    await pumpLibrary(tester, user: maria);

    final avatar = tester.widget<AppAvatar>(find.byType(AppAvatar));
    expect(avatar.guest, isFalse);
    expect(avatar.imageUrl, 'http://x/a.webp');
  });

  for (final signedIn in [false, true]) {
    testWidgets(
      'the avatar action opens the merged screen for ${signedIn ? 'signed-in users' : 'guests'}',
      (tester) async {
        await pumpLibrary(tester, user: signedIn ? maria : null);

        await tester.tap(find.byType(AppAvatar));
        await tester.pumpAndSettle();

        expect(find.text('Settings Page'), findsOneWidget);
      },
    );
  }
}
