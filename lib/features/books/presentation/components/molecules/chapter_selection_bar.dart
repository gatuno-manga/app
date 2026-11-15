import 'package:flutter/material.dart';

import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../shared/components/atoms/app_icon_button.dart';

/// Top bar of selection mode (Figma `Capítulos/Barra de seleção`): leave,
/// the count, and select the loaded chapters. It replaces the back button
/// while the mode is on.
class ChapterSelectionBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String countLabel;
  final String closeTooltip;
  final String selectLoadedTooltip;
  final VoidCallback onClose;

  /// Null disables it: every loaded chapter is already selected.
  final VoidCallback? onSelectLoaded;

  const ChapterSelectionBar({
    super.key,
    required this.countLabel,
    required this.closeTooltip,
    required this.selectLoadedTooltip,
    required this.onClose,
    required this.onSelectLoaded,
  });

  static const double height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<GatunoColors>()?.palette ?? lightPalette;
    return Material(
      color: palette.appBackground,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.divider)),
          ),
          child: Row(
            children: [
              AppIconButton(
                icon: Icons.close,
                tooltip: closeTooltip,
                onPressed: onClose,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    countLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              AppIconButton(
                icon: Icons.done_all,
                tooltip: selectLoadedTooltip,
                onPressed: onSelectLoaded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
