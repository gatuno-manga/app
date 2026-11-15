import 'package:flutter/material.dart';

/// Color role of an [AppTextButton].
enum AppTextButtonTone {
  /// `color/text`: the quiet choice, such as Cancel.
  neutral,

  /// `color/primary`: the action the screen is about.
  primary,

  /// `color/danger`: an action that deletes data.
  danger,
}

/// A text-only button, for dialog actions and other low-emphasis choices
/// where the filled [AppButton] would be too loud.
class AppTextButton extends StatelessWidget {
  final String text;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppTextButtonTone tone;

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.tone = AppTextButtonTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (tone) {
      AppTextButtonTone.neutral => colorScheme.onSurface,
      AppTextButtonTone.primary => colorScheme.primary,
      AppTextButtonTone.danger => colorScheme.error,
    };

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        // Height keeps the 48dp tap target; width follows the label.
        minimumSize: const Size(0, 48),
      ),
      child: Text(text),
    );
  }
}
