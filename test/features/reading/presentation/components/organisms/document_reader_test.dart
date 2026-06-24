import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/reading/domain/value_objects/chapter_content.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';


import 'package:gatuno/features/reading/domain/entities/reading_chapter.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import 'package:gatuno/features/reading/presentation/components/organisms/document_reader.dart';
import 'package:gatuno/features/reading/presentation/view_models/reading_view_model.dart';
import 'package:mocktail/mocktail.dart';


import 'package:provider/provider.dart';
import '../../../../../helpers/pump_app.dart';

class MockReadingViewModel extends Mock implements ReadingViewModel {}

class _MockChapter extends Fake implements ReadingChapter {
  @override
  final ChapterId id = const ChapterId('chapter-1');
  @override
  final DocumentFormat? documentFormat;
  @override
  final BookTitle bookTitle = const BookTitle('Test Book');
  @override
  final ChapterTitle? title = const ChapterTitle('Chapter 1');
  @override
  final List<ReadingPage> pages = [];
  @override
  final ChapterId? previous = null;
  @override
  final ChapterId? next = null;
  @override
  final ChapterIndex index = const ChapterIndex(1.0);

  _MockChapter({this.documentFormat});
}

void main() {
  late MockReadingViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockReadingViewModel();
    when(() => mockViewModel.currentPageIndex).thenReturn(0);
  });

  group('DocumentReader', () {
    testWidgets('renders deferred message and document format', (tester) async {
      final chapter = _MockChapter(documentFormat: DocumentFormat.pdf);

      await tester.pumpApp(
        ChangeNotifierProvider<ReadingViewModel>.value(
          value: mockViewModel,
          child: Scaffold(body: DocumentReader(chapter: chapter)),
        ),
      );

      expect(find.text('PDF and EPUB support is coming soon.'), findsOneWidget);
      expect(find.text('Format: PDF'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });
  });
}
