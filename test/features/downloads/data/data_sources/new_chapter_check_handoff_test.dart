import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/data/data_sources/new_chapter_check_handoff.dart';

void main() {
  late NewChapterCheckHandoff handoff;

  setUp(() => handoff = NewChapterCheckHandoff());
  tearDown(() => handoff.close());

  DateTime inAMinute() => DateTime.now().add(const Duration(minutes: 1));

  test('without a listening UI isolate the background run keeps it', () async {
    expect(
      await NewChapterCheckHandoff.handOff(
        acceptTimeout: const Duration(milliseconds: 50),
        deadline: inAMinute(),
      ),
      isFalse,
    );
  });

  test('a listening UI isolate runs it and the run waits for it', () async {
    final check = Completer<void>();
    var ran = false;
    handoff.listen(() {
      ran = true;
      return check.future;
    });

    var done = false;
    final result =
        NewChapterCheckHandoff.handOff(
          acceptTimeout: const Duration(seconds: 1),
          deadline: inAMinute(),
        ).then((value) {
          done = true;
          return value;
        });
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(ran, isTrue);
    expect(done, isFalse);

    check.complete();
    expect(await result, isTrue);
  });

  test('a closed listener no longer takes runs', () async {
    handoff
      ..listen(() async {})
      ..close();

    expect(
      await NewChapterCheckHandoff.handOff(
        acceptTimeout: const Duration(milliseconds: 50),
        deadline: inAMinute(),
      ),
      isFalse,
    );
  });
}
