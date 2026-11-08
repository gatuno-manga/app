import 'package:flutter/material.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/image/image_loading_strategy.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';

class SettingsProfileCard extends StatelessWidget {
  final String name;
  final String? email;

  /// Profile picture over the initials; null keeps the initials.
  final String? imageUrl;
  final VoidCallback onTap;

  const SettingsProfileCard({
    super.key,
    required this.name,
    this.email,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: AppAvatar(
        name: email != null ? name : null,
        imageUrl: imageUrl,
        strategy: sl<ImageLoadingStrategy>(),
        radius: 24,
      ),
      title: Text(
        name,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: email != null
          ? Text(
              email!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
