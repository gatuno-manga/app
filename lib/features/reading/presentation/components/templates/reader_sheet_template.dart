import 'package:flutter/material.dart';

import '../../../../../shared/components/atoms/app_sheet_handle.dart';
import '../../theme/reader_preferences_builder.dart';

/// Layout of the reader's bottom sheets (Figma `reader-settings-sheet`):
/// handle, [title] and a scrollable [body] on the surface of the chosen
/// reader theme. Needs the `ReaderPreferencesService` in the tree.
class ReaderSheetTemplate extends StatelessWidget {
  final String title;
  final Widget body;

  const ReaderSheetTemplate({
    super.key,
    required this.title,
    required this.body,
  });

  /// Material 3 modal sheets cap at this width on large screens.
  static const double _maxWidth = 640;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.85;
    final bottomInset = media.viewPadding.bottom;
    return ReaderPreferencesBuilder(
      // Only for the theme scope; the body follows the service itself.
      builder: (context, _) => Material(
        // Painted here, not by the route, so it follows live changes. A
        // Material, not a ColoredBox, so the rows' ink splashes show.
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSheetHandle(),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(height: 16),
                          body,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
