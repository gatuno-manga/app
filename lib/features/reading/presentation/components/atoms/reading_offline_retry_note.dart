import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';

/// "Still offline." under the offline view, after a retry that could not
/// open the chapter.
///
/// Its space is always kept, so the offline view does not move when it
/// appears. Each failure rebuilds the live region (keyed by [failures]), so
/// screen readers announce every failed retry, even two in a row.
class ReadingOfflineRetryNote extends StatelessWidget {
  /// Failed retries so far; 0 hides the note.
  final int failures;

  const ReadingOfflineRetryNote({super.key, required this.failures});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Visibility(
      visible: failures > 0,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          key: ValueKey(failures),
          liveRegion: true,
          child: Text(
            l10n.readingStillOffline,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
