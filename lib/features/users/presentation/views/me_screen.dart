import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gatuno/l10n/app_localizations.dart';
import '../../../../core/logging/logger.dart';
import '../../domain/value_objects/profile_image_failure.dart';
import '../../domain/value_objects/profile_image_kind.dart';
import '../view_models/me_view_model.dart';
import '../components/molecules/user_profile_header.dart';
import 'package:gatuno/features/settings/presentation/components/organisms/me_settings_list.dart';
import '../components/templates/profile_template.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeViewModel>().init();
    });
  }

  final ImagePicker _picker = ImagePicker();

  bool get _hasCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<ImageSource?> _chooseSource() async {
    if (!_hasCamera) return ImageSource.gallery;
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.userImageSourceGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.userImageSourceCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ProfileImageKind kind) async {
    final viewModel = context.read<MeViewModel>();
    final source = await _chooseSource();
    if (source == null || !mounted) return;
    final ProfileImageFailure? failure;
    try {
      final file = await _picker.pickImage(
        source: source,
        // Downscale camera photos so they stay under the API size limits.
        maxWidth: kind == ProfileImageKind.avatar ? 1024 : 2048,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      failure = await viewModel.uploadImage(
        kind: kind,
        fileName: file.name,
        bytes: await file.readAsBytes(),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Could not pick a profile image', e, stackTrace, 'MePage');
      if (mounted) {
        _showFailure(
          ProfileImageFailure(ProfileImageFailureReason.unknown, kind),
        );
      }
      return;
    }
    if (failure == null || !mounted) return;
    _showFailure(failure);
  }

  void _showFailure(ProfileImageFailure failure) {
    final l10n = AppLocalizations.of(context)!;
    final message = switch (failure.reason) {
      ProfileImageFailureReason.unsupportedType => l10n.userImageErrorType,
      ProfileImageFailureReason.tooLarge => l10n.userImageErrorTooLarge(
        failure.kind.maxMegabytes,
      ),
      ProfileImageFailureReason.forbidden => l10n.userImageErrorForbidden,
      ProfileImageFailureReason.network => l10n.userImageErrorNetwork,
      ProfileImageFailureReason.unknown => l10n.userImageErrorUnknown,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<MeViewModel>();

    return StreamBuilder<MeState>(
      stream: viewModel.stateStream,
      initialData: viewModel.state,
      builder: (context, snapshot) {
        final state = snapshot.data!;

        return ProfileTemplate(
          title: l10n.userMeTitle,
          isLoading: state.isLoading,
          header: UserProfileHeader(
            displayName: state.user.displayName,
            email: state.user.email.value,
            avatarUrl: state.user.profilePictureUrl,
            bannerUrl: state.user.profileBannerUrl,
            editAvatarLabel: l10n.userImageEditAvatar,
            editBannerLabel: l10n.userImageEditBanner,
            isAvatarBusy: state.uploading.contains(ProfileImageKind.avatar),
            isBannerBusy: state.uploading.contains(ProfileImageKind.banner),
            onEditAvatar: state.user.isGuest
                ? null
                : () => _pickAndUpload(ProfileImageKind.avatar),
            onEditBanner: state.user.isGuest
                ? null
                : () => _pickAndUpload(ProfileImageKind.banner),
          ),
          settings: MeSettingsList(
            logoutButton: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await viewModel.logout();
                  if (!context.mounted) return;
                  context.go('/settings');
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.commonLogout),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
