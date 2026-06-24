import 'package:flutter/material.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_description.dart';
import 'package:gatuno/features/books/domain/value_objects/book_cover.dart';
import 'package:gatuno/features/books/domain/value_objects/author_id.dart';
import 'package:gatuno/features/books/domain/value_objects/author_name.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_id.dart';
import 'package:gatuno/features/books/domain/value_objects/tag_name.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/entities/book.dart';
import 'package:gatuno/features/books/domain/entities/book_type.dart';
import 'package:gatuno/features/books/presentation/components/organisms/book_list.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/image/dio_image_loading_strategy.dart';
import 'package:gatuno/core/image/image_loading_strategy.dart';
import 'package:gatuno/core/network/dio_client.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../../helpers/pump_app.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDioClient mockDioClient;

    setUpAll(() {
    registerFallbackValue(BookId('dummy'));
  });

setUp(() {
    mockDioClient = MockDioClient();
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

  final testBooks = List.generate(
    5,
    (i) => Book(id: BookId('$i'),
      title: BookTitle('Book $i'),
      description: BookDescription('Description $i'),
      cover: BookCover('cover_$i.jpg'),
      type: TypeBook.manga,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  testWidgets('BookListView renders all items with fixed extent', (
    tester,
  ) async {
    await tester.pumpApp(Scaffold(body: BookListView(books: testBooks)));

    // Verify all books are present
    for (int i = 0; i < testBooks.length; i++) {
      expect(find.text('Book $i'), findsOneWidget);
    }
  });
}
