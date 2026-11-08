import 'package:flutter/material.dart';
import 'package:gatuno/core/theme/theme.dart';
import 'package:gatuno/l10n/app_localizations.dart';

import '../../../domain/entities/book_type.dart';
import '../../book_type_label.dart';

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
    final scrim =
        Theme.of(context).extension<GatunoColors>()?.overlayBackground ??
        Colors.black.withValues(alpha: 0.7);

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
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: Colors.white),
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
    return PositionedDirectional(
      top: inset,
      start: inset,
      end: inset,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: BookTypeBadge(type: type),
      ),
    );
  }
}
