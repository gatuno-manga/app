import 'package:flutter/material.dart';
import 'package:gatuno/core/di/injection.dart';
import 'package:gatuno/core/image/image_loading_strategy.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';
import 'package:gatuno/shared/components/atoms/app_clickable_action.dart';

class UserProfileIcon extends StatelessWidget {
  final String? displayName;

  /// Profile picture over the initials; null keeps the initials.
  final String? imageUrl;
  final String tooltip;
  final VoidCallback onPressed;

  const UserProfileIcon({
    super.key,
    required this.displayName,
    required this.imageUrl,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppClickableAction(
      tooltip: tooltip,
      onPressed: onPressed,
      child: AppAvatar(
        name: displayName,
        imageUrl: imageUrl,
        strategy: sl<ImageLoadingStrategy>(),
        radius: 16,
      ),
    );
  }
}
