import 'package:flutter/material.dart';
import 'package:gatuno/shared/components/atoms/app_loading_indicator.dart';

/// The filled `color/primary` button: the main action of a screen. For a
/// quieter choice use `AppTextButton` or `AppOutlinedButton`.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isLoading
          ? AppLoadingIndicator.small(color: colorScheme.onPrimary)
          : Text(text),
    );
  }
}
