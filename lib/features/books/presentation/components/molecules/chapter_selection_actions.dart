import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/theme.dart';
import '../atoms/selection_action_button.dart';

/// One action of [ChapterSelectionActions].
class SelectionAction {
  final IconData icon;
  final String label;

  /// Null disables it.
  final VoidCallback? onPressed;
  final bool danger;

  const SelectionAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });
}

/// Bottom bar of selection mode (Figma `Capítulos/Ações da seleção`):
/// labelled actions of equal width on glass (`color/context-menu-bg`,
/// `Vidro/Overlay`), above the system navigation.
class ChapterSelectionActions extends StatelessWidget {
  final List<SelectionAction> actions;

  const ChapterSelectionActions({super.key, required this.actions});

  /// Height of the bar above the system inset; the list pads its end by it.
  static const double height = 72;

  @override
  Widget build(BuildContext context) {
    final palette =
        Theme.of(context).extension<GatunoColors>()?.palette ?? lightPalette;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.contextMenuBackground,
            border: Border(top: BorderSide(color: palette.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  for (final action in actions)
                    Expanded(
                      child: SelectionActionButton(
                        icon: action.icon,
                        label: action.label,
                        onPressed: action.onPressed,
                        danger: action.danger,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
