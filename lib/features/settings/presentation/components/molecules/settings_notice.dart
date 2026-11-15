import 'package:flutter/material.dart';

import '../../../../../core/theme/theme.dart';

/// A permanent note under a group of settings: an info icon and secondary
/// text. Read by screen readers, unlike `SettingsCaption`, since the text is
/// not repeated anywhere else.
class SettingsNotice extends StatelessWidget {
  final String text;

  const SettingsNotice({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        theme.extension<GatunoColors>()?.palette.textSecondary ??
        theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          ExcludeSemantics(
            child: Icon(Icons.error_outline, size: 20, color: color),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
