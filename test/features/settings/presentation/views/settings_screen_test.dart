import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:gatuno/features/settings/presentation/views/settings_screen.dart';
import 'package:gatuno/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:gatuno/features/settings/presentation/components/molecules/settings_profile_card.dart';
import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_injection.dart';

void main() {
  late MockSettingsService mockSettingsService;
  late MockAuthService mockAuthService;
  late SettingsViewModel viewModel;

  setUp(() async {
    mockSettingsService = MockSettingsService();
    mockAuthService = MockAuthService();

    when(() => mockSettingsService.addListener(any())).thenAnswer((_) {});
    when(() => mockSettingsService.removeListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.addListener(any())).thenAnswer((_) {});
    when(() => mockAuthService.removeListener(any())).thenAnswer((_) {});

    viewModel = SettingsViewModel(
      settingsService: mockSettingsService,
      authService: mockAuthService,
    );

    await initTestDI(
      settingsService: mockSettingsService,
      authService: mockAuthService,
    );

    when(() => mockSettingsService.apiUrl).thenReturn('http://test.com');
    when(() => mockSettingsService.sensitiveContentEnabled).thenReturn(false);
    when(() => mockSettingsService.allowedBadCertificateUrls).thenReturn([]);
    when(() => mockAuthService.authenticated).thenReturn(false);
    when(() => mockAuthService.currentUser).thenReturn(null);
  });

  testWidgets('SettingsPage renders correctly for guest', (tester) async {
    await tester.pumpApp(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const SettingsPage(),
      ),
    );

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(SettingsProfileCard), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('API Base URL'), findsOneWidget);
  });

  testWidgets('SettingsPage updates sensitive content toggle', (tester) async {
    when(
      () => mockSettingsService.setSensitiveContentEnabled(any()),
    ).thenAnswer((_) async {});

    await tester.pumpApp(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const SettingsPage(),
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();

    verify(
      () => mockSettingsService.setSensitiveContentEnabled(true),
    ).called(1);
  });

  testWidgets('SettingsPage can add and remove allowed bad certificate URLs', (
    tester,
  ) async {
    when(
      () => mockSettingsService.allowedBadCertificateUrls,
    ).thenReturn(['https://storage.com']);
    when(
      () => mockSettingsService.addAllowedBadCertificateUrl(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsService.removeAllowedBadCertificateUrl(any()),
    ).thenAnswer((_) async {});

    await tester.pumpApp(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const SettingsPage(),
      ),
    );

    // Verify existing URL is rendered
    expect(find.text('https://storage.com'), findsOneWidget);

    // Add a new URL
    final addField = find.byType(TextField).last;
    await tester.dragUntilVisible(
      addField,
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.enterText(addField, 'https://new.com');

    final addButton = find.byIcon(Icons.add);
    await tester.tap(addButton);
    await tester.pump();

    verify(
      () => mockSettingsService.addAllowedBadCertificateUrl('https://new.com'),
    ).called(1);

    // Remove the URL
    final deleteButton = find.byIcon(Icons.delete_outline);
    await tester.dragUntilVisible(
      deleteButton,
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.tap(deleteButton);
    await tester.pump();

    verify(
      () => mockSettingsService.removeAllowedBadCertificateUrl(
        'https://storage.com',
      ),
    ).called(1);
  });

  testWidgets('SettingsPage can update API URL', (tester) async {
    when(
      () => mockSettingsService.validateApiUrl(any()),
    ).thenAnswer((_) async => true);
    when(() => mockSettingsService.setApiUrl(any())).thenAnswer((_) async {});

    await tester.pumpApp(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const SettingsPage(),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'https://new-api.com');
    await tester.tap(find.text('Connect'));
    await tester.pump(); // Start loading
    await tester.pump(); // Finish loading

    verify(
      () => mockSettingsService.validateApiUrl('https://new-api.com'),
    ).called(1);
    verify(
      () => mockSettingsService.setApiUrl('https://new-api.com'),
    ).called(1);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('API URL updated successfully'), findsOneWidget);
  });
}
