import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/network/exceptions.dart';
import 'package:gatuno/features/books/presentation/components/molecules/books_option_picker_sheet.dart';
import 'package:gatuno/features/books/presentation/models/filter_option.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  Widget sheet(Future<List<FilterOption>> Function() load) => Scaffold(
    body: BooksOptionPickerSheet(
      title: 'Tags',
      loadOptions: load,
      initialSelected: const {},
    ),
  );

  testWidgets('says the options are not saved when offline', (tester) async {
    await tester.pumpApp(sheet(() async => throw OfflineException()));
    await tester.pumpAndSettle();

    expect(
      find.textContaining("aren't saved on this device yet"),
      findsOneWidget,
    );
    expect(find.text('Could not load options'), findsNothing);
  });

  testWidgets('keeps the generic error for other failures', (tester) async {
    await tester.pumpApp(sheet(() async => throw Exception('boom')));
    await tester.pumpAndSettle();

    expect(find.text('Could not load options'), findsOneWidget);
  });
}
