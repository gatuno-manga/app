import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/library/presentation/views/library_screen.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the coming-soon placeholder', (tester) async {
    await tester.pumpApp(const LibraryPage());

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.text('Your library is coming soon.'), findsOneWidget);
  });

  testWidgets('shows the same placeholder in Portuguese', (tester) async {
    await tester.pumpApp(const LibraryPage(), locale: const Locale('pt'));

    expect(find.text('Em breve'), findsOneWidget);
    expect(find.text('A sua biblioteca chega em breve.'), findsOneWidget);
  });
}
