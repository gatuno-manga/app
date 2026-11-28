import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme.dart';

/// The flat card surface of Figma's `App/Molecule/Cartão de chamada` and
/// `App/Organism/Livro/Resumo de downloads`: `color/secondary-60` with a 1 dp
/// `color/border` outline and `radius/lg`.
class AppSurfaceCard extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const AppSurfaceCard({super.key, required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette =
        Theme.of(context).extension<GatunoColors>()?.palette ?? lightPalette;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: palette.secondary60,
        border: Border.all(color: palette.border),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: child,
    );
  }
}
