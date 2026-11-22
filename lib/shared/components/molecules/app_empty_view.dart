import 'package:flutter/material.dart';

import '../../../core/theme/semantic_colors.dart';

/// A centered icon, title and message for a screen with nothing to show yet.
class AppEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  /// Optional action under the message (a retry button, for example).
  final Widget? action;

  /// Keeps the message to a readable line length on tablets.
  static const double maxContentWidth = 480;

  const AppEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(icon, size: 48, color: theme.mutedColor),
              ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                // Essential copy: the default text color, since
                // `color/text-secondary` misses AA in some themes.
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[const SizedBox(height: 24), action!],
            ],
          ),
        ),
      ),
    );
  }
}
