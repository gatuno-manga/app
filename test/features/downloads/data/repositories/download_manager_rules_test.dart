/// DownloadManager: network rules.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/books/domain/value_objects/chapter_id.dart';
import 'package:gatuno/features/downloads/domain/entities/download_network.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/reading/domain/entities/reading_enums.dart';
import '../../helpers/download_test_doubles.dart';
import '../../helpers/download_manager_harness.dart';

void main() {
  setUpDownloadManager();

  group('network rule', () {
    test('files of an unmetered-only type require Wi-Fi', () async {
      await setRule(BookType.manga, DownloadNetwork.unmetered);
      manifest('c1', imageManifest('c1'));

      await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
      await until(() => transfers.enqueued.length == 2);

      expect(transfers.enqueued.every((t) => t.requiresWiFi), isTrue);
    });

    test(
      'a pending chapter on mobile data is waiting for the network',
      () async {
        await setRule(BookType.manga, DownloadNetwork.unmetered);
        manifest('c1', imageManifest('c1'));
        await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
        await until(() => transfers.enqueued.length == 2);

        final reasons = manager
            .watchBook(testBook)
            .map((b) => b!.chapters.single.reason)
            .distinct();
        final seen = <DownloadWaitReason>[];
        final sub = reasons.listen(seen.add);
        await until(() => seen.isNotEmpty);
        expect(seen.last, DownloadWaitReason.waitingForNetwork);

        unmetered.add(true);
        await until(() => seen.last == DownloadWaitReason.none);
        await sub.cancel();
      },
    );

    test(
      'a rule change queues pending files again under the new rule',
      () async {
        manifest('c1', imageManifest('c1'));
        await manager.enqueueChapters(testBook, const [ChapterId('c1')]);
        await until(() => transfers.enqueued.length == 2);
        final firstAttempt = [...transfers.enqueued];

        policy.rules[BookType.manga] = DownloadNetwork.unmetered;
        policy.changed.add(null);

        await until(() => transfers.enqueued.length == 4, reason: 'requeue');
        expect(transfers.cancelled, firstAttempt.map((t) => t.taskId));
        expect(transfers.queuedFor('c1').every((t) => t.requiresWiFi), isTrue);
      },
    );
  });
}
