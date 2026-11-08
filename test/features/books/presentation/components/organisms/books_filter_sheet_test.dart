import 'package:flutter/material.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';
import 'package:gatuno/features/books/domain/entities/book_type.dart';
import 'package:gatuno/features/books/presentation/components/organisms/books_filter_sheet.dart';
import 'package:gatuno/shared/components/atoms/app_button.dart';
import 'package:gatuno/features/books/presentation/models/filter_option.dart';
import '../../../../../helpers/pump_app.dart';
import '../../../../../helpers/test_injection.dart';

Future<List<FilterOption>> _tags() async => const [
  FilterOption(id: 'tag-1', label: 'Action'),
  FilterOption(id: 'tag-2', label: 'Drama'),
];

Future<List<FilterOption>> _authors() async => const [
  FilterOption(id: 'au-1', label: 'Oda'),
];

void main() {
  setUp(() async {
    await initTestDI();
  });

  group('BooksFilterSheet', () {
    testWidgets('shows initial options correctly', (tester) async {
      const initialOptions = BookPageOptions(
        publication: PositiveInt(2020),
        publicationOperator: 'gt',
        type: [TypeBook.manga],
      );

      await tester.pumpApp(
        Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (context) => BooksFilterSheet(
                initialOptions: initialOptions,
                onApply: (_) {},
                onClear: () {},
                loadTags: _tags,
                loadAuthors: _authors,
              ),
            ),
          ),
        ),
      );

      // Check year
      expect(find.text('2020'), findsOneWidget);
      // Check operator (After corresponds to 'gt' in en locale)
      expect(find.text('After'), findsOneWidget);
      // Check type (Manga chip selected)
      final mangaChip = tester.widget<FilterChip>(
        find.byWidgetPredicate(
          (widget) =>
              widget is FilterChip &&
              widget.label is Text &&
              (widget.label as Text).data == 'Manga',
        ),
      );
      expect(mangaChip.selected, true);
    });

    testWidgets('calls onClear when clear button is pressed', (tester) async {
      bool cleared = false;
      await tester.pumpApp(
        Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (context) => BooksFilterSheet(
                initialOptions: const BookPageOptions(),
                onApply: (_) {},
                onClear: () => cleared = true,
                loadTags: _tags,
                loadAuthors: _authors,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(cleared, true);
    });

    testWidgets('calls onApply with updated options', (tester) async {
      BookPageOptions? appliedOptions;
      await tester.pumpApp(
        Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (context) => BooksFilterSheet(
                initialOptions: const BookPageOptions(),
                onApply: (options) => appliedOptions = options,
                onClear: () {},
                loadTags: _tags,
                loadAuthors: _authors,
              ),
            ),
          ),
        ),
      );

      // Change year
      await tester.enterText(find.byType(TextField), '2022');

      // Change operator
      await tester.tap(find.text('Equal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Before').last); // The dropdown menu item
      await tester.pumpAndSettle();

      // Select type
      await tester.tap(find.text('Manhwa'));
      await tester.pumpAndSettle();

      // Select sensitive content
      await tester.tap(find.text('Ecchi'));
      await tester.pumpAndSettle();

      // Apply
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(appliedOptions?.publication?.value, 2022);
      expect(appliedOptions?.publicationOperator, 'lt');
      expect(appliedOptions?.type, contains(TypeBook.manhwa));
      expect(appliedOptions?.sensitiveContent, contains('Ecchi'));
    });

    testWidgets('picks tags, exclude tags and authors and applies them', (
      tester,
    ) async {
      BookPageOptions? applied;
      await tester.pumpApp(
        Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (context) => BooksFilterSheet(
                initialOptions: const BookPageOptions(),
                onApply: (o) => applied = o,
                onClear: () {},
                loadTags: _tags,
                loadAuthors: _authors,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tag selection to be implemented...'), findsNothing);

      Future<void> pick(int addIndex, List<String> labels) async {
        final add = find.text('Add');
        await tester.ensureVisible(add.at(addIndex));
        await tester.tap(add.at(addIndex));
        await tester.pumpAndSettle();
        for (final l in labels) {
          await tester.tap(
            find.descendant(
              of: find.byType(CheckboxListTile),
              matching: find.text(l),
            ),
          );
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
      }

      await pick(0, ['Action', 'Drama']);
      await pick(1, ['Drama']);
      await pick(2, ['Oda']);

      // Two included tags show the and/or toggle; switch to "Any".
      await tester.tap(find.text('Any'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(applied?.tags, ['tag-1', 'tag-2']);
      expect(applied?.tagsLogic, 'or');
      expect(applied?.excludeTags, ['tag-2']);
      expect(applied?.authors, ['au-1']);
    });

    testWidgets('removing the last tag chip sends null, not an empty list', (
      tester,
    ) async {
      BookPageOptions? applied;
      await tester.pumpApp(
        Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (context) => BooksFilterSheet(
                initialOptions: const BookPageOptions(tags: ['tag-1']),
                onApply: (o) => applied = o,
                onClear: () {},
                loadTags: _tags,
                loadAuthors: _authors,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Action'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(InputChip),
          matching: find.byType(Icon),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(applied?.tags, isNull);
    });

    testWidgets('picker Retry re-requests options after a failed load', (
      tester,
    ) async {
      var calls = 0;
      Future<List<FilterOption>> flaky() async {
        calls++;
        if (calls <= 1) throw Exception('boom');
        return const [FilterOption(id: 'tag-1', label: 'Action')];
      }

      await tester.pumpApp(
        Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (context) => BooksFilterSheet(
                initialOptions: const BookPageOptions(),
                onApply: (_) {},
                onClear: () {},
                loadTags: flaky,
                loadAuthors: _authors,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add').first);
      await tester.pumpAndSettle();
      expect(find.text('Could not load options'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets('picker does not overflow with the keyboard open on a short '
        'screen', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(640, 360);
      addTearDown(tester.view.reset);

      await tester.pumpApp(
        Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (context) => BooksFilterSheet(
                initialOptions: const BookPageOptions(),
                onApply: (_) {},
                onClear: () {},
                loadTags: _tags,
                loadAuthors: _authors,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Add').first);
      await tester.tap(find.text('Add').first);
      await tester.pumpAndSettle();

      tester.view.viewInsets = const FakeViewPadding(bottom: 190);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Action'), findsOneWidget);
    });
  });
}
