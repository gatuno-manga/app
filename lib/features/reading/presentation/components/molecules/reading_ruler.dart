import 'package:flutter/material.dart';

import '../../../../../core/theme/reader_palette.dart';
import '../../../../../l10n/app_localizations.dart';

/// The reading ruler (Figma `Leitor/Régua de leitura`): a band one line
/// tall with the rest of the page dimmed. Fills its parent and lets touches
/// through everywhere but the band, which the user drags up and down. It
/// does not follow the text lines, so it works for every content format.
class ReadingRuler extends StatefulWidget {
  final ReaderPalette palette;

  /// Height of the band: one rendered line.
  final double lineHeight;

  const ReadingRuler({
    super.key,
    required this.palette,
    required this.lineHeight,
  });

  @override
  State<ReadingRuler> createState() => _ReadingRulerState();
}

class _ReadingRulerState extends State<ReadingRuler> {
  /// Figma dims everything outside the band to 55%.
  static const double _maskOpacity = 0.55;
  static const double _bandInset = 12;

  /// Distance from the top; null until moved, which centres the band.
  double? _top;

  double _clamped(double top, double height) =>
      top.clamp(0.0, (height - widget.lineHeight).clamp(0.0, double.infinity));

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final l10n = AppLocalizations.of(context)!;
    final mask = IgnorePointer(
      child: ColoredBox(
        color: palette.background.withValues(alpha: _maskOpacity),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final top = _clamped(_top ?? (height - widget.lineHeight) / 2, height);
        void moveBy(double delta) =>
            setState(() => _top = _clamped(top + delta, height));
        return Stack(
          children: [
            Positioned(left: 0, right: 0, top: 0, height: top, child: mask),
            Positioned(
              left: 0,
              right: 0,
              top: top + widget.lineHeight,
              bottom: 0,
              child: mask,
            ),
            Positioned(
              left: _bandInset,
              right: _bandInset,
              top: top,
              height: widget.lineHeight,
              child: Semantics(
                label: l10n.readingRulerSemantics,
                onIncrease: () => moveBy(widget.lineHeight),
                onDecrease: () => moveBy(-widget.lineHeight),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) => moveBy(details.delta.dy),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.highlight,
                      border: Border(
                        left: BorderSide(color: palette.accent, width: 3),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
