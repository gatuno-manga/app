import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import 'reader_settings_sheet.dart';
import 'reading_bottom_overlay.dart';
import 'reading_top_overlay.dart';

class ReaderOverlayWrapper extends StatefulWidget {
  final Widget child;
  final ReadingChapter chapter;

  /// Called with the local position of a double tap. When set, a single tap
  /// is confirmed after the double-tap window (~300ms).
  final void Function(Offset position)? onDoubleTap;

  /// The reader's rows of the settings sheet. When set, both bars show the
  /// settings action and the wrapper opens [ReaderSettingsSheet] with the
  /// [ReaderPreferencesService] from the tree; a reader without settings
  /// leaves it null.
  final ReaderSettingsSections? settingsSections;

  const ReaderOverlayWrapper({
    super.key,
    required this.child,
    required this.chapter,
    this.onDoubleTap,
    this.settingsSections,
  });

  @override
  State<ReaderOverlayWrapper> createState() => _ReaderOverlayWrapperState();
}

class _ReaderOverlayWrapperState extends State<ReaderOverlayWrapper> {
  bool _showOverlay = false;
  Offset _doubleTapPosition = Offset.zero;

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  void _openSettings(ReaderSettingsSections sections) {
    ReaderSettingsSheet.show(
      context,
      service: context.read<ReaderPreferencesService>(),
      sections: sections,
    );
  }

  @override
  Widget build(BuildContext context) {
    final onDoubleTap = widget.onDoubleTap;
    final sections = widget.settingsSections;
    final onSettingsPressed = sections == null
        ? null
        : () => _openSettings(sections);
    return Stack(
      children: [
        GestureDetector(
          onTap: _toggleOverlay,
          onDoubleTapDown: onDoubleTap == null
              ? null
              : (details) => _doubleTapPosition = details.localPosition,
          onDoubleTap: onDoubleTap == null
              ? null
              : () => onDoubleTap(_doubleTapPosition),
          behavior: HitTestBehavior.opaque,
          child: widget.child,
        ),
        ReadingTopOverlay(
          showOverlay: _showOverlay,
          chapter: widget.chapter,
          onSettingsPressed: onSettingsPressed,
        ),
        ReadingBottomOverlay(
          showOverlay: _showOverlay,
          chapter: widget.chapter,
          onSettingsPressed: onSettingsPressed,
        ),
      ],
    );
  }
}
