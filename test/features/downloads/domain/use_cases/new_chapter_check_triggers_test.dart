import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/domain/use_cases/new_chapter_check.dart';
import 'package:gatuno/features/downloads/domain/use_cases/new_chapter_check_triggers.dart';
import 'package:mocktail/mocktail.dart';

class MockCheck extends Mock implements NewChapterCheck {}

void main() {
  late MockCheck check;
  late StreamController<void> triggers;
  late NewChapterCheckTriggers subject;

  setUpAll(() => registerFallbackValue(Duration.zero));

  setUp(() {
    check = MockCheck();
    triggers = StreamController<void>.broadcast();
    when(() => check.runIfStale(any())).thenAnswer(
      (_) async => const NewChapterCheckResult(NewChapterCheckOutcome.skipped),
    );
    subject = NewChapterCheckTriggers(check, triggers: triggers.stream);
  });

  tearDown(() async {
    await subject.dispose();
    await triggers.close();
  });

  test('checks on start and on every trigger, at most hourly', () async {
    subject.start();
    triggers
      ..add(null)
      ..add(null);
    await pumpEventQueue();

    verify(
      () => check.runIfStale(NewChapterCheckTriggers.staleAfter),
    ).called(3);
    expect(NewChapterCheckTriggers.staleAfter, const Duration(hours: 1));
  });

  test('stops listening once disposed', () async {
    subject.start();
    await subject.dispose();
    triggers.add(null);
    await pumpEventQueue();

    verify(() => check.runIfStale(any())).called(1);
  });
}
