import 'package:flutter/material.dart';
import '../../../../../shared/components/atoms/app_icon_button.dart';

class SettingsAddUrlField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onAdd;

  const SettingsAddUrlField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: AppIconButton(
            icon: Icons.add,
            filled: true,
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}
