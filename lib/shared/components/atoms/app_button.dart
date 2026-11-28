import 'package:flutter/material.dart';
import 'package:gatuno/shared/components/atoms/app_loading_indicator.dart';

/// Look of an [AppButton].
enum AppButtonVariant {
  /// Filled with `color/primary`: the main action of a screen.
  primary,
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
    }
  }
}
