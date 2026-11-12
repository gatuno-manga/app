import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/reader_preferences.dart';
import '../../../domain/use_cases/reader_preferences_service.dart';
import '../molecules/reader_theme_picker.dart';

/// Builds a reader's own rows of the settings for [preferences].
typedef ReaderSettingsSections =
    List<Widget> Function(ReaderPreferences preferences);

/// The reader preference controls shared by the in-reader sheet and the
/// Settings screen: the theme picker followed by each reader's own
/// [sections]. Follows and changes the [ReaderPreferencesService] in the
/// tree, without applying the reader theme to its surroundings. Add new
/// shared rows here so both entry points get them. The sheet passes only
/// the open reader's sections; Settings passes every reader's.
class ReaderPreferencesControls extends StatelessWidget {
  final ReaderSettingsSections sections;

  /// Visible caption above the theme picker, for screens where nothing else
  /// says what the swatches change.
  final String? themeTitle;

  const ReaderPreferencesControls({
    super.key,
    required this.sections,
    this.themeTitle,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.read<ReaderPreferencesService>();
    final title = themeTitle;
    return StreamBuilder<ReaderPreferences>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) {
        final preferences = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ReaderThemePicker(
              selected: preferences.theme,
              onSelected: (theme) =>
                  service.update((current) => current.copyWith(theme: theme)),
            ),
            const SizedBox(height: 8),
            ...sections(preferences),
          ],
        );
      },
    );
  }
}
