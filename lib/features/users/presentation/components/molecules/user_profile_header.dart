import 'package:flutter/material.dart';
import 'package:gatuno/shared/components/atoms/app_avatar.dart';
import 'package:gatuno/shared/components/atoms/app_text_skeleton.dart';
import 'user_banner.dart';

class UserProfileHeader extends StatelessWidget {
  static const double _bannerHeight = 140;
  static const double _avatarRadius = 50;
  static const double _avatarBorder = 4;

  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final String? bannerUrl;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditBanner;
  final String? editAvatarLabel;
  final String? editBannerLabel;
  final bool isAvatarBusy;
  final bool isBannerBusy;

  const UserProfileHeader({
    super.key,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.bannerUrl,
    this.onEditAvatar,
    this.onEditBanner,
    this.editAvatarLabel,
    this.editBannerLabel,
    this.isAvatarBusy = false,
    this.isBannerBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // The stack must contain the whole avatar, otherwise taps on the part
        // hanging below the banner would miss it.
        SizedBox(
          height: _bannerHeight + _avatarRadius,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: UserBanner(
                  imageUrl: bannerUrl,
                  height: _bannerHeight,
                  onEdit: onEditBanner,
                  editLabel: editBannerLabel,
                  isBusy: isBannerBusy,
                ),
              ),
              Positioned(
                top: _bannerHeight - _avatarRadius,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: _avatarBorder,
                    ),
                  ),
                  child: AppAvatar(
                    name: displayName,
                    radius: _avatarRadius,
                    imageUrl: avatarUrl,
                    onEdit: onEditAvatar,
                    editLabel: editAvatarLabel,
                    isBusy: isAvatarBusy,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppTextSkeleton(
          text: displayName,
          width: 150,
          height: 24,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        AppTextSkeleton(
          text: email,
          width: 200,
          height: 16,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
