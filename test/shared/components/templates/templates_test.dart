import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_title.dart';
import 'package:gatuno/features/books/domain/value_objects/book_title.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_index.dart';
import 'package:gatuno/features/books/domain/value_objects/book_id.dart';
import 'package:gatuno/features/reading/domain/value_objects/chapter_content.dart';
import 'package:gatuno/shared/domain/value_objects/positive_int.dart';
import 'package:gatuno/features/reading/domain/value_objects/reading_page_id.dart';
import 'package:gatuno/features/reading/domain/value_objects/reading_page_url.dart';
import 'package:gatuno/features/reading/domain/value_objects/original_url.dart';

import 'package:gatuno/features/users/presentation/components/templates/profile_template.dart';
import 'package:gatuno/features/home/presentation/components/templates/home_template.dart';

void main() {
  group('Templates', () {
    testWidgets('ProfileTemplate renders header and settings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileTemplate(
            title: 'Test Title',
            header: Text('HEADER'),
            settings: Text('SETTINGS'),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('HEADER'), findsOneWidget);
      expect(find.text('SETTINGS'), findsOneWidget);
    });

    testWidgets('HomeTemplate renders appBar and body', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeTemplate(
            appBar: AppBar(title: const Text('APPBAR')),
            body: const Text('BODY'),
          ),
        ),
      );

      expect(find.text('APPBAR'), findsOneWidget);
      expect(find.text('BODY'), findsOneWidget);
    });
  });
}
