import 'package:flutter/material.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_page_options.dart';
import 'package:gatuno/features/books/presentation/view_models/books_view_model.dart';
import 'package:gatuno/features/books/presentation/views/books_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import '../../../../helpers/pump_app.dart';

class MockBooksViewModel extends Mock implements BooksViewModel {}

void main() {
  late MockBooksViewModel mockViewModel;

    setUpAll(() {
    registerFallbackValue(BookId('dummy'));
    registerFallbackValue(const BookPageOptions());
  });

  late StreamController<BooksState> stateController;

setUp(() {
    mockViewModel = MockBooksViewModel();

    // Default mock behavior
    final mockState = BooksState.initial();
    stateController = StreamController<BooksState>.broadcast();
    stateController.add(mockState);
    when(() => mockViewModel.state).thenReturn(mockState);
    when(() => mockViewModel.stateStream).thenAnswer((_) => stateController.stream);
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.error).thenReturn(null);
    when(() => mockViewModel.layoutMode).thenReturn(BooksLayoutMode.grid);
    const options = BookPageOptions();
    when(() => mockViewModel.options).thenReturn(options);
    when(() => mockViewModel.bookList).thenReturn(null);
    when(() => mockViewModel.fetchBooks(
        refresh: any(named: 'refresh'),
        resetPage: any(named: 'resetPage'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return Provider<BooksViewModel>.value(
      value: mockViewModel,
      child: const BooksPage(),
    );
  }

  testWidgets('shows SnackBar when error occurs and there is content', (
    tester,
  ) async {
    final bookList = BookList(
      data: [
        Book(id: const BookId('1'),
          title: const BookTitle('Test Book'),
          type: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
        total: const PositiveInt(1),
        page: const PositiveInt(1),
      limit: const PositiveInt(20),
      totalPages: const PositiveInt(1),
    );

    // Initial state with content
    final mockState2 = BooksState.initial().copyWith(bookList: () => bookList);
    stateController.add(mockState2);
    when(() => mockViewModel.state).thenReturn(mockState2);
    when(() => mockViewModel.bookList).thenReturn(bookList);
    when(() => mockViewModel.error).thenReturn(null);

    await tester.pumpApp(createWidgetUnderTest());

    // Verify initial state
    expect(find.text('Test Book'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    // Trigger error
    final mockState3 = mockState2.copyWith(error: () => 'Some error occurred');
    stateController.add(mockState3);
    when(() => mockViewModel.state).thenReturn(mockState3);
    when(() => mockViewModel.error).thenReturn('Some error occurred');

    await tester.pump(); // Trigger build
    await tester.pumpAndSettle(); // Show snackbar

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Some error occurred'), findsOneWidget);

    verify(() => mockViewModel.clearError()).called(1);
  });

  testWidgets(
    'shows full screen error when error occurs and there is NO content',
    (tester) async {
      final mockState4 = BooksState.initial().copyWith(error: () => 'Initial load failed');
      stateController.add(mockState4);
      when(() => mockViewModel.state).thenReturn(mockState4);
      when(() => mockViewModel.bookList).thenReturn(null);
      when(() => mockViewModel.error).thenReturn('Initial load failed');

      await tester.pumpApp(createWidgetUnderTest());

      expect(find.text('Initial load failed'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    },
  );
}
