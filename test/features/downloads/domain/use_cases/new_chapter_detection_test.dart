import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/domain/entities/listed_chapter.dart';
import 'package:gatuno/features/downloads/domain/use_cases/new_chapter_detection.dart';

ListedChapter ready(String id) => ListedChapter(id: ChapterId(id), ready: true);
ListedChapter scraping(String id) =>
    ListedChapter(id: ChapterId(id), ready: false);
Set<ChapterId> ids(List<String> values) => {
  for (final v in values) ChapterId(v),
};

void main() {
  test('without a baseline every listed chapter is recorded, none queued', () {
    final decision = decideNewChapters(
      listed: [ready('c1'), scraping('c2')],
      seen: const {},
      downloaded: const {},
      hasBaseline: false,
    );

    expect(decision.queue, isEmpty);
    expect(decision.record, ids(['c1', 'c2']));
  });

  test('queues and records new ready chapters in the listed order', () {
    final decision = decideNewChapters(
      listed: [ready('c1'), ready('c3'), ready('c2')],
      seen: ids(['c1']),
      downloaded: const {},
      hasBaseline: true,
    );

    expect(decision.queue, [const ChapterId('c3'), const ChapterId('c2')]);
    expect(decision.record, ids(['c3', 'c2']));
  });

  test('a new chapter still being scraped waits, unrecorded', () {
    final decision = decideNewChapters(
      listed: [scraping('c2')],
      seen: ids(['c1']),
      downloaded: const {},
      hasBaseline: true,
    );

    expect(decision.queue, isEmpty);
    expect(decision.record, isEmpty);
  });

  test('seen chapters are never queued again', () {
    final decision = decideNewChapters(
      listed: [ready('c1')],
      seen: ids(['c1']),
      downloaded: const {},
      hasBaseline: true,
    );

    expect(decision.queue, isEmpty);
    expect(decision.record, isEmpty);
  });

  test('a new chapter that already has a download is only recorded', () {
    final decision = decideNewChapters(
      listed: [ready('c2'), scraping('c3')],
      seen: const {},
      downloaded: ids(['c2', 'c3']),
      hasBaseline: true,
    );

    expect(decision.queue, isEmpty);
    expect(decision.record, ids(['c2', 'c3']));
  });

  test('a chapter listed twice is queued once', () {
    final decision = decideNewChapters(
      listed: [ready('c2'), ready('c2')],
      seen: const {},
      downloaded: const {},
      hasBaseline: true,
    );

    expect(decision.queue, [const ChapterId('c2')]);
  });
}
