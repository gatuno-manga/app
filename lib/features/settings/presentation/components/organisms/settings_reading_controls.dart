import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../reading/domain/entities/reader_preferences.dart';
import '../../../../reading/domain/use_cases/reader_preferences_service.dart';
import '../../../../reading/presentation/components/organisms/reader_preferences_controls.dart';
import '../../../../reading/presentation/components/organisms/text_reader_settings_section.dart';

/// Reader preferences inside Settings: the same controls as the reader's
/// sheet, kept in the app theme and following the shared
/// [ReaderPreferencesService] found in the tree.
class SettingsReadingControls extends StatelessWidget {
  const SettingsReadingControls({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.read<ReaderPreferencesService>();
    return StreamBuilder<ReaderPreferences>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) => ReaderPreferencesControls(
        preferences: snapshot.data!,
        sections: TextReaderSettingsSection.sectionsFor(service),
      ),
    );
  }
}
