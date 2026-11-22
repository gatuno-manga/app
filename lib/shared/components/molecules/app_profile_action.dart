import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/image/image_loading_strategy.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_clickable_action.dart';

/// The profile slot at the end of every tab-root top bar: the user's avatar
/// (a user icon when there is no photo), or the same icon for guests.
///
/// Takes plain data; the page reads the user from its view model.
class AppProfileAction extends StatelessWidget {
  final bool isGuest;

  /// Keeps a neutral circle while the profile loads.
  final bool isLoading;
  final String? imageUrl;
  final String tooltip;
  final VoidCallback onPressed;

  const AppProfileAction({
    super.key,
    required this.isGuest,
    required this.tooltip,
    required this.onPressed,
    this.isLoading = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: AppClickableAction(
        tooltip: tooltip,
        onPressed: onPressed,
        child: AppAvatar(
          guest: isGuest && !isLoading,
          isLoading: isLoading,
          imageUrl: imageUrl,
          strategy: sl<ImageLoadingStrategy>(),
          radius: 12,
        ),
      ),
    );
  }
}
