import 'package:flutter/material.dart';
import 'package:gatuno/shared/components/atoms/app_loading_indicator.dart';

/// Look of an [AppButton].
enum AppButtonVariant {
  /// Filled with `color/primary`: the main action of a screen.
  primary,

  /// A `color/border` outline with a `color/danger` label, 48 dp high: an
  /// action that deletes data, next to a primary one (Figma `Botão`
  /// Contorno, stretched from 44 dp to the 48 dp target).
  outlinedDanger,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? AppLoadingIndicator(size: 20, color: colorScheme.onPrimary)
              : Text(text),
        );
      case AppButtonVariant.outlinedDanger:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? AppLoadingIndicator(size: 20, color: colorScheme.error)
              : Text(text),
        );
    }
  }
}
