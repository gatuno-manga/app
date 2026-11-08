import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gatuno/features/home/presentation/components/molecules/login_icon.dart';
import 'package:gatuno/features/home/presentation/components/molecules/user_profile_icon.dart';
import 'package:gatuno/features/home/presentation/view_models/home_view_model.dart';
import 'package:gatuno/features/home/presentation/views/home_screen.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_injection.dart';

void main() {
  late MockHomeViewModel viewModel;

  Future<void> pumpHome(WidgetTester tester, HomeState state) async {
    when(() => viewModel.stateStream).thenAnswer((_) => const Stream.empty());
    when(() => viewModel.state).thenReturn(state);
    await tester.pumpApp(const HomePage());
  }

  setUp(() async {
    viewModel = MockHomeViewModel();
    await initTestDI(homeViewModel: viewModel);
  });

  testWidgets('shows the avatar with the profile image when signed in', (
    tester,
  ) async {
    await pumpHome(
      tester,
      HomeState.initial().copyWith(
        isInitialized: true,
        isAuthenticated: true,
        displayName: () => 'Maria',
        profileImageUrl: () => 'http://x/a.webp',
      ),
    );

    expect(find.byType(UserProfileIcon), findsOneWidget);
    expect(find.byType(LoginIcon), findsNothing);
    expect(
      tester.widget<AppAvatar>(find.byType(AppAvatar)).imageUrl,
      'http://x/a.webp',
    );
  });

  testWidgets('shows the login icon for guests', (tester) async {
    await pumpHome(tester, HomeState.initial().copyWith(isInitialized: true));

    expect(find.byType(LoginIcon), findsOneWidget);
    expect(find.byType(UserProfileIcon), findsNothing);
  });

  testWidgets('shows no header action until auth is initialized', (
    tester,
  ) async {
    await pumpHome(tester, HomeState.initial());

    expect(find.byType(LoginIcon), findsNothing);
    expect(find.byType(UserProfileIcon), findsNothing);
  });

  testWidgets('tapping the avatar opens the profile', (tester) async {
    await pumpHome(
      tester,
      HomeState.initial().copyWith(
        isInitialized: true,
        isAuthenticated: true,
        displayName: () => 'Maria',
      ),
    );

    await tester.tap(find.byType(UserProfileIcon));
    await tester.pumpAndSettle();

    expect(find.text('Profile Page'), findsOneWidget);
  });

  testWidgets('tapping the login icon opens sign in', (tester) async {
    await pumpHome(tester, HomeState.initial().copyWith(isInitialized: true));

    await tester.tap(find.byType(LoginIcon));
    await tester.pumpAndSettle();

    expect(find.text('Signin Page'), findsOneWidget);
  });
}
