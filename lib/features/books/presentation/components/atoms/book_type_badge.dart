import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../domain/entities/book_type.dart';
import '../../book_type_label.dart';
import 'package:gatuno/core/theme/semantic_colors.dart';

/// Small chip showing the book type, meant to sit over a cover.
///
/// The label scales down instead of truncating, so narrow covers never turn
/// "Manhwa" and "Manhua" into the same "Manh…".
class BookTypeBadge extends StatelessWidget {
  final TypeBook? type;

  const BookTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Covers are arbitrary art, so the scrim keeps a floor of 0.7 alpha for
    // the white label: the light palette's overlay token alone is only 0.3.
    // The label is white on purpose, for the same reason.
    // The translucent GatunoColors.badgeType tint is meant for flat surfaces
    // and has no contrast over images.
    final overlay =
        theme.extension<GatunoColors>()?.overlayBackground ??
        OnImageColors.scrim;
    final scrim = overlay.withValues(alpha: math.max(overlay.a, 0.7));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scrim,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            bookTypeLabel(l10n, type),
            maxLines: 1,
            softWrap: false,
            textScaler: MediaQuery.textScalerOf(
              context,
            ).clamp(maxScaleFactor: 1.2),
            style: theme.textTheme.labelSmall?.copyWith(
              color: OnImageColors.content,
            ),
          ),
        ),
      ),
    );
  }
}

/// A [BookTypeBadge] pinned to the top-start corner of a cover [Stack].
class PositionedBookTypeBadge extends StatelessWidget {
  final TypeBook? type;
  final double inset;

  const PositionedBookTypeBadge({
    super.key,
    required this.type,
    required this.inset,
  });

  @override
  Widget build(BuildContext context) {
    // `end` is required: it bounds the width so the label can scale down.
    return PositionedDirectional(
      top: inset,
      start: inset,
      end: inset,
      child: Align(
        heightFactor: 1,
        alignment: AlignmentDirectional.topStart,
        child: BookTypeBadge(type: type),
      ),
    );
  }
}
