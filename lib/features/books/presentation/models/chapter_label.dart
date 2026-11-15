import 'package:gatuno/l10n/app_localizations.dart';

import '../../domain/entities/chapter.dart';

/// "Capítulo N", with a whole index written without decimals.
String chapterLabel(AppLocalizations l10n, Chapter chapter) {
  final index = chapter.index.value;
  return l10n.booksChapterLabel(
    index == index.toInt() ? index.toInt().toString() : index.toString(),
  );
}

/// "Capítulo N - Title", or the label alone when the chapter has no title.
String chapterHeading(AppLocalizations l10n, Chapter chapter) {
  final title = chapter.title?.value;
  final label = chapterLabel(l10n, chapter);
  return title == null || title.isEmpty ? label : '$label - $title';
}
