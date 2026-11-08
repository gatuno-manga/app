import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/reader_palette.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import '../../preferences/reader_preferences_builder.dart';
import '../../theme/reader_text_style.dart';
import '../../theme/reader_theme_scope.dart';
import '../molecules/text_reader_content.dart';
import 'reader_overlay_wrapper.dart';
import 'text_reader_settings_section.dart';

class TextReader extends StatelessWidget {
  final ReadingChapter chapter;

  const TextReader({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return ReaderPreferencesBuilder(
      builder: (context, preferences) => ReaderThemeScope(
        theme: preferences.theme,
        child: ReaderOverlayWrapper(
          chapter: chapter,
          settingsSections: (preferences) => [
            TextReaderSettingsSection(
              preferences: preferences,
              onChanged: (change) =>
                  context.read<ReaderPreferencesService>().update(change),
            ),
          ],
          child: _TextReaderBody(
            chapter: chapter,
            preferences: preferences.text,
          ),
        ),
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
    return ColoredBox(
      key: const ValueKey('text-reader-surface'),
      color: palette.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxProseWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      title.value,
                      textAlign: preferences.alignment.textAlign,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: palette.text,
                        fontWeight: FontWeight.bold,
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
    );
  }
}
