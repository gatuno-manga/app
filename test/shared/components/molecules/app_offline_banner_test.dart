import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/shared/components/molecules/app_offline_banner.dart';

import '../../../helpers/pump_app.dart';

const _message = 'Offline: showing saved data';

class _Toggle extends StatefulWidget {
  const _Toggle();

  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  bool offline = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: () => setState(() => offline = !offline),
      child: const Text('toggle'),
    ),
    bottomNavigationBar: AppOfflineBanner(offline: offline),
  );
}

void main() {
  group('AppOfflineBanner', () {
    testWidgets('shows the message while offline', (tester) async {
      await tester.pumpApp(
        const Scaffold(body: AppOfflineBanner(offline: true)),
      );

      expect(find.text(_message), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });

    testWidgets('takes no space while online', (tester) async {
      await tester.pumpApp(
        const Scaffold(
          body: Column(children: [AppOfflineBanner(offline: false)]),
        ),
      );

      expect(find.text(_message), findsNothing);
      expect(tester.getSize(find.byType(AppOfflineBanner)).height, 0);
    });

    testWidgets('announces itself as a live region', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        const Scaffold(body: AppOfflineBanner(offline: true)),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel(_message)),
        matchesSemantics(label: _message, isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('appears and disappears on the transition', (tester) async {
      await tester.pumpApp(const _Toggle());
      expect(find.text(_message), findsNothing);

      await tester.tap(find.text('toggle'));
      await tester.pumpAndSettle();
      expect(find.text(_message), findsOneWidget);

      await tester.tap(find.text('toggle'));
      await tester.pumpAndSettle();
      expect(find.text(_message), findsNothing);
    });

    testWidgets('localized in Portuguese', (tester) async {
      await tester.pumpApp(
        const Scaffold(body: AppOfflineBanner(offline: true)),
        locale: const Locale('pt'),
      );

      expect(find.text('Offline: mostrando dados salvos'), findsOneWidget);
    });
  });
}
