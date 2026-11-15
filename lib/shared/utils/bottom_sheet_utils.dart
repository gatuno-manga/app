import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/theme.dart';

/// Shows a modal bottom sheet with the app's shape and safe area.
///
/// [glass] draws the Figma glass sheet: `color/context-menu-bg` over a
/// `Vidro/Overlay` blur (12) of the page, with `radius/xl` (16) top
/// corners. Without it the sheet keeps the theme's opaque background and
/// 20 dp corners. Either way the content draws its own grabber.
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useSafeArea = true,
  bool glass = false,
}) {
  const glassRadius = BorderRadius.vertical(top: Radius.circular(16));
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: glass ? Colors.transparent : null,
    elevation: glass ? 0 : null,
    shape: RoundedRectangleBorder(
      borderRadius: glass
          ? glassRadius
          : const BorderRadius.vertical(top: Radius.circular(20)),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    builder: (context) {
      // useSafeArea only covers the top; keep the last control clear of the
      // home indicator / gesture bar.
      final content = SafeArea(top: false, child: builder(context));
      if (!glass) return content;
      final palette =
          Theme.of(context).extension<GatunoColors>()?.palette ?? lightPalette;
      return ClipRRect(
        borderRadius: glassRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(color: palette.contextMenuBackground),
            child: content,
          ),
        ),
      );
    },
  );
}
