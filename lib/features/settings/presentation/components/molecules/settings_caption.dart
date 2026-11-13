import 'package:flutter/material.dart';

/// Visible label of a group of controls inside a settings section, below
/// the section header. Hidden from semantics: the group it captions already
/// carries the same label.
class SettingsCaption extends StatelessWidget {
  final String text;

  const SettingsCaption({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
