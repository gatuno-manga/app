import 'package:flutter/material.dart';

import 'app_loading_indicator.dart';

/// Color role of an [AppOutlinedButton] label.
enum AppOutlinedButtonTone {
  /// `color/text`: a secondary action next to a primary one.
  neutral,

  /// `color/danger`: an action that deletes data.
  danger,
}

/// A `color/border` outlined button, 48 dp high (Figma `Core/Atom/Botão`
/// Outline), for an action that sits next to a primary one.
class AppOutlinedButton extends StatelessWidget {
  final String text;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppOutlinedButtonTone tone;

  /// Drawn before [text], in the same color.
  final IconData? icon;

  /// Replaces the label with a spinner and disables the button.
  final bool isLoading;

  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.tone = AppOutlinedButtonTone.neutral,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (tone) {
      AppOutlinedButtonTone.neutral => colorScheme.onSurface,
      AppOutlinedButtonTone.danger => colorScheme.error,
    };

    final style = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      foregroundColor: color,
      side: BorderSide(color: colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    if (isLoading) {
      return OutlinedButton(
        onPressed: null,
        style: style,
        child: AppLoadingIndicator(size: 20, color: color),
      );
    }
    final icon = this.icon;
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 18),
        label: Text(text),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(text),
    );
  }
}
