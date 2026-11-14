import 'package:flutter_test/flutter_test.dart';
import 'package:gatuno/features/downloads/domain/entities/download_state.dart';
import 'package:gatuno/features/downloads/domain/use_cases/download_state_machine.dart';

void main() {
  const q = DownloadState.queued;
  const r = DownloadState.running;
  const p = DownloadState.paused;
  const f = DownloadState.failed;
  const d = DownloadState.done;

  // Every legal transition; anything not listed must be rejected.
  const legal = <(DownloadState, DownloadEvent), DownloadState>{
    (q, DownloadEvent.fileStarted): r,
    (q, DownloadEvent.pause): p,
    (q, DownloadEvent.fail): f,
    (q, DownloadEvent.complete): d,
    (r, DownloadEvent.pause): p,
    (r, DownloadEvent.fail): f,
    (r, DownloadEvent.complete): d,
    (p, DownloadEvent.resume): q,
    (f, DownloadEvent.retry): q,
  };

  for (final state in DownloadState.values) {
    for (final event in DownloadEvent.values) {
      final expected = legal[(state, event)];
      test(
        '${state.name} + ${event.name} -> ${expected?.name ?? 'rejected'}',
        () {
          expect(DownloadStateMachine.next(state, event), expected);
        },
      );
    }
  }

  test('only queued and running are active', () {
    expect(DownloadState.values.where(DownloadStateMachine.isActive), [q, r]);
  });

  test('done is final', () {
    for (final event in DownloadEvent.values) {
      expect(DownloadStateMachine.next(d, event), isNull);
    }
  });
}
