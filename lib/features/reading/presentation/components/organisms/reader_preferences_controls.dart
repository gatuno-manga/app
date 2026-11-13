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
/// the open reader's sections; Settings passes the readers' sections.
class ReaderPreferencesControls extends StatelessWidget {
  final ReaderSettingsSections sections;

  /// Rows shown before the theme picker (the accessibility sheet's preset).
  final ReaderSettingsSections? leading;

  const ReaderPreferencesControls({
    super.key,
    required this.sections,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.read<ReaderPreferencesService>();
    return StreamBuilder<ReaderPreferences>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) {
        final preferences = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...?leading?.call(preferences),
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
