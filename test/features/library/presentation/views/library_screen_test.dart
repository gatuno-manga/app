import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/authentication/domain/use_cases/auth_service.dart';
import 'package:gatuno/features/library/presentation/views/library_screen.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/pump_app.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  tearDown(() => sl.reset());

  for (final signedIn in [false, true]) {
    testWidgets(
      'shows the coming-soon placeholder for ${signedIn ? 'signed-in users' : 'guests'}',
      (tester) async {
        await sl.reset();
        final auth = MockAuthService();
        when(() => auth.authenticated).thenReturn(signedIn);
        sl.registerSingleton<AuthService>(auth);

        await tester.pumpApp(const LibraryPage());

        expect(find.text('Library'), findsOneWidget);
        expect(find.text('Coming soon'), findsOneWidget);
        expect(find.text('Your library is coming soon.'), findsOneWidget);
      },
    );
  }

  testWidgets('shows the same placeholder in Portuguese', (tester) async {
    await tester.pumpApp(const LibraryPage(), locale: const Locale('pt'));

    expect(find.text('Em breve'), findsOneWidget);
    expect(find.text('A sua biblioteca chega em breve.'), findsOneWidget);
  });
}
