import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/semantic_colors.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../shared/components/atoms/app_surface_card.dart';
import '../../../../../shared/components/atoms/app_text_button.dart';

/// The book's download summary (Figma `Livro/Resumo de downloads`), between
/// the description and the chapters: how many chapters are downloaded and
/// their size, the current state, one action and, while chapters are
/// active, a progress bar.
class BookDownloadsSummary extends StatelessWidget {
  /// "X de Y capítulos baixados · tamanho".
  final String countLabel;

  /// The state line; null when everything is done.
  final String? statusLabel;

  /// Paints [statusLabel] as an error (some chapters failed).
  final bool statusIsError;

  /// The contextual action; null when there is none.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// The bar's value while chapters are active; null hides the bar.
  final double? progress;

  /// Draws the bar in the legible muted colour (waiting for the server or
  /// for Wi-Fi) instead of `color/primary`.
  final bool progressMuted;

  const BookDownloadsSummary({
    super.key,
    required this.countLabel,
    this.statusLabel,
    this.statusIsError = false,
    this.actionLabel,
    this.onAction,
    this.progress,
    this.progressMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<GatunoColors>()?.palette ?? lightPalette;
    final statusLabel = this.statusLabel;
    final actionLabel = this.actionLabel;
    final progress = this.progress;

    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(countLabel, style: theme.textTheme.labelLarge),
                    if (statusLabel != null) ...[
                      const SizedBox(height: 2),
                      // Announced when the state changes, not on every
                      // chapter the count goes up by.
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          statusLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.legible(
                              statusIsError
                                  ? theme.colorScheme.error
                                  : theme.mutedColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(width: 8),
                // Wraps its label instead of overflowing with large text.
                Flexible(
                  child: AppTextButton(
                    text: actionLabel,
                    tone: AppTextButtonTone.primary,
                    onPressed: onAction,
                  ),
                ),
              ],
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 4,
                color: progressMuted
                    ? theme.legible(theme.mutedColor)
                    : theme.colorScheme.primary,
                backgroundColor: palette.text10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
