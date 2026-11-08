import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/components/atoms/app_icon_button.dart';
import '../../../domain/entities/reading_chapter.dart';

class ReadingTopBar extends StatelessWidget {
  final ReadingChapter chapter;
  final double topPadding;

  /// Shows the settings action when set (readers with settings only).
  final VoidCallback? onSettingsPressed;

  const ReadingTopBar({
    super.key,
    required this.chapter,
    required this.topPadding,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSettingsPressed = this.onSettingsPressed;
    return Container(
      padding: EdgeInsets.only(top: topPadding, left: 8, right: 8, bottom: 8),
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.bookTitle.value,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  chapter.title?.value ?? 'Chapter ${chapter.index.value}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onSettingsPressed != null)
            AppIconButton(
              icon: Icons.settings_outlined,
              color: theme.colorScheme.onSurface,
              tooltip: AppLocalizations.of(context)!.readingSettingsAction,
              onPressed: onSettingsPressed,
            ),
        ],
      ),
    );
  }
}
