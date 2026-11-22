import 'package:flutter/material.dart';

class AppCtaCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final IconData buttonIcon;

  /// Null disables the button; say why in [note].
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
            if (note case final note?) ...[
              const SizedBox(height: 8),
              Text(note, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: Icon(buttonIcon),
                label: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
