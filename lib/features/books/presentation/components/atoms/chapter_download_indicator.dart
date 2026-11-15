import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/semantic_colors.dart';
import '../../../../../core/theme/theme.dart';
import '../../models/download_display.dart';

/// A chapter's download state (Figma `Capítulo/Download`): a 40×24 glyph
/// or progress ring inside a 48×48 touch area. Status colours go through
/// `theme.legible()`, since the raw tokens fall below 3:1 on the chapter
/// card in some themes.
class ChapterDownloadIndicator extends StatelessWidget {
  final ChapterDownloadStatus status;

  /// From 0 to 1, for the ring of a running or paused chapter.
  final double progress;

  /// What a screen reader announces.
  final String semanticLabel;

  /// Null makes it display-only (selection mode).
  final VoidCallback? onTap;

  const ChapterDownloadIndicator({
    super.key,
    required this.status,
    required this.semanticLabel,
    this.progress = 0,
    this.onTap,
  });

  static const double touchSize = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<GatunoColors>()?.palette ?? lightPalette;
    final muted = theme.legible(theme.mutedColor);
    final warning = theme.legible(theme.warningColor);

    final Widget visual = switch (status) {
      ChapterDownloadStatus.none => _glyph(Icons.download, muted),
      ChapterDownloadStatus.queued => _glyph(Icons.schedule, warning),
      ChapterDownloadStatus.running => _Ring(
        progress: progress,
        color: theme.colorScheme.primary,
        track: palette.text10,
        glyph: Icons.pause,
        glyphColor: theme.colorScheme.onSurface,
      ),
      ChapterDownloadStatus.waitingForNetwork => _glyph(Icons.wifi, warning),
      ChapterDownloadStatus.waitingForConnection => _glyph(
        Icons.cloud_off,
        warning,
      ),
      ChapterDownloadStatus.paused => _Ring(
        progress: progress,
        color: muted,
        track: palette.text10,
        glyph: Icons.play_arrow,
        glyphColor: muted,
      ),
      ChapterDownloadStatus.failed => _glyph(
        Icons.error_outline,
        theme.legible(theme.colorScheme.error),
      ),
      ChapterDownloadStatus.done => _glyph(
        Icons.check,
        theme.legible(theme.successColor),
      ),
    };

    final box = SizedBox.square(
      dimension: touchSize,
      child: Center(
        // Only the visual is hidden from screen readers: the label sits on
        // the node above, next to the tap action.
        child: ExcludeSemantics(
          child: SizedBox(width: 40, height: 24, child: Center(child: visual)),
        ),
      ),
    );
    final onTap = this.onTap;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      // Display-only: no ink, no focus stop.
      child: onTap == null
          ? box
          : InkResponse(onTap: onTap, radius: touchSize / 2, child: box),
    );
  }

  static Widget _glyph(IconData icon, Color color) =>
      Icon(icon, size: 18, color: color);
}

/// A 24 dp ring whose arc is [progress], with [glyph] in its middle. The
/// stroke leaves an inner radius of 80%.
class _Ring extends StatelessWidget {
  final double progress;
  final Color color;
  final Color track;
  final IconData glyph;
  final Color glyphColor;

  const _Ring({
    required this.progress,
    required this.color,
    required this.track,
    required this.glyph,
    required this.glyphColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress.clamp(0, 1),
              strokeWidth: 2.4,
              color: color,
              backgroundColor: track,
            ),
          ),
          Icon(glyph, size: 12, color: glyphColor),
        ],
      ),
    );
  }
}
