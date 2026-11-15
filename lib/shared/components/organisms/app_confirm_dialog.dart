import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../atoms/app_text_button.dart';

/// Asks the user to confirm one action, with Cancel beside it.
///
/// Built to the Figma component `Diálogo/Confirmação` (variants Padrão and
/// Destrutivo). Use [show]; it resolves to true only when the user confirms,
/// so tapping outside or pressing back counts as cancel.
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;

  /// Defaults to the localized Cancel.
  final String? cancelLabel;

  /// Paints the confirm action in `color/danger`, for actions that delete
  /// data.
  final bool destructive;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.cancelLabel,
    this.destructive = false,
  });

  /// Shows the dialog and resolves to whether the user confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    String? cancelLabel,
    bool destructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gatunoColors = theme.extension<GatunoColors>();
    final palette = gatunoColors?.palette ?? lightPalette;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: palette.contextMenuBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: gatunoColors?.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.text10),
      ),
      // Set explicitly: the dialog theme defaults differ from the Figma roles.
      titleTextStyle: theme.textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      contentTextStyle: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface,
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      actionsAlignment: MainAxisAlignment.end,
      // AlertDialog spaces actions by half of buttonPadding's horizontal
      // total: 8dp apart, and 8dp when large text stacks them.
      buttonPadding: const EdgeInsets.symmetric(horizontal: 8),
      actionsOverflowButtonSpacing: 8,
      title: Text(title),
      content: Text(body),
      actions: [
        AppTextButton(
          text: cancelLabel ?? l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppTextButton(
          text: confirmLabel,
          tone: destructive
              ? AppTextButtonTone.danger
              : AppTextButtonTone.primary,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
