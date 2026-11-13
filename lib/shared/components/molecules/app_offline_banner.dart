import 'package:flutter/material.dart';

import '../../../core/theme/semantic_colors.dart';
import '../../../l10n/app_localizations.dart';

/// A strip that says the app is offline and the data on screen is saved data.
///
/// Mounted once in the navigation shell, above the bottom bar. It collapses to
/// nothing when [offline] is false, animating unless the platform asks for
/// reduced motion, and announces itself to screen readers when it appears.
class AppOfflineBanner extends StatelessWidget {
  final bool offline;

  const AppOfflineBanner({super.key, required this.offline});

  static const Duration _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSize(
      duration: reduceMotion ? Duration.zero : _duration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.bottomCenter,
      child: offline
          ? const _OfflineStrip()
          : const SizedBox(width: double.infinity),
    );
  }
}

class _OfflineStrip extends StatelessWidget {
  const _OfflineStrip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final warning = theme.warningColor;

    return Semantics(
      container: true,
      liveRegion: true,
      label: l10n.offlineBannerMessage,
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        color: Color.alphaBlend(
          theme.warningSubtleColor,
          theme.colorScheme.surface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 18,
              color: theme.legible(warning),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.offlineBannerMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
