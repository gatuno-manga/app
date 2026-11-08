import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/reader_preferences.dart';
import '../../domain/use_cases/reader_preferences_service.dart';

/// Rebuilds [builder] with the current [ReaderPreferences] of the
/// [ReaderPreferencesService] found in the tree, starting from its current
/// value so the first frame is already right.
class ReaderPreferencesBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ReaderPreferences preferences)
  builder;

  const ReaderPreferencesBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final service = context.read<ReaderPreferencesService>();
    return StreamBuilder<ReaderPreferences>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) => builder(context, snapshot.data!),
    );
  }
}
