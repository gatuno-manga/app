import 'package:dio/dio.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart' as vo;
import 'package:gatuno/features/books/domain/value_objects/book_description.dart';
import 'package:gatuno/features/books/domain/value_objects/book_cover.dart' as vo;
import 'package:gatuno/features/books/domain/value_objects/author_id.dart';
import 'package:gatuno/features/books/domain/value_objects/author_name.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_id.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_name.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_type.dart';
import 'package:gatuno/features/books/presentation/components/molecules/book_card.dart';
import 'package:gatuno/features/books/presentation/components/atoms/book_cover.dart';
import 'package:gatuno/features/books/presentation/components/atoms/book_title.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/image/dio_image_loading_strategy.dart';
import 'package:gatuno/core/image/image_loading_strategy.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../../helpers/pump_app.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;

    setUpAll(() {
    registerFallbackValue(BookId('dummy'));
  });

setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();

    when(() => mockDioClient.dio).thenReturn(mockDio);

    // Mock successful image fetch
    registerFallbackValue(RequestOptions(path: ''));
    when(
      () => mockDio.get<List<int>>(any(), options: any(named: 'options')),
    ).thenAnswer(
      (_) async => Response(
        data: [0, 1, 2, 3],
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );

    if (sl.isRegistered<DioClient>()) {
      sl.unregister<DioClient>();
    }
    if (sl.isRegistered<ImageLoadingStrategy>()) {
      sl.unregister<ImageLoadingStrategy>();
    }
    sl.registerSingleton<DioClient>(mockDioClient);
    sl.registerSingleton<ImageLoadingStrategy>(
      DioImageLoadingStrategy(mockDioClient),
    );
  });

  tearDown(() {
    if (sl.isRegistered<DioClient>()) {
      sl.unregister<DioClient>();
    }
    if (sl.isRegistered<ImageLoadingStrategy>()) {
      sl.unregister<ImageLoadingStrategy>();
    }
  });

  final testBook = Book(
    id: const BookId('1'),
    title: const vo.BookTitle('Test Book Title'),
    type: TypeBook.manga,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    cover: const vo.BookCover('https://example.com/cover.jpg'),
    description: const BookDescription('Test Book Description'),
  );

  testWidgets('BookCard renders title correctly over image', (tester) async {
    await tester.pumpApp(BookCard(book: testBook));

    // Verify Atoms are present
    expect(find.byType(BookCover), findsOneWidget);
    expect(find.byType(BookTitle), findsOneWidget);

    // Verify Title text is present
    expect(find.text('Test Book Title'), findsOneWidget);

    // Verify it's inside a Stack
    expect(find.byType(Stack), findsOneWidget);

    // Verify Card has Clip.antiAlias
    final cardWidget = tester.widget<Card>(find.byType(Card));
    expect(cardWidget.clipBehavior, Clip.antiAlias);
  });
}
