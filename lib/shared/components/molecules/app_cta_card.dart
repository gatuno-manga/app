import 'package:flutter/material.dart';

import '../../../core/theme/semantic_colors.dart';
import '../atoms/app_button.dart';
import '../atoms/app_surface_card.dart';

/// Figma `App/Molecule/Cartão de chamada`: a flat outlined card with a title,
/// a description, an optional note and one primary action.
class AppCtaCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final IconData buttonIcon;

  /// Null disables the button; say why in [note]. The disabled look is
  /// `AppButton`'s, since Figma only draws it as 38% opacity.
  final VoidCallback? onPressed;

  /// A short line under the description, such as why the button is disabled.
  final String? note;

  const AppCtaCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonIcon,
    required this.onPressed,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(description, style: theme.textTheme.bodySmall),
          if (note case final note?) ...[
            const SizedBox(height: 8),
            // legible() lifts color/text-secondary to 4.5:1, which Figma's
            // raw token misses in Dracula, True-dark and Light.
            Text(
              note,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.legible(theme.mutedColor),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              text: buttonText,
              icon: buttonIcon,
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
