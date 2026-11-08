import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/users/presentation/components/molecules/user_banner.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('UserBanner', () {
    testWidgets('shows a placeholder without a url', (tester) async {
      await tester.pumpWidget(_wrap(const UserBanner()));
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('shows the network image when a url is given', (tester) async {
      await tester.pumpWidget(
        _wrap(const UserBanner(imageUrl: 'http://localhost/b.png')),
      );
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('edit button calls onEdit and is labelled', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(UserBanner(editLabel: 'Change banner', onEdit: () => taps++)),
      );
      await tester.tap(find.byTooltip('Change banner'));
      expect(taps, 1);
    });

    testWidgets('busy hides the edit button and shows a spinner', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(UserBanner(isBusy: true, onEdit: () {})));
      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
