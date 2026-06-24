import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/reading/domain/value_objects/chapter_content.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';


import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:gatuno/features/reading/presentation/views/reading_screen.dart';
import 'package:gatuno/features/reading/reading_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';


import '../../helpers/test_injection.dart';

class MockReadingViewModel extends Mock implements ReadingViewModel {}

void main() {
  late MockReadingViewModel mockViewModel;

  setUp(() async {
    await initTestDI();
    mockViewModel = MockReadingViewModel();
    sl.registerFactory<ReadingViewModel>(() => mockViewModel);

    when(
      () => mockViewModel.loadChapter(
        any(),
        initialPage: any(named: 'initialPage'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.error).thenReturn(null);
    when(() => mockViewModel.chapter).thenReturn(null);
  });

  testWidgets('reading route works', (tester) async {
    final router = GoRouter(
      initialLocation: '/chapters/123',
      routes: readingRoutes,
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
      ),
    );

    expect(find.byType(ReadingScreen), findsOneWidget);
    verify(() => mockViewModel.loadChapter('123', initialPage: 0)).called(1);
  });

  testWidgets('reading-page route works', (tester) async {
    final router = GoRouter(
      initialLocation: '/chapters/123/page/5',
      routes: readingRoutes,
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
      ),
    );

    expect(find.byType(ReadingScreen), findsOneWidget);
    verify(() => mockViewModel.loadChapter('123', initialPage: 5)).called(1);
  });
}
