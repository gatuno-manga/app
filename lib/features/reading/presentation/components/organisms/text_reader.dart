import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/reader_palette.dart';
import '../../../domain/entities/reader_preferences.dart';
import '../../../domain/entities/reading_chapter.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import '../../theme/reader_text_style.dart';
import '../../theme/reader_theme_scope.dart';
import '../molecules/text_reader_content.dart';
import 'reader_overlay_wrapper.dart';
import 'reader_settings_sheet.dart';
import 'text_reader_settings_section.dart';

class TextReader extends StatelessWidget {
  final ReadingChapter chapter;

  const TextReader({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final service = context.read<ReaderPreferencesService>();
    return StreamBuilder<ReaderPreferences>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) {
        final preferences = snapshot.data!;
        return ReaderThemeScope(
          theme: preferences.theme,
          // The Builder's context carries the reader theme into the sheet.
          child: Builder(
            builder: (context) => ReaderOverlayWrapper(
              chapter: chapter,
              onSettingsPressed: () => ReaderSettingsSheet.show(
                context,
                service: service,
                sections: (preferences) => [
                  TextReaderSettingsSection(
                    preferences: preferences,
                    onChanged: service.update,
                  ),
                ],
              ),
              child: _TextReaderBody(
                chapter: chapter,
                preferences: preferences.text,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TextReaderBody extends StatelessWidget {
  final ReadingChapter chapter;
  final TextReaderPreferences preferences;

  const _TextReaderBody({required this.chapter, required this.preferences});

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
    );
  }
}
