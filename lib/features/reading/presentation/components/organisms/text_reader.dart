import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/reader_palette.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import '../../theme/reader_preferences_builder.dart';
import '../../theme/reader_text_style.dart';
import '../molecules/reading_ruler.dart';
import '../molecules/text_reader_content.dart';
import 'reader_overlay_wrapper.dart';
import 'text_reader_settings_section.dart';

class TextReader extends StatelessWidget {
  final ReadingChapter chapter;

  const TextReader({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final sections = TextReaderSettingsSection.sectionsFor(
      context.read<ReaderPreferencesService>(),
    );
    return ReaderPreferencesBuilder(
      builder: (context, preferences) => ReaderOverlayWrapper(
        chapter: chapter,
        settingsSections: sections,
        child: _TextReaderBody(chapter: chapter, preferences: preferences.text),
      ),
    );
  }
}

class _TextReaderBody extends StatelessWidget {
  final ReadingChapter chapter;
  final TextReaderPreferences preferences;

  const _TextReaderBody({required this.chapter, required this.preferences});

  /// Prose measure cap on wide screens (about 70 characters at 19 dp).
  static const double _maxProseWidth = 680;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<ReaderPalette>()!;
    final title = chapter.title;
    final bodyStyle = preferences.textStyle(color: palette.text);
    // No app bar here, so the status bar icons must follow the reader
    // surface (a light Sépia under a dark app theme, or the reverse).
    final overlayStyle = theme.brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: ColoredBox(
        key: const ValueKey('text-reader-surface'),
        color: palette.background,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 32.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        preferences.maxContentWidth(
                          bodyStyle,
                          MediaQuery.textScalerOf(context),
                        ) ??
                        _maxProseWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Text(
                            title.value,
                            textAlign: preferences.alignment.textAlign,
                            // Same family as the body (Figma 882:910).
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: palette.text,
                              fontFamily: preferences.fontFamily.family,
                              fontWeight: FontWeight.bold,
                              letterSpacing: bodyStyle.letterSpacing,
                              wordSpacing: bodyStyle.wordSpacing,
                            ),
                          ),
                        ),
                      TextReaderContent(
                        content: chapter.content?.value ?? '',
                        format: chapter.contentFormat,
                        preferences: preferences,
                        palette: palette,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (preferences.readingRuler)
              Positioned.fill(
                child: ReadingRuler(
                  palette: palette,
                  // The body text scales with the system text size, so the
                  // band must too to cover one whole line.
                  lineHeight:
                      MediaQuery.textScalerOf(
                        context,
                      ).scale(preferences.fontSize) *
                      preferences.lineHeight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
