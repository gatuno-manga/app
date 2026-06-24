import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/reading/domain/value_objects/chapter_content.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';


import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/features/reading/domain/repositories/reading_repository.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:gatuno/features/reading/reading_injection.dart';
import 'package:mocktail/mocktail.dart';


import 'package:gatuno/core/network/dio_client.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  setUp(() {
    sl.reset();
  });

  test('initReadingDI registers expected types', () {
    sl.registerSingleton<DioClient>(MockDioClient());

    initReadingDI(sl);

    expect(sl.isRegistered<ReadingRepository>(), isTrue);
    expect(sl.isRegistered<ReadingViewModel>(), isTrue);
  });
}
