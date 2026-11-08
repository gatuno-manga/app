import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/image/dio_image_loading_strategy.dart';
import 'package:gatuno/core/image/image_loading_strategy.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_type.dart';
import 'package:gatuno/features/books/domain/value_objects/book_cover.dart'
    as vo;
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart'
    as vo;
import 'package:gatuno/features/books/presentation/components/atoms/book_cover.dart';
import 'package:gatuno/features/books/presentation/components/atoms/book_title_scrim.dart';
import 'package:gatuno/features/books/presentation/components/atoms/book_type_badge.dart';
import 'package:gatuno/features/books/presentation/components/molecules/book_cover_card.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/pump_app.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDioClient = MockDioClient();
    final mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    when(
      () => mockDio.get<List<int>>(any(), options: any(named: 'options')),
    ).thenAnswer(
      (_) async => Response(
        data: [0, 1, 2, 3],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );
    if (sl.isRegistered<DioClient>()) sl.unregister<DioClient>();
    if (sl.isRegistered<ImageLoadingStrategy>()) {
      sl.unregister<ImageLoadingStrategy>();
    }
    sl.registerSingleton<DioClient>(mockDioClient);
    sl.registerSingleton<ImageLoadingStrategy>(
      DioImageLoadingStrategy(mockDioClient),
    );
  });

  tearDown(() {
    if (sl.isRegistered<DioClient>()) sl.unregister<DioClient>();
    if (sl.isRegistered<ImageLoadingStrategy>()) {
      sl.unregister<ImageLoadingStrategy>();
    }
  });

  final testBook = Book(
    id: const BookId('1'),
    title: const vo.BookTitle('Test Book Title'),
    type: TypeBook.manga,
    cover: const vo.BookCover('https://example.com/cover.jpg'),
  );

  testWidgets('renders the title over the cover inside a scrim', (
    tester,
  ) async {
    await tester.pumpApp(
      SizedBox(width: 200, height: 270, child: BookCoverCard(book: testBook)),
    );

    expect(find.byType(BookCover), findsOneWidget);
    expect(find.byType(BookTitleScrim), findsOneWidget);
    expect(find.text('Test Book Title'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(BookTitleScrim),
        matching: find.byType(Stack),
      ),
      findsOneWidget,
    );
  });

  testWidgets('uses the same label size as the grid card title', (
    tester,
  ) async {
    await tester.pumpApp(
      SizedBox(width: 200, height: 270, child: BookCoverCard(book: testBook)),
    );

    final text = tester.widget<Text>(find.text('Test Book Title'));
    final context = tester.element(find.text('Test Book Title'));
    expect(
      text.style?.fontSize,
      Theme.of(context).textTheme.labelMedium?.fontSize,
    );
    expect(text.style?.color, Colors.white);
  });

  testWidgets('has no outer margin', (tester) async {
    await tester.pumpApp(
      SizedBox(width: 200, height: 270, child: BookCoverCard(book: testBook)),
    );

    expect(tester.widget<Card>(find.byType(Card)).margin, EdgeInsets.zero);
  });

  testWidgets('shows the book type badge', (tester) async {
    await tester.pumpApp(
      SizedBox(width: 200, height: 270, child: BookCoverCard(book: testBook)),
    );

    expect(find.byType(BookTypeBadge), findsOneWidget);
  });
}
